# Task: Automated Modernization of H.C. Andersen's Danish (1830–1873 → Modern Danish)

**Date:** 2026-08-12
**Repository:** `hca2modernDanish`

## 1. What this project does

H.C. Andersen's tales were published in 19th-century Danish orthography
(e.g. `Kjøbenhavn`, `deilig`, `Thee`, `kunde`). This project builds an
automated pipeline that converts that historical spelling into modern
Danish orthography, close to what a human editor would produce, while
flagging cases that need manual review rather than silently guessing.

The pipeline (`run.py`) runs each tale through four stages:

1. **Loop 1 — `normalize_xml.py`**: rule-based orthographic normalization
   driven by `tools/normalisering/rules/rules.tsv` (currently 130 rules,
   e.g. `ct→kt`, `Thee→te`), with named entities protected from rewriting
   via `tools/normalisering/rules/named_entities.txt` (938 entries).
2. **Verb-plural tagging — `tag_verb_plural.py`**: detects finite plural
   verb forms (`de vare`, `de kunde`) that need modernizing to singular
   agreement (`de var`, `de kunne`); output is a trace file for human
   review, not an automatic rewrite.
3. **PoS tagging — `tag_pos.py`** (opt-in, `--pos`): spaCy part-of-speech
   tagging per sentence, optionally against pre-segmented sentence
   boundaries (see §3).
4. **Loop 2 — `spellcheck_refine.py`**: runs the DDO Hunspell dictionary
   over Loop 1's output to catch **over-normalization** (rules that fired
   when they shouldn't have), producing a human-review report.

## 2. Data input

- **`input/`** — 167 XML files, one per H.C. Andersen tale/text, in
  original 19th-century orthography. This is the working set the pipeline
  runs on by default (`python run.py` processes all of them).
- **`source/`** — canonical original-orthography source XML
  (`source/originalDanish/`), the basis `input/` is derived from.
- **`resources/golden-standard/`** — fixed evaluation corpus: the same 161
  tales in two parallel versions, `original/` (historical) and `modern/`
  (human-modernized editor output, `*_modern.xml`), sourced from
  `sv-data/data/works` (CC BY 4.0). Used as ground truth to score the
  pipeline (`evaluate_gold.py`), not as pipeline input.
- **`editorial/`** — ~340 tracked-changes XML files (`*_corrected_fgj.xml`,
  organized by volume `bd. 1/2/3 gennemset af FGJ`) capturing a human
  editor's actual corrections. Mined for real-world modernization patterns
  (`resources/editorial-analysis/`, 61,536 recorded changes) that feed
  back into new Loop 1 rules.
- **`output/`** and `tools/normalisering/output/loop1/` /
  `.../loop2/` — pipeline results: normalized XML, change traces,
  verb-plural candidate lists, PoS tags, and over-normalization reports.

## 3. Resources: dictionaries and reference corpora

All under `resources/`:

| Resource | Path | Role |
|---|---|---|
| **DDO Hunspell dictionary** | `resources/dictionaries/ddo/ddo_DDO.{dic,aff,tdi}` | *Den Danske Ordbog* — 632,735 modern Danish word forms; used by Loop 2 to detect over-normalization (words Loop 1 broke that aren't valid modern Danish) |
| **ODS lemma list** | `resources/dictionaries/ods-lemma/ods_lemmas_extracted.tsv` | *Ordbog over det danske Sprog* — 162,978 lemmas with part-of-speech, used for lemma lookup/tagging of older word forms not in DDO |
| **Ret og Skrift, Bind 2** | `resources/dictionaries/RetogSkriftBind2_samlet.pdf` | Reference volume on Danish orthographic history/reform (`RP…` rule citations in the golden-standard report trace back to this) |
| **Frequency/replacement worksheet** | `resources/dictionaries/frekvens_163-eventyr_førsteudgaver_short_replacements.xlsx` | Word-frequency-ranked candidate replacements across 163 first-edition tales |
| **Corpora** (`resources/corpora/`) | `ordlisteXML*.xml`, `compounds*.xml`, `wordlist_ne_scored*.tsv/csv`, CATMA export | Wordlists (alphabetical/frequency-sorted), named-entity/compound lists, and a CATMA query export used to build and score the named-entity and rule tables |
| **Editorial guidelines (PDF)** | `resources/editorial-guidelines/1700/`, `.../1800/` | Institutional modernization guidelines (LHS orthographic guidelines; hcandersenDK and DSL modernization principles) that Loop 1 rules are meant to encode |
| **hca-tales-segmented corpus** | external repo, documented in `docs/resources/hca-tales-segmented.md` | 161 tales pre-segmented into 14,240 sentences (NLTK `sent_tokenize`), original orthography; supplies reliable sentence boundaries via `run.py --segmented PATH` for verb-plural/PoS tagging |
| **Golden standard** | `resources/golden-standard/` | 161 original/modern XML pairs + `eval_results.json` + `REPORT.md`; the evaluation ground truth (not a dictionary, but the resource the rule table is scored against) |

## 4. Current status (from `resources/golden-standard/REPORT.md`, 2026-06-14 eval)

On the 52,472 orthographic gold changes (excluding case-only and structural
changes, which are separate pipeline stages):

- **Recall 40.4% / Precision 82.9%** with the 46→130-rule Loop 1 table
  (recall since improved to ~63.1% per commit history).
- Only 102 over-normalizations across ~2M tokens; Loop 2's Hunspell check
  traced essentially all of them to a single overly aggressive rule
  (`R0027 ee→e`).
- Biggest remaining gaps: `ei/øi→ej/øj` diphthongs, palatal `gj/kj→g/k`,
  silent/assimilated `e`/`d`, and `x→ks` — all attested in
  `historical_variants.tsv` and *Ret og Skrift*, not yet promoted into
  `rules.tsv`.
