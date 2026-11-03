# PowerFit Gym — XML / DTD / XSLT / HTML

## Files

- `gym.dtd` — DTD vocabulary and validation rules
- `gym.xml` — sample XML data and DTD reference
- `gym.xsl` — portable XSLT 1.0 transformation into one HTML page
- `gym.html` — generated HTML output (do not hand-edit)
- `style.css` — local, dependency-free stylesheet
- `transform.py` — optional local validator and transformer using lxml

## Generate HTML in VS Code

Install Python 3 and the `lxml` package:

```bash
python -m pip install lxml
```

In this folder, run:

```bash
python transform.py
```

This first validates `gym.xml` against `gym.dtd`, then runs `gym.xsl`, and writes `gym.html`.
Open `gym.html` in your browser; `style.css` must remain in the same folder.

## Generate HTML with Altova XMLSpy

1. Keep all project files together.
2. Open `gym.xml` and validate it against `gym.dtd`.
3. Run the XSLT 1.0 transformation selecting `gym.xsl` as the stylesheet.
4. Save the resulting HTML to `gym.html` in the same directory as `style.css`.
5. Open it in a browser and compare with the provided `gym.html`.

The output HTML references `style.css` by a relative URL and uses no external images,
fonts, JavaScript, or CSS libraries.

## XSLT demonstrations

- Multiple `xsl:template` and `xsl:apply-templates` rules
- XPath 1.0 selection, predicates, `count`, `sum`, `format-number`
- `xsl:sort` for class names, member names, schedule day/time
- `xsl:key` for ID/IDREF lookups and sessions grouped by class ID
- Conditional output via `xsl:if` / `xsl:choose`
- Recursive named template that splits `IDREFS` into linked member names
- All major fields and optional values from the XML are represented

**Note:** People and contact information in this example are fictional educational data.
