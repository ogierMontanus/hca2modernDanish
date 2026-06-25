#!/usr/bin/env python3
"""
tag_pos.py -- Part-of-speech tag the Loop 1 normalized text of one tale.

Two sentence-source modes:

  --segmented CSV   Read sentence boundaries from hca-tales-segmented CSV
                    (NLTK-pre-tokenized, 161 tales). Each raw sentence is
                    normalized with Loop 1 rules before spaCy sees it.
                    Recommended: produces the most reliable sentence splits.

  (no --segmented)  Extract text directly from the Loop 1 XML, split on
                    sentence-ending punctuation. Faster but boundaries are
                    approximate.

Output: TSV with one token per row, columns:
  tale  seg_id  tok_id  form  lemma  upos  xpos  feats  head  deprel

Usage:
  python tag_pos.py LOOP1_XML [--segmented CSV] [--rules RULES] [--out PATH]
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path

_HERE = Path(__file__).parent
_NORM = _HERE.parent
_ROOT = _NORM.parent.parent

sys.path.insert(0, str(_HERE))
from rule_engine import load_rules, normalize

# Simple sentence splitter used when no external CSV is supplied.
_SENT_END = re.compile(r'(?<=[.!?»])\s+(?=[A-ZÆØÅ»])')
# Strip XML tags for text extraction
_TAG = re.compile(r'<[^>]+>')


# ---------------------------------------------------------------------------
# Sentence sources
# ---------------------------------------------------------------------------

def sentences_from_csv(tale_slug: str, csv_path: Path) -> list[tuple[int, str]]:
    """Return (segment_id, raw_sentence) pairs for the given tale from CSV."""
    rows: list[tuple[int, str]] = []
    with open(csv_path, encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        # column may be 'saetning' or 'sætning' depending on encoding
        seg_col = next(
            (c for c in reader.fieldnames or []
             if c.lower() in ("saetning", "s\xe6tning")),
            None,
        )
        if seg_col is None:
            raise ValueError(f"No sentence column found in {csv_path.name}")
        for i, row in enumerate(reader):
            if row.get("eventyr", "") == tale_slug:
                rows.append((i, row[seg_col]))
    return rows


def sentences_from_xml(xml_path: Path) -> list[tuple[int, str]]:
    """Extract text from Loop 1 XML and split into rough sentences."""
    text = xml_path.read_text(encoding="utf-8")
    # Remove the teiHeader
    text = re.sub(r'<teiHeader[^>]*>.*?</teiHeader>', '', text, flags=re.DOTALL)
    # Strip tags
    text = _TAG.sub(' ', text)
    # Collapse whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    # Split on sentence-ending punctuation
    parts = _SENT_END.split(text)
    return [(i, p.strip()) for i, p in enumerate(parts) if p.strip()]


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("xml", type=Path,
                    help="Loop 1 XML file (output/loop1/{tale}.xml)")
    ap.add_argument("--segmented", type=Path, default=None,
                    help="Path to hca-tales-segmented CSV (recommended for "
                         "accurate sentence boundaries)")
    ap.add_argument("--rules", type=Path,
                    default=_NORM / "rules" / "rules.tsv")
    ap.add_argument("--out", type=Path, default=None,
                    help="Output TSV path (default: {xml stem}.pos.tsv "
                         "next to input)")
    args = ap.parse_args()

    try:
        import spacy
        nlp = spacy.load("da_core_news_lg")
    except (ImportError, OSError) as e:
        sys.exit(f"spaCy da_core_news_lg required but not available: {e}")

    tale_slug = args.xml.stem
    rules = load_rules(args.rules)
    out_path = args.out or args.xml.with_suffix(".pos.tsv")

    if args.segmented:
        raw_sents = sentences_from_csv(tale_slug, args.segmented)
        if not raw_sents:
            sys.exit(f"No sentences found for '{tale_slug}' in {args.segmented}")
        # Normalize each raw (old-Danish) sentence with Loop 1 rules
        sents = [(sid, normalize(raw, rules)[0]) for sid, raw in raw_sents]
        print(f"  {len(sents)} sentences from CSV  ({args.segmented.name})")
    else:
        raw_sents = sentences_from_xml(args.xml)
        sents = [(sid, txt) for sid, txt in raw_sents]
        print(f"  {len(sents)} sentences extracted from XML")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    texts = [txt for _, txt in sents]
    docs = list(nlp.pipe(texts, batch_size=64))

    with open(out_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f, delimiter="\t")
        writer.writerow(["tale", "seg_id", "tok_id",
                         "form", "lemma", "upos", "xpos", "feats",
                         "head", "deprel"])
        for (seg_id, _), doc in zip(sents, docs):
            for tok in doc:
                writer.writerow([
                    tale_slug,
                    seg_id,
                    tok.i,
                    tok.text,
                    tok.lemma_,
                    tok.pos_,
                    tok.tag_,
                    str(tok.morph) or "_",
                    tok.head.i,
                    tok.dep_,
                ])

    n_tokens = sum(len(d) for d in docs)
    print(f"  {n_tokens:,} tokens -> {out_path}")


if __name__ == "__main__":
    main()
