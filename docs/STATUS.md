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
- S5 (sealed Enc, rule O7): `sealed family` and `law def` in
  domain/domain.lang only (a guest use gives `REFUSE_DATA`). The domain has
  `sealed family Enc` (the identity cell monad), encBind, encMap, encOp2
  and the law defs decrypt and observe. check_def_body (src/front/check.c:
  law_uses, law_type) marks a law-only def and gives `REFUSE_LAW` to a
  guest law-only def whose codomain is not a Path or a Trunc1. The host
  model is exponential ElGamal over BN254 G1 (src/front/elgamal.c, not
  guest visible). New: examples/enc.lang and enc-ideal.lang (kit), 7 eval
  rows, 8 check refusals, 11 fronttool rows, test/elgamaltool.c (8 rows).
  The review retains checked declared types and binder annotations so
  normalization and erasure cannot discard law-only references.
- S6 (threshold opening, rule O7): domain/domain.lang has `family Quorum`
  (t of n, public) and the law def `open` (decrypt for each quorum). A
  guest use gives `REFUSE_LAW` with no checker edit. The host opening is
  src/front/threshold.c: a trusted dealer, Shamir shares over Fr, one
  Chaum-Pedersen (DLEQ) proof for each partial decryption with the guest
  `hash` chain as the challenge, and Lagrange in the exponent before the
  BSGS of elg_log (src/front/elgamal.c). New: examples/open.lang,
  examples/threshold.lang (kit: the chain DLEQ, combine and open views), 6
  eval rows, 2 check refusals, 3 fronttool rows, test/thresholdtool.c (15
  rows) and 6 precompile steps. examples/storage.lang renames its state
  field `open` to `isOpen` (a domain name is reserved, rule R4).
  The dealer requires fresh private seed entropy for its polynomial
  coefficients. Review reproduced master-key recovery from one share
  with the original public coefficients and added two dealer regressions.
- S7 (proofs, rule O7): domain/domain.lang has `def ZKProof := Trunc1`
  (the O7 walk skips its argument), `sealed family Transcript` and the law
  def `verified`. The host Sigma verifiers are src/front/sigma.c: a proof
  of randomness and a one-hot ballot (OR proofs bound to ctx, the split
  modulo 2^256). A closed `ecrecover` computes (src/front/secp256k1.c, the
  0x01 rules, high s accepted). src/front/bn254.c fe_add and fe_mul keep
  the top carry for a modulus near 2^256. New: examples/zkproof.lang,
  examples/onehot.lang (kit: randOk, slotOk, splitView, sumX, sumY), the
  view signedBy in examples/precompile.lang, 11 eval rows, 2 check
  refusals, 3 fronttool rows, test/sigmatool.c (14 rows),
  test/secptool.c (6 rows) and 9 precompile steps.
- S8 (Part S, O17): examples/intent.lang has intents with encrypted
  amounts as guest defs over Size: Prod records (O37), the decay rule
  without division, `meaning` under ZKProof, `settle` and `settleS` on the
  opened amounts with the proofs as arguments (O32), the Swap ledger and
  used set, `cancel`, the laws as refl or path defs, FinOf bundles and the
  view tuple (O38). The kit examples/intentsig.lang has cipherDigest,
  intentHash, replayKey (owner, nonce) and fillAuth (the owner 0 is
  refused). Env is `makeEnv now block caller` in the prelude, in `langc
  run` (NOW BLOCK CALLER NAME ARGS) and in each test script; K4c refuses
  `block` until S10. New: examples/blocks.lang, 25 eval rows, 2 check
  refusals, 1 run, 1 run refusal, 1 lower refusal, 2 fronttool rows and
  the vector mode of test/secptool.c.

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
