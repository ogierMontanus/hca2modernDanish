# 04 — Phase 2: Human-guided rule induction & validation

> Learn from human corrections, but only generate transparent, inspectable
> rules. Never directly deploy model-generated changes.

Phase 2 turns the editorial work that already happens (machine output → human
review) into reviewed candidate rules, fully auditable.

## Inputs

* **A** — machine-normalized text (Phase 1 output).
* **B** — human-reviewed text (the `*_final_and_modern.xml` files; oXygen
  track-changes captures the diff).
* **C** — the edit-history repository: `time, editor, before, after`. This is
  effectively a *supervised dataset* and a *versioned training corpus*.

A correction record is just:

```
before <TAB> after <TAB> date <TAB> editor
skiøn      skøn        2024-03-01  AS
skiønne    skønne      2024-03-03  AS
```

`tests/sample_edits.tsv` is a runnable example; the docs below describe how to
generate the real one from track-changes / git history.

## Rule extraction — `mine_rules.py`

For each correction `machine → human` we compute character **alignment**, then
extract each changed segment with one char of left/right **context**:

```
skiøn → skøn        edit: delete 'i'   in context  k_ø
qvinde → kvinde     edit: q → k        in context  ^_v
```

Edits are aggregated across all corrections into candidate rules that record the
supporting examples — so every candidate is traceable back to real editorial
decisions.

## Confidence scoring (four transparent components)

```
confidence = w1·frequency  +  w2·consistency  +  w3·lexical  +  w4·historical
```

* **frequency** — saturating: 1 observation is weak, ~10+ strong.
* **consistency** — of all times `source` was edited, what fraction took *this*
  target? `skiøn/skiønne/skiønhed` all dropping `i` → high.
* **lexical** — is the resulting form in the modern lexicon? (`skøn` ✓ `skøx` ✗)
* **historical** — is the pair already in the variant database?

All weights and inputs are printed; there is no hidden state. Example run:

```bash
python mine_rules.py tests/sample_edits.tsv \
    --lexicon tests/modern_lexicon.sample.txt \
    --variants tests/known_variants.sample.tsv --threshold 0.85
```

## Promotion pipeline (never auto-deploy)

```
human edits → candidate extraction → validation → confidence scoring
            → review queue → APPROVED rule → production
```

* `confidence ≥ threshold` → `candidate_rules.json` (still requires a PR + human
  approval; written with `enabled:false`).
* `confidence < threshold` → `review_queue.json` (uncertainty queue):

```json
{ "status": "review_required", "candidate": "krands → krans", "confidence": 0.61 }
```

Each review item becomes a GitHub issue automatically (see [`03`](03-github-workflow.md)).

## Weighted edit-distance learning — `weighted_edit_distance.py`

The goal is not to minimize raw edit distance, but to *learn which edits are
typical* for historical Danish and make them cheap:

```
qv → kv  cost 0.1      aa → å  cost 0.1      gj → g  cost 0.1
random substitution    cost 1.0
```

```bash
$ python weighted_edit_distance.py tests/edit_costs.sample.tsv qvinde kvinde svinde
0.000   qvinde
0.100   kvinde     ← attested transformation, preferred
1.000   svinde
```

These costs are refined continuously from human corrections (a correction that
keeps recurring lowers the cost of its edit), and are used to *rank* candidate
normalizations — not to apply them.

## Repository learning from edit history

Treat the revision history as a versioned corpus and derive:

* **Rule emergence** — when did an edit first appear?
* **Rule stability** — does it keep being accepted, or get reverted?
* **Rule disagreement** — do different editors choose differently? (the `editor`
  column makes inter-annotator disagreement measurable.)

## Hold-out evaluation

Prefer a *temporal* split over a random 80/20: **older corrections → training,
newest corrections → testing.** This simulates future editorial work and guards
against overfitting to settled cases. Wired into CI in [`03`](03-github-workflow.md).

## Human-in-the-loop for unseen texts

```
raw text → Pass 1 (rules) → Pass 2 (learned candidates) → confidence
         → human review → final approval
```

Editors see suggestions with confidence; high-confidence ones are pre-applied,
low-confidence ones require explicit confirmation:

```
Suggested: kiærlighed → kærlighed    confidence 98%   (auto, revertible)
Suggested: krands → krans            confidence 62%   (needs confirmation)
```

## Interpretability constraint on any ML layer

Any ML output **must** be traceable, or it is rejected:

```json
{
  "prediction": "skøn",
  "confidence": 0.94,
  "supporting_pattern": "iø → ø",
  "similar_examples": ["skiøn", "skiønne", "skiønhed"]
}
```

Black-box predictions that cannot point back to observed edits, known variants,
lexical evidence, or historical sources are not admissible. Masked-change
prediction (`sk[MASK]øn → skøn`) is used **for evaluation only** — "can the model
recover the human correction?" — never as a deployment path. See
[`05`](05-hybrid-roadmap.md).
