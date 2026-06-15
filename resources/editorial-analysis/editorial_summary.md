# Editorial analysis — oXygen Author tracked changes

Source: `editorial/*/` `_fgj.xml` + `_final.xml` files  |  Total changes: **61536**

## Change type distribution

| Type | Count | % |
|------|------:|--:|
| word_replace | 19610 | 32% |
| phrase_replace | 13136 | 21% |
| structural | 9196 | 15% |
| punctuation | 7514 | 12% |
| case_change | 6132 | 10% |
| delete_only | 4986 | 8% |
| insert_only | 959 | 2% |
| hyphenation | 3 | 0% |

## Word replacements (Loop 1 candidates)

These are single-word or short phrase changes that may become
Loop 1 spelling/vocabulary rules (after human verification).

| old | new | occurrences |
|-----|-----|------------:|
| kunde | kunne | 3968 |
| ; d | . d | 2349 |
| vilde | ville | 2285 |
| skulde | skulle | 2084 |
| moder | mor | 1436 |
| ; h | . h | 1430 |
| ; d | d | 1248 |
| fader | far | 1067 |
| é | e | 787 |
| ; h | h | 736 |
| c | k | 555 |
| , d | d | 486 |
| kunne | kan | 451 |
| ; m | . m | 444 |
| e | æ | 439 |
| e | é | 415 |
| ch | k | 359 |
| ; s | . s | 357 |
| ; m | m | 318 |
| ; o | . o | 317 |
| æ | e | 295 |
| ; j | . j | 274 |
| i | j | 261 |
| o | ó | 249 |
| ville | vil | 241 |
| ; f | . f | 234 |
| ; i | . i | 234 |
| , h | h | 232 |
| ; s | s | 221 |
| skulle | skal | 212 |
| ; o | o | 198 |
| ; v | . v | 195 |
| ; e | . e | 194 |
| ; n | . n | 179 |
| ph | f | 166 |
| aa | å | 164 |
| broder | bror | 144 |
| ; t | . t | 132 |
| ; j | j | 129 |
| ; k | . k | 129 |
| ; d | . | 125 |
| kjø | kø | 111 |
| ; n | n | 102 |
| fa’er | far | 102 |
| ; l | . l | 98 |
| ; i | i | 94 |
| ; b | . b | 93 |
| ; a | . a | 89 |
| , d | . d | 89 |
| ; g | . g | 86 |
| ; t | t | 84 |
| de | t | 80 |
| , h | . h | 80 |
| , d | . | 80 |
| eu | ø | 79 |
| ; f | f | 78 |
| ; h | . | 78 |
| bro’er | bror | 75 |
| , m | m | 72 |
| ; p | . p | 67 |

## Punctuation deletions (most frequent)

Characters the editor removed — may indicate over-use in the corrected text.

| deleted | count |
|---------|------:|
| `,` | 3537 |
| `-` | 461 |
| `e` | 349 |
| `–` | 155 |
| `d` | 72 |
| `t` | 70 |
| `j` | 49 |
| `;` | 45 |
| `r` | 44 |
| `h` | 24 |
| `!` | 24 |
| `i` | 14 |
| `te` | 13 |
| `f` | 12 |
| `n` | 11 |

## Loop 1 implications

Top word replacements that are NOT yet covered by `rules/rules.tsv`
should be reviewed for addition as new rules.

## Loop 2 implications

High-frequency punctuation deletions suggest the corrected text
contains stylistic over-commaing or semi-colon use that Loop 2's
Hunspell layer cannot detect. These are structural edits that must
be addressed at the XSLT/post-processing level.

> All changes require human verification before entering production.
