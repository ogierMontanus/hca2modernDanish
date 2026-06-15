#!/usr/bin/env bash
# End-to-end checks for the v2 normalization tooling.
# Run from normalisering/tests/ :  bash run_tests.sh
set -u
cd "$(dirname "$0")"
TOOLS=../tools
RULES=../rules/rules.tsv
fail=0

ok()   { printf '  ok   %s\n' "$1"; }
bad()  { printf '  FAIL %s\n' "$1"; fail=1; }
check(){ # check "name" "expected" "actual"
  if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected [$2] got [$3])"; fi
}

echo "== 1. extractor produces a non-empty rule table =="
n=$(grep -vc '^#' "$RULES")
[ "$n" -ge 40 ] && ok "rule table has $n rules" || bad "rule table too small ($n)"

echo "== 2. clean normalization (AWK reference) =="
out=$(printf 'Maaneder og Aaret\n' | awk -v RULES="$RULES" -f "$TOOLS/normalize.awk")
check "aa→å, Aa→Å" "Måneder og Året" "$out"
out=$(printf 'Photographi\n' | awk -v RULES="$RULES" -f "$TOOLS/normalize.awk")
check "Ph→F, raph→raf" "Fotografi" "$out"

echo "== 3. runtime loop guard (returning cycle) =="
out=$(printf 'Aaret\n' | awk -v RULES=cyclic_rules.tsv -v TRACE=1 -f "$TOOLS/normalize.awk" 2>/dev/null)
case "$out" in
  *"[LOOP-GUARDED]"*) ok "cyclic rules trigger the loop guard" ;;
  *) bad "loop guard did not fire: $out" ;;
esac

echo "== 4. static cycle detection exit codes =="
python "$TOOLS/detect_cycles.py" "$RULES" >/dev/null 2>&1
check "clean table exits 0" "0" "$?"
python "$TOOLS/detect_cycles.py" cyclic_rules.tsv >/dev/null 2>&1
check "cyclic table exits 1" "1" "$?"

echo "== 5. weighted edit distance ranks attested edits first =="
top=$(python "$TOOLS/weighted_edit_distance.py" edit_costs.sample.tsv qvinde kvinde svinde \
      | grep -v '0.000' | head -1 | cut -f2)
check "qvinde ranks kvinde above svinde" "kvinde" "$top"

echo "== 6. rule mining + uncertainty queue =="
tmp=./_mineout   # relative path: resolves identically for bash and native python
rm -rf "$tmp"
python "$TOOLS/mine_rules.py" sample_edits.tsv \
    --lexicon modern_lexicon.sample.txt \
    --variants known_variants.sample.tsv \
    --threshold 0.85 --out-dir "$tmp" >/dev/null 2>&1
[ -s "$tmp/candidate_rules.json" ] && ok "candidate_rules.json written" || bad "no candidates"
q=$(python -c "import json;print(len(json.load(open('$tmp/review_queue.json'))))")
[ "$q" -ge 1 ] && ok "review queue populated ($q low-confidence items)" || bad "empty review queue"
rm -rf "$tmp"

echo "== 7. historical variant knowledge base present and sane =="
hv=../rules/historical_variants.tsv
if [ -f "$hv" ]; then
  rows=$(grep -vc '^#' "$hv")
  [ "$rows" -ge 100 ] && ok "historical_variants.tsv has $rows pairs" || bad "too few pairs ($rows)"
  grep -qP '^Qvinde\tkvinde\t' "$hv" && ok "contains Qvinde→kvinde" || bad "missing Qvinde→kvinde"
else
  bad "historical_variants.tsv missing (run extract_ordlister.py)"
fi

echo "== 8. Python rule engine agrees with normalize.awk =="
printf 'Maaneder og Aaret\nKaffeen var reel\nPhotographi\n' > ./_eng.txt
awk -v RULES="$RULES" -f "$TOOLS/normalize.awk" ./_eng.txt > ./_awk.out
PYTHONIOENCODING=utf-8 python "$TOOLS/rule_engine.py" "$RULES" < ./_eng.txt | sed 's/  #.*//' > ./_py.out
if diff -q ./_awk.out ./_py.out >/dev/null; then ok "awk and python engines agree"; else bad "engines diverge"; fi
rm -f ./_eng.txt ./_awk.out ./_py.out

echo "== 9. Hunspell spell-check (skipped if spylls/DDO absent) =="
ddo=../../ordbøger/aaTilÅ/ddo_DDO.dic
if python -c "import spylls" 2>/dev/null && [ -f "$ddo" ]; then
  out=$(PYTHONIOENCODING=utf-8 python "$TOOLS/spellcheck_refine.py" sample_corpus.txt \
        --rules "$RULES" --lexicon "../../ordbøger/aaTilÅ/ddo_DDO" --out-dir ./_sc 2>&1)
  case "$out" in
    *"reel -> rel"*) ok "flags reel->rel (over-normalization)";;
    *) bad "did not flag reel->rel: $out";;
  esac
  case "$out" in
    *"Aagaard"*) bad "false-positive on name Aagaard";;
    *) ok "name Aagaard left alone";;
  esac
  rm -rf ./_sc
else
  printf '  skip spylls or DDO dictionary not available\n'
fi

echo
if [ "$fail" -eq 0 ]; then echo "ALL TESTS PASSED"; else echo "SOME TESTS FAILED"; fi
exit $fail
