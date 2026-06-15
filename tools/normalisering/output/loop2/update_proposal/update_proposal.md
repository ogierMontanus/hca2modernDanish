# Normalization refinement proposal (review required)

- distinct tokens analyzed: **862**
- clear over-normalizations flagged: **3**
- changed-but-unknown left alone (assumed valid/rare/NER): **19**

> Nothing here is applied automatically. Approve items individually.

## Flagged tokens

| original | → normalized | suggested | implicated rule | n | conf |
|---|---|---|---|--:|--:|
| fransk-schweizisk | fransk-schwejzisk | **fransk-schweizisk** | R0047: ei -> ej | 1 | 0.90 |
| xml | ksml | **xml** | R0063: x -> ks | 68 | 0.80 |
| xml-model | ksml-model | **xml-model** | R0063: x -> ks | 1 | 0.80 |

## Over-aggressive rule evidence (for Loop 2 review queue)

| rule | over-normalizations | examples |
|---|--:|---|
| R0063: x -> ks | 69 | xml -> ksml (suggest xml); xml-model -> ksml-model (suggest xml-model) |
| R0047: ei -> ej | 1 | fransk-schweizisk -> fransk-schwejzisk (suggest fransk-schweizisk) |
