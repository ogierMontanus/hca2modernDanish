# 08 — Hunspell spell-check refinement layer

A **report-only** lexical layer that uses the modern Danish **DDO Hunspell
dictionary** ([`../../ordbøger/aaTilÅ/`](../../ordbøger/aaTilÅ/), 632k entries)
to find clear cases where normalization produced a non-word, and proposes
refinements **for human review**. It never edits text and never changes a rule.

Backend: **`spylls`** (pure-Python Hunspell; `pip install spylls`) — no native
deps, identical on Windows/CI, reads the existing `.dic`/`.aff` directly.
Wrapper: [`../tools/danish_lexicon.py`](../tools/danish_lexicon.py) (cached
`known()` / `suggest()`; falls back to a plain word list when spylls/DDO are
absent, so tests run anywhere).

## The precision contract (anti-*Verschlimmbesserung*)

A token is flagged **only** when all three hold:

1. a v1 rule actually **changed** the token, **and**
2. the normalized form is **unknown** to DDO (case-insensitively), **and**
3. **undoing the implicated rule reconstructs a known word.**

Everything else is deliberately *not* flagged:

* unchanged unknown tokens (names, archaisms) — no rule fired;
* changed-but-unknown tokens that no rule-reversal repairs — classified
  `left_alone` (assumed valid low-frequency word / named entity). This is how
  "allow low-frequency words outside the dictionary" is honoured.

We dropped an earlier "Hunspell-suggestion-only" path because it flagged the
place name *Aagaard → Ågård* and proposed the nonsense *Gård* — the exact class
of error this contract forbids. Hunspell suggestions are now only *corroborating*
evidence (they raise confidence 0.8 → 0.9), never the trigger.

## Loop 1 — over-normalization detector

[`../tools/spellcheck_refine.py`](../tools/spellcheck_refine.py) runs the rules
(via [`rule_engine.py`](../tools/rule_engine.py), the Python mirror of
`normalize.awk`) over a corpus and emits:

* `update_proposal.json` / `update_proposal.md` — each flagged token with its
  original, normalized form, suggested fix, **implicated rule id**, occurrences,
  and confidence. Reviewed and approved item-by-item; nothing auto-applies.

```
$ python spellcheck_refine.py corpus.txt --rules ../rules/rules.tsv \
      --lexicon ../../ordbøger/aaTilÅ/ddo_DDO
... flagged 1 clear over-normalization, left 1 unknown-but-plausible alone.
  reel -> rel  suggest reel  [R0027: ee -> e]  conf 0.90
```

## Loop 2 — lexical scoring + over-aggressive-rule evidence

* `mine_rules.py --lexicon …/ddo_DDO` now uses DDO as the real backend for the
  `lexical_ok` confidence component ([`04`](04-phase2-rule-induction.md)).
* `spellcheck_refine.py` aggregates flags **per rule** ("over-aggressive rule
  evidence"): a rule that repeatedly turns known words into non-words across the
  corpus is surfaced for the Loop-2 review queue → GitHub issue. (`R0027 ee→e`,
  whose work-arounds [`02`](02-loop-detection-and-runtime.md) already flagged
  statically, is the textbook example.)

## CI

The reference test-suite runs a spell-check smoke test **only if spylls and the
DDO dictionary are present**; otherwise it skips (CI stays green without the
large dictionary). The proposal is a report; it does not gate merges.
