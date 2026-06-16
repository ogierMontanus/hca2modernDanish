#!/usr/bin/env python3
"""run.py — run the HCA modernization conversion chain on one or more XML files.

Steps executed for each input file:
  1. Loop 1  : normalize_xml.py  — rule-based orthographic normalization
  2. Verb     : tag_verb_plural.py — finite plural verb detection (trace only)

Output lands in tools/normalisering/output/loop1/{stem}.xml (Loop 1 result)
and {stem}.verb-plural.tsv (verb plural trace for human review).

Usage:
  python run.py                          # process all XML files in input/
  python run.py input/klods-hans.xml     # single file
  python run.py input/*.xml              # shell glob
  python run.py --input-dir some/folder  # all XMLs in a folder
  python run.py --skip-verb-plural       # Loop 1 only (faster)
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


def _run(cmd: list[str | Path], label: str) -> bool:
    """Run a subprocess command, print result. Returns True on success."""
    result = subprocess.run(
        [sys.executable, *[str(c) for c in cmd]],
        capture_output=False,
    )
    if result.returncode != 0:
        print(f"  [FAILED] {label} (exit {result.returncode})", file=sys.stderr)
        return False
    return True


def process_file(xml: Path, skip_verb: bool) -> bool:
    stem = xml.stem
    _OUT1.mkdir(parents=True, exist_ok=True)

    # --- Step 1: Loop 1 normalization ---
    out1 = _OUT1 / f"{stem}.xml"
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
        help="Folder to glob *.xml from when no files are specified",
    )
    ap.add_argument(
        "--skip-verb-plural", action="store_true",
        help="Skip verb plural tagger (Step 2)",
    )
    args = ap.parse_args()

    if args.files:
        files = args.files
    else:
        files = sorted(args.input_dir.glob("*.xml"))
        if not files:
            sys.exit(f"No XML files found in {args.input_dir}")

    # Sanity-check resource files exist
    missing = [p for p in [_RULES, _NE, _DDO, _ODS] if not p.exists()]
    if missing:
        for p in missing:
            print(f"Missing resource: {p}", file=sys.stderr)
        sys.exit(1)

    ok_count, fail_count = 0, 0
    for xml in files:
        if not xml.exists():
            print(f"File not found: {xml}", file=sys.stderr)
            fail_count += 1
            continue
        if process_file(xml, args.skip_verb_plural):
            ok_count += 1
        else:
            fail_count += 1

    print(f"\nDone: {ok_count} ok, {fail_count} failed.")
    if fail_count:
        sys.exit(1)


if __name__ == "__main__":
    main()
