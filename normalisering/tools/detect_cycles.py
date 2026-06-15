#!/usr/bin/env python3
"""
detect_cycles.py - static loop analysis for the rewrite-rule table.

General termination of an arbitrary string-rewriting system is undecidable, so
this tool runs two practical, complementary checks that catch the loop classes
actually observed in this pipeline:

  1. LITERAL CYCLES
     Treat every rule as a directed edge  source -> target.  A cycle in this
     graph means a set of rules maps a form back onto itself, e.g.
         aa -> å
         å  -> aa
     or the indirect  A -> B -> C -> A.  Found via DFS (Tarjan-style colouring).

  2. RE-TRIGGER (EXPANSION) HAZARDS
     A rule R: s -> t is a re-trigger hazard when its output t still *contains*
     the source pattern of some enabled rule R' (possibly R itself). Applying R
     therefore produces text that R' will rewrite again. Iterated re-triggering
     is the mechanism behind both genuine non-termination and the fragile
     `ee -> e` work-arounds in the legacy stylesheet, so each hazard is reported
     with its triggering chain.

Exit status is non-zero when literal cycles are found, so CI can gate on it.

Usage:
    python detect_cycles.py ../rules/rules.tsv [--format text|json] [--max-depth N]
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def load_rules(path: Path) -> list[dict]:
    rules = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line or line.startswith("#"):
            continue
        cols = line.split("\t")
        rid, src, tgt = cols[0], cols[1], cols[2]
        enabled = cols[6] if len(cols) > 6 else "1"
        if enabled != "1":
            continue
        # Restore escaped tabs (see extractor); spaces are significant.
        src = src.replace("\\t", "\t")
        tgt = tgt.replace("\\t", "\t")
        rules.append({"id": rid, "source": src, "target": tgt})
    return rules


def find_literal_cycles(rules: list[dict]) -> list[list[str]]:
    """DFS cycle detection on the source->target graph (node = string form)."""
    # adjacency: form -> list of (next_form, rule_id)
    adj: dict[str, list[tuple[str, str]]] = {}
    for r in rules:
        adj.setdefault(r["source"], []).append((r["target"], r["id"]))

    WHITE, GREY, BLACK = 0, 1, 2
    color: dict[str, int] = {}
    stack: list[tuple[str, str]] = []  # (form, rule_id that entered it)
    cycles: list[list[str]] = []

    def dfs(form: str) -> None:
        color[form] = GREY
        for nxt, rid in adj.get(form, []):
            if color.get(nxt, WHITE) == GREY:
                # Found a back-edge: reconstruct the cycle from the stack.
                chain = [f"{rid}: {form} -> {nxt}"]
                for f, r in reversed(stack):
                    chain.append(f"{r}: {f}")
                    if f == nxt:
                        break
                cycles.append(list(reversed(chain)))
            elif color.get(nxt, WHITE) == WHITE:
                stack.append((form, rid))
                dfs(nxt)
                stack.pop()
        color[form] = BLACK

    for form in list(adj.keys()):
        if color.get(form, WHITE) == WHITE:
            dfs(form)
    return cycles


def find_retrigger_hazards(rules: list[dict]) -> list[dict]:
    """Flag rules whose output still matches some enabled rule's source."""
    hazards = []
    for r in rules:
        triggered = []
        for other in rules:
            if other["source"] and other["source"] in r["target"]:
                # Self re-trigger only matters if the source survives in target.
                triggered.append(other["id"] + f" ({other['source']} -> {other['target']})")
        if triggered:
            hazards.append(
                {
                    "rule": r["id"],
                    "rewrite": f"{r['source']} -> {r['target']}",
                    "retriggers": triggered,
                }
            )
    return hazards


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("rules", type=Path)
    ap.add_argument("--format", choices=["text", "json"], default="text")
    args = ap.parse_args()

    rules = load_rules(args.rules)
    cycles = find_literal_cycles(rules)
    hazards = find_retrigger_hazards(rules)

    if args.format == "json":
        print(json.dumps({"literal_cycles": cycles, "retrigger_hazards": hazards},
                         ensure_ascii=False, indent=2))
    else:
        print(f"Analyzed {len(rules)} enabled rules.\n")
        if cycles:
            print(f"!! {len(cycles)} LITERAL CYCLE(S) DETECTED:")
            for c in cycles:
                print("  Cycle detected:")
                for step in c:
                    print(f"    {step}")
                print()
        else:
            print("OK: no literal source->target cycles.\n")
        if hazards:
            print(f"~  {len(hazards)} re-trigger hazard(s) (output re-matches a rule source):")
            for h in hazards:
                print(f"  {h['rule']}  {h['rewrite']}")
                for t in h["retriggers"]:
                    print(f"      re-triggers {t}")
            print("\n  Re-triggers are not necessarily bugs (some are intentional"
                  "\n  collapse work-arounds) but every one is a runtime-loop risk"
                  "\n  and should be covered by a runtime guard + a test case.")
        else:
            print("OK: no re-trigger hazards.")

    # CI gate: literal cycles are always errors.
    sys.exit(1 if cycles else 0)


if __name__ == "__main__":
    main()
