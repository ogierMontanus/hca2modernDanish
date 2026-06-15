# 06 — Data structures (AWK now, NLP-framework later)

The same logical rule record must be cheap to process in AWK *today* and easy to
migrate to richer NLP tooling *later*. We achieve that with two synchronized
serializations plus a JSON Schema contract.

## The rule record

Authoritative schema: [`../rules/rules.schema.json`](../rules/rules.schema.json).

### TSV (AWK-friendly, source of truth for the runtime)
```
#id     source  target  confidence  period_from  period_to  enabled
R0033   aa      å       1.0                                  1
R0046    ere     er     1.0                                  1
```
* One rule per line, tab-separated → `split($0, f, "\t")` in AWK, no parser.
* **Whitespace in `source`/`target` is significant** (many rules key on a
  leading/trailing space, e.g. ` ere ` → ` er `). Literal tabs are escaped `\t`;
  spaces are preserved verbatim. Never `gsub`-trim these columns.
* `period_from`/`period_to` empty = all periods; `enabled` is `1`/`0`.

### JSON (review-friendly, full metadata)
```json
{ "id":"R0033","source":"aa","target":"å","confidence":1.0,
  "evidence":["legacy:...xsl"],"period":null,
  "protect_entities":true,"enabled":true }
```
`evidence[]`, `protect_entities`, and structured `period` live here; the TSV is a
projection. `extract_rules_from_xslt.py` regenerates both from the legacy table;
a future `sync_rules.py` keeps TSV⇄JSON consistent (the JSON is canonical for
metadata, the TSV for the runtime columns).

## Runtime structures (in `normalize.awk`)
* `rid[k], src[k], tgt[k], conf[k]` — parallel arrays indexed by rule order.
* `seen[form]` — associative set = the per-token state history (loop guard).
* `applied` — ordered list of fired rule ids = the provenance trace.

These are exactly the "character arrays / string replacement tables" of the
current design, but with an explicit history set and provenance list added.

## Phase 2 structures
* **edit pairs**: `before, after, date, editor` (TSV) — the supervised dataset.
* **candidate rule**: `{source, target, observations, consistency, top_contexts,
  lexical_ok, historical_evidence, confidence, supporting_examples[]}`.
* **review item**: `{status, candidate, confidence, observations,
  supporting_examples[]}`.
* **edit-cost table**: `source, target, cost` (TSV) for weighted edit distance.

## Migration path
| Need | Now | Later |
|---|---|---|
| storage | TSV + JSON | SQLite / Parquet (same columns) |
| matching | AWK `index()` literal | WFST (`pynini`/HFST) compiled from same TSV |
| validation | JSON Schema | + RNG/Schematron in the TEI toolchain |
| scoring | `mine_rules.py` (pure Python stdlib) | scikit-learn / sequence models, same features |
| provenance | `# rules: R0033,...` | TEI `<app>/<rdg>` or standoff annotation |

Because every layer reads the *same flat columns*, no migration requires
re-encoding the linguistic data — only swapping the engine that consumes it. The
JSON Schema is the stable contract across all of them.
