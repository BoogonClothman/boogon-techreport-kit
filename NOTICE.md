# NOTICE

**Cooper Intelligence Technical Report template**
© 2026 Cooper Intelligence. All rights reserved.

## Upstream provenance

`boogonreport.cls` is derived from the LaTeX class distributed with the e-print of
*DeepSeek-V3 Technical Report* (DeepSeek-AI, arXiv:2412.19437). What was taken is the layout
layer: page geometry, the header/footer machinery, the abstract and title block, section and
caption formatting. The paper content (body text, figures, tables, bibliography) is not part of
this repository and is not reproduced here.

The upstream e-print is available from arXiv at <https://arxiv.org/abs/2412.19437>.

## Review item before external redistribution

The upstream LaTeX source carries no explicit licence statement. Publishing the derived class
outside the organisation, for example as an open-source package, should therefore be reviewed
against the upstream terms before release. Internal use to typeset Cooper and Boogon documents
is unaffected by this note.

## Marks and assets

The Cooper Intelligence wordmark, its geometry and the type treatments in `logo/` are marks of
Cooper Intelligence, included here as the reference sample. It embeds outlines of Arial (regular
and bold) as part of the lockup; Arial is licensed separately by its owner and is not
redistributed in this repository as a font file. Organisations adopting the template replace the
mark with their own.

`scripts/svg-wordmark.py` is a generic utility and contains no organisation-specific values: it
exports whatever text and font it is given as vector outlines. It reads font files from the
machine it runs on and does not bundle them.
