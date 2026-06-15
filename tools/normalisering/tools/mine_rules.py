#!/usr/bin/env python3
"""
mine_rules.py - Phase 2 human-guided rule induction.

Reads a supervised dataset of corrections (before -> after, with metadata) and
induces *candidate* rewrite rules. It never deploys anything: it emits
candidates and a review queue for human approval, preserving full
explainability (every candidate lists the examples that support it).

Pipeline (matches the Phase 2 spec):

    edit pairs -> char alignment -> contextual edit extraction
              -> aggregation -> confidence scoring -> {candidates, review_queue}

Confidence combines four documented components, each traceable:
  * frequency   - how many times the edit was observed
  * consistency - fraction of occurrences of `source` that took THIS target
  * lexical     - is the resulting form in the modern lexicon?
  * historical  - is the pair already attested in the variant database?

Input  (TSV, header optional):  before <TAB> after [<TAB> date [<TAB> editor]]
Output (JSON):                  candidate_rules.json, review_queue.json

Usage:
  python mine_rules.py edits.tsv \
      [--lexicon modern_lexicon.txt] [--variants known_variants.tsv] \
      [--threshold 0.85] [--out-dir .]
"""
from __future__ import annotations

import argparse
import difflib
import json
from collections import defaultdict
from pathlib import Path


def read_pairs(path: Path):
    pairs = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        cols = line.split("\t")
        if cols[0].lower() in ("before", "#before"):
            continue  # header
        before, after = cols[0], cols[1]
        date = cols[2] if len(cols) > 2 else ""
        editor = cols[3] if len(cols) > 3 else ""
        if before != after:
            pairs.append((before, after, date, editor))
    return pairs


def load_lexicon(path: Path | None):
    """Return an object with .known(word); accepts a DDO Hunspell prefix/.dic
    or a plain word list. None if no lexicon given."""
    if not path:
        return None
    from danish_lexicon import DanishLexicon
    return DanishLexicon.load(path)


def read_variants(path: Path | None):
    """Known historical variant pairs 'source<TAB>target' -> set of (s,t)."""
    if not path:
        return set()
    out = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        c = line.split("\t")
        if len(c) >= 2:
            out.add((c[0], c[1]))
    return out


def extract_edits(before: str, after: str):
    """Yield (src_segment, tgt_segment, left_ctx, right_ctx) for each change.

    Uses character-level alignment; each replace/insert/delete block is reported
    with one character of surrounding context so rules stay specific enough to be
    safe (e.g. `iø -> ø` in context `sk_n`).
    """
    sm = difflib.SequenceMatcher(a=before, b=after, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            continue
        src = before[i1:i2]
        tgt = after[j1:j2]
        left = before[i1 - 1] if i1 > 0 else "^"
        right = before[i2] if i2 < len(before) else "$"
        yield src, tgt, left, right


def mine(pairs, lexicon, variants):
    # Aggregate by the (src,tgt) edit; track context + supporting examples.
    agg = defaultdict(lambda: {"count": 0, "contexts": defaultdict(int), "examples": []})
    src_totals = defaultdict(int)  # how often src was edited at all (any target)

    for before, after, date, editor in pairs:
        for src, tgt, left, right in extract_edits(before, after):
            key = (src, tgt)
            agg[key]["count"] += 1
            agg[key]["contexts"][f"{left}_{right}"] += 1
            if len(agg[key]["examples"]) < 8:
                agg[key]["examples"].append({"before": before, "after": after,
                                             "date": date, "editor": editor})
            src_totals[src] += 1

    candidates = []
    for (src, tgt), data in agg.items():
        freq = data["count"]
        consistency = freq / src_totals[src] if src_totals[src] else 0.0
        # Lexical validation: did at least one resulting word land in the lexicon?
        lexical_ok = (any(lexicon.known(ex["after"]) for ex in data["examples"])
                      if lexicon else None)
        historical = (src, tgt) in variants

        conf = score(freq, consistency, lexical_ok, historical)
        candidates.append({
            "source": src,
            "target": tgt,
            "edit": f"{src} -> {tgt}",
            "observations": freq,
            "consistency": round(consistency, 3),
            "top_contexts": dict(sorted(data["contexts"].items(),
                                        key=lambda kv: -kv[1])[:3]),
            "lexical_ok": lexical_ok,
            "historical_evidence": historical,
            "confidence": round(conf, 3),
            "supporting_examples": data["examples"],
        })
    candidates.sort(key=lambda c: -c["confidence"])
    return candidates


def score(freq, consistency, lexical_ok, historical) -> float:
    """Transparent, monotonic confidence in [0,1]. No black boxes."""
    # Frequency: saturating, so 1 obs is weak, ~10+ is strong.
    freq_score = 1.0 - (1.0 / (1.0 + freq))            # 1->0.5, 4->0.8, 9->0.9
    parts = [(freq_score, 0.35), (consistency, 0.35)]
    if lexical_ok is not None:
        parts.append((1.0 if lexical_ok else 0.0, 0.20))
    parts.append((1.0 if historical else 0.0, 0.10))
    total_w = sum(w for _, w in parts)
    return sum(v * w for v, w in parts) / total_w


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("edits", type=Path)
    ap.add_argument("--lexicon", type=Path,
                    help="DDO Hunspell prefix/.dic, or a plain word list")
    ap.add_argument("--variants", type=Path)
    ap.add_argument("--threshold", type=float, default=0.85,
                    help="confidence >= threshold -> candidate; below -> review queue")
    ap.add_argument("--out-dir", type=Path, default=Path("."))
    args = ap.parse_args()

    pairs = read_pairs(args.edits)
    lexicon = load_lexicon(args.lexicon)
    variants = read_variants(args.variants)

    all_c = mine(pairs, lexicon, variants)
    candidates = [c for c in all_c if c["confidence"] >= args.threshold]
    review = []
    for c in all_c:
        if c["confidence"] < args.threshold:
            review.append({
                "status": "review_required",
                "candidate": c["edit"],
                "confidence": c["confidence"],
                "observations": c["observations"],
                "supporting_examples": c["supporting_examples"],
            })

    args.out_dir.mkdir(parents=True, exist_ok=True)
    (args.out_dir / "candidate_rules.json").write_text(
        json.dumps(candidates, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (args.out_dir / "review_queue.json").write_text(
        json.dumps(review, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"{len(pairs)} corrections -> {len(all_c)} distinct edits")
    print(f"  {len(candidates)} candidate rule(s)  (confidence >= {args.threshold})")
    print(f"  {len(review)} item(s) routed to review queue")
    for c in candidates[:10]:
        print(f"    {c['confidence']:.2f}  {c['edit']:<14} x{c['observations']}"
              f"  consistency={c['consistency']}")


if __name__ == "__main__":
    main()
