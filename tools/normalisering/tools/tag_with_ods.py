#!/usr/bin/env python3
"""
tag_with_ods.py — supplement NE reclassification with ODS lemma lookup.

ODS (Ordbog over det Danske Sprog, 1918-1956) covers 1700-1950 Danish —
the same linguistic period as HCA's texts. Where the modern DDO dictionary
misses archaic nouns (e.g. historical spellings not carried into modern
Danish), ODS provides an authoritative second lookup.

ODS lemmas are in MODERN spelling (å/ø/æ). The matching pipeline is:
  1. Apply Loop 1 normalization (aa→å, oe→ø, etc.) to the HCA form.
  2. Try direct ODS match (lowercase normalized form).
  3. Try suffix stripping (common Danish noun/adj endings) + ODS match.
     Also try re-adding silent -e after stripping (Kong→Konge, Billed→Billede).
  4. If matched → reclassify namedEntity → noun (label: noun, score: 0.15).

Scope:
  - Only `namedEntity` and `namedEntity_uncertain` rows are candidates.
  - Rows already confirmed as `noun` via DDO (score=0.10) are skipped.
  - Rows with ne_score=1.0 (NE whitelist) are never touched.

Usage:
  python tag_with_ods.py
    [--tsv ../../resources/corpora/wordlist_ne_scored.tsv]
    [--ods ../../resources/dictionaries/ods-lemma/ods_lemmas_extracted.tsv]
    [--rules ../rules/rules.tsv]
    [--out PATH]      # default: overwrite --tsv
    [--backup]        # write .bak before overwriting (default: True)
    [--no-backup]
"""
from __future__ import annotations

import argparse
import csv
import re
import shutil
import sys
from collections import Counter
from pathlib import Path

_HERE = Path(__file__).parent
_NORM = _HERE.parent
_ROOT = _NORM.parent.parent
sys.path.insert(0, str(_HERE))

from rule_engine import load_rules, normalize

# ---------------------------------------------------------------------------
# ODS loader
# ---------------------------------------------------------------------------

_ODS_NOUN_CLASSES = {"Noun", "Noun/Plural", "BoundForm"}
_ODS_ADJ_CLASSES  = {"Adjective"}


def load_ods(ods_path: Path) -> tuple[set[str], set[str]]:
    """Return (ods_nouns_lc, ods_adjs_lc) as lowercase sets."""
    nouns: set[str] = set()
    adjs:  set[str] = set()
    with open(ods_path, encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            w = row["word"].strip().lower()
            cls = row.get("char_issue", "").strip()
            if not w:
                continue
            if cls in _ODS_NOUN_CLASSES:
                nouns.add(w)
            elif cls in _ODS_ADJ_CLASSES:
                adjs.add(w)
    return nouns, adjs


# ---------------------------------------------------------------------------
# Matching helpers
# ---------------------------------------------------------------------------

_CAPS_RE = re.compile(r'^[A-ZÆØÅ][A-ZÆØÅ]+$')

def _caps_to_initial(w: str) -> str:
    """FREDERIK → Frederik."""
    if _CAPS_RE.match(w) and len(w) > 1:
        return w[0] + w[1:].lower()
    return w


# Danish noun/adj suffixes, longest-first to avoid premature stripping.
# "ne" added to catch definite plural "filisterne" → strip "ne" → "filister".
_SUFFIXES = [
    "ernes", "enes", "ens", "ets", "erne", "ene", "ers",
    "er", "en", "et", "es", "ne", "e", "s",
]


def _ods_candidates(lw: str) -> list[str]:
    """Generate ODS lemma candidates from a (normalized, lowercase) word.

    Strategies:
      a) As-is.
      b) Strip each suffix → stem; also try stem + 'e' (silent final e lost
         in many inflected forms: Kong→Konge, Billed→Billede).
      c) Try adding 'e' to the unstemmed form (catches cases where the
         nominative itself lost the -e: Ild→Ilde → ODS has both).
    """
    candidates: list[str] = [lw, lw + "e"]

    for sfx in _SUFFIXES:
        if lw.endswith(sfx):
            stem = lw[: -len(sfx)]
            if len(stem) >= 3:
                candidates.append(stem)
                candidates.append(stem + "e")

    # deduplicate while preserving order
    seen: set[str] = set()
    out: list[str] = []
    for c in candidates:
        if c not in seen:
            seen.add(c)
            out.append(c)
    return out


def _extra_normalize(s: str) -> str:
    """Apply orthographic transforms NOT yet in Loop 1 rules, for ODS lookup.

    These are conservative transforms used ONLY when the direct ODS lookup fails,
    as a fallback to reach the correct ODS lemma for historical/foreign spellings.

    qv  → kv  (Samvittighedsqval → samvittighedskval)
    qu  → kv  (Latin/French qu: Sqvadron → skvadron)
    sc  → sk  word-initial (Scandale → skandale)
    sch → sk  (Schiller → skiller — use with care)
    eur → ør  French suffix (manuducteur → manuduktør, couleur already →kulør)
    orch → ork (orchestre → orkestre)
    kk  → k   double-consonant reduction (perpendikkel → perpendikel)
    """
    # qv / qu before vowel → kv
    s = re.sub(r"qv", "kv", s)
    s = re.sub(r"qu(?=[aeiouyæøå])", "kv", s)
    # word-initial sc → sk
    s = re.sub(r"^sc", "sk", s)
    # orch → ork  (orchestra → orkestra)
    s = s.replace("orch", "ork")
    # French -eur suffix (including -teur) → -ør
    s = re.sub(r"eur\b", "ør", s)
    s = re.sub(r"eur(s|ens|ernes|ene)\b", r"ør\1", s)
    # double kk → k before vowel (perpendikkel → perpendikel)
    s = re.sub(r"kk(?=[aeiouyæøå])", "k", s)
    # double ll → l (porcellæn → porcelæn)
    s = re.sub(r"ll(?=[aeiouyæøå])", "l", s)
    # double ee → e (sandsteen → sandsten, heer → her)
    s = re.sub(r"ee(?=[aeiouyæøånb])", "e", s)  # before vowel or n
    s = s.replace("een", "en")   # catch remaining: beenbryder → benbryder
    # ain → æn  (porcellain → porcelæn; Champain → Champæn)
    s = s.replace("ain", "æn")
    # eu before consonant → ø  (meublement → møblement)
    s = re.sub(r"eu(?=[bcdfghjklmnpqrstvwxyz])", "ø", s)
    return s


# Danish productive noun-forming suffixes.  A word ending in one of these is
# almost certainly a noun even if its lemma is not found in ODS.
_NOUN_SUFFIXES: tuple[str, ...] = (
    "else",   # opoffrelse, forståelse
    "ning",   # samling, vandring
    "ighed",  # ydmyghed
    "hed",    # kloghed, godhed
    "dom",    # visdom, barndom
    "skab",   # venskab, selskab
    "ment",   # meublement, ornament
    "tion",   # station, nation
    "sion",   # passion
    "eri",    # bageri, bryggeri
    "inde",   # lærerinde
    "schaft", # gesellschaft (German loans)
)


_INFL_STRIP = ("erne", "ernes", "ene", "enes", "ens", "ets", "ers", "en", "et", "er", "es", "e", "s")

def _has_noun_suffix(word: str) -> bool:
    """True if word (or its uninflected stem) ends in a productive noun suffix."""
    lw = word.lower()
    if any(lw.endswith(sfx) for sfx in _NOUN_SUFFIXES):
        return True
    # also check after stripping one inflectional suffix
    for inf in _INFL_STRIP:
        if lw.endswith(inf) and len(lw) - len(inf) >= 4:
            stem = lw[:-len(inf)]
            if any(stem.endswith(sfx) for sfx in _NOUN_SUFFIXES):
                return True
    return False


def _part_in_ods(part: str, ods_nouns: set[str], ods_adjs: set[str],
                 rules) -> bool:
    """Check one component of a solid compound: direct ODS + extra-norm only.

    Tries three forms to handle old vs modern spelling (ODS uses old-spelling):
    - raw  (part as-is, old spelling like 'maaneds')
    - norm (after Loop1 rules, e.g. 'måneds')
    - extra (after extra ortho transforms, e.g. 'porcelæns')
    Deliberately does NOT recurse into compound splitting (would be exponential).
    """
    eval_w = _caps_to_initial(part)
    raw = eval_w.lower()
    norm, _, _ = normalize(raw, rules)
    extra = _extra_normalize(norm)

    forms = [raw]
    if norm != raw:
        forms.append(norm)
    if extra != norm:
        forms.append(extra)

    for form in forms:
        for cand in _ods_candidates(form):
            if cand in ods_nouns or cand in ods_adjs:
                return True
    return False


def _split_solid_compound(word: str, ods_nouns: set[str], ods_adjs: set[str],
                           rules) -> str | None:
    """Try a binary split of a solid (unhyphenated) compound.

    Tries splits on both the original lowercase form (ODS uses old spelling like
    'maaneds') AND the Loop1-normalized form, deduplicated.

    At each split position the right part (head) is checked first.  The left
    part may end in genitive -s, which is stripped for the ODS lookup.

    Returns 'noun' if a valid binary split is found, else None.
    """
    eval_w = _caps_to_initial(word)
    orig_lw = eval_w.lower()
    base, _, _ = normalize(orig_lw, rules)
    norm = _extra_normalize(base)

    # Deduplicated ordered list of forms to try splits on
    forms_to_split: list[str] = [orig_lw]
    if norm != orig_lw:
        forms_to_split.append(norm)

    seen_splits: set[tuple[str, str]] = set()

    for form in forms_to_split:
        n = len(form)
        for i in range(3, n - 2):
            left  = form[:i]
            right = form[i:]
            if len(right) < 3:
                break
            key = (left, right)
            if key in seen_splits:
                continue
            seen_splits.add(key)

            right_ok = _part_in_ods(right, ods_nouns, ods_adjs, rules)
            if not right_ok:
                continue

            left_stems = [left]
            if left.endswith("s") and len(left) > 3:
                left_stems.append(left[:-1])

            for ls in left_stems:
                if _part_in_ods(ls, ods_nouns, ods_adjs, rules):
                    return "noun"

    return None


def _compound_all_in_ods(word: str, ods_nouns: set[str], ods_adjs: set[str],
                          rules) -> str | None:
    """Træ-Altan → ['Træ', 'Altan']: noun if ALL hyphen-parts are in ODS.

    Mirrors reclassify_ne._compound_all_in_ddo() but uses the ODS set.
    Returns 'noun' if every part matches, else None.
    """
    parts = [p for p in word.split("-") if len(p) > 1]
    if len(parts) < 2:
        return None
    for part in parts:
        if in_ods(part, ods_nouns, ods_adjs, rules) is None:
            return None
    return "noun"


def in_ods(word: str, ods_nouns: set[str], ods_adjs: set[str],
           rules) -> str | None:
    """Return ODS class ('noun'|'adj') if matched, else None.

    Lookup tiers (first match wins):
    1. Normalize ALL-CAPS → initial-cap; apply Loop 1 rules.
    2. Direct ODS match + suffix-stripped candidates.
    3. Extra orthographic normalization (qv→kv, sc→sk, eur→ør …) + ODS.
    4. Hyphen-compound: all parts must be in ODS.
    5. Solid compound: binary split, both parts in ODS.
    6. Abstract-noun suffix heuristic (-else, -hed, -ning, -ment …).
    """
    eval_w = _caps_to_initial(word)
    orig_lw = eval_w.lower()
    norm, _, _ = normalize(orig_lw, rules)
    extra = _extra_normalize(norm)

    # Tier 2: try raw (old-spelling), normalized, and extra-normalized forms
    for form in dict.fromkeys([orig_lw, norm, extra]):  # deduped, order-preserved
        for cand in _ods_candidates(form):
            if cand in ods_nouns:
                return "noun"
            if cand in ods_adjs:
                return "adj"

    # Tier 4: hyphen-compound (existing)
    result = _compound_all_in_ods(eval_w, ods_nouns, ods_adjs, rules)
    if result:
        return result

    # Tier 5: solid compound binary split
    result = _split_solid_compound(word, ods_nouns, ods_adjs, rules)
    if result:
        return result

    # Tier 6: noun-suffix heuristic (productive Danish morphology)
    if _has_noun_suffix(word):
        return "noun"

    return None


# ---------------------------------------------------------------------------
# Reclassification
# ---------------------------------------------------------------------------

_NE_TARGETS = {"namedEntity", "namedEntity_uncertain"}
_ODS_SCORE  = "0.15"   # ODS hit score (between DDO noun=0.10 and conservative NE=0.65)


def reclassify_with_ods(rows: list[dict],
                        ods_nouns: set[str],
                        ods_adjs:  set[str],
                        rules) -> tuple[list[dict], dict]:
    """Apply ODS reclassification to namedEntity rows.

    Returns (new_rows, stats).
    """
    stats: dict[str, int] = {
        "ods_noun_hit": 0,
        "ods_adj_hit": 0,
        "unchanged_ne": 0,
        "skipped": 0,
    }
    out: list[dict] = []

    for r in rows:
        label = r["ne_label"]

        if label not in _NE_TARGETS:
            stats["skipped"] += 1
            out.append(r)
            continue

        # Never touch NE-whitelist entries
        if r["ne_score"] == "1.00":
            stats["unchanged_ne"] += 1
            out.append(r)
            continue

        match = in_ods(r["word"], ods_nouns, ods_adjs, rules)
        if match == "noun":
            r = {**r, "ne_score": _ODS_SCORE, "ne_label": "noun"}
            stats["ods_noun_hit"] += 1
        elif match == "adj":
            r = {**r, "ne_score": _ODS_SCORE, "ne_label": "noun"}  # treat adj as common word
            stats["ods_adj_hit"] += 1
        else:
            stats["unchanged_ne"] += 1

        out.append(r)

    return out, stats


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def _compare_report(before: list[dict], after: list[dict]) -> None:
    """Print a side-by-side comparison of what changed."""
    changed = [
        (b, a) for b, a in zip(before, after)
        if b["ne_label"] != a["ne_label"] or b["ne_score"] != a["ne_score"]
    ]
    print(f"\nRows changed: {len(changed)}")

    # Group by before-label → after-label
    transitions: Counter = Counter(
        (b["ne_label"], a["ne_label"]) for b, a in changed
    )
    print("Transition summary:")
    for (old_lbl, new_lbl), n in transitions.most_common():
        print(f"  {old_lbl} -> {new_lbl}: {n}")

    # Top changed words (by frequency)
    top = sorted(changed, key=lambda x: -int(x[0]["total"]))[:30]
    print("\nTop reclassified words (by corpus frequency):")
    print(f"  {'word':28s}  {'total':>6s}  {'before':30s}  after")
    for b, a in top:
        before_str = f"{b['ne_label']} ({b['ne_score']})"
        after_str  = f"{a['ne_label']} ({a['ne_score']})"
        print(f"  {b['word']:28s}  {b['total']:>6s}  {before_str:30s}  {after_str}")

    # Label distribution after
    label_after = Counter(r["ne_label"] for r in after)
    print("\nLabel distribution after ODS tagging:")
    for lbl, n in sorted(label_after.items(), key=lambda x: -x[1]):
        print(f"  {lbl:<30s}  {n:,}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tsv", type=Path,
                    default=_ROOT / "resources" / "corpora" / "wordlist_ne_scored.tsv")
    ap.add_argument("--ods", type=Path,
                    default=_ROOT / "resources" / "dictionaries" / "ods-lemma" /
                            "ods_lemmas_extracted.tsv")
    ap.add_argument("--rules", type=Path,
                    default=_NORM / "rules" / "rules.tsv")
    ap.add_argument("--out", type=Path, default=None,
                    help="Output path (default: overwrite --tsv)")
    ap.add_argument("--backup", dest="backup", action="store_true", default=True)
    ap.add_argument("--no-backup", dest="backup", action="store_false")
    args = ap.parse_args()

    out_path = args.out or args.tsv

    # Backup
    if args.backup and args.tsv.exists():
        bak = args.tsv.with_suffix(".tsv.bak")
        shutil.copy2(args.tsv, bak)
        print(f"Backup: {bak}")

    print(f"Loading ODS: {args.ods}")
    ods_nouns, ods_adjs = load_ods(args.ods)
    print(f"  ODS nouns: {len(ods_nouns):,}   ODS adjs: {len(ods_adjs):,}")

    rules = load_rules(args.rules)
    print(f"Rules: {len(rules)}")

    with open(args.tsv, encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t")
        fieldnames = reader.fieldnames
        rows = list(reader)
    print(f"Input rows: {len(rows):,}")

    new_rows, stats = reclassify_with_ods(rows, ods_nouns, ods_adjs, rules)

    with open(out_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter="\t",
                                lineterminator="\n")
        writer.writeheader()
        writer.writerows(new_rows)
    print(f"\nOutput: {out_path}")

    print(f"\nODS reclassification stats:")
    for k, v in stats.items():
        print(f"  {k:<25s}  {v:,}")

    _compare_report(rows, new_rows)


if __name__ == "__main__":
    main()
