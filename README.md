# hca2modernDanish

Automated modernization of H.C. Andersen's tales from 19th-century Danish
orthography (1830–1873) into modern Danish spelling.

**→ See [`docs/TASK.md`](docs/TASK.md) for the full task description:
pipeline stages, data inputs, and the dictionaries/corpora used.**

## Background

H.C. Andersen's fairy tales and stories were published in the spelling
conventions of his time (e.g. `Kjøbenhavn`, `deilig`, `Thee`, `kunde`),
which differ substantially from modern Danish. This project is an academic
effort, based at the University of Southern Denmark (SDU), to automate
that modernization — replacing (or assisting) manual editorial
normalization with a rule-based pipeline that is transparent, inspectable,
and evaluated against a human-modernized gold standard.

The rule table is grounded in the documented history of Danish orthography
(Henrik Galberg Jacobsen, *Ret og Skrift: Officiel dansk retskrivning
1739–2005*, SDU 2010) and in institutional editorial guidelines for
modernizing H.C. Andersen's texts, and is validated against `sv-data`
originals/human-modernized pairs and Den Danske Ordbog (DDO).

## Repository layout

| Path | Contents |
|---|---|
| `run.py` | Pipeline entry point — normalize, tag, and spell-check XML tales |
| `input/`, `source/` | Original-orthography source texts |
| `output/` | Pipeline output |
| `tools/normalisering/` | v2 normalization engine: rules, taggers, evaluation tools |
| `resources/` | Dictionaries, corpora, editorial guidelines, golden standard |
| `editorial/` | Human editor tracked-changes files, mined for rule candidates |
| `docs/` | Task description, methods notes, resource documentation |

## Getting started

```bash
python run.py                        # process all XML in input/
python run.py input/klods-hans.xml   # process a single tale
python run.py --pos                  # include spaCy PoS tagging
```

See [`tools/normalisering/README.md`](tools/normalisering/README.md) for
details on the rule engine, loop-safety design, and evaluation tooling.

## Contributors

- **Holger Berg** ([@ogierMontanus](https://github.com/ogierMontanus)) — repository maintainer
- Editorial review and correction of source texts: initialled **FGJ** (see `editorial/`)
- Academic reference: Bjerring-Hansen & Conroy (forthcoming), *"Guldet i guldalderen og T'et i GPT"* (see [`docs/resources/hca-tales-segmented.md`](docs/resources/hca-tales-segmented.md))

If you contribute to this project, feel free to add yourself here.
