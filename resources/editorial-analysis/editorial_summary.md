# Editorial analysis — oXygen Author tracked changes

Source: `editorial/*/` `_fgj.xml` files  |  Total changes: **40753**

## Change type distribution

| Type | Count | % |
|------|------:|--:|
| word_replace | 12939 | 32% |
| phrase_replace | 8690 | 21% |
| structural | 6096 | 15% |
| punctuation | 4967 | 12% |
| case_change | 4125 | 10% |
| delete_only | 3306 | 8% |
| insert_only | 628 | 2% |
| hyphenation | 2 | 0% |

## Word replacements (Loop 1 candidates)

These are single-word or short phrase changes that may become
Loop 1 spelling/vocabulary rules (after human verification).

| old | new | occurrences |
|-----|-----|------------:|
| kunde | kunne | 2640 |
| ; d | . d | 1558 |
| vilde | ville | 1522 |
| skulde | skulle | 1388 |
| moder | mor | 958 |
| ; h | . h | 951 |
| ; d | d | 830 |
| fader | far | 711 |
| é | e | 520 |
| ; h | h | 490 |
| c | k | 371 |
| , d | d | 320 |
| ; m | . m | 295 |
| e | æ | 294 |
| kunne | kan | 290 |
| e | é | 266 |
| ch | k | 239 |
| ; s | . s | 239 |
| ; m | m | 212 |
| ; o | . o | 211 |
| æ | e | 196 |
| ; j | . j | 183 |
| i | j | 174 |
| o | ó | 165 |
| ; f | . f | 155 |
| ; i | . i | 155 |
| ville | vil | 154 |
| , h | h | 153 |
| ; s | s | 147 |
| skulle | skal | 136 |
| ; o | o | 133 |
| ; v | . v | 130 |
| ; e | . e | 129 |
| ; n | . n | 118 |
| ph | f | 110 |
| aa | å | 110 |
| broder | bror | 96 |
| ; t | . t | 87 |
| ; j | j | 86 |
| ; k | . k | 86 |
| ; d | . | 84 |
| kjø | kø | 74 |
| ; n | n | 68 |
| fa’er | far | 68 |
| ; l | . l | 65 |
| ; i | i | 63 |
| ; b | . b | 62 |
| ; a | . a | 59 |
| , d | . d | 57 |
| ; g | . g | 57 |
| ; t | t | 56 |
| de | t | 55 |
| , h | . h | 53 |
| ; f | f | 52 |
| eu | ø | 52 |
| , d | . | 51 |
| bro’er | bror | 50 |
| ; h | . | 49 |
| , m | m | 48 |
| d | l | 44 |

## Punctuation deletions (most frequent)

Characters the editor removed — may indicate over-use in the corrected text.

| deleted | count |
|---------|------:|
| `,` | 2347 |
| `-` | 309 |
| `e` | 227 |
| `–` | 101 |
| `d` | 48 |
| `t` | 46 |
| `j` | 34 |
| `r` | 30 |
| `;` | 29 |
| `h` | 16 |
| `!` | 16 |
| `te` | 9 |
| `i` | 9 |
| `f` | 8 |
| `n` | 7 |

## Loop 1 implications

Top word replacements that are NOT yet covered by `rules/rules.tsv`
should be reviewed for addition as new rules.

## Loop 2 implications

High-frequency punctuation deletions suggest the corrected text
contains stylistic over-commaing or semi-colon use that Loop 2's
Hunspell layer cannot detect. These are structural edits that must
be addressed at the XSLT/post-processing level.

> All changes require human verification before entering production.
