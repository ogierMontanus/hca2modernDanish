#!/usr/bin/env python3
"""
rule_engine.py - canonical Python mirror of normalize.awk.

normalize.awk is the AWK *deliverable*; this module is the Python
implementation of the exact same semantics (literal ordered substitution,
iterate to fixpoint, seen-state runtime loop guard) so that the spell-check /
mining tools can normalize a token AND know which rules fired. The test-suite
cross-checks the two engines on sample input to guard against drift.
"""
from __future__ import annotations

from pathlib import Path


def load_rules(path: str | Path) -> list[dict]:
    rules = []
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        if not line or line.startswith("#"):
            continue
        c = line.split("\t")
        if len(c) > 6 and c[6] != "1":
            continue
        rules.append({"id": c[0],
                      "source": c[1].replace("\\t", "\t"),
                      "target": c[2].replace("\\t", "\t")})
    return rules


def normalize(text: str, rules: list[dict], maxiter: int = 100):
    """Return (normalized_text, applied_rule_ids, looped: bool)."""
    form = text
    seen = {form}
    applied: list[str] = []
    looped = False
    for _ in range(maxiter):
        changed = False
        for r in rules:
            if r["source"] and r["source"] in form:
                form = form.replace(r["source"], r["target"])
                applied.append(r["id"])
                changed = True
        if not changed:
            break
        if form in seen:
            looped = True
            break
        seen.add(form)
    return form, applied, looped


if __name__ == "__main__":
    import sys
    rules = load_rules(sys.argv[1])
    for line in sys.stdin:
        out, ap, lp = normalize(line.rstrip("\n"), rules)
        print(out + ("  # rules: " + ",".join(ap) if ap else "")
              + (" [LOOP-GUARDED]" if lp else ""))
