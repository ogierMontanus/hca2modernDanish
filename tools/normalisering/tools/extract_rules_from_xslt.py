#!/usr/bin/env python3
"""
extract_rules_from_xslt.py

Extract the <pattern><old>/<new></pattern> rewrite table from the legacy XSLT
normalizer and emit it in the canonical rule formats used by the v2 pipeline:

    rules/rules.tsv   - tab-separated, AWK-friendly, one rule per line
    rules/rules.json  - the same rules with full provenance metadata

The legacy table is the authoritative starting point: every existing rule is
preserved verbatim, but commented-out (<!-- ... -->) patterns are skipped so
that the extracted table reflects what actually runs.

Usage:
    python extract_rules_from_xslt.py \
        ../../../tools/stilark/DSL-HCAC_replaceOriginal2ModernXSLT3.0.xsl \
        --out-dir ../rules
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

# Matches a <pattern> ... <old>X</old> ... <new>Y</new> ... </pattern> block.
PATTERN_RE = re.compile(
    r"<pattern>\s*<old>(?P<old>.*?)</old>\s*<new>(?P<new>.*?)</new>",
    re.DOTALL,
)
COMMENT_RE = re.compile(r"<!--.*?-->", re.DOTALL)

# Minimal XML entity unescaping for the few entities the table uses.
ENTITIES = {"&lt;": "<", "&gt;": ">", "&amp;": "&", "&quot;": '"', "&apos;": "'"}


def unescape(s: str) -> str:
    for ent, ch in ENTITIES.items():
        s = s.replace(ent, ch)
    return s


def extract(xsl_path: Path) -> list[dict]:
    raw = xsl_path.read_text(encoding="utf-8")
    # Drop commented-out patterns so the table reflects active rules only.
    active = COMMENT_RE.sub("", raw)
    rules = []
    for i, m in enumerate(PATTERN_RE.finditer(active), start=1):
        old = unescape(m.group("old"))
        new = unescape(m.group("new"))
        rules.append(
            {
                "id": f"R{i:04d}",
                "source": old,
                "target": new,
                # Sensible defaults; refine via review / mining (Phase 2).
                "confidence": 1.0,
                "evidence": ["legacy:DSL-HCAC_replaceOriginal2ModernXSLT3.0.xsl"],
                "period": None,          # null = applies to all periods
                "protect_entities": True,
                "enabled": True,
            }
        )
    return rules


def write_tsv(rules: list[dict], path: Path) -> None:
    lines = ["#id\tsource\ttarget\tconfidence\tperiod_from\tperiod_to\tenabled"]
    for r in rules:
        pf, pt = "", ""
        if r["period"]:
            pf, pt = r["period"].get("from", ""), r["period"].get("to", "")
        # TSV is whitespace-significant for this corpus, so we must NOT strip
        # leading/trailing spaces in source/target. Encode them visibly.
        src = r["source"].replace("\t", "\\t")
        tgt = r["target"].replace("\t", "\\t")
        lines.append(
            f"{r['id']}\t{src}\t{tgt}\t{r['confidence']}\t{pf}\t{pt}\t"
            f"{'1' if r['enabled'] else '0'}"
        )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("xsl", type=Path, help="legacy replace stylesheet")
    ap.add_argument("--out-dir", type=Path, default=Path("../rules"))
    args = ap.parse_args()

    rules = extract(args.xsl)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    write_tsv(rules, args.out_dir / "rules.tsv")
    (args.out_dir / "rules.json").write_text(
        json.dumps(rules, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Extracted {len(rules)} active rules -> {args.out_dir}/rules.tsv, rules.json")


if __name__ == "__main__":
    main()
