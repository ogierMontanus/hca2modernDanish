#!/usr/bin/env python3
"""
extract_editorial_changes.py — mine oXygen Author tracked changes from _fgj.xml files.

The editorial/*/_corrected_fgj.xml files contain manual revisions by the
editorial team (author="as" in oXygen PIs). These tracked changes are the
authoritative human modernization decisions and inform Loop 1 (spelling/vocab
rules) and Loop 2 (over-normalization, punctuation, capitalization) refinements.

oXygen tracked-change markup:
  Delete:  <?oxy_delete author="as" timestamp="..." content="OLD"?>
  Insert:  <?oxy_insert_start author="as" timestamp="..."?>NEW<?oxy_insert_end?>
  Replace: delete PI immediately followed by insert PI (or vice versa)

Output:
  resources/editorial-analysis/editorial_changes.tsv   — one change per row
  resources/editorial-analysis/editorial_summary.md    — aggregated patterns

Usage:
  python extract_editorial_changes.py [--editorial ../../editorial]
                                      [--out-dir ../../../resources/editorial-analysis]
"""
from __future__ import annotations

import argparse
import csv
import re
from collections import Counter, defaultdict
from pathlib import Path

_HERE = Path(__file__).parent
_NORM = _HERE.parent
_ROOT = _NORM.parent.parent

# ---------------------------------------------------------------------------
# oXygen PI parsing
# ---------------------------------------------------------------------------

# Match <?oxy_delete author="..." timestamp="..." content="..."?>
_DELETE_RE = re.compile(
    r'<\?oxy_delete\s[^>]*?content="((?:[^"\\]|\\.)*)"\s*\?>',
    re.DOTALL,
)
# Match <?oxy_insert_start ...?>TEXT<?oxy_insert_end?>
_INSERT_RE = re.compile(
    r'<\?oxy_insert_start\s[^>]*?\?>(.*?)<\?oxy_insert_end\?>',
    re.DOTALL,
)

# A replace pair: delete PI then insert PI (optionally interleaved text)
# We look for these patterns together for replace detection
_REPLACE_RE = re.compile(
    r'<\?oxy_delete\s[^>]*?content="((?:[^"\\]|\\.)*)"\s*\?>'
    r'<\?oxy_insert_start\s[^>]*?\?>(.*?)<\?oxy_insert_end\?>',
    re.DOTALL,
)
# Also handle insert-then-delete (same timestamp)
_REPLACE_INS_FIRST_RE = re.compile(
    r'<\?oxy_insert_start\s[^>]*?\?>(.*?)<\?oxy_insert_end\?>'
    r'<\?oxy_delete\s[^>]*?content="((?:[^"\\]|\\.)*)"\s*\?>',
    re.DOTALL,
)

_TAG_RE = re.compile(r'<[^>]+>')
_MULTI_WS = re.compile(r'\s+')


def _strip_xml(s: str) -> str:
    return _MULTI_WS.sub(' ', _TAG_RE.sub('', s)).strip()


def _classify(old: str, new: str) -> str:
    """Classify the type of editorial change."""
    o, n = old.strip(), new.strip()
    if not o and n:
        return "insert_only"
    if o and not n:
        return "delete_only"
    # Both non-empty: replace
    if o.lower() == n.lower():
        return "case_change"
    # Punctuation-only changes
    punc = set('.,;:!?-–—…()[]»«')
    if all(c in punc or c.isspace() for c in o) and all(c in punc or c.isspace() for c in n):
        return "punctuation"
    if all(c in punc or c.isspace() for c in o) and not n:
        return "punctuation_delete"
    if all(c in punc or c.isspace() for c in n) and not o:
        return "punctuation_insert"
    # Whitespace/spacing
    if o.replace(' ', '') == n.replace(' ', ''):
        return "spacing"
    # Hyphenation change
    if o.replace('-', '') == n.replace('-', '') or o.replace(' ', '') == n.replace('-', ''):
        return "hyphenation"
    # Single word replace (most interesting for Loop 1)
    o_words = o.split()
    n_words = n.split()
    if len(o_words) == 1 and len(n_words) == 1:
        return "word_replace"
    if len(o_words) <= 2 and len(n_words) <= 2:
        return "phrase_replace"
    return "structural"


def parse_file(path: Path) -> list[dict]:
    """Extract all tracked changes from one _fgj.xml file."""
    raw = path.read_text(encoding="utf-8")
    tale = path.stem.replace("_corrected_fgj", "").replace("_corrected-fgj", "")
    tale = tale.replace("_corrected_NEW_fgj", "").replace("_corrected_NY_fgj", "")
    tale = tale.replace("_corrected_NEW-fgj", "").replace("_final", "")

    # Remove changes already handled as a replacement pair (to avoid double-counting)
    handled_spans: set[tuple[int, int]] = set()
    changes: list[dict] = []

    # 1. Replace pairs: delete then insert
    for m in _REPLACE_RE.finditer(raw):
        old = _strip_xml(m.group(1))
        new = _strip_xml(m.group(2))
        handled_spans.add((m.start(), m.end()))
        changes.append({
            "tale": tale,
            "type": _classify(old, new),
            "old": old,
            "new": new,
            "direction": "replace",
        })

    # 2. Replace pairs: insert then delete (less common)
    for m in _REPLACE_INS_FIRST_RE.finditer(raw):
        if (m.start(), m.end()) in handled_spans:
            continue
        new = _strip_xml(m.group(1))
        old = _strip_xml(m.group(2))
        handled_spans.add((m.start(), m.end()))
        changes.append({
            "tale": tale,
            "type": _classify(old, new),
            "old": old,
            "new": new,
            "direction": "replace",
        })

    # 3. Lone deletes (not part of a replace pair)
    for m in _DELETE_RE.finditer(raw):
        # Check if this span overlaps any handled span
        if any(hs <= m.start() < he or hs < m.end() <= he
               for hs, he in handled_spans):
            continue
        old = _strip_xml(m.group(1))
        changes.append({
            "tale": tale,
            "type": _classify(old, ""),
            "old": old,
            "new": "",
            "direction": "delete",
        })

    # 4. Lone inserts (not part of a replace pair)
    for m in _INSERT_RE.finditer(raw):
        if any(hs <= m.start() < he or hs < m.end() <= he
               for hs, he in handled_spans):
            continue
        new = _strip_xml(m.group(2) if m.lastindex == 2 else m.group(1))
        changes.append({
            "tale": tale,
            "type": _classify("", new),
            "old": "",
            "new": new,
            "direction": "insert",
        })

    return changes


# ---------------------------------------------------------------------------
# Aggregation and reporting
# ---------------------------------------------------------------------------

def _loop1_candidates(changes: list[dict]) -> list[dict]:
    """Word-replace changes likely to become Loop 1 spelling/vocab rules."""
    cands = []
    for c in changes:
        if c["type"] not in {"word_replace", "phrase_replace"}:
            continue
        o, n = c["old"], c["new"]
        if not o or not n:
            continue
        # Exclude pure punctuation swaps and capitalization-only
        if o.lower() == n.lower():
            continue
        # Exclude single punctuation
        if len(o) == 1 and not o.isalpha():
            continue
        cands.append(c)
    return cands


def write_summary(path: Path, changes: list[dict]) -> None:
    type_counts = Counter(c["type"] for c in changes)
    total = len(changes)

    # Word-replace pattern frequency
    replacements = _loop1_candidates(changes)
    repl_counter: Counter[tuple[str, str]] = Counter(
        (c["old"].lower(), c["new"].lower()) for c in replacements
    )

    # Punctuation patterns
    punc_changes = [c for c in changes if "punctuation" in c["type"] or c["type"] == "delete_only"]
    punc_del = Counter(c["old"] for c in punc_changes if c["old"] and not c["new"])

    lines = [
        "# Editorial analysis — oXygen Author tracked changes",
        "",
        f"Source: `editorial/*/` `_fgj.xml` + `_final.xml` files  |  Total changes: **{total}**",
        "",
        "## Change type distribution",
        "",
        "| Type | Count | % |",
        "|------|------:|--:|",
    ]
    for t, n in type_counts.most_common():
        lines.append(f"| {t} | {n} | {100*n/total:.0f}% |")

    lines += [
        "",
        "## Word replacements (Loop 1 candidates)",
        "",
        "These are single-word or short phrase changes that may become",
        "Loop 1 spelling/vocabulary rules (after human verification).",
        "",
        "| old | new | occurrences |",
        "|-----|-----|------------:|",
    ]
    for (old, new), n in repl_counter.most_common(60):
        lines.append(f"| {old} | {new} | {n} |")

    lines += [
        "",
        "## Punctuation deletions (most frequent)",
        "",
        "Characters the editor removed — may indicate over-use in the corrected text.",
        "",
        "| deleted | count |",
        "|---------|------:|",
    ]
    for ch, n in punc_del.most_common(15):
        lines.append(f"| `{ch}` | {n} |")

    lines += [
        "",
        "## Loop 1 implications",
        "",
        "Top word replacements that are NOT yet covered by `rules/rules.tsv`",
        "should be reviewed for addition as new rules.",
        "",
        "## Loop 2 implications",
        "",
        "High-frequency punctuation deletions suggest the corrected text",
        "contains stylistic over-commaing or semi-colon use that Loop 2's",
        "Hunspell layer cannot detect. These are structural edits that must",
        "be addressed at the XSLT/post-processing level.",
        "",
        "> All changes require human verification before entering production.",
    ]

    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--editorial", type=Path,
                    default=_ROOT / "editorial")
    ap.add_argument("--out-dir", type=Path,
                    default=_ROOT / "resources" / "editorial-analysis")
    args = ap.parse_args()

    # Find all _fgj.xml and _final.xml files (reviewed/ layer is most authoritative)
    fgj_files = (
        list(args.editorial.rglob("*_fgj.xml"))
        + list(args.editorial.rglob("*-fgj.xml"))
        + list(args.editorial.rglob("*_final.xml"))
    )
    fgj_files = sorted(set(fgj_files))
    print(f"Found {len(fgj_files)} _fgj.xml files")

    all_changes: list[dict] = []
    for f in fgj_files:
        changes = parse_file(f)
        all_changes.extend(changes)
        print(f"  {f.name}: {len(changes)} changes")

    print(f"\nTotal changes: {len(all_changes)}")

    args.out_dir.mkdir(parents=True, exist_ok=True)

    # TSV output
    tsv_path = args.out_dir / "editorial_changes.tsv"
    fieldnames = ["tale", "type", "direction", "old", "new"]
    with open(tsv_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter="\t",
                                lineterminator="\n")
        writer.writeheader()
        writer.writerows(all_changes)
    print(f"Changes written to {tsv_path}")

    # Markdown summary
    md_path = args.out_dir / "editorial_summary.md"
    write_summary(md_path, all_changes)
    print(f"Summary written to {md_path}")

    # Quick type breakdown
    from collections import Counter
    type_counts = Counter(c["type"] for c in all_changes)
    print("\nType breakdown:")
    for t, n in type_counts.most_common():
        print(f"  {n:5d}  {t}")

    # Top word replacements
    replacements = _loop1_candidates(all_changes)
    repl_counter: Counter[tuple[str, str]] = Counter(
        (c["old"], c["new"]) for c in replacements
    )
    print("\nTop word replacements (Loop 1 candidates):")
    for (old, new), n in repl_counter.most_common(20):
        print(f"  {n:4d}  {old!r:20s} -> {new!r}")


if __name__ == "__main__":
    main()
