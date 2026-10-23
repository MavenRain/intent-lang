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
- S3 (REFUSE_CELL, rule R1): a domain family with a type parameter must be
  a cell signature, else `REFUSE_CELL` (src/front/check.c: has_type_param,
  cell_param, cell_header, cell_field, cell_generators). Quot is removed.
  Charter and Ratified use Size for the rule type; Orbit is a family of the
  front.c splice; Parity is on Size; ChoiceBag and OrbitN are indexed
  families; Bag is the free commutative monoid. `FreeMon` (the free monoid,
  with fmBind, fmFold, fmMap) is in domain/domain.lang; `List`, `nil`,
  `cons` and `unfold` are kit only (a guest use gives `REFUSE_CELL`). New:
  examples/freemon.lang, test/check/guest-list.lang, 5 REFUSE_CELL rows of
  test/fronttool.c. Review adds 10 fronttool rows: 7 refusals for hidden
  type arguments or invalid labels and 3 accepted cell signatures. Header
  aliases are normalized, higher-kinded parameters and type indices are
  refused, and fixed operation labels are admitted (PLAN section 2).
  Open items O18 to O27 (docs/PLAN.md section 10).
- S4 (cocell comonads, O28): `cofamily D (A : Type n) := c fields` in
  domain/domain.lang only (a guest `cofamily` gives `REFUSE_DATA`). The
  shape check (src/front/check.c: cocell_shape, cocell_kind) admits one
  observation and cofields `D A` or `E -> D A` with closed labels, else
  `REFUSE_CELL`. check_cofamily elaborates the cofamily to text (choice
  (ii)): the positions D.pos, `D A := D.pos -> A`, the destructors, the
  walk D.walk, the corecursor and DBisim, and checks each declaration.
  The domain has `Stream` with sExtend and sDuplicate. New:
  examples/cocell.lang (the comonad laws), 5 eval rows,
  test/check/cofamily-guest.lang and cofamily-state.lang, 27 fronttool rows.

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
