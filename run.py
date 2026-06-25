#!/usr/bin/env python3
"""run.py -- run the HCA modernization conversion chain on one or more XML files.

Steps executed for each input file:
  1. Loop 1  : normalize_xml.py  -- rule-based orthographic normalization
  2. Verb     : tag_verb_plural.py -- finite plural verb detection (trace only)
  3. PoS      : tag_pos.py -- spaCy part-of-speech tagging (opt-in, --pos)

Output lands in tools/normalisering/output/loop1/:
  {stem}.xml              Loop 1 normalized XML
  {stem}.trace.txt        Loop 1 change trace
  {stem}.verb-plural.tsv  Verb plural candidates (human review)
  {stem}.pos.tsv          CoNLL-style PoS tags per token  (if --pos)

Sentence segmentation:
  By default verb and PoS steps extract sentences from the Loop 1 XML.
  Pass --segmented PATH to use pre-tokenized sentence boundaries from the
  hca-tales-segmented corpus (NLTK-based, 161 tales, old-Danish text).
  Recommended for better sentence boundary quality.
  See docs/resources/hca-tales-segmented.md.

Usage:
  python run.py                                    # all XML in input/
  python run.py input/klods-hans.xml               # single file
  python run.py input/*.xml                        # shell glob
  python run.py --input-dir some/folder            # all XMLs in folder
  python run.py --skip-verb-plural                 # Loop 1 only
  python run.py --pos                              # include PoS tagging
  python run.py --pos --segmented ../hca-tales-segmented/HCA_zeroshot_fattigdom_renset.csv
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Canonical paths
# ---------------------------------------------------------------------------

_ROOT   = Path(__file__).parent
_TOOLS  = _ROOT / "tools" / "normalisering" / "tools"
_RULES  = _ROOT / "tools" / "normalisering" / "rules" / "rules.tsv"
_NE     = _ROOT / "tools" / "normalisering" / "rules" / "named_entities.txt"
_DDO    = _ROOT / "resources" / "dictionaries" / "ddo" / "ddo_DDO.dic"
_ODS    = _ROOT / "resources" / "dictionaries" / "ods-lemma" / "ods_lemmas_extracted.tsv"
_OUT1   = _ROOT / "tools" / "normalisering" / "output" / "loop1"

_NORM   = _TOOLS / "normalize_xml.py"
_VERB   = _TOOLS / "tag_verb_plural.py"
_POS    = _TOOLS / "tag_pos.py"


def _run(cmd: list[str | Path], label: str) -> bool:
    """Run a subprocess; print label and return True on success."""
    result = subprocess.run(
        [sys.executable, *[str(c) for c in cmd]],
        capture_output=False,
    )
    if result.returncode != 0:
        print(f"  [FAILED] {label} (exit {result.returncode})", file=sys.stderr)
        return False
    return True


def process_file(xml: Path, *,
                 skip_verb: bool,
                 run_pos: bool,
                 segmented: Path | None) -> bool:
    stem = xml.stem
    _OUT1.mkdir(parents=True, exist_ok=True)

    # --- Step 1: Loop 1 normalization ---
    out1   = _OUT1 / f"{stem}.xml"
    trace1 = _OUT1 / f"{stem}.trace.txt"

    print(f"\n[{stem}] Loop 1 -> {out1.relative_to(_ROOT)}")
    ok = _run([
        _NORM, xml,
        "--out", out1,
        "--trace", trace1,
        "--rules", _RULES,
        "--entities", _NE,
    ], "normalize_xml")
    if not ok:
        return False

    # --- Step 2: Verb plural trace ---
    if not skip_verb:
        out_vp = _OUT1 / f"{stem}.verb-plural.tsv"
        print(f"[{stem}] Verb plural -> {out_vp.relative_to(_ROOT)}")
        ok = _run([
            _VERB, out1,
            "--ddo", _DDO,
            "--ods", _ODS,
            "--out", out_vp,
        ], "tag_verb_plural")
        if not ok:
            return False

    # --- Step 3: PoS tagging (optional) ---
    if run_pos:
        out_pos = _OUT1 / f"{stem}.pos.tsv"
        print(f"[{stem}] PoS -> {out_pos.relative_to(_ROOT)}")
        pos_cmd: list[str | Path] = [_POS, out1, "--rules", _RULES, "--out", out_pos]
        if segmented:
            pos_cmd += ["--segmented", segmented]
        ok = _run(pos_cmd, "tag_pos")
        if not ok:
            return False

    return True


def main() -> None:
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument(
        "files", nargs="*", type=Path,
        help="Input XML files (default: all *.xml in input/)",
    )
    ap.add_argument(
        "--input-dir", type=Path, default=_ROOT / "input",
        help="Folder to glob *.xml from when no files are given",
    )
    ap.add_argument(
        "--skip-verb-plural", action="store_true",
        help="Skip verb plural tagger (Step 2)",
    )
    ap.add_argument(
        "--pos", action="store_true",
        help="Run PoS tagger (Step 3, requires spaCy da_core_news_lg)",
    )
    ap.add_argument(
        "--segmented", type=Path, default=None,
        metavar="CSV",
        help="Path to hca-tales-segmented CSV for accurate sentence boundaries "
             "(used by --pos and improves verb-plural detection). "
             "See docs/resources/hca-tales-segmented.md.",
    )
    args = ap.parse_args()

    if args.files:
        files = args.files
    else:
        files = sorted(args.input_dir.glob("*.xml"))
        if not files:
            sys.exit(f"No XML files found in {args.input_dir}")

    # Sanity-check required resource files
    required = [_RULES, _NE, _DDO, _ODS]
    if args.pos:
        required.append(_POS)
    missing = [p for p in required if not p.exists()]
    if missing:
        for p in missing:
            print(f"Missing resource: {p}", file=sys.stderr)
        sys.exit(1)

    if args.segmented and not args.segmented.exists():
        sys.exit(f"Segmented CSV not found: {args.segmented}")

    ok_count, fail_count = 0, 0
    for xml in files:
        if not xml.exists():
            print(f"File not found: {xml}", file=sys.stderr)
            fail_count += 1
            continue
        if process_file(xml,
                        skip_verb=args.skip_verb_plural,
                        run_pos=args.pos,
                        segmented=args.segmented):
            ok_count += 1
        else:
            fail_count += 1

    print(f"\nDone: {ok_count} ok, {fail_count} failed.")
    if fail_count:
        sys.exit(1)


if __name__ == "__main__":
    main()
