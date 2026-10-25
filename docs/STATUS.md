# intent-lang status

The build implements the milestones M0 to M2 and a part of M3 (SPEC.md
section 10). The slices S2 to S10R built the language, the DAO contract
and the reactor contract. S11 killed the refusal mutants (12 of 12) and
wrote the close docs, and the plan is closed after it. M0 is complete:
P1 filled the probe file (docs/PLAN.md row P1). M3 has no speed work and
no checked certificate for the output. The final gate is the header of
docs/VALIDATION.md.

## Implemented

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
- S9 (Part D, O34, O35): examples/tally.lang has the encrypted tally as
  guest defs over Size: tallyEnc (the encOp2 sum of n ballots), count,
  hist, lawTallyEnc (by elim on n), lawHist, pass and decide. The link in
  examples/intent.lang has Market (Params and the Swap), settleM at the
  window of the market, lawWindow, govern and OpensH (O41, O42). The kit
  examples/ballot.lang has the views ballotCtx, slotBound, sumBound,
  ballotDigest, ballotSig, tallyX, tallyY, dleqOk, combineX, combineY and
  openOk (O40). test/ballottool.c gives the host words and the host
  results; test/check/tally-leak.lang opens the tally in a def
  (REFUSE_LAW). New: 18 eval rows (tally 6, intent 3, ballot 9), 1 check
  refusal, 9 precompile steps, 1 example (ballot.lang; tally.lang is
  counted at b1) and `ballot regressions`.
- S10 (the DAO contract; O15, O17, O36, O40): `Env.block` lowers to
  NUMBER, and the chain tests set the block by `evm t8n` (opt-in by
  `numbered=1`, PLAN O43). The kit examples/daokit.lang (PLAN O44) has
  the entries castSig, castSlot, castSeal and enact and the views
  tallyWord, windowNow, castCount and stageOf (16702 runtime bytes, 16737
  initcode bytes; 16883 and 16918 after the pay of S10R). `ballottool dao` gives the words and `dao
  regressions`; test/dao.sh runs 33 chain steps and prints the size and
  gas rows; test/run/daokit.script runs on the guest and on the EVM
  chain. New: 1 example (daokit.lang), 11 eval rows, 1 run and 16 evm
  steps (blocks 1, daokit 15); the env-block lower refusal and its check
  leave. The fill is not in S10 (Q-S10-12 (d), PLAN row S10R).
- S10R (the reactor contract; O15, O35, O41, O45, O46): the kit
  examples/reactor.lang has the entries fillCipher, fillAuth, fillOpen,
  fillSettle (6 call words, Q-S11-8 (a)), cancel and transfer and the
  views windowOf, amountOf and closedOf (20571 runtime bytes, 20595
  initcode bytes). The DAO pushes the window: enact pays the new window
  to the reactor address, and the entry transfer sets the window when
  the caller is the DAO address (Q-S11-2 (a)). `times` goes to k <= 16,
  and fillSettle reverts at a window more than 16u (Q-S11-5 (c)).
  test/reactor.sh runs 40 chain steps on the DAO, the reactor and two
  `asmtool mock` tokens and prints the size and gas rows;
  test/run/reactor.script runs on the guest and on the EVM chain (with
  a stub token, PLAN O47). New: 1 example (reactor.lang), 19 eval rows
  (reactor 18, daokit enactPay), 1 run and 26 evm steps; mutants f1 ..
  f9 killed.
- S11 (the refusal mutants and the close; Q-S11-6 (a), Q-S11-7 (a)): one
  mutant for each refusal code that had no intent-lang mutant
  (REFUSE_STATE, REFUSE_DATA, REFUSE_NAME, REFUSE_REC, REFUSE_MAP,
  REFUSE_EVENT, REFUSE_HISTORY_WRITE, REFUSE_AXIOM, REFUSE_KIT, REFUSE_SIG
  and REFUSE_CONTRACT) and q9b: 12 of 12 killed (docs/VALIDATION.md "##
  The refusal mutants (S11)"). The check rows kit-literal-nat-infer.lang
  and kit-literal-word-infer.lang kill q9 (+2 check refusals, +2 kit-only
  refusals; PLAN O49). The S6 mutant lines go into docs/VALIDATION.md.
  No file in src/ changes. S11 writes the close docs, and the plan is
  closed.

## Remaining M0 work

None. P1 filled `probe/CAPABILITY.md` (docs/PLAN.md row P1).

## Known limits

- O16: ElGamal decryption is exponential, so it needs a discrete log. The
  host evaluator bounds the plaintexts for the tests. The chain checks
  `m G` for a claimed `m` and never solves a discrete log.
- O28: `Cofree F` (a cocell field `D A -> F (D A)` for a CM `F`) gives
  REFUSE_CELL. Its positions depend on the shape of `F`, so it needs
  M-types (native codata, or the limit of the finite approximations).
- O29: the BSGS walk is affine (one field inverse for each step), so
  every row stays at 16 plaintext bits. A Jacobian walk with a batch
  inverse makes a larger bound practical.
- O30: the dealer is trusted. The host deals the Shamir shares from fresh
  private seed entropy. A distributed key generation (DKG) replaces the
  dealer. docs/VALIDATION.md states the assumption.
- O31: the chain does not check the Lagrange coefficients. They are
  contract constants (l1 = 2 and l2 = -1 mod r for the quorum {1, 2}). The
  check needs a word multiply, and the word prims have no multiply.
- O37: rule R1 refuses a program family, so Intent, Quote, Transfer and
  Swap are Prod aliases with a constructor def and one accessor def for
  each field, not families.
- O38: `view` is not a def. `observe` is law-only, so privacyI and
  privacyB state the view tuple in their Path types.
- O39: one chain view over all the intent words takes 23 arguments, more
  than the 22 of slotOk. Thus `cipherDigest` hashes the 16 ciphertext
  words, and `intentHash` takes that digest as one argument.
- O45: the chain does not refuse a fill whose intent or quote has a bad
  randomness proof. The randomness proofs stay host rows (`sigma
  regressions`); fillOpen checks only the openings of the amount words.
- The window cap (Q-S11-5 (c)): `times` takes k <= 16, and fillSettle
  reverts at a window more than 16u.
- The transfer selector: the reactor entry `transfer (to : Addr) (amount
  : U256)` has the selector a9059cbb (`transfer(address,uint256)`), the
  selector of the pay CALL of enact. The entry sets the window only when
  the caller is the DAO address (a contract constant). Another caller
  reverts (docs/VALIDATION.md "## The reactor contract (S10R)").
- The gas rows: `dao gas rows` and `reactor gas rows` are printed, not
  checked, so a gas change does not fail the gate. docs/VALIDATION.md
  records the numbers.

## Internal boundaries

`src/front/` holds the front end: the lexer, the parser and the syntax
tree (`lexer.c`, `parser.c`, `ast.h`), the checker with the BUILTINS table,
the visibility classes and the refusal codes (`check.c`), the core terms
(`core.h`), the evaluator, the conversion test and the printer (`eval.c`),
and the entry point (`front.c`). `contract.c` is the contract prelude
(slice K3a): `front_load` reads it after `domain/domain.lang` as trusted
text of origin ORIGIN_KIT. `writer.c` is the contract writer: it writes
the kit program text of the DAO in a checked guest program.

The host crypto is in `src/front/`: `u256.c` (256-bit words), `bn254.c`
(the field and G1), `secp256k1.c` (the recovery of the host ecrecover),
`blsag.c` (bLSAG rings) and `src/keccak.c`. `elgamal.c` (exponential
ElGamal), `threshold.c` (the threshold opening) and `sigma.c` (the Sigma
verifiers) are not in `langc`: only the test tools link them
(Makefile:12-16).

`src/lower.c` lowers a checked program to the first-order IR of
`src/ir.h` (K4a). `src/evm.c` (the EVM back end and the ABI selectors) and
`src/asm.c` (the assembler) write the EVM bytecode behind the interface of
`src/target.h`. `src/main.c` is the `langc` command (exit 0 ok, 1 refused,
2 usage or IO).

`make -B check` runs `test/gate.sh` first: the examples, the parse and
check refusals (`test/parse/expect.txt`, `test/check/expect.txt` and
`kit.txt`), the kit-only refusals, the evals (`test/eval/expect.txt`), the
proves, the contract rows (`test/contract/dao.expect`), the ring sizes and
the guest differential (`test/contract/diff.txt`). Then `test/run.sh`
(the runs and the host differential), `asm.sh`, `build.sh`
(`test/lower/expect.txt`), `dispatch.sh`, `evm.sh` (`test/abi.expect`),
`precompile.sh`, `mock.sh`, `dao.sh`, `reactor.sh`, `diff.sh` and
`review.sh` run. The C tools (fronttool to evmtool) check the domain,
crypto, path, run, writer, build, lowering, emitter and hashing rows.

A guest program (origin ORIGIN_PROGRAM) can use only the VIS_GUEST names.
A VIS_INTERNAL name (the kit words `Nat`, `Flag`, `U256`, `Addr`, `Map` and
their prims, `hash`, `ecrecover`, the curve prims and the zk prims) or a
name of origin ORIGIN_KIT gives REFUSE_KIT, and `langc --kit` admits it. A
VIS_CELL name (the cons list: `List`, `nil`, `cons` and `unfold`, PLAN O24)
gives REFUSE_CELL (rule R1). A law-only name (`decrypt`, `observe`,
`open`, `verified`, an elim, fold or projection of a sealed family) out of
a law gives REFUSE_LAW. A reserved, core or domain name gives REFUSE_NAME,
and a use of the definition itself or of a later one gives REFUSE_REC.
