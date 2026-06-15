# XSLT Scenario Integration Report

**Date:** 2026-06-14 · **Scenario:** `stilark/2023-08-10_allStepsInOne.scenarios`  
**Test file:** `2026-input/i-jurabjergene.xml` · **Rules:** 114 (up from 63 pre-integration)

---

## 1. What the XSLT scenario does

The oXygen scenario chains **9 stylesheets** in sequence:

| Step | Stylesheet | Function |
|------|-----------|---------|
| 1 | `SVremoveItalics.xsl` | Remove italic `<hi>` wrappers (italicised foreign words/titles) |
| 2 | `DSL-HCAC_toLowerCase.xsl` | Lowercase all body text **except** pronouns (De, I…) and 888 listed proper nouns |
| 3 | `DSL-HCAC_Original2Modern_step1.xsl` | ~300 orthographic substitution patterns |
| 4 | `DSL-HCAC_toLowerCase2.xsl` | Re-capitalise sentence-initial letter (after `.?!:`) |
| 5–9 | `DSL-HCAC_toLowerCase3–7.xsl` | Additional lowercasing refinements (titles, post-comma capitalisation, etc.) |

Loop 1 (`normalize_xml.py`) corresponds to **step 3** only: it applies orthographic substitution rules to body-text nodes while leaving markup, teiHeader, and now named entities untouched.

---

## 2. Key findings from XSLT analysis

### 2a. Named-entity strategy
`DSL-HCAC_toLowerCase.xsl` uses `xsl:analyze-string` with a regex listing **888 proper nouns** (Schweiz, Heiberg, Reitzel, Meiringen, Sophie, Raphael…). These are kept in their original case while everything else is lowercased. This is a **separate concern** from orthographic substitution: the toLowerCase stylesheet runs first, and the proper nouns still enter step 3 with their original spellings.

**Critical gap found:** The toLowerCase whitelist protects names from lowercasing but **not** from orthographic rules. `Schweiz` enters step 3 with its `ei` intact, and the `ei→ej` rule (R0047) would produce `Schwejz` — both in the XSLT pipeline and in our Loop 1. This is a bug shared by both implementations, not a v2-specific regression.

### 2b. Preamble/postludium guards in the XSLT
The XSLT uses an asterisk-trick to protect foreign names from generic rules:
```
meiringen → me*iringen   (preamble)
ei → ej                  (main rule)
e*i → ei                 (postludium / restore)
```
The XSLT guards for `ei` protect: `ein`, `freia`, `meiringen`, `heiberg`, `heim`, `lein`, `peiter`, `seid`, `wei…`, but **not `schweiz`**. This confirms `Schwejz` is a bug in the production XSLT too.

### 2c. `ph→f` scope in the XSLT
The XSLT uses **space-prefixed** pattern `" ph" → " f"` for word-initial lowercase `ph`, complemented by specific mid-word guards (`raph→raf`, `soph→sof`, `elephant→elefant`). This avoids corrupting Danish prefix compounds like `ophæve` (op + hæve), which contain `ph` across a morpheme boundary — a generic `ph→f` would produce the erroneous `ofhæve`.

### 2d. Patterns in XSLT not yet in Loop 1 (before integration)
Analysis of `DSL-HCAC_Original2Modern_step1.xsl` identified ~250 patterns across ~20 linguistic categories. The main systematic groups absent from the 63-rule table: silent-e verb forms (`døer→dør`, `moer→mor`…), vowel deduplication (`ii→i`), silent-d nouns (`dands→dans`, `grændse→grænse`…), e/æ alternations (`flesk→flæsk`, `neppe→næppe`…), and specific word fixes (`allene→alene`, `linie→linje`…).

---

## 3. Changes implemented

### 3a. Named-entity protection layer (new)
- **`normalisering/rules/named_entities.txt`** — 888 proper nouns extracted from `DSL-HCAC_toLowerCase.xsl`, sorted longest-first.
- **`normalize_xml.py`** — before normalizing each text segment, named-entity occurrences are replaced with NUL-delimited placeholders (`\x000\x00`, `\x001\x00`…); after normalization the originals are restored. This prevents rules like `ei→ej` and ` ph→ f` from corrupting place-names.
- Result on test file: **33 entity spans protected** per run. `Schweiz` and `Schweizergrændsen` are now correctly preserved (`Schweizergrænsen` in output — the Danish suffix `grændse→grænse` still fires on the non-entity part of the compound).

### 3b. `ph→f` (R0065) — changed to word-initial form
Changed R0065 source from `ph` to ` ph` (space-prefixed), mirroring the XSLT exactly. Added R0066 `elephant→elefant` as the XSLT's specific guard for a word where mid-word `ph` cannot be caught by the space prefix. Combined with existing R0030 (`Ph→F`) and R0031/R0032 (`raph→raf`, `soph→sof`), this covers the main cases without corrupting `ophæve`.

**Test:** `det photographerede sig` → `det fotograferede sig` ✓ (R0065 fires on ` ph`)

### 3c. New rules ported from XSLT (R0067–R0115, 48 rules)
| Category | Rules | Examples |
|---------|-------|---------|
| Silent-e verb forms | R0068–R0072 | `døer→dør`, `moer→mor`, `groer→gror`, `troer→tror`, `boer→bor` |
| Suffix `-øe` | R0073–R0077 | `øe `, `øe,`, `øe.`, `øe!`, `øe;` → `ø…` |
| Vowel dedup | R0078 | `ii→i` |
| Silent-d nouns/adj | R0079–R0089 | `dands→dans`, `grændse→grænse`, `kudsk→kusk`, `prinds→prins`… |
| e/æ alternations | R0090–R0099 | `flesk→flæsk`, `melk→mælk`, `neppe→næppe`, `teppe→tæppe`… |
| Specific word fixes | R0100–R0115 | `allene→alene`, `linie→linje`, `tredie→tredje`, `medens→mens`, `psalme→salme`… |

Cycle check after additions: **0 literal cycles** (confirmed by `detect_cycles.py`).

---

## 4. Test results on `2026-input/i-jurabjergene.xml`

### Loop 1
```
41 segments changed; rules fired: R0027 R0031 R0033 R0034 R0047 R0049 R0050
R0051 R0053 R0054 R0055 R0057 R0063 R0064 R0065 R0078 R0081 R0095
33 entity spans protected; teiHeader excluded (48 segments)
```

Selected changes:
| Original | Normalized | Rule(s) |
|---------|-----------|--------|
| `photographerede` | `fotograferede` | R0065 (` ph→ f`) |
| `Schweiz` | `Schweiz` | **protected** (was `Schwejz` before) |
| `Fiirbeen` | `Firben` | R0078 (ii→i), R0047 |
| `grændse` | `grænse` | R0081 |
| `neppe` | `næppe` | R0095 |
| `gaaer` | `går` | R0064 (aaer→år), R0033 |

### Loop 2 (spell-check, report-only)
3 flags from 862 tokens (19 unknown-but-plausible left alone):

| Token | Output | Issue | Rule |
|-------|--------|-------|------|
| `schweizisk` | `schwejzisk` | Adjective form of proper noun — NE list covers noun, not derived adj | R0047 |
| `xml` | `ksml` | Processing-instruction text leaks into spell-checker tokenizer | R0063 |
| `xml-model` | `ksml-model` | Same PI tokenizer leak | R0063 |

---

## 5. Remaining issues and next steps

### Named entity: adjective forms (high priority)
`schweizisk`, `heibergs-agtig`, `reitzelske` etc. are derived adjectives not in the NE list. Options:
1. Add a curated adjective/genitive supplement to `named_entities.txt`
2. Add preamble guards to the rule table (e.g., `schweiz→schwe*iz` before `ei→ej`)

The preamble approach is already used for `ee` and the `ei` foreign-name guards (`heiberg→he*iberg`) and would be the cleanest fix for Schweiz.

### `x→ks` scope (medium priority)
The generic `x→ks` (R0063) fires on `xml` in PI/attribute text. Two fixes needed:
1. Tighten the spell-checker tokenizer to skip non-body text (add `BODY` regex filter to `spellcheck_refine.py`)
2. Consider adding specific x-word guards: `xml→xml`, `extra→extra` (proper loanwords that DDO spells with x)

### XSLT step 1 (italics) and step 2 (lowercasing)
These stages are **not** part of Loop 1's scope and are handled by separate XSLT stylesheets in production. Loop 1 focuses solely on orthographic substitution (step 3 equivalent). Steps 1 and 2 remain as XSLT; integration into the Python pipeline would require a separate lowercasing module with the same 888-entity protection.

### Word-split and compound reforms
The XSLT `DSL-HCAC_Original2Modern_step1.xsl` includes ~25 word-split patterns (`idag→i dag`, `imorgen→i morgen`, `altfor→alt for`…). These require multi-word context and are tricky in a substring engine; they are deferred to a future "structural" Loop 3 stage.
