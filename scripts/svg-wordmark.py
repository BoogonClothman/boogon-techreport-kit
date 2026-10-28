"""Convert a text wordmark into vector outlines and write it as SVG.

The output contains no <text> elements. Every glyph is emitted as <path> data, so
the file renders identically in a browser, in Inkscape and in a PDF converter,
without depending on the fonts installed on the machine that opens it. That is
what a wordmark needs if it is going to be embedded in a LaTeX header.

The utility is generic: it knows nothing about any particular organisation.
Pass your own text, fonts, size and colour.

Example
-------
    python svg-wordmark.py ^
        --runs "Acme=bold;Labs=regular" ^
        --font C:\\Windows\\Fonts\\arial.ttf ^
        --font-bold C:\\Windows\\Fonts\\arialbd.ttf ^
        --size 36 --tracking 0.9 --color "#1A1A1A" ^
        --out logo/acme-wordmark.svg

The `--runs` argument splits the wordmark into runs, each rendered in its own
weight: `"Acme=bold;Labs=regular"` renders Acme in bold and Labs in regular, with
a fixed gap between the runs. A single run is fine too: `--runs "Acme Labs"`.

An icon or mark is not drawn here. Draw it separately, export it as SVG, and
place it beside the wordmark inside the same viewBox.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from fontTools.misc.transform import Transform
    from fontTools.pens.svgPathPen import SVGPathPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.ttLib import TTFont
except ImportError:  # pragma: no cover
    sys.exit("fontTools is required: python -m pip install fonttools")


def parse_runs(spec: str) -> list[tuple[str, str]]:
    """Turn 'Acme=bold;Labs=regular' into [(text, weight), ...]."""
    runs: list[tuple[str, str]] = []
    for chunk in spec.split(";"):
        chunk = chunk.strip()
        if not chunk:
            continue
        if "=" in chunk:
            text, weight = chunk.rsplit("=", 1)
            weight = weight.strip().lower()
            if weight not in {"regular", "bold"}:
                raise SystemExit(f"unknown weight {weight!r} in run {chunk!r}")
        else:
            text, weight = chunk, "regular"
        if text:
            runs.append((text, weight))
    if not runs:
        raise SystemExit("no text to draw")
    return runs


class Face:
    """A loaded font, scaled to the requested point size."""

    def __init__(self, path: str | Path, size: float):
        self.font = TTFont(str(path))
        self.upem = self.font["head"].unitsPerEm
        self.scale = size / self.upem
        self.glyphs = self.font.getGlyphSet()
        self.cmap = self.font.getBestCmap()
        self.hmtx = self.font["hmtx"]
        self.ascent = self.font["hhea"].ascent * self.scale
        self.descent = self.font["hhea"].descent * self.scale  # negative

    def advance(self, char: str) -> float:
        return self.hmtx[self.cmap.get(ord(char), ".notdef")][0] * self.scale

    def run(self, text: str, x: float, baseline: float, tracking: float) -> tuple[str, float]:
        commands: list[str] = []
        pen_x = 0.0
        for char in text:
            name = self.cmap.get(ord(char), ".notdef")
            pen = SVGPathPen(self.glyphs, ntos=lambda v: f"{v:.2f}")
            self.glyphs[name].draw(
                TransformPen(pen, Transform(self.scale, 0, 0, -self.scale, x + pen_x, baseline))
            )
            d = pen.getCommands()
            if d:
                commands.append(d)
            pen_x += self.advance(char) + tracking
        return " ".join(commands), pen_x


def build_svg(runs, faces, size, tracking, gap, color, padding, label) -> tuple[str, float, float]:
    ascent = max(face.ascent for face in faces.values())
    descent = min(face.descent for face in faces.values())
    baseline = padding + ascent
    height = ascent - descent + 2 * padding

    cursor = padding
    paths: list[str] = []
    for index, (text, weight) in enumerate(runs):
        if index:
            cursor += gap
        face = faces[weight]
        d, advance = face.run(text, cursor, baseline, tracking)
        if d:
            paths.append(d)
        cursor += advance - tracking  # the trailing tracking is not part of the run

    width = cursor + padding
    body = "\n".join(f'  <path d="{d}"/>' for d in paths)
    svg = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width:.0f}" height="{height:.0f}" '
        f'viewBox="0 0 {width:.0f} {height:.0f}" role="img" aria-label="{label}">\n'
        f"  <title>{label}</title>\n"
        f'  <g fill="{color}">\n{body}\n  </g>\n'
        "</svg>\n"
    )
    return svg, width, height


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Convert text into an outline-only SVG wordmark.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--runs", default="Your Organisation",
                        help='wordmark runs, e.g. "Acme=bold;Labs=regular"')
    parser.add_argument("--font", required=True, help="regular font file (.ttf/.otf)")
    parser.add_argument("--font-bold", help="bold font file; defaults to --font")
    parser.add_argument("--size", type=float, default=36.0, help="cap-to-descender size in SVG units")
    parser.add_argument("--tracking", type=float, default=0.9, help="extra space between glyphs")
    parser.add_argument("--gap", type=float, default=0.0,
                        help="space between runs; defaults to 0.28 x size")
    parser.add_argument("--color", default="#000000", help="fill colour")
    parser.add_argument("--padding", type=float, default=4.0, help="blank margin around the text")
    parser.add_argument("--out", required=True, help="destination .svg")
    args = parser.parse_args()

    runs = parse_runs(args.runs)
    regular = Face(args.font, args.size)
    faces = {"regular": regular}
    faces["bold"] = Face(args.font_bold, args.size) if args.font_bold else regular

    gap = args.gap if args.gap else 0.28 * args.size
    label = " ".join(text for text, _ in runs)

    svg, width, height = build_svg(runs, faces, args.size, args.tracking, gap,
                                   args.color, args.padding, label)

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(svg, encoding="utf-8")
    print(f"wrote {out} ({width:.0f}x{height:.0f} units, {len(runs)} run(s))")


if __name__ == "__main__":
    main()
