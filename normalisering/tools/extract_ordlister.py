#!/usr/bin/env python3
"""
extract_ordlister.py - extract historical→modern word pairs from
Galberg Jacobsen, *Ret og Skrift* (Bind 2), chapter 4 "Ordlister".

Each ordliste entry has the shape:

    <modern lemma>  <HistoricalForm> <year> [= <year> ...] > <ReformedForm> <year> ...

e.g.
    kvinde Qvinde 1775 = 1800 = 1847 > Kvinde 1871-Cirk. = ... > [kvinde] 1948-Bek.
    vokse  voxe 1775 = 1800 = 1847 = 1872 > vokse 1891 = 1896

For the HCA project we want the *old* attested spelling that a ~1830-1875 text
would use, paired with its modern lemma. We therefore anchor each extraction on
a historical norm-year (1739/1775/1800/1847/1872): the first form attested at one
of those years is the historical variant, and the section's lemma is the modern
target. This anchoring also filters out words that only entered the norm after
the reforms (no old form → not relevant to Andersen) and most footnote noise.

This is a *best-effort* extraction from a 600-page scholarly PDF text layer; the
output is meant as candidate historical evidence for review, not as auto-applied
rules (consistent with the project's never-auto-deploy principle).

Usage:
    pdftotext -enc UTF-8 ortography-history/RetogSkriftBind2_samlet.pdf b2.txt
    python extract_ordlister.py b2.txt --out ../rules/historical_variants.tsv
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

NORM_YEARS = ("1739", "1775", "1800", "1847", "1872")

# RP9 is "ét eller flere ord" (word-spacing, e.g. forsaavidt -> for saa vidt):
# a different problem class that cannot be represented as a single-token
# substring pair, so we skip it here.
SKIP_RP = {"RP9"}
# All-caps tokens are dictionary abbreviations (DHO, SRO, VSO, RO, DRO ...)
# leaking in from footnotes, never historical word forms.
ABBREV = re.compile(r"^[A-ZÆØÅ]{2,4}$")

# Real section headings look like "4.11. Ordliste RP7b Fremmede bogstaver..."
HEADING = re.compile(r"^\d+\.\d+\.\s+Ordliste\s+(RP[0-9a-z-]+)\s*(.*)$")
# Lowercase running page-headers ("4.11. ordliste rp7b - ...") and page numbers
# are noise we simply never match entries against meaningfully.
END = re.compile(r"Kapitel\s+5|^\s*5\.\s")

# An entry opener: lowercase modern lemma, a historical form (optionally with an
# attached footnote number), then one of the historical norm-years.
ENTRY = re.compile(
    r"(?<![-\wÆØÅæøå])"
    r"(?P<head>[a-zæøå][a-zæøå-]+)"             # single lowercase modern lemma
    r"\s+(?P<form>[A-ZÆØÅa-zæøå][A-Za-zÆØÅæøå]+)"
    r"\d{0,3}"                                  # swallow attached footnote digits
    r"\s+(?P<year>" + "|".join(NORM_YEARS) + r")\b"
)


def extract(text_path: Path):
    rp_desc: dict[str, str] = {}
    pairs = []          # (modern, historical, rp, year)
    seen = set()
    current_rp = None
    in_ch4 = False

    for line in text_path.read_text(encoding="utf-8").splitlines():
        h = HEADING.match(line)
        if h:
            in_ch4 = True
            current_rp = h.group(1)
            desc = h.group(2).strip()
            if desc and current_rp not in rp_desc:
                rp_desc[current_rp] = desc
            continue
        if not in_ch4:
            continue
        if END.search(line):
            break
        if current_rp is None or current_rp in SKIP_RP:
            continue
        for m in ENTRY.finditer(line):
            modern = m.group("head").strip()
            hist = m.group("form").strip()
            if ABBREV.match(hist):
                continue                         # footnote abbreviation, not a word
            if hist.lower() == modern.lower():
                continue                         # no spelling change → skip
            if len(hist) < 2 or len(modern) < 2:
                continue
            key = (modern, hist, current_rp)
            if key in seen:
                continue
            seen.add(key)
            pairs.append((modern, hist, current_rp, m.group("year")))
    return pairs, rp_desc


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("text", type=Path, help="pdftotext output of Ret og Skrift Bind 2")
    ap.add_argument("--out", type=Path, default=Path("../rules/historical_variants.tsv"))
    args = ap.parse_args()

    pairs, rp_desc = extract(args.text)
    pairs.sort(key=lambda p: (p[2], p[0]))

    lines = [
        "# Historical Danish spelling variants extracted from",
        "# Galberg Jacobsen, Ret og Skrift (Bind 2, kap. 4 Ordlister), SDU 2010.",
        "# best-effort extraction; review before promoting to rules. See docs/07.",
        "#source(historical)\ttarget(modern)\trp\tnorm_year",
    ]
    for modern, hist, rp, year in pairs:
        lines.append(f"{hist}\t{modern}\t{rp}\t{year}")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"Extracted {len(pairs)} historical->modern pairs across "
          f"{len(set(p[2] for p in pairs))} ordlister -> {args.out}")
    print("Sample:")
    for modern, hist, rp, year in pairs[:20]:
        print(f"  {hist:<16} -> {modern:<16} ({rp}, {year})")


if __name__ == "__main__":
    main()
