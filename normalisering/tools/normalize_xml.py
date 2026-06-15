#!/usr/bin/env python3
"""
normalize_xml.py - apply Loop 1 rules to the TEXT NODES of a TEI/XML file only.

Mirrors the legacy XSLT text()-template behaviour: markup, attributes, the XML
declaration and processing-instructions are left byte-for-byte untouched; only
character data between tags is normalized, using the shared rule_engine (same
semantics as normalize.awk, incl. the runtime loop guard).

By default the <teiHeader> is EXCLUDED: its text (titles, editor names, English
metadata, dates, URLs) must not be normalized. Pass --include-teiheader to
normalize the whole document instead.

Named-entity protection: loads named_entities.txt (ported from the legacy XSLT
DSL-HCAC_toLowerCase.xsl). Before normalizing each text segment, every named
entity occurrence is replaced with a NUL-delimited placeholder; after
normalization the original spelling is restored. This prevents rules like
ei->ej and ph->f from corrupting place-names (Schweiz->Schwejz, Raphael->Rafael).
Pass --no-entity-protection to disable.

Writes the normalized XML and a provenance trace listing every changed text
segment with the rule ids that fired.

Usage:
  python normalize_xml.py in.xml --out out.xml --trace out.trace.txt \
      --rules ../rules/rules.tsv [--include-teiheader] [--entities ../rules/named_entities.txt]
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

from rule_engine import load_rules, normalize

TAG = re.compile(r"<[^>]+>")          # tags, PIs and the XML declaration
# Separator that cannot appear in XML text content
_SEP = "\x00"


def load_entities(path: Path) -> list[str]:
    """Load named-entity list (longest-first for greedy left-to-right matching)."""
    entities = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            entities.append(line)
    # Sort longest first to prevent partial clobbering (e.g. 'Carl Reitzel' before 'Carl')
    return sorted(set(entities), key=len, reverse=True)


def protect(text: str, entities: list[str]) -> tuple[str, dict[str, str]]:
    """Replace named-entity occurrences with NUL-delimited placeholders.

    Returns the protected text and a restore map {placeholder: original}.
    Only entities whose normalized form would differ are worth protecting,
    but we protect all to be safe — overhead is tiny."""
    restore: dict[str, str] = {}
    i = 0
    for ne in entities:
        if ne in text:
            ph = f"{_SEP}{i}{_SEP}"
            restore[ph] = ne
            text = text.replace(ne, ph)
            i += 1
    return text, restore


def restore(text: str, restore_map: dict[str, str]) -> str:
    for ph, ne in restore_map.items():
        text = text.replace(ph, ne)
    return text


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("xml", type=Path)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--trace", type=Path)
    ap.add_argument("--rules", type=Path, default=Path("../rules/rules.tsv"))
    ap.add_argument("--entities", type=Path,
                    default=Path("../rules/named_entities.txt"),
                    help="named-entity protection list (default: ../rules/named_entities.txt)")
    ap.add_argument("--no-entity-protection", action="store_true",
                    help="disable named-entity token protection")
    ap.add_argument("--include-teiheader", action="store_true",
                    help="also normalize text inside <teiHeader> (default: skip it)")
    args = ap.parse_args()

    rules = load_rules(args.rules)

    entities: list[str] = []
    if not args.no_entity_protection and args.entities.exists():
        entities = load_entities(args.entities)

    s = args.xml.read_text(encoding="utf-8")

    out_parts, trace, applied_total, changed = [], [], set(), 0
    protected_count = 0
    pos = 0
    in_header = False
    skipped_header = 0
    for m in TAG.finditer(s):
        text = s[pos:m.start()]
        if text:
            if in_header and not args.include_teiheader:
                out_parts.append(text)
                if text.strip():
                    skipped_header += 1
            else:
                # Named-entity protection
                if entities:
                    ptext, rmap = protect(text, entities)
                    protected_count += len(rmap)
                else:
                    ptext, rmap = text, {}
                norm_p, applied, looped = normalize(ptext, rules)
                norm = restore(norm_p, rmap)
                out_parts.append(norm)
                if norm != text:
                    changed += 1
                    applied_total.update(applied)
                    trace.append((text, norm, applied, looped))
        tag = m.group(0)
        out_parts.append(tag)
        low = tag.lower()
        if low.startswith("<teiheader"):
            in_header = True
        elif low.startswith("</teiheader"):
            in_header = False
        pos = m.end()
    tail = s[pos:]
    if tail:
        if entities:
            ptail, rmap = protect(tail, entities)
            norm_p, applied, looped = normalize(ptail, rules)
            norm = restore(norm_p, rmap)
        else:
            norm, applied, looped = normalize(tail, rules)
        out_parts.append(norm)
        if norm != tail:
            changed += 1
            applied_total.update(applied)
            trace.append((tail, norm, applied, looped))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("".join(out_parts), encoding="utf-8")

    if args.trace:
        lines = [f"# {args.xml.name}: {changed} text segments changed; "
                 f"{len(applied_total)} distinct rules fired\n"]
        for orig, norm_out, applied, looped in trace:
            o = re.sub(r"\s+", " ", orig).strip()
            n = re.sub(r"\s+", " ", norm_out).strip()
            if not o:
                continue
            tag = " [LOOP-GUARDED]" if looped else ""
            lines.append(f"- rules {','.join(applied)}{tag}\n    {o}\n    {n}")
        args.trace.write_text("\n".join(lines) + "\n", encoding="utf-8")

    ne_msg = (f", {protected_count} entity spans protected"
              if entities else " (entity protection disabled)")
    hdr = ("" if args.include_teiheader
           else f" (teiHeader excluded: {skipped_header} segments left untouched)")
    print(f"{args.xml.name}: {changed} segments changed, "
          f"rules fired: {','.join(sorted(applied_total))}{ne_msg}{hdr} -> {args.out}")


if __name__ == "__main__":
    main()
