# 03 — GitHub feedback: issue → rule, and continuous evaluation

## 10. Structured issue workflow

Three issue forms live in [`../.github/ISSUE_TEMPLATE/`](../../.github/ISSUE_TEMPLATE/):

* **new-variant.yml** — report a historical form and its normalization
  (`historical form / normalized form / source / date / evidence`).
* **incorrect-normalization.yml** — `input / current output / expected output`.
* **missing-rule.yml** — `observed form / expected form / corpus reference`.

Each form uses GitHub *issue forms* (structured YAML fields) so the payload is
machine-parseable — no free-text scraping — and auto-labels the issue
(`variant`, `incorrect`, `missing-rule`).

## 11. Automatic rule-candidate generation

A scheduled GitHub Action (sketched in the workflow file) processes labelled
issues:

```
issue  →  classify (by label/form)  →  extract variant pair (source,target)
       →  validate (lexicon + period + cycle check)
       →  score confidence (reuses mine_rules.py scoring)
       →  open a PR adding the candidate to rules.json
```

Generated proposals carry their provenance:

```json
{
  "id": "R0207",
  "source": "skiøn",
  "target": "skøn",
  "confidence": 0.92,
  "evidence": ["Issue #143", "Issue #188"],
  "enabled": false
}
```

**Human review is mandatory.** Candidates are added with `enabled: false`; a
maintainer flips them to `true` only after the PR passes review + evaluation.
This is the GitHub-side mirror of the Phase 2 promotion gate
([`04`](04-phase2-rule-induction.md)): edits never deploy automatically.

## 12. Continuous evaluation

`../.github/workflows/normalization-eval.yml` runs on every PR and on schedule:

1. **Loop gate** — `detect_cycles.py`; a literal cycle fails the build.
2. **Schema check** — every rule validates against `rules.schema.json`.
3. **Benchmark** — normalize a held-out benchmark corpus and measure
   **precision / recall / F1 / accuracy / loop frequency / unresolved variants**
   against gold human-reviewed output (the `*_final_and_modern.xml` files are the
   natural gold set; older corrections train, newest test — see
   [`04`](04-phase2-rule-induction.md#hold-out-evaluation)).
4. **Regression guard** — a PR that lowers F1 or raises loop frequency is
   flagged on the PR; the offending rule id is named.

The benchmark numbers are written to the job summary so every rule change has an
auditable before/after record.

## Roles & cadence

| Actor | Action |
|---|---|
| Editor / public | files an issue via a form |
| Bot (Action) | classifies, validates, opens candidate PR (`enabled:false`) |
| Maintainer | reviews PR, checks eval, enables rule |
| CI | gates every PR on loops + schema + benchmark |
