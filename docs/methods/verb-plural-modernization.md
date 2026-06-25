# Method: Verb Plural Modernization (finite plural → modern invariant form)

## Background

Pre-1870 Danish maintained **number agreement** in present-tense verbs. The plural
present (subjects *vi / de / I*) ended in **`-e`** — identical to the infinitive for
most verb classes. Modern Danish uses the same `-er` form for all persons and numbers.

This method targets the change:  
**finite plural present `elske` → modern `elsker`** (subject `de/vi/I`).

## Grammar of old Danish finite plural forms

| Class | Infinitive | Sg. present | **Pl. present (old)** | Modern target |
|---|---|---|---|---|
| Weak | `elske` | `elsker` | **`elske`** | `elsker` |
| Strong | `synge` | `synger` | **`synge`** | `synger` |
| Irregular `at være` | — | `er` | **`ere`** | `er` |
| Irregular `at have` | `have` | `har` | **`have`** | `har` |
| Irregular `at vide` | `vide` | `ved` | **`vide`** | `ved` |

**Core ambiguity**: for regular verbs, plural present = infinitive in form.
A simple string rule cannot distinguish `de synge` (finite) from `at synge` / `kan synge`
(infinitive). Sentence-aware disambiguation is required.

## Tiered implementation

### Tier 1 — Safe rules (zero NLP cost)

Irregular verbs whose plural form **differs** from their infinitive can be handled as
Loop 1 rules. Currently only one safe case:

```
ere → er    # plural of "er"; infinitive is "at være" — no collision
```

Add as R0131 in `rules/rules.tsv`. All other irregular plurals (`have`, `vide`, etc.)
equal their infinitive and require context.

### Tier 2 — Context-window pattern (O(n), no model)

Scan tokenized text. For each verb token ending in `-e`:

**Finite signal** (change `-e → -er`):  
- Immediately preceded by plural subject pronoun `vi / de / I` within ≤ 5 tokens,
  with no intervening `at` or modal verb.
- Confidence: **high** for `[vi|de|I] ADV* VERB-e` pattern.

**Infinitive signal** (skip):  
- Preceded within ≤ 3 tokens by `at` (infinitive marker).
- Preceded within ≤ 3 tokens by a modal: `kan`, `vil`, `skal`, `må`, `bør`,
  `lad`, `lader`, `burde`, `tør`.
- Preceded by another infinitive-governing verb: `prøve at`, `begynde at`, etc.

This tier covers the most frequent, clear-cut patterns (~70–80% of cases) with no
model dependency.

### Tier 3 — spaCy `da_core_news_lg` morphological tagging

Run **after Loop 1 normalization** so that texts are closer to modern Danish (improving
model accuracy on historical forms).

```python
import spacy
nlp = spacy.load("da_core_news_lg")

for sent in doc.sents:
    for token in sent:
        morph = token.morph
        if (morph.get("VerbForm") == ["Fin"]
                and morph.get("Number")  == ["Plur"]
                and token.text.endswith("e")):
            candidate = token.text[:-1] + "er"
            # proceed to Tier 4 validation
```

Model: `da_core_news_lg` (spaCy 3.8, Danish, installed via `python -m spacy download da_core_news_lg`).  
Token cost: single forward pass per document; efficient for batch processing.

**Limitation**: model trained on modern Danish. Historical forms not yet normalized
by Loop 1 (rare words, irregular verbs) may receive incorrect morphological tags.
Mitigation: apply DDO gate (Tier 4) before accepting any change.

### Tier 4 — DDO validation gate

Before writing any `VERB-e → VERB-er` change, confirm `VERB-er` exists in DDO
(`resources/dictionaries/aaTilÅ/ddo_DDO.dic`). This rejects:

- Non-verb `-e` words accidentally tagged as finite verbs.
- Irregular verbs where modern form is NOT `stem + er` (e.g., `have → har`,
  `vide → ved`). For these, a separate lookup in an irregular verb table is needed.

## Irregular verb table (most common HCA cases)

| Old plural present | Infinitive (= same form) | Modern finite | Rule safe? |
|---|---|---|---|
| `ere` | `være` (different) | `er` | Yes — Tier 1 |
| `have` | `have` | `har` | No — context only |
| `vide` | `vide` | `ved` | No — context only |
| `gjøre` / `gøre` | `gøre` | `gør` | No — context only |
| `kunne` | `kunne` | `kan` | No — context only |
| `ville` | `ville` | `vil` | No — context only |
| `skulle` | `skulle` | `skal` | No — context only |
| `måtte` | `måtte` | `må` | No — context only |
| `turde` | `turde` | `tør` | No — context only |
| `stode` | `stå` (different) | `stod` | Past tense, separate issue |

## Pipeline integration

The recommended insertion point is **between Loop 1 and Loop 2**:

```
Loop 1 (rule_engine.py, spelling rules)
         |
         +--[optional] tag_pos.py  (PoS + dep-parse, see below)
         |
[NEW] tag_verb_plural.py  <-- this method
         |
Loop 2 (Hunspell spell-check)
```

Input: Loop 1 XML output (`output/loop1/*.xml`).  
Output: `.verb-plural.tsv` trace of candidates for human review.

### Sentence segmentation: hca-tales-segmented

The verb plural tagger needs reliable sentence boundaries to constrain the
context window. The `hca-tales-segmented` corpus (see
`docs/resources/hca-tales-segmented.md`) provides NLTK-pre-segmented
sentences for all 161 tales.

When `run.py --pos --segmented PATH` is used, `tag_verb_plural.py` and
`tag_pos.py` receive proper sentence boundaries rather than relying on the
XML paragraph structure. This:
- Eliminates false window matches that span sentence boundaries
- Gives spaCy correctly-bounded input (improving dep-parse quality)
- Enables per-sentence PoS output aligned to the segmented corpus

### PoS tagging option

`tag_pos.py` is an optional post-Loop-1 step activated by `run.py --pos`.
It applies spaCy `da_core_news_lg` to normalized (Loop 1) sentences and
outputs a TSV with token-level PoS, lemma, dependency, and morphology.
This output feeds the adj/verb border disambiguation deferred from Step 4c.

## Human review requirement

As with all pipeline changes, **no verb modification enters production without human
verification**. The script produces a diff/trace file, not a silent in-place edit.
The editorial team reviews the trace before merging into `2026-input/`.

## Sample output (i-jurabjergene, 1869)

See `docs/methods/verb-plural-sample-jurabjergene.txt` for annotated findings.

---

*Method developed 2026-06. Implements grammar described in §3.2 of DSL modernization
guidelines and the 1947/1948 spelling reform abolishing number agreement in verbs.*
