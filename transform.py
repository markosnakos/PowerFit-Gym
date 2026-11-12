"""Validate gym.xml against gym.dtd, then transform with gym.xsl (XSLT 1.0)."""
from pathlib import Path
from lxml import etree


def validate_references(document):
    """Check record IDs and announcement attachment references."""
    for dtd in (document.docinfo.internalDTD, document.docinfo.externalDTD):
        if dtd is None:
            continue
        for element_type in dtd.iterelements():
            for attribute in element_type.iterattributes():
                if attribute.type not in ("idref", "idrefs"):
                    continue
                for element in document.iter(element_type.name):
                    for reference in element.get(attribute.name, "").split():
                        if not document.xpath("id($reference)", reference=reference):
                            raise ValueError(
                                f"{element.tag}/@{attribute.name} references "
                                f"an unknown ID: {reference}"
                            )
    guide_resources = document.xpath("/gym/memberDesk/guides/guide/@resource")
    if len(guide_resources) != len(set(guide_resources)):
        raise ValueError("Each guide file must have one catalogue entry")
    for announcement in document.xpath("/gym/memberDesk/announcements/announcement"):
        for resource in announcement.get("attachments", "").split():
            if resource not in guide_resources:
                raise ValueError(
                    f"Announcement {announcement.get('id')} attaches a file "
                    f"without a guide catalogue entry: {resource}"
                )


base = Path(__file__).resolve().parent
xml_file = base / "gym.xml"
xsl_file = base / "gym.xsl"
html_file = base / "gym.html"

xml_parser = etree.XMLParser(
    load_dtd=True,
    dtd_validation=True,
    attribute_defaults=True,
    resolve_entities=True,
    no_network=True,
)
xml = etree.parse(str(xml_file), parser=xml_parser)
# Resolve record and guide references against the complete parsed document.
validate_references(xml)
print("DTD validation: PASS")

transform = etree.XSLT(etree.parse(str(xsl_file)))
html = transform(xml)
# Indent each nesting level before the HTML serializer writes the result.
etree.indent(html, space="  ")
html.write(str(html_file), method="html", encoding="UTF-8", pretty_print=True)
print(f"HTML generated: {html_file.name}")
