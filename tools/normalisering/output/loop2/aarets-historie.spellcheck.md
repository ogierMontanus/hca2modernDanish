# Normalization refinement proposal (review required)

- distinct tokens analyzed: **1207**
- clear over-normalizations flagged: **1**
- changed-but-unknown left alone (assumed valid/rare/NER): **2**

> Nothing here is applied automatically. Approve items individually.

## Flagged tokens

| original | → normalized | suggested | implicated rule | n | conf |
|---|---|---|---|--:|--:|
| Sneen | snen | **sneen** | R0027: ee -> e | 1 | 0.90 |

## Over-aggressive rule evidence (for Loop 2 review queue)

| rule | over-normalizations | examples |
|---|--:|---|
| R0027: ee -> e | 1 | Sneen -> snen (suggest sneen) |
