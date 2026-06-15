#!/usr/bin/env python3
"""
weighted_edit_distance.py - learned, transparent edit costs.

Standard Levenshtein treats every substitution as cost 1. For historical Danish
normalization that is wrong: `qv -> kv`, `aa -> å`, `gj -> g`, `iø -> ø` are
*expected* transformations and should be cheap, while a random substitution
should stay expensive. This module loads a cost table (learned/refined from
human corrections in Phase 2) and ranks candidate normalizations by weighted
distance.

The cost table is just data, fully inspectable:

    qv	kv	0.1
    aa	å	0.1
    gj	g	0.1
    *	*	1.0      # default substitution cost (optional)

Usage as a library:
    from weighted_edit_distance import WeightedEditDistance
    wed = WeightedEditDistance.from_file("edit_costs.tsv")
    wed.distance("qvinde", "kvinde")     # -> 0.1
    wed.rank("qvinde", ["kvinde", "qvinde", "svinde"])

Usage from CLI:
    python weighted_edit_distance.py edit_costs.tsv qvinde kvinde svinde
"""
from __future__ import annotations

import sys
from pathlib import Path


class WeightedEditDistance:
    def __init__(self, sub_costs: dict[tuple[str, str], float],
                 default_sub: float = 1.0, indel: float = 1.0,
                 max_ngram: int = 3):
        self.sub_costs = sub_costs
        self.default_sub = default_sub
        self.indel = indel
        self.max_ngram = max_ngram

    @classmethod
    def from_file(cls, path: str | Path) -> "WeightedEditDistance":
        costs: dict[tuple[str, str], float] = {}
        default_sub = 1.0
        mx = 1
        for line in Path(path).read_text(encoding="utf-8").splitlines():
            if not line.strip() or line.startswith("#"):
                continue
            s, t, c = line.split("\t")
            if s == "*" and t == "*":
                default_sub = float(c)
                continue
            costs[(s, t)] = float(c)
            mx = max(mx, len(s), len(t))
        return cls(costs, default_sub=default_sub, max_ngram=mx)

    def distance(self, a: str, b: str) -> float:
        """Weighted edit distance allowing learned multi-char substitutions.

        DP over prefixes; at each cell we may consume an n-gram from a and an
        m-gram from b if (a-gram, b-gram) is in the cost table (cheap), in
        addition to the usual single-char insert/delete/substitute moves.
        """
        n, m = len(a), len(b)
        INF = float("inf")
        d = [[INF] * (m + 1) for _ in range(n + 1)]
        d[0][0] = 0.0
        for i in range(n + 1):
            for j in range(m + 1):
                cur = d[i][j]
                if cur == INF:
                    continue
                if i < n:                                   # delete a[i]
                    d[i + 1][j] = min(d[i + 1][j], cur + self.indel)
                if j < m:                                   # insert b[j]
                    d[i][j + 1] = min(d[i][j + 1], cur + self.indel)
                if i < n and j < m:                         # substitute / copy
                    c = 0.0 if a[i] == b[j] else self.default_sub
                    d[i + 1][j + 1] = min(d[i + 1][j + 1], cur + c)
                # learned multi-char substitutions
                for p in range(1, self.max_ngram + 1):
                    for q in range(1, self.max_ngram + 1):
                        if i + p <= n and j + q <= m:
                            key = (a[i:i + p], b[j:j + q])
                            if key in self.sub_costs:
                                d[i + p][j + q] = min(d[i + p][j + q],
                                                      cur + self.sub_costs[key])
        return d[n][m]

    def rank(self, form: str, candidates: list[str]) -> list[tuple[str, float]]:
        return sorted(((c, self.distance(form, c)) for c in candidates),
                      key=lambda x: x[1])


def main() -> None:
    if len(sys.argv) < 4:
        print("usage: weighted_edit_distance.py costs.tsv FORM CAND [CAND ...]",
              file=sys.stderr)
        sys.exit(2)
    wed = WeightedEditDistance.from_file(sys.argv[1])
    form, cands = sys.argv[2], sys.argv[3:]
    for cand, dist in wed.rank(form, cands):
        print(f"{dist:.3f}\t{cand}")


if __name__ == "__main__":
    main()
