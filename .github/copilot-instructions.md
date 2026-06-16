# Copilot instructions for hca2modernDanish

Purpose: help future Copilot sessions understand how this repo is built, tested, and organized so suggestions and edits are context-aware.

---

1) Build, test, and lint commands (how to run, including single-test examples)

- Primary test suite (end-to-end checks for normalization tooling):
  - From normalisering/tests/:
    bash run_tests.sh
  - To run single checks manually (useful for focused edits):
    - Static cycle detection: python tools/detect_cycles.py ../rules/rules.tsv
    - AWK reference normalization: echo 'Maaneder og Aaret' | awk -v RULES=../rules/rules.tsv -f ../tools/normalize.awk
    - Python rule engine: PYTHONIOENCODING=utf-8 python ../tools/rule_engine.py ../rules/rules.tsv < sample_input.txt
    - Mine candidate rules (single run): python ../tools/mine_rules.py sample_edits.tsv --lexicon modern_lexicon.sample.txt --variants known_variants.sample.tsv --out-dir ./_mineout
    - Weighted edit ranking: python ../tools/weighted_edit_distance.py edit_costs.sample.tsv qvinde kvinde svinde

- Golden-standard evaluation (end-to-end eval against human modernizations):
  cd resources/golden-standard
  python ../../tools/normalisering/evaluate_gold.py ../../golden-standard/original ../../golden-standard/modern \
    --rules ../rules/rules.tsv --lexicon ../../ordbøger/aaTilÅ/ddo_DDO --out ../../golden-standard/eval_results.json

- Notes: there is no centralized build tool. Tests and checks are script-driven (bash, awk, python). The AWK pipeline (tools/normalize.awk) is the canonical runtime reference.

---

2) High-level architecture (big picture)

- Legacy layer: stilark/ — existing XSLT stylesheets (the historical, working pipeline).
- v2 normalization: tools/normalisering/ implements a safer, metadata-rich rule system:
  - rules/: canonical rules table (rules.tsv) + rules.json with provenance and metadata (period, confidence, etc.)
  - tools/: Python + AWK utilities: extract_rules_from_xslt.py, detect_cycles.py (static loop analysis), normalize.awk (AWK runtime with loop guard), rule_engine.py (Python mirror), mine_rules.py (candidate induction), weighted_edit_distance.py (ranking)
  - tests/: end-to-end checks and fixtures; run_tests.sh coordinates AWK + Python checks
- Auxiliary data: ordbøger/ (Hunspell/DDO dictionaries) and golden-standard/ (evaluation gold data and reporting)
- CI: .github/workflows/normalization-eval.yml runs static loop checks and benchmarks on PRs; ISSUE_TEMPLATE/ maps issue types to the rule feedback/workflow described in docs.

---

3) Key conventions and repository patterns (what Copilot should assume)

- rules.tsv is the single source-of-truth for rewrite rules; rules.json provides full metadata. Changes to stilark/ require running extract_rules_from_xslt.py to update rules/.
- The AWK normalizer (tools/normalize.awk) is the canonical runtime for behavior and is used as the oracle in tests. When proposing normalization logic changes, ensure Python rule_engine.py reproduces AWK output.
- Loop safety is critical: any rule edits should pass tools/detect_cycles.py and not trigger the runtime loop guard. CI enforces this.
- Paths in tests are relative (tests expect to be run from normalisering/tests/): prefer using the same relative layout when running scripts locally or from Copilot-driven edits.
- Provenance and metadata fields matter: new rules should include period, confidence, and provenance where applicable (follow rules.schema.json in normalisering/rules/).
- Spell-check / lexicon steps are optional and gated on presence of the DDO Hunspell files and spylls; tests skip those steps cleanly if missing.
- Do not replace AWK reference with a behaviorally different implementation without updating tests/docs and ensuring parity.

---

Files/docs to consult when generating changes or suggestions:
- tools/normalisering/README.md (architecture & quickstart)
- tools/normalisering/docs/*.md (design notes, loop detection, workflow)
- resources/golden-standard/README.md (evaluation command and regression gate)
- .github/workflows/normalization-eval.yml and .github/ISSUE_TEMPLATE/ (CI + feedback workflow)

---

If updates are needed to this instruction file, prefer small, targeted edits that preserve links to the tooling commands above.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
