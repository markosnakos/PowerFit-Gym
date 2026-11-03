"""Validate gym.xml against gym.dtd, then transform with gym.xsl (XSLT 1.0)."""
from pathlib import Path
from lxml import etree

base = Path(__file__).resolve().parent
xml_file = base / "gym.xml"
dtd_file = base / "gym.dtd"
xsl_file = base / "gym.xsl"
html_file = base / "gym.html"

xml_parser = etree.XMLParser(load_dtd=True, resolve_entities=True, no_network=True)
xml = etree.parse(str(xml_file), parser=xml_parser)
with dtd_file.open("rb") as handle:
    dtd = etree.DTD(handle)
if not dtd.validate(xml):
    raise ValueError(f"DTD validation failed:\n{dtd.error_log}")
print("DTD validation: PASS")

transform = etree.XSLT(etree.parse(str(xsl_file)))
html = transform(xml)
html.write(str(html_file), method="html", encoding="UTF-8", pretty_print=True)
print(f"HTML generated: {html_file.name}")
