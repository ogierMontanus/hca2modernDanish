# 05 — Hybrid rule-based / probabilistic roadmap (point 8)

Rule-based normalization stays the **primary, high-precision** mechanism. Any
probabilistic component is a **ranking / suggestion** layer that must remain
interpretable (see [`04` interpretability constraint](04-phase2-rule-induction.md#interpretability-constraint-on-any-ml-layer)).

## Layering

```
        high precision                      ambiguity resolution
   ┌─────────────────────┐            ┌──────────────────────────┐
   │  rule-based rewrite  │  ──────▶   │  probabilistic ranking   │
   │  (deterministic)     │  candidates│  (suggests, never forces)│
   └─────────────────────┘            └──────────────────────────┘
            │                                      │
            └────────────► human review ◄──────────┘
```

The rule layer decides; the probabilistic layer only orders competing
candidates and flags uncertainty for a human.

## Stages (incremental, each shippable)

| Stage | Mechanism | Interpretable? | Role |
|---|---|---|---|
| 0 (now) | ordered substitution (XSLT) | yes | production |
| 1 | graph rules + loop guard + provenance (this folder) | yes | production |
| 2 | **weighted edit distance** (`weighted_edit_distance.py`) | yes — cost table is data | candidate ranking |
| 3 | **weighted finite-state transducer** compiled from the rule graph | yes — paths are rules | fast, composable rewriting |
| 4 | **noisy-channel** model `P(modern) · P(historical \| modern)` | mostly — channel = weighted edits | rank ambiguous spans |
| 5 | contextual / transformer model | only as evaluator + suggester with `supporting_pattern` | recall booster, never autonomous |

Each stage is additive and reversible; we can stop at any stage and still have a
complete, auditable system.

## Why WFST next (stage 3)
The rule graph already *is* a transducer. Compiling `rules.tsv` to a WFST gives
composition, ambiguity via weighted paths, and linear-time application, while
every accepting path still corresponds to a named rule — provenance survives.
This is the natural bridge from AWK/XSLT to mainstream NLP tooling
(`pynini`/OpenFst, HFST) without giving up auditability.

## Guardrails for the ML layer
* Train/evaluate only on the human-corrected corpus (temporal split, [`04`](04-phase2-rule-induction.md#hold-out-evaluation)).
* Every prediction must emit `supporting_pattern` + `similar_examples`.
* ML may *raise* a candidate's rank or *open a review issue*; it may not write a
  production rule. Promotion always goes through the human gate in [`03`](03-github-workflow.md).
* Masked-change prediction is an **evaluation probe**, not a deployment path.
