#!/usr/bin/env python3
"""
evaluate_gold.py - measure the v2 pipeline against the human gold standard.

For every tale we have an ORIGINAL (historical orthography) and a human
MODERNIZED version. We run Loop 1 (rule normalization) and Loop 2 (Hunspell
over-normalization detection) on the original and compare to the modern gold.

Because lower-casing and comma/word-splitting reforms are handled by *separate*
stages in the production pipeline (not by the rule table evaluated here), we
report orthographic changes separately from case-only and structural changes,
so the rule table is judged on what it is actually responsible for.

Metrics (token-aligned via difflib):
  * gold changes, split into  case-only | orthographic | structural(n:m)
  * Loop-1 recall    = orthographic gold changes the rules reproduce
  * Loop-1 precision = of the rules' changes, how many match the gold
  * over-normalizations = rules changing a token the gold kept
  * top missed gold edit-patterns (what rules to add next)
  * Loop-2 = clear over-normalizations flagged by the Hunspell layer

Usage:
  python evaluate_gold.py ../../golden-standard/original ../../golden-standard/modern \
      --rules ../rules/rules.tsv --lexicon ../../ordbøger/aaTilÅ/ddo_DDO \
      --out ../../golden-standard/eval_results.json
"""
from __future__ import annotations

import argparse
import difflib
import json
import re
from collections import Counter
from pathlib import Path

from rule_engine import load_rules, normalize
from danish_lexicon import DanishLexicon
from spellcheck_refine import is_known, reverse_to_known

TOKEN = re.compile(r"[A-Za-zÆØÅæøåÉéÜüÖöÄä][A-Za-zÆØÅæøåÉéÜüÖöÄä'-]*")
BODY = re.compile(r"<body.*?>(.*)</body>", re.DOTALL)


def body_tokens(path: Path) -> list[str]:
    s = path.read_text(encoding="utf-8")
    m = BODY.search(s)
    b = m.group(1) if m else s
    b = re.sub(r"<[^>]+>", " ", b)
    return TOKEN.findall(b)


def char_edit(a: str, b: str) -> str:
    """Compact description of the char-level change a->b (for pattern mining)."""
    sm = difflib.SequenceMatcher(a=a, b=b, autojunk=False)
    parts = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag != "equal":
            parts.append(f"{a[i1:i2] or '∅'}→{b[j1:j2] or '∅'}")
    return ",".join(parts)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("original", type=Path)
    ap.add_argument("modern", type=Path)
    ap.add_argument("--rules", type=Path, default=Path("../rules/rules.tsv"))
    ap.add_argument("--lexicon")
    ap.add_argument("--out", type=Path, default=Path("../../golden-standard/eval_results.json"))
    ap.add_argument("--limit", type=int, default=0, help="only N tales (0=all)")
    args = ap.parse_args()

    rules = load_rules(args.rules)
    rules_by_id = {r["id"]: r for r in rules}
    lex = DanishLexicon.load(args.lexicon) if args.lexicon else None

    c = Counter()
    missed_patterns = Counter()
    wrong_examples, correct_examples, overnorm_examples = [], [], []
    l2_flagged = Counter()
    l2_seen = set()
    l2_examples = []

    pairs = sorted(args.original.glob("*.xml"))
    if args.limit:
        pairs = pairs[:args.limit]
    tales = 0
    for orig_path in pairs:
        mod_path = args.modern / orig_path.name
        if not mod_path.exists():
            continue
        tales += 1
        o_toks = body_tokens(orig_path)
        m_toks = body_tokens(mod_path)
        sm = difflib.SequenceMatcher(a=o_toks, b=m_toks, autojunk=False)
        for tag, i1, i2, j1, j2 in sm.get_opcodes():
            if tag == "equal":
                # gold kept these tokens; rules must not change them
                for tok in o_toks[i1:i2]:
                    c["gold_kept"] += 1
                    out, applied, _ = normalize(tok, rules)
                    if out != tok and out.lower() != tok.lower():
                        c["overnorm"] += 1
                        if len(overnorm_examples) < 25:
                            overnorm_examples.append(f"{tok}→{out} ({','.join(applied)})")
            elif tag == "replace" and (i2 - i1) == (j2 - j1):
                # clean 1:1 token replacements = gold change candidates
                for o, m in zip(o_toks[i1:i2], m_toks[j1:j2]):
                    c["gold_changed"] += 1
                    case_only = (o != m and o.lower() == m.lower())
                    if case_only:
                        c["change_caseonly"] += 1
                        continue
                    c["change_orth"] += 1
                    out, applied, _ = normalize(o, rules)
                    if out.lower() == m.lower():
                        c["orth_correct"] += 1
                        if len(correct_examples) < 25:
                            correct_examples.append(f"{o}→{out}")
                    elif out.lower() == o.lower():
                        c["orth_missed"] += 1
                        missed_patterns[char_edit(o.lower(), m.lower())] += 1
                    else:
                        c["orth_wrong"] += 1
                        if len(wrong_examples) < 25:
                            wrong_examples.append(f"{o}→{out} (gold {m})")
            else:
                # insert/delete/n:m = structural (word-split, punctuation, etc.)
                c["structural"] += max(i2 - i1, j2 - j1)

        # Loop 2 over-normalization detection (unique original types)
        if lex is not None:
            for tok in set(o_toks):
                if tok in l2_seen:
                    continue
                l2_seen.add(tok)
                out, applied, _ = normalize(tok, rules)
                if out == tok or not applied or is_known(lex, out):
                    continue
                hit = reverse_to_known(out, applied, rules_by_id, lex)
                if hit:
                    l2_flagged[hit[1]] += 1
                    if len(l2_examples) < 25:
                        l2_examples.append(f"{tok}→{out} (fix {hit[0]}, {hit[1]})")

    # Derived rates
    def pct(a, b): return round(100 * a / b, 1) if b else 0.0
    loop1_changes = c["orth_correct"] + c["orth_wrong"] + c["overnorm"]
    summary = {
        "tales": tales,
        "gold_changed_tokens": c["gold_changed"],
        "change_caseonly": c["change_caseonly"],
        "change_orthographic": c["change_orth"],
        "structural_changes": c["structural"],
        "loop1_orth_correct": c["orth_correct"],
        "loop1_orth_missed": c["orth_missed"],
        "loop1_orth_wrong": c["orth_wrong"],
        "loop1_recall_pct": pct(c["orth_correct"], c["change_orth"]),
        "loop1_precision_pct": pct(c["orth_correct"], c["orth_correct"] + c["orth_wrong"]),
        "overnormalizations_on_kept": c["overnorm"],
        "loop2_flagged_types": int(sum(l2_flagged.values())),
    }
    result = {
        "summary": summary,
        "top_missed_patterns": missed_patterns.most_common(20),
        "loop2_by_rule": l2_flagged.most_common(20),
        "examples": {
            "correct": correct_examples[:15],
            "wrong": wrong_examples[:15],
            "overnorm": overnorm_examples[:15],
            "loop2": l2_examples[:15],
        },
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                        encoding="utf-8")

    print(f"Tales: {tales}")
    for k, v in summary.items():
        print(f"  {k}: {v}")
    print("Top missed gold patterns:")
    for pat, n in missed_patterns.most_common(12):
        print(f"  {n:5d}  {pat}")
    print("Loop-2 over-normalizations by rule:")
    for rid, n in l2_flagged.most_common(10):
        r = rules_by_id[rid]
        print(f"  {n:5d}  {rid}: {r['source']}→{r['target']}")


if __name__ == "__main__":
    main()
