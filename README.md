# PowerFit Gym — XML, DTD & XSLT 1.0

A fictional gym management dataset and a dynamically generated HTML dashboard for an XML/XSLT university assignment.

## Files

- `gym.dtd` — XML vocabulary, content models, attributes, and ID/IDREF constraints.
- `gym.xml` — example data for plans, trainers, rooms, members, classes, and 16 weekly sessions.
- `gym.xsl` — XSLT 1.0 stylesheet producing the complete dashboard.
- `gym.html` — generated HTML output. Do not edit it manually.
- `style.css` — local styles for the HTML output.
- `transform.py` — optional XML validation and HTML generation using Python/lxml.
- `SETUP.md` — step-by-step instructions for VS Code and Altova XMLSpy.

## Generate and validate

Install Python 3 and run from this directory:

```bash
python -m pip install lxml
python transform.py
```

Expected output:

```text
DTD validation: PASS
HTML generated: gym.html
```

Open `gym.html` in a browser. Keep `style.css` alongside the HTML file.

You can also open `gym.xml` in Altova XMLSpy, validate against `gym.dtd`, and run the XSLT 1.0 transformation using `gym.xsl`. Save the HTML output alongside `style.css`.

## What the transformation demonstrates

XSLT templates, XPath predicates and functions, sorting, branching, keys for linked data, and a recursive template for resolving whitespace-separated member IDs. The output covers the gym's sections and includes generated counts and statistics.

**Note:** All personal information is fictional. The XML DTD checks structure and ID existence, not business rules such as subscription attendance limits. This sample keeps Student registrations within two sessions per week.
