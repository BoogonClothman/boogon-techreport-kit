# NOTICE

**Cooper Intelligence Technical Report template**
Copyright 2026 Cooper Intelligence

## Licence

This work may be distributed and/or modified under the conditions of the LaTeX Project Public
License, either version 1.3c of this licence or (at your option) any later version. The latest
version of this licence is in <https://www.latex-project.org/lppl.txt>, and version 1.3c or later
is part of all distributions of LaTeX version 2008 or later. The full text is in `LICENSE`.

This work has the LPPL maintenance status `maintained'. The Current Maintainer of this work is
Cooper Intelligence.

This work consists of the files `boogonreport.cls`, `sample/main.tex`, `sample/sections/*.tex`,
`sample/refs.bib`, `scripts/svg-wordmark.py`, `README.md`, `NOTICE.md` and the derived file
`sample/main.pdf`.

In practice the LPPL means you may use, modify and redistribute this template, including in a
different organisation, provided that a modified version you distribute identifies itself as
modified (rename the class file and its `\ProvidesClass` line), states what you changed, and does
not imply that Cooper Intelligence supports your version.

## Upstream provenance

`boogonreport.cls` is derived from the LaTeX class distributed with the e-print of
*DeepSeek-V3 Technical Report* (DeepSeek-AI, arXiv:2412.19437). What was taken is the layout
layer: page geometry, the header/footer machinery, the abstract and title block, section and
caption formatting. The paper content (body text, figures, tables, bibliography) is not part of
this repository and is not reproduced here.

The upstream e-print is available from arXiv at <https://arxiv.org/abs/2412.19437>.

## Provenance note

The upstream LaTeX source carries no explicit licence statement. The licence in `LICENSE` covers
the work as it is maintained in this repository, including the changes made to the layout layer;
it cannot grant rights in material the upstream authors did not license. An organisation that
needs certainty about the provenance of the layout layer, for example before depending on this
template commercially, should review the upstream terms itself. This remains an open item rather
than a settled one.

## Marks and assets

The Cooper Intelligence wordmark, its geometry and the type treatments in `logo/` are marks of
Cooper Intelligence, included here as the reference sample. They are **not** covered by the LPPL:
the licence above grants rights in the template, not in the mark. Organisations adopting the
template replace the mark with their own.

The wordmark embeds outlines of Arial (regular and bold) as part of the lockup; Arial is licensed
separately by its owner and is not redistributed in this repository as a font file.

`scripts/svg-wordmark.py` is a generic utility and contains no organisation-specific values: it
exports whatever text and font it is given as vector outlines. It reads font files from the
machine it runs on and does not bundle them.
