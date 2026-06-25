# Resource: hca-tales-segmented

**Repo:** `c:\Users\nh\Documents\GitHub\hca-tales-segmented`  
**Reference:** Bjerring-Hansen & Conroy (forthcoming), "Guldet i guldalderen og T'et i GPT"

## What the corpus is

161 HCA tales (1830-1873) pre-segmented into **14,240 sentences** using
NLTK `sent_tokenize()` on plain-text exports. Each sentence row carries:

| Column | Content |
|--------|---------|
| `eventyr` | Tale slug (e.g. `aarets-historie`) — matches filenames in `source/originalDanish/` |
| `saetning` | Sentence text in **original old Danish orthography** (pre-Loop-1) |
| `kategori` | Zero-shot classification label (research-specific) |
| `aarstal` | Publication year |

Two CSV files exist, covering the same segmentation with different labels:

| File | Tales | Segments | Categories |
|------|-------|----------|------------|
| `HCA_zeroshot_fattigdom_renset.csv` | 161 | 14,242 | Fattigdom / Ikke-relevante |
| `HCA_okonomi_zeroshot_renset.csv` | 159 | 14,240 | 5 economic categories |

Average: ~88 sentences per tale. Year range: 1830-1873.

## Relation to hca2modernDanish

The `eventyr` slugs directly match the XML filenames in this repo:

```
hca-tales-segmented:   aarets-historie   (sætning column)
hca2modernDanish:      source/originalDanish/aarets-historie.xml
                       input/aarets-historie.xml
                       tools/normalisering/output/loop1/aarets-historie.xml
```

The sentence text is from the same underlying source as the XML files, in
the same pre-normalization spelling. This means:
- Loop 1 rules can be applied sentence-by-sentence to each `saetning` value
- The resulting modern sentences can be fed to spaCy with reliable boundaries
- Sentence context is correct for verb-plural detection and NE disambiguation

## Why sentence boundaries matter

The verb plural tagger (`tag_verb_plural.py`) currently splits XML text into
sentences using a heuristic regex. The segmented CSV replaces that with
NLTK-based boundaries, which correctly handle:
- Dialogue nested inside longer sentences
- Sentences split across XML paragraph breaks
- Short fragments (interjections, single words) as distinct units

## Pipeline integration

See `run.py --pos` and `tools/normalisering/tools/tag_pos.py`.

When `--segmented PATH` is supplied, sentences are taken from the CSV rather
than extracted from the XML, so boundary quality improves. The tool applies
Loop 1 normalization to each raw sentence before running spaCy, so the
tagger sees modern-looking text.

## Caveats

- NLTK `sent_tokenize()` (Danish punkt model) occasionally mis-splits on
  abbreviations, direct speech markers (`»«`), and mid-sentence semicolons.
  Rough error rate: ~2-3% of boundaries.
- The CSV contains plain text; XML markup (italics, verse lines, speaker
  labels) is not reflected in the sentence strings.
- Two tales are absent from the økonomi CSV (159 vs 161 in fattigdom); use
  the fattigdom CSV when full coverage is needed.
