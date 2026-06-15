#!/usr/bin/awk -f
#
# normalize.awk - reference rule-based normalizer with runtime loop protection.
#
# This is the AWK reference implementation requested in the deliverables. It is
# deliberately small and transparent: the production pipeline stays in XSLT, but
# this script defines the *semantics* the v2 design commits to, and is what the
# test-suite and CI run against.
#
# It applies the canonical rule table (rules.tsv) to each input line, iterating
# to a fixpoint, while guarding against rewrite loops exactly as specified:
#
#     seen_forms = {}
#     while a rule applies:
#         if current_form in seen_forms: stop, keep current form, log it
#         seen_forms.add(current_form)
#
# Replacement is LITERAL (not regex), so spaces and punctuation in sources are
# significant and safe. Every applied rule is recorded so the normalization is
# fully traceable (explainability requirement).
#
# Usage:
#   awk -v RULES=../rules/rules.tsv [-v TRACE=1] [-v MAXITER=100] \
#       -f normalize.awk  input.txt
#
# Output: one normalized line per input line.
# With TRACE=1: each line is followed by  # rules: R0001,R0027,...
#               and loop events are reported on stderr.

BEGIN {
    if (RULES == "") { print "normalize.awk: set -v RULES=path/to/rules.tsv" > "/dev/stderr"; exit 2 }
    if (MAXITER == "") MAXITER = 100
    n = 0
    while ((getline line < RULES) > 0) {
        if (line == "" || substr(line, 1, 1) == "#") continue
        nf = split(line, f, "\t")
        # columns: id, source, target, confidence, period_from, period_to, enabled
        if (nf >= 7 && f[7] != "1") continue          # skip disabled rules
        n++
        rid[n]  = f[1]
        src[n]  = unescape_tab(f[2])
        tgt[n]  = unescape_tab(f[3])
        conf[n] = (nf >= 4 ? f[4] : "1.0")
    }
    close(RULES)
}

# Literal "replace all occurrences of find in s with repl".
function replace_all(s, find, repl,   out, i, fl) {
    if (find == "") return s
    out = ""
    fl = length(find)
    while ((i = index(s, find)) > 0) {
        out = out substr(s, 1, i - 1) repl
        s = substr(s, i + fl)
    }
    return out s
}

function unescape_tab(s) { gsub(/\\t/, "\t", s); return s }

{
    form = $0
    delete seen
    seen[form] = 1
    applied = ""
    looped = 0
    for (iter = 0; iter < MAXITER; iter++) {
        changed = 0
        for (k = 1; k <= n; k++) {
            new = replace_all(form, src[k], tgt[k])
            if (new != form) {
                form = new
                applied = applied (applied == "" ? "" : ",") rid[k]
                changed = 1
            }
        }
        if (!changed) break                       # fixpoint reached: done
        if (form in seen) {                       # state repeats: loop guard
            looped = 1
            if (TRACE) printf("LOOP: line %d returned to a prior state; stopping at %d iters\n", NR, iter) > "/dev/stderr"
            break
        }
        seen[form] = 1
    }
    if (iter >= MAXITER && TRACE)
        printf("LOOP: line %d hit MAXITER=%d without converging\n", NR, MAXITER) > "/dev/stderr"

    if (TRACE)
        print form "  # rules: " (applied == "" ? "(none)" : applied) (looped ? " [LOOP-GUARDED]" : "")
    else
        print form
}
