#!/usr/bin/env python3
"""
reclassify_ne.py — reduce NE false positives in wordlist_ne_scored.tsv.

Strategy (three-tier):
  1. NE whitelist (named_entities.txt):  score=1.00, label=namedEntity
  2. ALL-CAPS (drama characters):         score=0.85, label=namedEntity
  3. DDO lookup (normalized lowercase):
        HIT  → score=0.10, label=noun          (common word)
        MISS → conservative pattern scoring     (genuine NE candidate)

For DDO misses the score is derived from:
  - base from frequency band (< 5 → 0.75, 5-23 → 0.65, >= 24 → 0.50)
  - +0.10 for known place-name suffixes
  - +0.10 for known person-name suffixes
  - label namedEntity if score >= 0.60, else namedEntity_uncertain

Rows with labels noun / lowercase / pronoun_capital / number_punct are
untouched (they were already correctly classified).

Usage:
  python reclassify_ne.py [--tsv ../../resources/ordlister/wordlist_ne_scored.tsv]
                          [--ddo ../../resources/ordbøger/ddo-dsl/ddo_DDO.dic]
                          [--ne-list ../rules/named_entities.txt]
                          [--rules ../rules/rules.tsv]
                          [--out wordlist_ne_scored.tsv]   # overwrites by default
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path

# Resolve paths relative to this file
# _HERE = tools/normalisering/tools/; _NORM = tools/normalisering/; _PROJ = project root
_HERE = Path(__file__).parent
_NORM = _HERE.parent
_ROOT = _NORM.parent.parent
sys.path.insert(0, str(_HERE))

from rule_engine import load_rules, normalize

# ---------------------------------------------------------------------------
# Pattern-based NE scoring helpers
# ---------------------------------------------------------------------------

# Danish/Scandinavian place-name suffixes (lowercase)
_PLACE_SUFFIXES = re.compile(
    r"(borg|berg|by|holm|dal|mark|land|fjord|havn|sund|bro|gaard|strup|"
    r"lev|inge|rup|sted|ø|torp|rød|købing|vang|skov|lund|drup|bøl)$"
)

# Common person-name endings
_PERSON_SUFFIXES = re.compile(
    r"(sen|son|sson|datter|dotter|ling|burg|mann|mann)$"
)


def _place_pattern(word: str) -> bool:
    return bool(_PLACE_SUFFIXES.search(word.lower()))


def _person_pattern(word: str) -> bool:
    return bool(_PERSON_SUFFIXES.search(word.lower()))


def _is_all_caps(word: str) -> bool:
    """All-alphabetic ALL-CAPS word (drama character stage direction)."""
    return word.isalpha() and word == word.upper() and len(word) > 1


def _conservative_score(word: str, total: int) -> tuple[float, str]:
    """Score for a word not in DDO (genuine NE candidate).

    High-frequency words not in DDO are MORE likely genuine NEs (they
    appear often, yet DDO doesn't know them as common words). The old
    DSL freq<24 threshold was a first-pass heuristic before DDO matching;
    after DDO filtering it no longer makes sense to penalise frequency.
    """
    if total < 5:
        base = 0.70
    elif total < 24:
        base = 0.65
    else:
        base = 0.65   # frequent + not in DDO → confident NE candidate
    bonus = 0.0
    if _place_pattern(word):
        bonus = 0.10
    elif _person_pattern(word):
        bonus = 0.10
    score = min(0.85, base + bonus)
    label = "namedEntity" if score >= 0.60 else "namedEntity_uncertain"
    return round(score, 2), label


# ---------------------------------------------------------------------------
# DDO loader + lookup
# ---------------------------------------------------------------------------

def load_ddo(dic_path: Path) -> set[str]:
    """Load flat DDO .dic word list as lowercase set (strips BOM)."""
    words: set[str] = set()
    with open(dic_path, encoding="utf-8-sig") as f:
        for line in f:
            w = line.strip()
            if w:
                words.add(w.lower())
    return words


def _extra_stems(lw: str):
    """Generate additional candidate forms for DDO lookup.

    Covers historical spellings that Loop 1 rules don't yet normalize:
      - French-influenced -ie suffix: Melodie → melodi
      - Latin -ium/-eum: Publicum → publikum (try -um→-um and -c→-k)
      - -tion → -tion (already in DDO), -sion → -sion
      - French -eur/-eur: Humeur → humor/humør (try -eur→-ør)
      - -ee suffix: Comitee → komite (handled by rule but check anyway)
      - -c- → -k- in foreign borrowings: Comedie → komedie
    """
    candidates = []
    # -ie → -i  (Melodie→Melodi, Comedie→Komedi, Tragedie→Tragedi)
    if lw.endswith("ie"):
        candidates.append(lw[:-2] + "i")
        candidates.append(lw[:-2].replace("c", "k") + "i")
    # -eum / -ium → try as-is (Gymnasium, Museum are in DDO)
    # -eur → -ør (Humeur→humør, Coiffeur→coiffeur — coiffeur IS in DDO)
    if lw.endswith("eur"):
        candidates.append(lw[:-3] + "ør")
    # -um → -um with c→k (Publicum→publikum)
    if lw.endswith("um") and "c" in lw:
        candidates.append(lw.replace("c", "k"))
    # Leading c → k (Comedie → komedie after -ie fix above also triggers this)
    if lw.startswith("c") and not lw.startswith("ch"):
        candidates.append("k" + lw[1:])
    return candidates


def _denorm(s: str) -> str:
    """Reverse å/æ/ø → aa/ae/oe to check historical spellings in DDO.

    The DDO-DSL dictionary contains both modern (å, æ, ø) and historical
    (aa, ae, oe) forms for many words (e.g. 'maaske' but not 'måske').
    Checking the de-normalised form catches these misses.
    """
    return s.replace("å", "aa").replace("æ", "ae").replace("ø", "oe")


def in_ddo(word: str, ddo_set: set[str], rules) -> bool:
    """True if word or its Loop-1-normalised lowercase form is in DDO.

    Lookup order:
      1. original lowercase
      2. Loop-1 normalized form
      3. de-normalised (å→aa etc.) historical spelling (DDO has both)
      4. extra historical stems (-ie→-i, -eur→-ør, c→k, etc.)
      5. all of the above with genitive -s stripped
    """
    lw = word.lower()
    candidates = [lw]
    norm, _, _ = normalize(lw, rules)
    candidates.append(norm)
    candidates.append(_denorm(norm))     # historical: måske → maaske
    candidates.extend(_extra_stems(lw))

    for cand in candidates:
        if cand in ddo_set:
            return True
        nc, _, _ = normalize(cand, rules)
        if nc in ddo_set:
            return True

    # genitive -s strip
    if lw.endswith("s") and len(lw) > 2:
        base = lw[:-1]
        base_norm, _, _ = normalize(base, rules)
        for cand in [base, base_norm, _denorm(base_norm)] + _extra_stems(base):
            if cand in ddo_set:
                return True
    return False


# ---------------------------------------------------------------------------
# Main reclassification
# ---------------------------------------------------------------------------

_NE_TARGETS = {"namedEntity", "namedEntity_uncertain", "noun_or_ne"}


def reclassify(rows: list[dict], ddo_set: set[str],
               ne_whitelist: set[str], rules) -> list[dict]:
    stats = {
        "whitelist": 0,
        "all_caps": 0,
        "ddo_hit": 0,
        "ddo_miss": 0,
        "unchanged": 0,
    }
    out = []
    for r in rows:
        word = r["word"]
        label = r["ne_label"]

        if label not in _NE_TARGETS:
            stats["unchanged"] += 1
            out.append(r)
            continue

        # Tier 1: NE whitelist
        if word.lower() in ne_whitelist:
            r = {**r, "ne_score": "1.00", "ne_label": "namedEntity"}
            stats["whitelist"] += 1
            out.append(r)
            continue

        # Tier 2: ALL-CAPS drama characters
        if _is_all_caps(word):
            r = {**r, "ne_score": "0.85", "ne_label": "namedEntity"}
            stats["all_caps"] += 1
            out.append(r)
            continue

        total = int(r["total"])

        # Tier 3: DDO lookup
        if in_ddo(word, ddo_set, rules):
            r = {**r, "ne_score": "0.10", "ne_label": "noun"}
            stats["ddo_hit"] += 1
        else:
            score, new_label = _conservative_score(word, total)
            r = {**r, "ne_score": str(score), "ne_label": new_label}
            stats["ddo_miss"] += 1

        out.append(r)

    return out, stats


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tsv", type=Path,
                    default=_ROOT / "resources" / "ordlister" / "wordlist_ne_scored.tsv")
    ap.add_argument("--ddo", type=Path,
                    default=_ROOT / "resources" / "ordbøger" / "ddo-dsl" / "ddo_DDO.dic")
    ap.add_argument("--ne-list", type=Path,
                    default=_NORM / "rules" / "named_entities.txt")
    ap.add_argument("--rules", type=Path,
                    default=_NORM / "rules" / "rules.tsv")
    ap.add_argument("--out", type=Path, default=None,
                    help="Output path (default: overwrite --tsv)")
    args = ap.parse_args()

    out_path = args.out or args.tsv

    print(f"Loading DDO: {args.ddo}")
    ddo_set = load_ddo(args.ddo)
    print(f"  {len(ddo_set):,} entries")

    ne_whitelist = {
        line.strip().lower()
        for line in args.ne_list.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.startswith("#")
    }
    print(f"NE whitelist: {len(ne_whitelist)} entries")

    rules = load_rules(args.rules)
    print(f"Rules: {len(rules)}")

    with open(args.tsv, encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t")
        fieldnames = reader.fieldnames
        rows = list(reader)
    print(f"Input rows: {len(rows):,}")

    out_rows, stats = reclassify(rows, ddo_set, ne_whitelist, rules)

    with open(out_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter="\t",
                                lineterminator="\n")
        writer.writeheader()
        writer.writerows(out_rows)

    total_ne_before = sum(1 for r in rows if r["ne_label"] in _NE_TARGETS)
    total_ne_after = sum(1 for r in out_rows if r["ne_label"] in _NE_TARGETS)

    print(f"\nReclassification complete → {out_path}")
    print(f"  NE candidates before: {total_ne_before:,}")
    print(f"  NE candidates after:  {total_ne_after:,}")
    print(f"  Reduction:            {total_ne_before - total_ne_after:,} "
          f"({(total_ne_before - total_ne_after) / total_ne_before:.0%})")
    print(f"\n  Tier breakdown:")
    print(f"    NE whitelist kept:         {stats['whitelist']:,}")
    print(f"    ALL-CAPS drama chars:      {stats['all_caps']:,}")
    print(f"    DDO hit → noun:            {stats['ddo_hit']:,}")
    print(f"    DDO miss → NE candidate:   {stats['ddo_miss']:,}")
    print(f"    Unchanged (other labels):  {stats['unchanged']:,}")

    # Label distribution after
    from collections import Counter
    label_counts = Counter(r["ne_label"] for r in out_rows)
    print(f"\n  Label distribution after reclassification:")
    for label, count in sorted(label_counts.items(), key=lambda x: -x[1]):
        print(f"    {label:<30} {count:,}")


if __name__ == "__main__":
    main()
