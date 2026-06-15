# 07 — Historical variant knowledge base (from *Ret og Skrift*)

The "Historical Variant Knowledge Base" (spec section C) is grounded in the
standard scholarly reference on the history of official Danish orthography:

> **Henrik Galberg Jacobsen, *Ret og Skrift. Officiel dansk retskrivning
> 1739–2005*. Bind 1–2. Dansk Sprognævns skrifter 42 / University of Southern
> Denmark Studies in Scandinavian Languages and Literatures vol. 95. Syddansk
> Universitetsforlag, 2010.**

Local copy (not committed — see note below): [`../../ortography-history/`](../../ortography-history/)
(`RetogSkriftBind1_samlet.pdf`, `RetogSkriftBind2_samlet.pdf`). **Bind 2** is
*Ordlister, Kronologi, Bibliografi* — chapter 4 contains the official word lists
documenting every change in the official spelling from 1739/1775 to 2001.

For changes **since 1892**, the authoritative living resource is *Retskrivningen
gennem tiderne* (Dansk Sprognævn): <https://rohist.dsn.dk/#om-rohist>.

## Extracted word list — `rules/historical_variants.tsv`

[`extract_ordlister.py`](../tools/extract_ordlister.py) parses Bind 2 chapter 4
and extracts **142** historical→modern pairs across 24 ordlister. Each entry is
anchored on a historical norm-year (1739/1775/1800/1847/1872), so the captured
form is the spelling a ~1830–1875 text (i.e. Andersen's) would actually use:

```
#source(historical)  target(modern)  rp     norm_year
Qvinde               kvinde          RP7b   1775
voxe                 vokse           RP7d   1775
skiøn                skøn            RP11   1847
Kierlighed           kærlighed       RP13   1775
giøre                gøre            RP6    1739
Throne (Theater)     trone (teater)  RP21   ...
```

Reproduce:

```bash
pdftotext -enc UTF-8 ortography-history/RetogSkriftBind2_samlet.pdf b2.txt
cd normalisering/tools
python extract_ordlister.py /path/to/b2.txt --out ../rules/historical_variants.tsv
```

This is a **best-effort** extraction from a 600-page PDF text layer and is
treated as *candidate historical evidence for review*, not auto-applied rules —
consistent with the project's never-auto-deploy principle ([`04`](04-phase2-rule-induction.md)).
It is used three ways:

1. as **authoritative evidence** when scoring induced candidates
   (`historical_evidence` component, [`04`](04-phase2-rule-induction.md)) — a
   mined edit already attested here gets a confidence boost;
2. as a seed for **whole-word rules** (high-confidence, period-stamped);
3. as a **historical lexicon** for lexical validation ([`01`](01-architecture.md)).

The `rp` and `norm_year` columns give every pair scholarly provenance back to a
specific orthographic principle and norm.

## The orthographic principles (RP) — from the *Eksempler* table (Bind 2)

The reforms are organised by *retskrivningsproblem* (RP). The book's summary
*Eksempler* table maps each principle to representative old→new pairs; these are
exactly the transformation classes the v1 rule table already encodes (`aa→å`,
`qv→kv`, `ph→f`, …):

| Principle | Old | Modern | RP |
|---|---|---|---|
| store→små bogstaver | Kundskab | kundskab | RP1 |
| dobbelt→enkeltvokal | heel, Viin, Huus | hel, Vin, hus | RP3 |
| dobbelt→enkeltkonsonant | tappre, Yttring | tapre, ytring | RP5 |
| palatalisering gj/kj→g/k | gjerne, Kjærlighed, skjøn | gerne, kærlighed, skøn | RP6 |
| fremmede bogstaver qv→kv, x→ks | Qvinde, voxe | kvinde, vokse | RP7 |
| fremmedord ph→f m.m. | philosophere, Affaire | filosofere, affære | RP8 |
| ét/flere ord | forsaavidt, istedenfor | for så vidt, i stedet for | RP9 |
| verbalpluralis | vi spise, de lode, I kunne | vi spiser, de lod, I kan | RP10 |
| ø/ö | høj | höj/høj | RP11 |
| e→æ | begge, sjelden | bægge, sjælden | RP13 |
| o/aa→å | taale, Aabning | tåle, åbning | RP14 |
| ie→je | Stierne, Lillie | stjerne, lilje | RP16 |
| diftonger ey/øy→ej/øj | feye, Øye | feje, øje | RP17 |
| stumt d | blandt, fraadse, tidt | blant, fraase, tit | RP18-19 |
| stumt g | spørgsmål, valgte | spørsmål, valte | RP20 |
| stumt h / th→t | hjem, Throne, Theater, Uhr | jem, trone, teater, ur | RP21 |
| v/f | grovt, havt; av | groft, haft; af | RP22 |
| kunde/skulde/vilde | kunde, skulde, vilde | kunne, skulle, ville | RP24 |
| bøjning trykstærk vokal | Tæer, syer, rue | tær, syr, ru | RP24 |
| dobbeltkons. fremmedord | Fabriken, Punktumet | fabrikken, punktummet | RP25 |
| aa→å | taale, Aabning | tåle, åbning | (1948) |

(The book documents the *exact* year each change became official, letting a rule
be period-stamped — e.g. `qv→kv` becomes official with the 1872-cirkulære, so a
rule normalizing it can carry `period.to` / evidence accordingly.)

## Copyright note
The two PDFs are © Forfatteren og Syddansk Universitetsforlag 2010 and are **not
committed** to the repository (see [`../../.gitignore`](../../.gitignore)). Only
the derived list of orthographic facts (`historical_variants.tsv`) is stored,
for use within this academic project at the publishing institution (SDU).
