#### Morphosyntactical Tools for 19th‑Century Danish, with Focus on CLARIN‑DK & DSL

***

### 🧩 CLARIN‑DK Tools

**NLP Tools (CST.dk / CLARIN‑DK)**

* Online interface supporting:
  * Sentence segmentation, tokenization
  * Part‑of‑speech tagging
  * Lemmatisation
  * Named‑entity recognition
  * Word‑frequency extraction
* Accepts TXT, RTF, PDF; outputs zipped annotated files

**Text Tonsorium**

* Workflow manager for TEI‑P5
* Integrates Danish UDPipe (dapipe) + CST NER
* Outputs TEI enriched with morphosyntactic attributes (`@msd`, `<w>`)

**CST’s Brill‑Tagger**

* Rule‑based POS tagger adapted to Danish
* Trained on the PAROLE corpus
* Attains ≈ 97 % accuracy; includes morphological feature assignment

***

### 📚 DSL (Det Danske Sprog‑ og Litteraturselskab)

**ELEXIS‑DK Infrastructure Tools**

* Provides internal-use tools:
  * Corpus tool, Word2Vec statistical models
  * iLEX XML editing system (for DSL‐annotated resources)

**Survey of POS Taggers (DK‑CLARIN WP2.1 report)**

* Comparative study of lexicon‑based vs HMM POS taggers
* Recommends lexicon‑integrated lemmatisation and configurable POS tagging workflows

**CoREST Korpusværktøj (DSL edition)**

* Concordancer integrated with corpus metadata
* Uses annotated POS for corpus exploration (note: outdated)

**ePOS Tagger (design mentioned in WP2.1)**

* Intended to tag TEI with POS + lemma
* Custom workflows with user‑configurable lexicon integration

***

### ⚙️ Summary Table

| Platform      | Tools                          | Features                                                                                                                                                                                                                                                                                                     |
| ------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **CLARIN-DK** | NLP Tools (CST)                | Marker-based tagging (POS, lemma, NER) via web interface                                                 |
|               | Text Tonsorium                 | TEI workflow; TEI‑P5 → enriched `<w @msd>` |
|               | CST Brill‑tagger               | Rule-based POS tagging (\~97 %); PAROLE‑trained                                                                                                |
| **DSL**       | ELEXIS‑DK Corpus & iLEX editor | Lexical analysis, Word2Vec, digital resources                                                             |
|               | POS tagger survey / ePOS       | Emphasises lexicon + typology; integrated lexicon rulebase                                                                                                                                            |
|               | CoREST (archive)               | Concordancing with POS annotations                                                                                                                                                                            |

***

### 💡 Suitability for 19th‑Century Danish

* **Text Tonsorium’s TEI pipeline** supports TEI‑P5 and can be adapted for 19th‑c texts (body‑only extraction + `<w @msd>`)
* **CST Brill‑tagger** has strong Danish morphology capabilities but based on PAROLE (modern). Historical corpus training would enhance it.
* **ePOS / POS workflows from DSL** emphasise lexicon integration (like ODS/DDO), enabling adaptation to historical paradigms.
* **ELEXIS infrastructure** supports rich lexica (including historical ODS linking) usable as lexical grounding.

***

### 🔍 Recommended Approach

Combine:

* **Text Tonsorium** as input/TEI conversion path,
* **CST Brill‑tagger** for rule‑based morpho-syntactic tagging,
* **ELEXIS lexicons** for historical word forms,
* **DSL‑inspired ePOS workflows** for lexicon‑informed tagset customization.

This leverages institutional tools (CLARIN‑DK / DSL) focused on configurable, linguistically grounded morpho‑syntactic processing—well aligned with philological accuracy and 19th‑c Danish needs.Want a prioritized shortlist of tools to integrate directly into your Python pipeline?
