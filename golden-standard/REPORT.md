# Golden-standard evaluation — v2 normalization vs. human modernization

**Date:** 2026-06-14 · **Corpus:** 161 H.C. Andersen tales, each as *original*
orthography vs. *human-modernized* (`_modern.xml`), from
`sv-data/data/works`. **Method:** body text token-aligned (difflib); Loop 1 =
46-rule table ([`normalisering/rules/rules.tsv`](../normalisering/rules/rules.tsv));
Loop 2 = DDO-Hunspell over-normalization detector. Reproduce with
[`normalisering/tools/evaluate_gold.py`](../normalisering/tools/evaluate_gold.py);
full numbers in [`eval_results.json`](eval_results.json).

## What the editors changed (112,118 token changes)

| Category | Tokens | Share | Handled by the rule table? |
|---|--:|--:|---|
| **Case-only** (Substantiv → substantiv) | 59,646 | 53% | No — separate lower-casing stage |
| **Orthographic** (spelling) | 52,472 | 47% | **Yes — this is what Loop 1 owns** |
| Structural (word-split, punctuation, commas) | 8,589 | — | No — separate stages |

Over half of all "modernization" is **lower-casing of nouns**, which the v1 rule
table deliberately does not do (it is a downstream XSLT stage). Judging the rules
on the 52,472 *orthographic* changes is therefore the fair test.

## Loop 1 (rule table) on orthographic changes

| Metric | Value |
|---|--:|
| Correctly modernized (matches gold) | 21,197 |
| Missed (left unchanged) | 26,896 |
| Wrong (changed, ≠ gold — usually partial) | 4,379 |
| **Recall** | **40.4 %** |
| **Precision** | **82.9 %** |
| Over-normalizations on tokens the gold *kept* | **102** (0.06 % of kept) |

**Reading:** the rules are **safe but partial** — when they fire they are right
~83 % of the time and almost never damage a word the editors kept (102 cases in
~2 M tokens), but they only cover ~40 % of the orthographic work. Most "wrong"
cases are *partial* normalizations (one change applied, another missing in the
same word), not true errors.

## Biggest gaps — what to add next (top missed gold patterns)

| Pattern | Missed | Example | Documented in *Ret og Skrift* |
|---|--:|---|---|
| `i → j` (diphthongs ei/øi/ai) | 5,293 | deilig→dejlig, Øine→øjne | RP17 |
| `j → ∅` (palatal gj/kj/sj) | 3,625 | gjøre→gøre, skjøn→skøn | RP6 |
| `e → ∅` (silent/ending e) | 3,099 | — | RP4 |
| `d → l / n / ∅` (silent/assimilated d) | 3,913 | — | RP18-19 |
| `de → ∅` (verbal/inflection) | 1,021 | — | RP24 |
| `x → ks` | 537 | voxe→vokse, strax→straks | RP7d |

Every top gap corresponds to a principle already captured in
[`historical_variants.tsv`](../normalisering/rules/historical_variants.tsv) — so
the highest-value next step is to **promote `ei/øi→ej/øj`, palatal `gj/kj→g/k`,
and `x→ks` into the rule table.** These three pattern families alone would lift
recall well past 60 % at high precision.

## Loop 2 (Hunspell over-normalization detector)

Run report-only on all originals, the detector flagged **16 distinct
over-normalization types — every one caused by `R0027 ee → e`** (e.g.
`reel→rel`, the standalone cases the legacy `ee`-preamble work-arounds don't
cover). This independently confirms the static analysis: **`ee→e` is the one
over-aggressive rule** and is the prime candidate for a guard/exception list.
No other rule produced a clear over-normalization across 161 tales.

## Recommendations
1. Add `ei/øi→ej/øj`, palatal `gj/kj→g/k`, and `x→ks` rules (sourced from
   `historical_variants.tsv`) — the largest, best-attested recall wins.
2. Constrain `R0027 ee→e` with a lexical guard / exception list (reel, Allé…).
3. Keep lower-casing and comma/word-split reforms as their own evaluated stages;
   re-run this harness after each rule change to track recall/precision and the
   over-normalization count as a regression gate.
