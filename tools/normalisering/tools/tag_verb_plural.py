#!/usr/bin/env python3
"""
tag_verb_plural.py — detect and modernize finite plural verb forms.

Pre-1870 Danish marked plural subjects with a distinct present-tense verb ending
(-e), which is identical to the infinitive in most verb classes. This script
disambiguates finite plural (de synge -> de synger) from infinitive (at synge)
using a three-tier approach:

  Tier 1: Context-window pattern (no model, high confidence)
           [vi|de|I] within <=5 tokens, no intervening at/modal -> finite
  Tier 2: spaCy da_core_news_lg morphological tagging
           VerbForm=Fin + Number=Plur -> finite plural
  Tier 3: DDO validation gate
           stem+er must exist in DDO before accepting any change

Handles irregulars via lookup table (have->har, vide->ved, etc.).

Usage:
  python tag_verb_plural.py INPUT_XML [--ddo PATH] [--out PATH] [--sample-only]

INPUT_XML  : Loop 1 output file (tools/normalisering/output/loop1/*.xml)
--ddo      : DDO .dic path (default: resources/dictionaries/aaTilÅ/ddo_DDO.dic)
--out      : output trace path (default: INPUT_XML.verb-plural.tsv)
--sample-only : print candidates to stdout, do not write trace file
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

_HERE = Path(__file__).parent
_NORM = _HERE.parent
_ROOT = _NORM.parent.parent

# ---------------------------------------------------------------------------
# Irregular verb table: old plural form -> modern finite form
# (only entries where plural != infinitive, OR where DDO won't find stem+er)
# ---------------------------------------------------------------------------

IRREGULARS: dict[str, str] = {
    # ere is the ONLY safe Tier-1 irregular (infinitive is "at være")
    "ere":    "er",
    # The rest need context (plural = infinitive), handled here for the DDO gate
    "have":   "har",
    "vide":   "ved",
    "gjøre":  "gør",
    "gøre":   "gør",
    "kunne":  "kan",
    "ville":  "vil",
    "skulle": "skal",
    "måtte":  "må",
    "turde":  "tør",
    "burde":  "bør",
    "gide":   "gider",
}

# Old-Danish past-tense verb forms that end in -e and look like present plurals.
# These must NEVER be changed to stem+er.
PAST_TENSE_FORMS: set[str] = {
    "vare",    # past plural of "at være" (= "were")
    "skulde",  # past of "at skulle"
    "kunde",   # past of "at kunne"
    "maatte",  # past of "at måtte"
    "vilde",   # past of "at ville"
    # Past tense of -se/-se verbs whose -te form ends in -e
    "lyste",   # past of "at lyse" (shone); present plural = "lyse", not "lyste"
    "lydte",   # past of "at lyde" (sounded)
    "bruste",  # past of "at bruse" (roared)
    # Past plural forms in -ode/-ode ending
    "stode",   # past of "at stå" (stood)
    "laae",    # past of "at ligge" (lay)
    "foere",   # past of "at fare" (traveled)
}

# Common adverbs and particles that end in -e but are never finite verbs.
ADVERBS_E: set[str] = {
    "bare",    # only / just
    "borte",   # away / gone
    "hjemme",  # at home
    "oppe",    # up / above
    "nede",    # down / below
    "ude",     # outside
    "inde",    # inside
    "fremme",  # forward / present
    "tilbage", # back (doesn't end -e, but keep for safety)
    "gjerne",  # gladly
    "gerne",   # gladly (modern)
    "næppe",   # hardly
    "neppe",   # hardly (old spelling)
    "videre",  # further
    "længe",   # for a long time (adverb of duration)
    "endnu",   # still (doesn't end -e)
    "netop",   # just/exactly (doesn't end -e)
}

# Cardinal/ordinal numbers ending in -e (not verbs)
NUMBERS_E: set[str] = {
    "tre", "fire", "femte", "sjette", "syvende", "ottende", "niende", "tiende",
    "elvte", "tolvte", "tyvende", "tredive", "halvtredse", "halvfemse",
    "hundrede", "tusinde",
}

# Plural subject pronouns (lowercase form for comparison).
# IMPORTANT: "I" (2nd person plural) is always CAPITALISED in Danish;
# "i" (preposition "in") is always lowercase. We check case below.
PLURAL_SUBJECTS_LOWER = {"vi", "de"}   # checked case-insensitively
PLURAL_I_CAPITAL      = "I"            # only capital I counts as subject pronoun

# Modal / infinitive-governing verbs (signal that following -e verb is infinitive).
# Past-tense modals included: "skulde vi komme" governs infinitive.
MODALS = {
    "at",                                      # infinitive marker
    "kan", "vil", "skal", "må", "bør",
    "lad", "lader", "burde", "tør",
    "gider", "prøver", "begynder", "forsøger",
    "ønsker", "plejer", "agter",
    # past-tense modals (govern infinitives + are themselves blocked via PAST_TENSE_FORMS)
    "skulde", "kunde", "maatte", "vilde",
}

# Clause boundary tokens (reset the context window)
BOUNDARIES = {",", ".", ";", ":", "!", "?", "–", "—", "(", ")", "[", "]", "»", "«"}

# ---------------------------------------------------------------------------
# DDO loader
# ---------------------------------------------------------------------------

def load_ddo(dic_path: Path) -> set[str]:
    words: set[str] = set()
    with open(dic_path, encoding="utf-8-sig") as f:
        for line in f:
            w = line.strip()
            if w:
                words.add(w.lower())
    return words


# ---------------------------------------------------------------------------
# XML text extraction
# ---------------------------------------------------------------------------

_TAG_RE  = re.compile(r"<[^>]+>")
_PIS_RE  = re.compile(r"<\?[^>]+\?>")
_WS_RE   = re.compile(r"\s+")


def extract_text_with_offsets(xml: str) -> list[tuple[int, int, str]]:
    """Return list of (xml_start, xml_end, text_char) pairs — one per visible char.

    Only characters outside XML tags/PIs are returned. Preserves newlines so that
    sentence boundaries can be detected.
    """
    result: list[tuple[int, int, str]] = []
    i = 0
    while i < len(xml):
        if xml[i] == "<":
            # Skip tag or PI
            end = xml.find(">", i)
            if end == -1:
                break
            i = end + 1
        else:
            result.append((i, i + 1, xml[i]))
            i += 1
    return result


def extract_sentences(xml_path: Path) -> list[str]:
    """Extract body text from TEI XML and split into crude sentences.

    Skips the <teiHeader> entirely so that metadata, editor names, and
    bibliographic references do not generate false-positive verb candidates.
    """
    raw = xml_path.read_text(encoding="utf-8")

    # Keep only the <body>...</body> content (or full text if no body tag)
    body_match = re.search(r"<body\b[^>]*>(.*?)</body>", raw, re.DOTALL | re.IGNORECASE)
    content = body_match.group(1) if body_match else raw

    text = _TAG_RE.sub(" ", _PIS_RE.sub(" ", content))
    text = _WS_RE.sub(" ", text).strip()
    # Split on sentence-ending punctuation followed by space+capital
    sentences = re.split(r"(?<=[.!?;])\s+(?=[A-ZÆØÅ])", text)
    return [s for s in sentences if len(s.strip()) > 10]


# ---------------------------------------------------------------------------
# Tokenizer (simple whitespace + punctuation split)
# ---------------------------------------------------------------------------

def tokenize(text: str) -> list[str]:
    """Very simple tokenizer: split on whitespace, keep punctuation separate."""
    tokens = re.findall(r"[\w'æøåÆØÅ]+|[.,;:!?–—()\[\]»«]", text, re.UNICODE)
    return tokens


# ---------------------------------------------------------------------------
# Tier 1: Context-window finite-plural detection
# ---------------------------------------------------------------------------

@dataclass
class Candidate:
    token: str
    token_idx: int
    sentence: str
    method: str           # "window" | "spacy" | "irregular"
    modern_form: str
    confidence: float


def window_candidates(sentences: list[str], ddo: set[str],
                      ods_adjs: set[str] | None = None) -> list[Candidate]:
    """Tier 1: purely rule-based context window — no model required."""
    candidates: list[Candidate] = []

    for sent in sentences:
        tokens = tokenize(sent)
        n = len(tokens)

        for i, tok in enumerate(tokens):
            lw = tok.lower()

            # Must end in -e and be alphabetic
            if not (lw.endswith("e") and lw.isalpha() and len(lw) >= 4):
                continue

            # Skip modals and infinitive markers
            if lw in MODALS:
                continue

            # Skip old-Danish past-tense forms (vare=were, skulde, kunde, …)
            if lw in PAST_TENSE_FORMS:
                continue

            # Skip cardinal/ordinal numbers (fire=4, tredive=30, …)
            if lw in NUMBERS_E:
                continue

            # Skip known adverbs/particles that end in -e and are never verbs
            if lw in ADVERBS_E:
                continue

            # In old Danish all nouns are capitalised.  A mid-sentence
            # capitalised token ending in -e is almost certainly a noun or
            # adjective, not a finite verb.  (Sentence-initial words with a
            # plural pronoun PRECEDING them cannot be sentence-initial in
            # normal SVO order, so this filter is safe for the window pass.)
            if tok[0].isupper():
                continue

            # ODS adjective filter (Round 3): if the stem of the candidate
            # is in the ODS adjective set, it is almost certainly an adjective
            # in weak/plural form (de gode, de lange…) rather than a finite verb.
            # Exception: known IRREGULARS are unambiguous verbs (vide→ved,
            # have→har, etc.) — their stems may coincide with ODS adjectives
            # (vid=wide, løs=loose) so we skip the filter for them.
            if ods_adjs is not None and lw not in IRREGULARS:
                stem = lw[:-1]            # drop final -e
                if stem in ods_adjs or lw in ods_adjs:
                    continue

            # Determine modern form
            if lw in IRREGULARS:
                modern = IRREGULARS[lw]
                # "ere" is the only safe irregular (no context needed for Tier 1)
                if lw == "ere":
                    candidates.append(Candidate(
                        tok, i, sent, "irregular", modern, 0.95))
                    continue
                # other irregulars need context confirmation below
            else:
                stem = lw[:-1]          # drop final -e
                modern = stem + "er"
                # Validate: stem+er must be in DDO
                if modern not in ddo:
                    continue

            # Two-pass window scan: first check for any blocking modal/at in the
            # full window (catches inverted "tør vi ikke VERB"), then check for
            # a plural subject.  Capital "I" only — lowercase "i" is preposition.
            blocked           = False
            found_plural_subj = False
            window_start = max(0, i - 5)
            window_tokens_raw = []
            for j in range(i - 1, window_start - 1, -1):
                t_raw = tokens[j]
                if t_raw.lower() in BOUNDARIES:
                    break
                window_tokens_raw.append(t_raw)

            # Pass 1: block if any modal is anywhere in the window
            for t_raw in window_tokens_raw:
                if t_raw.lower() in MODALS:
                    blocked = True
                    break

            # Pass 2: require a plural subject somewhere in the window
            if not blocked:
                for t_raw in window_tokens_raw:
                    if t_raw.lower() in PLURAL_SUBJECTS_LOWER or t_raw == PLURAL_I_CAPITAL:
                        found_plural_subj = True
                        break

            if found_plural_subj and not blocked:
                confidence = 0.80 if lw not in IRREGULARS else 0.70
                candidates.append(Candidate(
                    tok, i, sent, "window", modern, confidence))

    return candidates


# ---------------------------------------------------------------------------
# Tier 2: spaCy morphological tagging
# ---------------------------------------------------------------------------

def spacy_candidates(sentences: list[str], ddo: set[str]) -> list[Candidate]:
    """Tier 2: use da_core_news_lg dependency parser to find plural-subject verbs.

    Strategy: spaCy cannot distinguish old-Danish finite plural from infinitive
    on morphological grounds (VerbForm=Fin+Plur is not assigned to historical
    plural forms). Instead we use the dependency tree:
      - Find verb tokens ending in -e
      - Look for an nsubj child with Number=Plur
      - If found -> finite plural candidate

    This complements the context-window pass by catching plural NOUN subjects
    (e.g. "Skinnerne ligge") that the pronoun-only window misses.
    """
    try:
        import spacy
        nlp = spacy.load("da_core_news_lg")
    except (ImportError, OSError) as e:
        print(f"  [spaCy not available: {e}] — skipping Tier 2", file=sys.stderr)
        return []

    candidates: list[Candidate] = []
    batch = list(nlp.pipe(sentences, batch_size=32))

    for doc, sent_text in zip(batch, sentences):
        for token in doc:
            lw = token.text.lower()
            if not (lw.endswith("e") and lw.isalpha() and len(lw) >= 4):
                continue
            if token.pos_ not in ("VERB", "AUX"):
                continue
            # Skip old-Danish past-tense forms (explicit blacklist handles irregular
            # past-tense words that spaCy may not tag as Tense=Past)
            if lw in PAST_TENSE_FORMS:
                continue

            # Skip past-tense forms detected by spaCy morphology (-te/-ede endings)
            # Do NOT filter VerbForm=Inf: historical plural presents are tagged Inf.
            if token.morph.get("Tense") == ["Past"]:
                continue

            # Find nsubj children with plural morphology
            plural_subj = any(
                child.dep_ == "nsubj"
                and child.morph.get("Number") == ["Plur"]
                for child in token.children
            )
            if not plural_subj:
                continue

            # Modal check: scan the dep-tree ancestors for modal heads.
            # Also scan the raw-token window (same logic as Tier 1) to catch
            # cases where spaCy mislabels the modal's POS (e.g. "tør" as ADP).
            sent_tokens = [t.text for t in doc]
            tok_i = token.i
            win_start = max(0, tok_i - 6)
            modal_blocked = False
            for j in range(win_start, tok_i):
                if sent_tokens[j].lower() in MODALS:
                    modal_blocked = True
                    break
            # Also check dep-tree ancestors
            if not modal_blocked:
                anc = token.head
                for _ in range(5):   # climb at most 5 levels
                    if anc == token:
                        break
                    if anc.text.lower() in MODALS:
                        modal_blocked = True
                        break
                    anc = anc.head
            if modal_blocked:
                continue

            # Determine modern form
            if lw in IRREGULARS:
                modern = IRREGULARS[lw]
            else:
                modern = lw[:-1] + "er"
                if modern not in ddo:
                    continue   # DDO gate

            candidates.append(Candidate(
                token.text, token.i, sent_text, "spacy-dep", modern, 0.82))

    return candidates


# ---------------------------------------------------------------------------
# Deduplication and reporting
# ---------------------------------------------------------------------------

def deduplicate(window: list[Candidate], spacy_: list[Candidate]) -> list[Candidate]:
    """Merge window + spaCy candidates; prefer window when both agree."""
    key_w = {(c.token.lower(), c.sentence[:40]): c for c in window}
    merged: list[Candidate] = list(window)

    for c in spacy_:
        k = (c.token.lower(), c.sentence[:40])
        if k not in key_w:
            merged.append(c)
        else:
            # Both agree: boost confidence
            existing = key_w[k]
            existing.confidence = min(0.95, existing.confidence + 0.10)

    return merged


def print_report(candidates: list[Candidate], tale: str) -> None:
    if not candidates:
        print("No finite-plural candidates found.")
        return

    by_method: dict[str, int] = {}
    for c in candidates:
        by_method[c.method] = by_method.get(c.method, 0) + 1

    print(f"\n=== Verb plural candidates: {tale} ({len(candidates)} total) ===")
    print(f"  window:    {by_method.get('window', 0)}")
    print(f"  spacy:     {by_method.get('spacy', 0)}")
    print(f"  irregular: {by_method.get('irregular', 0)}")
    print()
    print(f"  {'old':15s}  {'->':3s}  {'modern':15s}  {'conf':5s}  method    context")
    print(f"  {'-'*15}  ---  {'-'*15}  {'-'*5}  --------  -------")
    for c in sorted(candidates, key=lambda x: -x.confidence):
        ctx = c.sentence.strip()[:60].replace("\n", " ")
        print(f"  {c.token:15s}  ->   {c.modern_form:15s}  {c.confidence:.2f}   "
              f"{c.method:9s} {ctx}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input_xml", nargs="?", type=Path,
                    default=_ROOT / "tools" / "normalisering" / "output" /
                            "loop1" / "i-jurabjergene.xml")
    ap.add_argument("--ddo", type=Path,
                    default=_ROOT / "resources" / "dictionaries" /
                            "ddo" / "ddo_DDO.dic")
    ap.add_argument("--ods", type=Path,
                    default=_ROOT / "resources" / "dictionaries" /
                            "ods-lemma" / "ods_lemmas_extracted.tsv",
                    help="ODS lemma TSV for adjective filtering (optional)")
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--sample-only", action="store_true",
                    help="Print to stdout only; do not write trace file")
    args = ap.parse_args()

    tale = args.input_xml.stem
    print(f"Tale: {tale}")
    print(f"DDO:  {args.ddo}")

    ddo = load_ddo(args.ddo)
    print(f"  {len(ddo):,} DDO entries loaded")

    # Load ODS adjective set for Round-3 filtering (suppress adj false positives)
    ods_adjs: set[str] | None = None
    if args.ods and args.ods.exists():
        import csv as _csv
        ods_adjs = set()
        with open(args.ods, encoding="utf-8-sig", newline="") as f:
            for row in _csv.DictReader(f, delimiter="\t"):
                if row.get("char_issue", "").strip() == "Adjective":
                    ods_adjs.add(row["word"].strip().lower())
        print(f"  {len(ods_adjs):,} ODS adjective lemmas loaded")

    sentences = extract_sentences(args.input_xml)
    print(f"  {len(sentences)} sentences extracted")

    print("\nTier 1: context-window pass...")
    w_cands = window_candidates(sentences, ddo, ods_adjs=ods_adjs)
    print(f"  {len(w_cands)} candidates")

    print("Tier 2: spaCy morphological tagging...")
    s_cands = spacy_candidates(sentences, ddo)
    print(f"  {len(s_cands)} candidates")

    merged = deduplicate(w_cands, s_cands)
    print_report(merged, tale)

    if not args.sample_only:
        out_path = args.out or args.input_xml.with_suffix(".verb-plural.tsv")
        fieldnames = ["tale", "old", "modern", "confidence", "method", "context"]
        with open(out_path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter="\t",
                                    lineterminator="\n")
            writer.writeheader()
            for c in merged:
                writer.writerow({
                    "tale":       tale,
                    "old":        c.token,
                    "modern":     c.modern_form,
                    "confidence": f"{c.confidence:.2f}",
                    "method":     c.method,
                    "context":    c.sentence.strip()[:120],
                })
        print(f"\nTrace written: {out_path}")


if __name__ == "__main__":
    main()
