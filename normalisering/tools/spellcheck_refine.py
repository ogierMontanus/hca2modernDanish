#!/usr/bin/env python3
"""
spellcheck_refine.py - Hunspell-backed over-normalization detector (report-only).

Runs the v1 rules over a corpus, then uses the modern Danish DDO Hunspell
dictionary to find *clear cases where normalization produced a non-word*, and
proposes refinements for HUMAN REVIEW. It never edits text and never changes a
rule; it emits an update proposal (JSON + Markdown).

A token is flagged ONLY when all hold (high precision, low recall by design):
  1. a v1 rule actually CHANGED the token, and
  2. the normalized form is UNKNOWN to the DDO dictionary, and
  3. reversing one of the applied rules yields a KNOWN word (the implicated
     rule is shown), optionally corroborated by a Hunspell suggestion.

Consequences (these are the anti-"Verschlimmbesserung" guards):
  * Unchanged unknown tokens (names, archaisms, rare words) are NOT flagged.
  * Changed-but-still-unknown tokens with no reversal to a known word are
    classified "left_alone" (assumed low-frequency valid words / NER).
  * Output is a proposal; nothing is applied automatically.

Aggregating flags per rule yields "over-aggressive rule" evidence for Loop 2.

Usage:
  python spellcheck_refine.py corpus.txt \
      --rules ../rules/rules.tsv \
      --lexicon ../../ordbøger/aaTilÅ/ddo_DDO \
      --out-dir . [--min-occurrences 1]
"""
from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

from rule_engine import load_rules, normalize
from danish_lexicon import DanishLexicon

TOKEN = re.compile(r"[A-Za-zÆØÅæøåÉéÜüÖöÄä][A-Za-zÆØÅæøåÉéÜüÖöÄä'-]*")
# Strip XML tags, processing instructions and attribute content before tokenizing
_XML_STRIP = re.compile(r"<[^>]*>|<!--.*?-->", re.DOTALL)


def is_known(lex: DanishLexicon, w: str) -> bool:
    """Known if the form OR its lower-case variant is in the dictionary, so a
    legitimately capitalized word (sentence start) is not treated as a non-word."""
    return lex.known(w) or (w[:1].isupper() and lex.known(w.lower()))


def reverse_to_known(normalized: str, applied: list[str],
                     rules_by_id: dict[str, dict], lex: DanishLexicon):
    """Try undoing each applied rule; return (known_word, rule_id) or None."""
    for rid in dict.fromkeys(reversed(applied)):     # most-recent first, unique
        r = rules_by_id[rid]
        src, tgt = r["source"], r["target"]
        if not tgt or tgt not in normalized:
            continue
        # try undoing all occurrences, then the first occurrence only
        for cand in (normalized.replace(tgt, src),
                     normalized.replace(tgt, src, 1)):
            if cand != normalized and is_known(lex, cand):
                return cand, rid
    return None


def analyze(corpus: Path, rules, lex, min_occ: int, entities: list[str] | None = None):
    rules_by_id = {r["id"]: r for r in rules}
    raw = corpus.read_text(encoding="utf-8")
    # Strip XML markup so tags, PIs and attribute values don't leak into token counts
    if raw.lstrip().startswith("<"):
        raw = _XML_STRIP.sub(" ", raw)
    freq = Counter(TOKEN.findall(raw))
    # Build a set for fast NE substring check (lower-cased)
    ne_set: set[str] = set()
    if entities:
        ne_set = {e.lower() for e in entities}

    flagged, left_alone = [], 0
    rule_evidence = defaultdict(lambda: {"count": 0, "examples": []})

    for tok, occ in freq.items():
        # Skip tokens that contain a named-entity substring: Loop 1 already
        # protects them, so a flag here would be a false positive.
        if ne_set and any(ne in tok.lower() for ne in ne_set):
            continue
        norm, applied, _ = normalize(tok, rules)
        if norm == tok or not applied:
            continue                                  # unchanged -> not our concern
        if is_known(lex, norm):
            continue                                  # good normalization
        # normalized is a non-word AND a rule changed it -> investigate.
        # We flag ONLY when undoing the implicated rule reconstructs a known
        # word. Cases that need a fix Hunspell can only *guess* at (no clean
        # reversal) are intentionally left to human review, not auto-proposed:
        # that is what keeps names / rare words from being "corrected" wrongly.
        hit = reverse_to_known(norm, applied, rules_by_id, lex)
        if hit is None:
            left_alone += 1                           # rare/valid word or NER
            continue
        if occ < min_occ:
            continue
        suggestions = lex.suggest(norm, 5)
        suggested, implicated = hit
        confidence = 0.9 if suggested in suggestions else 0.8
        flagged.append({
            "original": tok,
            "normalized": norm,
            "suggested_form": suggested,
            "implicated_rule": f"{implicated}: {rules_by_id[implicated]['source']}"
                               f" -> {rules_by_id[implicated]['target']}",
            "all_applied_rules": applied,
            "hunspell_suggestions": suggestions,
            "occurrences": occ,
            "confidence": confidence,
        })
        ev = rule_evidence[implicated]
        ev["count"] += occ
        if len(ev["examples"]) < 8:
            ev["examples"].append(f"{tok} -> {norm} (suggest {suggested})")

    flagged.sort(key=lambda f: (-f["confidence"], -f["occurrences"]))
    evidence = sorted(
        ({"rule": f"{rid}: {rules_by_id[rid]['source']} -> {rules_by_id[rid]['target']}",
          "overnormalizations": ev["count"], "examples": ev["examples"]}
         for rid, ev in rule_evidence.items()),
        key=lambda e: -e["overnormalizations"])
    return flagged, left_alone, evidence, len(freq)


def write_markdown(path, flagged, left_alone, evidence, n_types):
    L = ["# Normalization refinement proposal (review required)\n",
         f"- distinct tokens analyzed: **{n_types}**",
         f"- clear over-normalizations flagged: **{len(flagged)}**",
         f"- changed-but-unknown left alone (assumed valid/rare/NER): **{left_alone}**\n",
         "> Nothing here is applied automatically. Approve items individually.\n",
         "## Flagged tokens\n",
         "| original | → normalized | suggested | implicated rule | n | conf |",
         "|---|---|---|---|--:|--:|"]
    for f in flagged:
        L.append(f"| {f['original']} | {f['normalized']} | **{f['suggested_form']}** "
                 f"| {f['implicated_rule']} | {f['occurrences']} | {f['confidence']:.2f} |")
    L.append("\n## Over-aggressive rule evidence (for Loop 2 review queue)\n")
    L.append("| rule | over-normalizations | examples |")
    L.append("|---|--:|---|")
    for e in evidence:
        L.append(f"| {e['rule']} | {e['overnormalizations']} | {'; '.join(e['examples'][:3])} |")
    path.write_text("\n".join(L) + "\n", encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("corpus", type=Path, help="plain-text corpus (one+ files concatenated)")
    ap.add_argument("--rules", type=Path, default=Path("../rules/rules.tsv"))
    ap.add_argument("--lexicon", required=True,
                    help="DDO Hunspell prefix/.dic, or a plain word list")
    ap.add_argument("--out-dir", type=Path, default=Path("."))
    ap.add_argument("--entities", type=Path,
                    default=Path("../rules/named_entities.txt"),
                    help="named-entity list; tokens containing these are skipped "
                         "(mirrors normalize_xml.py protection, avoids false positives)")
    ap.add_argument("--min-occurrences", type=int, default=1)
    args = ap.parse_args()

    rules = load_rules(args.rules)
    lex = DanishLexicon.load(args.lexicon)
    entities: list[str] | None = None
    if args.entities and args.entities.exists():
        entities = [l.strip() for l in args.entities.read_text(encoding="utf-8").splitlines()
                    if l.strip() and not l.startswith("#")]
    flagged, left_alone, evidence, n_types = analyze(
        args.corpus, rules, lex, args.min_occurrences, entities)

    args.out_dir.mkdir(parents=True, exist_ok=True)
    proposal = {"summary": {"tokens": n_types, "flagged": len(flagged),
                            "left_alone": left_alone},
                "flagged": flagged, "rule_evidence": evidence}
    (args.out_dir / "update_proposal.json").write_text(
        json.dumps(proposal, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_markdown(args.out_dir / "update_proposal.md",
                   flagged, left_alone, evidence, n_types)

    print(f"{n_types} tokens; flagged {len(flagged)} clear over-normalization(s), "
          f"left {left_alone} unknown-but-plausible alone.")
    for f in flagged[:12]:
        print(f"  {f['original']} -> {f['normalized']}  suggest {f['suggested_form']}"
              f"  [{f['implicated_rule']}]  conf {f['confidence']:.2f}")


if __name__ == "__main__":
    main()
