# intent-lang status

> Write here: one paragraph. Say which milestone the build implements, and
> which milestone it does not complete yet.

## Implemented

> Write here: one item for each feature that works. Name the former (F1 to
> F15), the core type or the core operation.

- S2 (kernel port): `src/`, `domain/`, `examples/`, `test/`, `gen/` and
  the Makefile of orbit-lang 2162fb2 (by `git archive`), and the orbit
  text of SPEC.md, docs/host/README.md, docs/VALIDATION.md,
  formers/FORMERS.md, formers/tcc-evm-contract.md and probe/CAPABILITY.md.
  `examples/inventory.lang` and `test/check/domain-name.lang` are removed
  (orbit-lang removed them in 7734007). The gate gives the orbit-lang
  counts (docs/PLAN.md section 9). Name changes in the orbit text: SPEC.md
  line 1 (the title), line 3 (the working name) and line 14 (the purpose)
  say intent-lang; docs/host/README.md line 3 adds "intent-lang S2 ports it
  from orbit-lang 2162fb2". These stay: the provenance comments
  `(orbit-lang Sn ...)`, the DAO words (`Orbit`, `orbitProj`), the bLSAG
  domain tag "orbit" (Q-S2-1) and docs/VALIDATION.md, which records the
  final gate of orbit-lang.

## Remaining M0 work

> Write here: one numbered item for each missing feature. Say what each item
> needs first.

1. <work item>.

## Known limits

> Write here: one item for each limit of the current build, with its cause
> (a fuel budget, a host limit, a stack size).

- <limit>.

## Internal boundaries

> Write here: one paragraph for each module group. Say which module holds
> which job, which tests check which tables, and which types a program
> cannot use.
