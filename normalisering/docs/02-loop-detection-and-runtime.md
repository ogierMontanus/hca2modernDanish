# 02 — Loop detection (static) and loop prevention (runtime)

The legacy pipeline can enter rewrite loops. We address this at **two layers**:
a static analyzer that runs before deployment (CI gate), and a runtime guard
that protects every token even if a bad rule slips through.

> Termination of an arbitrary string-rewriting system is undecidable. We
> therefore do not claim to *prove* termination; we (a) detect the concrete loop
> classes that occur here, and (b) make runaway rewriting impossible at runtime.

## 2. Automatic loop detection — `detect_cycles.py`

Two complementary static checks over `rules.tsv`:

### a) Literal cycles
Treat each rule as a directed edge `source → target`. A cycle means a set of
rules maps a form back onto itself. DFS with grey/black colouring reports both:

```
aa → å            (direct,   C0001/C0002)
A → B → C → A      (indirect, C0003/C0004/C0005)
```

Literal cycles are **always errors** → the tool exits non-zero so CI fails.

### b) Re-trigger (expansion) hazards
A rule `s → t` is a hazard when `t` still *contains* some enabled rule's source,
so applying it produces text another rule (or itself) will rewrite again. On the
current real table this flags **13 hazards**, including:

```
R0009   Fee →  Feee   re-triggers R0009 ( Fee →  Feee)   ← self-growing!
R0006  leet → leeet   re-triggers R0027 (ee → e)         ← the ee→e work-around
```

These are not all bugs — the `leet → leeet` family is the *intentional*
mechanism that lets the global `ee → e` collapse leave a single `ee`. But each
is a runtime-loop risk and must be covered by a runtime guard + a regression
test. Surfacing them automatically replaces the fragile hand-maintained
"preamble/postludium" comments in the stylesheet with a checkable invariant.

Run:

```bash
python detect_cycles.py ../rules/rules.tsv            # human report, CI gate
python detect_cycles.py ../rules/rules.tsv --format json
```

## 3. Runtime loop protection — `normalize.awk`

Even after static validation, the runtime keeps a per-token history and refuses
to revisit a state — exactly the spec's design:

```
seen_forms = {}
while a rule applies:
    if current_form in seen_forms:    # we've been here before
        stop; keep current form; log the event
    seen_forms.add(current_form)
```

Two independent stops:

1. **Returning loop** (`A → B → A`, or `A→B→C→A`): the form re-enters a state in
   `seen_forms` → stop immediately, mark `[LOOP-GUARDED]`. Demonstrated:

   ```
   $ printf 'Aaret\n' | awk -v RULES=cyclic_rules.tsv -v TRACE=1 -f normalize.awk
   LOOP: line 1 returned to a prior state; stopping at 0 iters
   Aaret  # rules: C0003,C0004,C0005 [LOOP-GUARDED]
   ```
   (`Aaret → Baret → Caret → Aaret`, caught the instant it returns.)

2. **Unbounded growth** (`Fee → Feee → Feeee …`, which never *repeats* a state):
   bounded by `MAXITER` (default 100), reported on stderr. The seen-set catches
   cycles; the iteration cap catches monotone divergence.

When a guard fires the token keeps its **best safe form so far** and the event
is logged, so a single pathological token never stalls a corpus run and the
problem is visible rather than silent.

### Why a fixpoint loop at all?
The legacy stylesheet applies each rule exactly once in order, which trivially
terminates but makes correctness depend on hand-tuned ordering (the source of
the `ee` work-arounds). The v2 reference iterates to a fixpoint so rule *order*
matters less and the table is easier to reason about — and the loop guard is
what makes iterating safe. Production XSLT can keep single-pass semantics; the
analyzer + guard apply to both.

## CI wiring
`../.github/workflows/normalization-eval.yml` runs `detect_cycles.py` on every
PR; a literal cycle blocks merge. See [`03`](03-github-workflow.md).
