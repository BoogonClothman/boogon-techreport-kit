# Technical Report — LaTeX template

A single-column A4 technical-report template, built on `extarticle`. It fixes the identity
block, the typographic grid and the running furniture, and leaves the argument to the author.
Reports typeset with it share a layout without sharing a voice, which is the point: a group can
adopt the template in an afternoon and still write what it needs to write.

The repository ships with a complete reference report (`sample/`, typeset for Cooper
Intelligence) and the assets behind it. Every organisation-specific string lives in a branding
hook, so the same class can serve any group, in any field, that wants a defensible PDF.

```text
boogonreport.cls           the document class (single file, no dependencies beyond LaTeX)
logo/                      the reference wordmark: SVG source, PDF for LaTeX, PNG for slides
scripts/svg-wordmark.py    generic utility: turns any text into an outline-only SVG wordmark
sample/                    the reference report; copy this directory to start your own
build.ps1                  one-command build of the reference report
```

## Quick start

1. Copy `sample/` to a new directory, for example `reports/2026-q1-notes/`.
2. Edit the three branding lines at the top of the main file:

   ```latex
   \renewcommand{\reportorg}{Your Organisation}
   \renewcommand{\reportshorttitle}{Your Organisation Technical Report}
   \renewcommand{\reportlogo}{../logo/your-logo.pdf}
   ```

3. Replace the title, author block and abstract, then write sections under `sections/`.
4. Build:

   ```powershell
   latexmk -pdf main.tex          # from inside the report directory
   .\build.ps1                    # or, from the repository root
   ```

Copy `sample/` **including its `.latexmkrc`**: that file puts the repository root on
`TEXINPUTS`, so a report directory may live anywhere below the root and still find the class
file.

## Branding hooks

| Hook | Rendered where | Default |
| --- | --- | --- |
| `\reportorg` | copyright line | Cooper Intelligence |
| `\reportshorttitle` | running header from page 2 | Technical Report |
| `\reportlogo` | first-page header | none |
| `\reportaddress` | first-page footer, left | none |
| `\reportinternalnote` | footer, when `internal` is passed | Confidential. Internal Only. |

Class options: `logo`, `copyright`, `address`, `internal`, `nonumbering`. A released report uses
`logo` and `copyright`; an internal draft adds `internal`.

## Contents page

Reports longer than a few pages start with a contents page. Insert `\reporttoc` immediately after
`\maketitle`; it breaks the page, sets the contents at 0.9 line spacing, lists sections and
subsections, and breaks again before the body.

## Adapting the template for your organisation

Four changes are enough for a first report, and none of them touch the layout code:

1. **Branding.** Set `\reportorg` and `\reportshorttitle` as above.
2. **Wordmark.** Replace `logo/cooper-logo.pdf` (and the `.svg` behind it) with your own mark, or
   generate a text-only one with `scripts/svg-wordmark.py` and add your icon beside it.
3. **Author block.** The sample's `\author` names the organisation, a guidance line and a contact
   address; edit those three lines.
4. **Copyright wording.** `\reportorg` feeds the footer, so the line becomes
   `© <year> <your organisation>. All rights reserved` automatically.

Renaming the class itself is only needed if you redistribute a modified version: the LPPL asks
such a version to identify itself as modified, which in practice means renaming the class file
and its `\ProvidesClass{...}` line together. Private use of a modified copy needs no rename.

## The wordmark

The reference wordmark in `logo/` is stored as **glyph outlines, not text**: the SVG contains no
`<text>` element, so it renders identically in a browser, in Inkscape and in the PDF it is
embedded in, with no font dependency and no font substitution on a machine that lacks the font.

`scripts/svg-wordmark.py` builds such a file for any text. It is generic and carries no
organisation-specific values:

```powershell
python scripts/svg-wordmark.py `
  --runs "Acme=bold;Labs=regular" `
  --font C:\Windows\Fonts\arial.ttf --font-bold C:\Windows\Fonts\arialbd.ttf `
  --size 36 --tracking 0.9 --color "#1A1A1A" `
  --out logo/acme-wordmark.svg
```

Convert the SVG to PDF with any converter for LaTeX embedding, and export a high-resolution PNG
if the mark is also needed on the web. An icon is not drawn by the script: draw it separately and
place it beside the wordmark in the same viewBox.

The utility depends only on `fontTools` (`python -m pip install fonttools`). It reads font files
from the machine it runs on; no font is bundled with this repository.

## Conventions enforced by review

- A4, single column, 2.5 cm side margins, 3 cm top and bottom.
- Vector figures, captions below; `booktabs` tables without vertical rules, captions above.
- Numbered equations with every symbol defined in prose.
- The copyright line reads `© <year> <organisation>. All rights reserved`.
- PDF and sources are archived together; build artefacts are not committed.

## Provenance

The class is a fork of the typesetting layer used for the DeepSeek-V3 technical report
(arXiv:2412.19437). That paper's content has been removed from this repository; only the layout
layer was kept, and the identity block was rebuilt. See `NOTICE.md` for the attribution and for
the review item that applies if the template is redistributed outside an organisation.

## License

Released under the **LaTeX Project Public License 1.3c** (or any later version). You may use,
modify and redistribute this template, including inside another organisation; a modified version
that you distribute must identify itself as modified and state what changed. The full text is in
[`LICENSE`](LICENSE), and [`NOTICE.md`](NOTICE.md) records the upstream attribution.

The Cooper Intelligence wordmark in `logo/` is a trademark of Cooper Intelligence and is not
covered by the LPPL — replace it with your own mark.
