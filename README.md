# PowerFit Gym

PowerFit Gym turns XML data into a responsive HTML dashboard for browsing gym records and weekly class schedules. A DTD defines the data structure, an XSLT 1.0 stylesheet generates the page, and CSS controls its appearance.

## Contents

- [Dashboard features](#dashboard-features)
- [Project files](#project-files)
- [Setup and preview](#setup-and-preview)
  - [Preview the dashboard](#preview-the-dashboard)
  - [Generate with Python](#generate-with-python)
  - [Altova XMLSpy](#altova-xmlspy)
- [Data model](#data-model)
- [External resources](#external-resources)
- [Additional XML examples](#additional-xml-examples)
- [Updating the project](#updating-the-project)

## Dashboard features

- **Overview:** gym details, contact information and calculated totals.
- **Membership plans:** prices, access levels, benefits, limitations and average prices by currency.
- **Classes:** descriptions, difficulty levels, durations, equipment and assigned trainers.
- **Weekly timetable:** sessions ordered by weekday and start time, with rooms and registered members.
- **Trainers and members:** profiles, membership status, subscription links and available contact details.
- **Facilities:** room types, codes, capacities and amenities.
- **Member desk:** reception announcements and text guides.
- **Linked records:** names lead to the corresponding entries, which are highlighted when selected.

## Project files

| File | Purpose |
| --- | --- |
| [`gym.xml`](gym.xml) | Main dataset and reference to the stylesheet. |
| [`gym.dtd`](gym.dtd) | Vocabulary, content models, attributes and record references. |
| [`gym-media.dtd`](gym-media.dtd) | Guide file entities and format declarations. |
| [`gym.xsl`](gym.xsl) | XSLT 1.0 transformation from XML to HTML. |
| [`gym.html`](gym.html) | Generated dashboard, ready to open in a browser. |
| [`style.css`](style.css) | Page styling and responsive layouts. |
| [`transform.py`](transform.py) | DTD validation, reference checks and HTML generation with Python. |
| [`resources/`](resources/) | Announcement fragment and text guides. |
| [`examples/`](examples/) | Two additional XML datasets demonstrating valid variations. |

## Setup and preview

Viewing the supplied dashboard requires a web browser. To regenerate it, use either Python with `lxml` or Altova XMLSpy. No web server is required.

### Preview the dashboard

Open `gym.html` in your browser. Keep it next to `style.css`, with the complete `resources/` directory beside it, so the styles and guide links load correctly.

### Generate with Python

Requirements: Python 3 and `lxml`.

Open a terminal in the project directory and run:

```bash
python -m pip install lxml
python transform.py
```

On Windows, you can replace `python` with `py -3` in both commands.

Successful execution prints:

```text
DTD validation: PASS
HTML generated: gym.html
```

The script validates `gym.xml`, loads DTD defaults and external parsed content, checks record and guide references, then generates `gym.html` with two-space indentation. A validation or transformation error stops generation before the output is written.

### Altova XMLSpy

1. Open `gym.xml` and run **XML > Check Well-Formedness** (F7).
2. Run **XML > Validate XML** (F8). The document references `gym.dtd`, which loads `gym-media.dtd` automatically.
3. With `gym.xml` active, run **XSL/XQuery > XSL Transformation** (F10) using the built-in Altova XSLT engine. The XML references `gym.xsl`. Select that file if prompted.
4. Save the result as `gym-xmlspy.html` in the project root, next to `gym.html` and `style.css`.
5. For the internal preview, select **Microsoft Edge WebView2** under **Tools > Options > View > Browser engine**, then select **Browser** on the saved HTML document.
6. Compare `gym-xmlspy.html` and `gym.html` in the same browser at the same width and zoom. Check the layout, record counts, schedule order, EUR 36.75 average and record/guide links.

The XMLSpy and Python outputs have been checked for matching content and appearance.

## Data model

The `gym` root contains gym details, six related collections and an optional member desk. The main dataset contains:

| Collection | Records | Relationships |
| --- | ---: | --- |
| Membership plans | 4 | Referenced by members through `planRef`. |
| Trainers | 5 | Referenced by classes through `trainerRef`. |
| Rooms | 4 | Referenced by sessions through `roomRef`. |
| Members | 12 | Each member has a plan and can register for sessions. |
| Classes | 8 | Each class has a trainer and can have multiple weekly sessions. |
| Sessions | 16 | Each session references a class, a room and an optional list of members. |
| Announcements | 3 | Can attach guides from the catalogue. |
| Guides | 2 | Associate titles and descriptions with external text files. |

These counts refer to `gym.xml`, which includes 33 session registrations. The DTD supplies omitted default attributes, such as `EUR` for plan currency and `active` for member status. XSLT resolves record references, sorts the timetable and calculates totals and average prices separately for each currency.

## External resources

| File | Use |
| --- | --- |
| [`front-desk.ent`](resources/front-desk.ent) | XML fragment inserted into the welcome announcement when the XML is parsed. |
| [`class-check-in.txt`](resources/class-check-in.txt) | Arrival and registration instructions opened through **Open guide (.txt)**. |
| [`shared-equipment.txt`](resources/shared-equipment.txt) | Equipment handling instructions opened through **Open guide (.txt)**. |

The `.ent` fragment becomes part of the generated page. The `.txt` guides remain separate files and open as plain text.

## Additional XML examples

| Document | Cases demonstrated |
| --- | --- |
| [`gym-international.xml`](examples/gym-international.xml) | EUR, USD and GBP prices, an email-only contact, a guide without a description and an internal DTD subset that overrides the default guide declarations. |
| [`gym-minimal.xml`](examples/gym-minimal.xml) | One record in each required collection, omitted optional sections and DTD default values. |

Both examples use the same DTD and stylesheet as `gym.xml`. They are independent datasets with separate totals.

Use the [XMLSpy procedure](#altova-xmlspy) for either example. Save its generated HTML in the **project root**, for example as `gym-international.html`, so the CSS and guide links resolve correctly. `transform.py` processes the main `gym.xml` only.

## Updating the project

| Change | Edit | Next step |
| --- | --- | --- |
| Gym records or guide metadata | `gym.xml` | Validate and regenerate the HTML. |
| Vocabulary or entity declarations | `gym.dtd`, `gym-media.dtd` and any affected XML | Validate and regenerate the HTML. |
| HTML structure or calculations | `gym.xsl` | Regenerate the HTML. |
| Reception announcement | `resources/front-desk.ent` | Validate and regenerate the HTML. |
| Text of a linked guide | Its `.txt` file in `resources/` | Reopen the guide. |
| Colours, typography or layout | `style.css` | Refresh the dashboard. |

Treat `gym.html` as generated output. Edit the source XML or XSLT and regenerate it to keep changes reproducible.
