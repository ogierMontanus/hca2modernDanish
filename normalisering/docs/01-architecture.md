# 01 — Improved normalization architecture (Phase 1)

## Pipeline overview

```
Historical text (TEI/XML or plain)
        │
        ▼
[1] Tokenize + carry period metadata        (from @when / sourceDesc dates)
        │
        ▼
[2] Named-entity protection                  freeze persons/places/works
        │
        ▼
[3] Rule selection                           enabled ∧ period-valid rules
        │
        ▼
[4] Rule-based rewriting  ◄── runtime loop guard (seen-state set)
        │                     records applied rule ids (provenance)
        ▼
[5] Lexical validation + candidate ranking   prefer known words / higher confidence
        │
        ▼
Normalized text + provenance trace
```

Stages [2]–[5] are new; [4] reimplements the legacy substitution semantics with
a safety guard. The **rule table is the single source of truth** and is shared
by the XSLT production path and the AWK reference path.

## 1. Rules as a directed graph

Each rule is a typed record (see [`../rules/rules.schema.json`](../rules/rules.schema.json)):

```json
{
  "id": "R0033",
  "source": "aa",
  "target": "å",
  "confidence": 1.0,
  "evidence": ["legacy:DSL-HCAC_replaceOriginal2ModernXSLT3.0.xsl"],
  "period": null,
  "protect_entities": true,
  "enabled": true
}
```

Viewing the table as a graph (`source → target`) gives us, for free:
dependency analysis, **cycle detection** (point 2), rule provenance, and
explainability. The legacy ordered list is just a topological *traversal* of
this graph; making the graph explicit is what lets us reason about it.

Two serializations, same records:

* `rules.tsv` — column-oriented, the format `normalize.awk` and any future AWK
  stage read directly (no XML/JSON parser needed in AWK);
* `rules.json` — full metadata, the format tools and reviewers edit.

`extract_rules_from_xslt.py` keeps them in sync with the legacy stylesheet.

## 4. Rule prioritization

`confidence ∈ [0,1]` plus `evidence[]` rank competing rewrites. When two rules
could apply to the same span, the higher-confidence rule wins; ties break toward
the rule whose output is a **known word** (point 6). Hand-curated authoritative
rules are `1.0`; induced candidates (Phase 2) carry their computed score and are
*never* auto-promoted (see [`04`](04-phase2-rule-induction.md)).

## 5. Century-aware processing

`period: {from, to}` gates a rule by the source text's date. A rule valid only
before the 1872 reform is expressed as `{"to": 1872}`; a rule for 1850–1899 as
`{"from": 1850, "to": 1899}`. The driver reads the date from the TEI header
(`sourceDesc//date`, `@when`) and activates only rules whose window contains it.
`null` = all periods (the safe default for the current hand-curated set).

This prevents anachronistic normalization (e.g. applying a late-19th-century
convention to an 1835 first edition).

## 6. Lexicon-assisted validation

After rewriting, candidate forms are checked against:

* a **modern Danish lexicon** (e.g. RO/DSL word list),
* a **historical lexicon** (attested period forms),
* the **named-entity inventory**.

Ranking rule, all else equal: `known word > unknown word`. In Phase 2 this is an
explicit confidence component (`lexical_ok`); in Phase 1 it is a *tie-breaker
and a warning signal* — a rewrite that turns a known word into an unknown one is
surfaced for review rather than silently accepted.

## 7. Named-entity protection

Order matters: **NER → entity protection → orthographic normalization.**
Entities (persons, places, institutions, work titles) are frozen before any
rule runs and thawed afterwards, so `Huus` → `hus` does **not** also rewrite the
place name *Huusby* or a quoted work title. Rules with `protect_entities: true`
(the default) are suppressed inside frozen spans; a rule may opt out only with
explicit review. In TEI input, existing `<persName>/<placeName>/<rs>/<title>`
markup already provides the entity spans.

## 9. Explainability

Every normalization is traceable to the rules that produced it. The AWK
reference emits, per line:

```
Måneder og Året  # rules: R0033,R0034
```

and the structured form is:

```json
{
  "original": "Aaret",
  "normalized": "Året",
  "rules_applied": ["R0034: Aa → Å"]
}
```

No rewrite can occur that is not attributable to a listed rule — this is the
non-negotiable property that keeps the system **scholarly auditable**.

See [`02`](02-loop-detection-and-runtime.md) for loop detection/prevention,
[`03`](03-github-workflow.md) for the feedback loop, and
[`06`](06-data-structures.md) for the data structures and AWK/NLP migration path.
