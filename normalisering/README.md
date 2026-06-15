# `normalisering/` — Historical Danish orthography normalization, v2

A redesign of the HCA orthographic normalization pipeline that keeps the
rule-based transparency of the current XSLT system while adding **loop safety,
period awareness, provenance, lexical validation, a GitHub feedback loop, and a
human-guided rule-induction layer (Phase 2)**.

> **Design principle.** Learn from human corrections, but only ever generate
> *transparent, inspectable rules*. Never deploy a model-generated change
> directly to production.

This folder is **additive**: the legacy stylesheets under
[`../stilark/`](../stilark/) keep working unchanged. v2 starts from the *same*
rules (extracted automatically) and layers safety + tooling on top.

## Why

The current pipeline ([`DSL-HCAC_replaceOriginal2ModernXSLT3.0.xsl`](../stilark/DSL-HCAC_replaceOriginal2ModernXSLT3.0.xsl))
is an ordered list of `<pattern><old>/<new></pattern>` substitutions. It works,
but:

* rule interactions can create **rewrite loops** (`aa → å`, `å → aa`; or
  indirect `A → B → C → A`);
* the `ee → e` family is guarded by a fragile hand-written *preamble* of
  `leet → leeet` style work-arounds — exactly the re-trigger hazard our static
  analyzer now flags automatically (13 of them in the current table);
* rules carry no period, confidence, or provenance metadata;
* there is no structured way for editors / the public to report errors and have
  them become reviewed rules.

## Layout

```
normalisering/
  rules/
    rules.schema.json     JSON Schema for one rewrite rule
    rules.tsv             canonical rule table (AWK-friendly, source of truth)
    rules.json            same rules with full provenance metadata
    historical_variants.tsv  142 attested historical→modern pairs (Ret og Skrift)
  tools/
    extract_rules_from_xslt.py   legacy XSLT pattern table  -> rules.{tsv,json}
    extract_ordlister.py         Ret og Skrift (Bind 2) -> historical_variants.tsv
    detect_cycles.py             static loop analysis (CI gate)
    normalize.awk                reference normalizer + runtime loop guard
    mine_rules.py                Phase 2: induce candidate rules from corrections
    weighted_edit_distance.py    learned edit costs for candidate ranking
    rule_engine.py               Python mirror of normalize.awk (shared by tools)
    danish_lexicon.py            DDO Hunspell (spylls) wrapper, cached
    spellcheck_refine.py         report-only over-normalization detector (Loop 1+2)
  tests/
    run_tests.sh          end-to-end checks for all of the above
    *.sample.*            small fixtures
  docs/
    01-architecture.md            improved architecture (Phase 1, points 1–7,9)
    02-loop-detection-and-runtime.md   loop detection + runtime prevention
    03-github-workflow.md         issue → rule workflow + continuous evaluation
    04-phase2-rule-induction.md   human-guided rule induction (Phase 2)
    05-hybrid-roadmap.md          rule-based ⇄ probabilistic roadmap (interpretable)
    06-data-structures.md         data structures for AWK + future NLP migration
../.github/
    ISSUE_TEMPLATE/               new-variant / incorrect-normalization / missing-rule
    workflows/normalization-eval.yml   loop gate + benchmark eval on every PR
```

## Quickstart

```bash
cd normalisering/tools

# 1. (Re)build the canonical rule table from the legacy stylesheet
python extract_rules_from_xslt.py \
    ../../stilark/DSL-HCAC_replaceOriginal2ModernXSLT3.0.xsl --out-dir ../rules

# 2. Static loop analysis (non-zero exit on literal cycles -> CI gate)
python detect_cycles.py ../rules/rules.tsv

# 3. Normalize text with provenance + runtime loop protection
echo 'Maaneder og Aaret; Kaffeen og Photographi' \
  | awk -v RULES=../rules/rules.tsv -v TRACE=1 -f normalize.awk
# -> Måneder og Året; caféen og Fotografi  # rules: R0033,R0034,...

# 4. Phase 2: induce candidate rules from human corrections
python mine_rules.py ../tests/sample_edits.tsv \
    --lexicon ../tests/modern_lexicon.sample.txt \
    --variants ../tests/known_variants.sample.tsv

# 5. Run the whole test suite
cd ../tests && bash run_tests.sh
```

## Requirements coverage

| Spec requirement | Where |
|---|---|
| 1. Rules as a directed graph | `rules/`, [`docs/01`](docs/01-architecture.md), [`docs/06`](docs/06-data-structures.md) |
| 2. Automatic loop detection | `tools/detect_cycles.py`, [`docs/02`](docs/02-loop-detection-and-runtime.md) |
| 3. Runtime loop protection | `tools/normalize.awk`, [`docs/02`](docs/02-loop-detection-and-runtime.md) |
| 4. Rule prioritization | `confidence` in schema, [`docs/01`](docs/01-architecture.md) |
| 5. Century-aware processing | `period` in schema, [`docs/01`](docs/01-architecture.md) |
| 6. Lexicon-assisted validation | `mine_rules.py --lexicon`, [`docs/01`](docs/01-architecture.md) |
| 7. Named entity protection | `protect_entities`, [`docs/01`](docs/01-architecture.md) |
| 8. Probabilistic layer (optional) | [`docs/05`](docs/05-hybrid-roadmap.md) |
| 9. Explainability | `normalize.awk` TRACE, candidate `supporting_examples` |
| 10. GitHub feedback integration | `../.github/ISSUE_TEMPLATE/`, [`docs/03`](docs/03-github-workflow.md) |
| 11. Automatic rule-candidate generation | [`docs/03`](docs/03-github-workflow.md), `mine_rules.py` |
| 12. Continuous evaluation | `../.github/workflows/normalization-eval.yml`, [`docs/03`](docs/03-github-workflow.md) |
| Phase 2: rule induction & weighted edits | `mine_rules.py`, `weighted_edit_distance.py`, [`docs/04`](docs/04-phase2-rule-induction.md) |

## Reference resources

* **Thesis — development of Danish orthography:** Henrik Galberg Jacobsen,
  *Ret og Skrift. Officiel dansk retskrivning 1739–2005*, Bind 1–2, SDU 2010.
  Local: [`../ortography-history/`](../ortography-history/) (PDFs, not committed).
  Bind 2 = *Ordlister*; see [`docs/07`](docs/07-historical-data.md) and the
  extracted [`rules/historical_variants.tsv`](rules/historical_variants.tsv).
* **Orthography since 1892 (living resource):** *Retskrivningen gennem tiderne*,
  Dansk Sprognævn — <https://rohist.dsn.dk/#om-rohist>
* Editorial guidelines: [`../retningslinjer/hcandersenDK_retningslinjer_modernisering.pdf`](../retningslinjer/hcandersenDK_retningslinjer_modernisering.pdf)
* **Modern Danish Hunspell dictionary (DDO):** [`../ordbøger/aaTilÅ/`](../ordbøger/aaTilÅ/)
  (`ddo_DDO.dic` / `ddo_DDO.aff`) — for the planned lexical spell-check layer.
