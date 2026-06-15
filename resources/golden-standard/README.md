# golden-standard/

A fixed evaluation set for the v2 normalization pipeline: 161 H.C. Andersen
tales in two parallel versions.

```
golden-standard/
  original/   <tale>.xml          historical orthography (input)
  modern/     <tale>.xml          human-modernized gold (target; = *_modern.xml)
  REPORT.md                       1-page findings of the latest evaluation
  eval_results.json               full machine-readable metrics
```

Both versions come from `sdu_gitlab/sv-data/data/works` (CC BY 4.0): `modern/`
is the `*_modern.xml` editor output; `original/` is the same-named base file.

Evaluate (Loop 1 rules + Loop 2 Hunspell) against the gold:

```bash
cd normalisering/tools
python evaluate_gold.py ../../golden-standard/original ../../golden-standard/modern \
    --rules ../rules/rules.tsv --lexicon ../../ordbøger/aaTilÅ/ddo_DDO \
    --out ../../golden-standard/eval_results.json
```

See [REPORT.md](REPORT.md). Headline: on the orthographic changes the rules are
responsible for, Loop 1 reaches **40 % recall / 83 % precision** with only 102
over-normalizations across ~2 M tokens; Loop 2 confirms `ee→e` as the single
over-aggressive rule. Re-run after any rule change as a regression gate.
