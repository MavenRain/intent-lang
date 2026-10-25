# intent-lang plan

intent-lang is a Cubical TT language for two parts of one system: a
zero-knowledge, homomorphically encrypted, multi-party self-referential DAO
(the DAO of MavenRain/orbit-lang), and the private intent swap protocol that
the DAO governs. A program declares the DAO and the swap protocol. The
compiler checks the laws and writes the EVM bytecode of the contract. The
contract deploys to any EVM chain, for example Telcoin Network or Ethereum
mainnet. `design/DESIGN.md` holds the request and the design verbatim.

## 1. Rulings

USER rulings (the request, 2026-10-22):

- R1 type formers: for type constructors (higher kinds), only cell monads
  and their duals, in a locally presentable, locally cartesian closed
  (infinity,1)-category, as Cubical TT realizes it.
- R2 base types and operations: the minimum that a program needs for a ZK
  FHE MPC self-referential DAO (MavenRain/orbit-lang) that governs a ZK FHE
  intent swap protocol with the pasted denotational design.
- R3 host: TinyCC.
- R4 target: EVM bytecode for any EVM chain (Telcoin Network, Ethereum
  mainnet).

USER rulings (S1, 2026-10-22), verbatim:

> For rulings, I will say blocks for Q4, and check from the declaration's
> shape for Q2, taking recommendations for the rest of the Qs.

- Q1 (a): ambient Pi, Sigma, Path and U with Glue are not limited. The
  declared type constructors are only CM (cell monads) and CC (cocell
  comonads).
- Q2 (a): the cell criterion is syntactic: the type parameter occurs only
  in the generator. Cons lists are refused; the free monoid is used.
- Q3 (a): `Enc` is the identity cell monad with a sealed eliminator.
  `decrypt` is law-only. Exponential ElGamal on BN254, MPC opening, general
  `bind` off the chain.
- Q4 (b): decay progress is in BLOCKS, not seconds. This is NOT the plan
  default. Sections 3.2, 3.3, 4.1, 7 and O17 give the consequences.
- Q5 (a): the governed parameter is `window`, now a number of blocks.
- Q6 (a): `ecrecover` for the intent signature, one contract for the DAO
  and the reactor.
- Q7: `startOut : Enc Amount` is added to `Intent`; the prose formula
  (`decay i ≤ o`) is the reading.
- Q8: the orbit-lang DAO slot `Outcome` is renamed `Decision`.

USER rulings (S3 step 0, 2026-10-22): the RECOMMENDED option (a) of each
of Q-S2-1 and Q-S3-1 to Q-S3-4 (section 11).

- Q-S2-1 (a): the bLSAG domain tag stays "orbit" until S9.
- Q-S3-1 (a): REFUSE_CELL checks the `family` declarations of
  `domain/domain.lang` and the type builtins. List (a cons list) is
  replaced by the free monoid.
- Q-S3-2 (a): the defs of type `U -> U` are ambient constructions.
- Q-S3-3 (a): Bag, Quot, Charter and Ratified are rewritten as cell
  signatures or moved to ambient constructions. Each law stays.
- Q-S3-4 (a): the test rows with the cell shape stay; each other row gets a
  family with the cell shape that tests the same rule; one REFUSE_CELL row
  for each refused shape.
- Q-S4-1 .. Q-S4-6 (a), USER 2026-10-22: "just record all of the recommended
  rulings". A `cofamily` declaration in `domain/domain.lang`, elaborated to
  its position encoding; a field `D A -> F (D A)` is REFUSE_CELL (O28); one
  observation, other fields `D A` or `E -> D A` with E closed data; the
  clause name is the corecursor and `DBisim` is generated; Stream only; no
  EVM lowering.
- Q-S5-1 .. Q-S5-6 (a), USER 2026-10-23: "Rule all defaults for Q-S5-01
  . . . Q-S5-06". `sealed family Enc` in `domain/domain.lang`; `law def
  decrypt` and the law-only rule (Trunc1 arguments exempt, REFUSE_LAW);
  `observe` by `trunc1`, `Trunc1 A` spelling; host ElGamal in
  src/front/elgamal.{c,h}, not guest visible; no EVM lowering (an `Enc`
  state field is REFUSE_STATE); `open` and `Quorum` in S6.
- Q-S6-1 .. Q-S6-7 (a), USER 2026-10-23: "All (a) (Recommended)".
  `family Quorum := quorum (quorumT : Size) (quorumN : Size)` and `law def
  open` in `domain/domain.lang`; host threshold opening in
  src/front/threshold.{c,h} on `elg_log`; a trusted dealer, Shamir shares
  and Chaum-Pedersen proofs (A, B, z); every row at bits 16; chain rows in
  examples/threshold.lang; the opener gives lambda_i (no chain check until
  S10).
- Q-S7-1 .. Q-S7-9 (a), USER 2026-10-23: "Rulings on Q-S7-1..9: all (a)."
  `def ZKProof` as `Trunc1 W` in `domain/domain.lang` (the O7 walk skips
  its arguments), `sealed family Transcript` and `law def verified`; guest
  statements in examples/zkproof.lang; host Sigma proofs in
  src/front/sigma.{c,h} (a randomness DLEQ, one-hot OR proofs bound to ctx,
  the split modulo 2^256); chain rows in examples/onehot.lang; host
  ecrecover in src/front/secp256k1.{c,h} (a closed ecrecover computes, R17
  amended) and the view signedBy.
- Q-S8-1 .. Q-S8-9 (a), USER 2026-10-24: "Take all recommendations for
  rulings." Part S as guest program defs over Size in examples/intent.lang
  (no domain edit): Intent without the zk field, Quote, Transfer, Outcome;
  the affine decay check (no division) and meaning as a ZKProof; settle
  takes its proofs as arguments and computes on the opened a and o; Swap
  with a ledger and the used (owner, nonce) set; the FinOf bundle (Fin3
  fallback); the kit replay key hash (owner, nonce) in
  examples/intentsig.lang; Env as makeEnv now block caller and the call
  format NOW BLOCK CALLER NAME ARGS... (O17), with examples/blocks.lang.
- Q-S9-1 .. Q-S9-9 (a), USER 2026-10-24: "take all recommendations for
  Q-S9-1 .. Q-S9-9." Part D in the guest file examples/tally.lang and the
  link at the end of examples/intent.lang; `Hist := Choice -> Size`,
  `Ballot := Enc Hist`, the FinOf ballots (Fin3 fallback) and tallyEnc by
  elim on n; the guest theorems lawTallyEnc and lawHist; `Params := Size`
  (window), `Decision := Params`, a tie keeps the old Params, the DAO
  slot stays `Outcome`; `Market := Prod Params Swap`, so a fill reads its
  window from the market (O35); ctx is ballotCtx of the key image (O34),
  the ring signs ballotDigest, the host data is test/ballottool.c; the
  chain views as eval rows and precompile steps, the cast entry, the
  tally state and the enact entry are S10 (O40).
- Q-S10-1 .. Q-S10-10 (a), USER 2026-10-24: "Rulings on Q-S10-1..10: take
  all recommendations." A step with BLOCK more than 0 runs `evm t8n` (env
  currentNumber BLOCK, currentTimestamp NOW; CALLER is the key address
  0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b), a step at BLOCK 0 stays
  `evm run --prestate` (O36); `IR_ENV_BLOCK` lowers to NUMBER (0x43) and
  test/lower/env-block.lang leaves the refusal list (O17);
  examples/dao.lang is a kit file written by hand from the host constants,
  and src/front/writer.c does not change; one contract for the DAO and the
  reactor (O15: if the size row is over EIP-170, STOP and ask); the cast
  is castSig, castSlot and castSeal under the nullifier N = hash (hash ix
  iy) poll, and a second castSig of a pending N starts N again (O39); 8
  tally words start at 0 (the ecAdd identity), with `casts` and `castEnd`
  (castSeal reverts when block is more than castEnd, enact reverts when
  block is not more than castEnd and a second time); enact opens slot 0
  with the quorum {1, 2}, no = casts - yes, window := decide proposal
  window, so O31 becomes "the Lagrange constants are contract constants";
  the fill is fillCipher, fillAuth, fillOpen, fillSettle and cancel, and
  the intent and quote randomness proofs stay host rows (a new O row); the
  host data is `ballottool dao` with `dao regressions`; the chain test is
  test/dao.sh and test/run/dao.script on the guest and the EVM.
- Q-S11-1 .. Q-S11-4, Q-S11-6, Q-S11-7 (a) and Q-S11-5 (c), USER
  2026-10-25 (the S11 kickoff; the survey is
  ~/Documents/intent-lang-work/S11-survey.md). S10R comes before S11,
  and S11 closes the plan with the reactor in it. The DAO pushes the
  window at enact: one `pay` to the reactor address, and the reactor
  entry `transfer (to : Addr) (amount : U256)` sets window when the
  caller is the DAO address (a probe first checks the selector). The
  mock tokens are the `asmtool mock` runtime at 0x..ee and 0x..ef. S10R
  adds examples/reactor.lang, test/run/reactor.script and
  test/reactor.sh (`reactor size rows`, `reactor gas rows` and `reactor
  chain`). `times` goes to k <= 16, and fillSettle reverts when the
  window is more than 16u (Q-S11-5 (c), in place of the 8u of Q-S10-11
  (a)). S11 adds one mutant for each of the 11 refusal codes that have
  no intent-lang mutant, and writes all the close docs.
- Q-S11-8 (a), USER 2026-10-25 (the S10R size stop): fillSettle takes
  so, mo, start and amtIn as call words, each checked one time against
  fillWord.

Builder calls (NOT ruled; section 10 gives each one; section 11 gives the
questions that the USER ruled in S1):

- O1: the name intent-lang.
- O2: the kit is hosts/tcc-evm-contract (U256, Addr, Env, `pay`, `pull`,
  events). The cubical kernel, the BN254 host and the bLSAG ballots come
  from orbit-lang at 2162fb2 (section 6).
- Tests are guest-language files plus `langc run` scripts. The kit gate
  scripts stay. We add no new harness.

## 2. The reading of R1

R1 has two parts: the ambient category, and the type constructors that a
program can declare.

### 2.1 The ambient structure

A locally presentable, locally cartesian closed (infinity,1)-category has
dependent sums and products along each map (base change
`Sigma_f -| f* -| Pi_f`), identity types and, with univalence, a universe.
Cubical TT (CCHM) realizes this structure with computation:

| Ambient part | Cubical TT term | Note |
|---|---|---|
| Pi, Sigma | `(x : A) -> B x`, `(x : A) * B x` | the LCC structure |
| identity | `Path A a b`, `PathP`, the interval `I`, `transp`, `hcomp` | Kan operations |
| universe | `U`, `Glue`, `ua` | univalence by Glue |

These are the internal language of the category. A program does not
declare them, and R1 does not limit them. The pair type `A * B` and the
function type `A -> B` are ambient.

### 2.2 The admitted type constructors

A type constructor is a declaration with a type parameter, or any map
`U -> U`. R1 admits two classes and no others (O3):

| Class | Definition | Structure from the kernel | Examples |
|---|---|---|---|
| CM, cell monad | The free algebra monad of a cell signature. The type parameter `A` occurs in one constructor only, the generator `eta : A -> T A`. Each other constructor (a point, path or higher cell) takes closed base data and arguments of type `T A` only. | unit = `eta`; bind = the recursor; the three laws are paths by the induction principle | `Option` (one 0-cell), `Either E` (E 0-cells), the free monoid (`List`), the free commutative monoid (`Bag`, a QIT), `‖-‖` (propositional truncation: one 1-cell `squash`), `‖-‖_0`, the quotient `X / act` of the DAO, the identity monad |
| CC, cocell comonad | The cofree coalgebra comonad of a cocell signature: a coinductive record with one observation `eps : D A -> A`; each other field has type `D A -> D A` or `D A -> E -> D A` with `E` closed data (Q-S4-2 (a); `D A -> F (D A)` waits for O28). | counit = `eps`; extend = the corecursor; the laws are paths by coinduction | `Stream` (`Cofree F`: O28) |

Why the two adjectives in R1 matter:

- Locally presentable: the small object argument gives the free algebra of
  each set of cells. So each cell signature has its monad.
- Locally cartesian closed: base change gives Pi and Sigma, so the ambient
  part of 2.1 exists, and `Path A a b` is the fiber of `I -> A` over its
  end points.

New refusal code (S3): `REFUSE_CELL` refuses a parameterized declaration
that is not a cell signature or a cocell signature. Example: `data Pair (A :
U) := mk A A` is refused (`A` occurs outside the generator). The admitted
form is the ambient `Bool -> A` or `A * A`.

Consequence for lists: `cons : A -> List A -> List A` uses `A` outside the
generator, so the cons form of List is refused. A program uses the free
monoid (`eta`, `e`, `m`, the unit and associativity paths, set
truncation). The kernel can give the cons form as a derived view (O4).

`filter` (former F8 of lang-template) is not a former under R1. It is a
derived operation: `filter p = bind (\a. if p a then eta a else e)`.

## 3. The minimal base signature (R2)

Each name has one of three kinds, as in orbit-lang:

| Kind | Meaning |
|---|---|
| slot | The program gives the type from formers and kit base data. |
| defined | The prelude defines it from slots, formers and kit base data. |
| primitive | Opaque. The kit implements it. Only the listed operations use it. |

Kit base data (tcc-evm-contract): `U256`, `Addr`, `Env` (`now`, `caller`;
`block` is added by O17),
`Out` (`pay`, `pull`, `emit`), the contract `State`. No other base data.
`Nat` stays internal to the kernel, as in orbit-lang.

### 3.1 Part D: the DAO

From the orbit-lang design (its sections "Types" and "Operations"), with the
FHE and MPC layer of this request:

| Name | Kind | Reading |
|---|---|---|
| Member, Choice, Group | slot | as orbit-lang |
| Decision | slot | The orbit-lang slot `Outcome`, renamed (O5). The DAO decides one value of `Params` (section 3.3). |
| Config, Orbit, Constitution, Aggregation, Tally | defined | as orbit-lang; `Orbit := Config / act` is a CM instance (the reflection onto trivial actions) |
| act, orbitProj, aggregate, gov, amend | defined | as orbit-lang |
| Ballot_priv | defined | `Enc (Choice -> U256)`: an encrypted one-hot vector (FHE), signed with a bLSAG ring signature (ZK anonymity) |
| ZKWitness | primitive | the bLSAG witness of orbit-lang plus the one-hot proof (a disjunctive Chaum-Pedersen proof) |
| castPrivate, proveZK, verifyZK, project | defined over the primitives | as orbit-lang, on `Ballot_priv` |
| tallyEnc | defined | the homomorphic sum of the ballots: `Enc (Choice -> U256)` |
| open | primitive | the MPC opening (3.4) |

TCM law of the DAO tally (new): the opened homomorphic tally is the
histogram of the decrypted ballots. The histogram is the orbit of the
configuration (`Orbit = Bag` at a symmetric group action). So
`open q (tallyEnc bs) ≡ count (map decrypt bs)` is the anonymity law of
orbit-lang under encryption.

### 3.2 Part S: the swap protocol

From the pasted design:

| Name | Kind | Reading |
|---|---|---|
| Token, Address | defined | `Addr` |
| Amount | defined | `U256` |
| Progress | defined | `U256`: the number of blocks since the intent start block (O6, Q4 (b)) |
| Enc | primitive former | the ciphertext monad (3.4) |
| decrypt | primitive, law-only | `Enc A -> A`. The ideal decryption. It occurs only in law positions; no program term computes it (O7). |
| ZKProof W | defined | `‖ W ‖`, the propositional truncation (a CM). Zero knowledge is the `squash` cell: all proofs of `W` are equal. |
| verified | primitive | `Transcript -> Option ‖ W ‖` |
| Intent | defined record | `inTok`, `outTok`, `amtIn`, `startOut`, `minOut` (all three `Enc Amount`), `decoyIdx : Enc (Fin n)`, `owner : Addr`, `nonce`, `start` (`U256`, the start block number), `zk` (O8, O9) |
| Bundle n | defined | `Fin n -> Intent`, with `Fin n` a chain of `Option` over `Unit` (a CM) |
| Quote | defined record | `outAmt : Enc Amount`, `solver : Address` |
| Transfer | defined record | `token`, `from`, `to`, `amount` |
| Outcome | defined | `Option (Transfer * Transfer)`: `Settled = some`, `Unfilled = none` |
| decay | defined | `Progress -> Amount` with `decay 0 = startOut` and `decay window = minOut` (4.1) |
| meaning | defined | `Intent -> Progress -> Amount -> Prop` |
| settle | defined | `Intent -> Quote -> ZKProof W -> State -> Outcome * State` |
| pullIn, pushOut | defined | two `pull` effects of the kit (4.2) |
| cancel | defined | marks the nonce used; the reclaim law (4.2) |

### 3.3 The link: the DAO governs the swap

`Params := (window : U256)`, the decay window in blocks (O10, Q4 (b)). `Decision
:= Params`. The entry `enact` writes the decided `Params` into the contract
state. `settle` reads `window` from the state. The DAO members are the MPC
committee: each member holds one share of the threshold key (3.4). So the
DAO also controls who can open ciphertexts. Self-reference (`amend`) is as in
orbit-lang.

### 3.4 Enc, the MPC opening and their laws

Reading (O7): `Enc` is the identity cell monad (one generator `eta`, no
other cells) behind a sealed eliminator.

- `eta : A -> Enc A` is the ideal encryption. Users encrypt off chain.
- `bind : Enc A -> (A -> Enc B) -> Enc B` is homomorphic evaluation.
  `op* c1 c2 := bind c1 (\a. bind c2 (\b. eta (op a b)))`. So the
  operations `+*`, `.*` and `cmp*` of the design are derived, not
  primitive.
- `decrypt` is the denotation. It is a monad morphism `Enc -> Id`:
  `decrypt (eta a) ≡ a` and `decrypt (bind c f) ≡ decrypt (f (decrypt c))`.
  The homomorphism law of the design follows for each `op*`. This is the TCM
  principle for `Enc`.
- `open : Quorum -> Enc A -> A` is the MPC threshold opening, with the law
  `open q c ≡ decrypt c`. `Quorum` is `t` partial decryptions with one
  equality-of-discrete-log (DLEQ) proof each.
- Observer view: `observe : Enc A -> ‖ A ‖ := |_| . decrypt`. Privacy path:
  `observe c ≡ observe c'` is `squash`. For a bundle, the view of
  `Bundle n` is path-equal to the view of a decoy bundle of the same `n`.
  The paths state ideal privacy. The real guarantee is IND-CPA of the scheme
  under DDH on BN254, a VALIDATION assumption (O11).

## 4. Readings of the design on Cubical TT

### 4.1 Decay is not a path in Amount

`Amount` is `U256`, a set with decidable equality (Hedberg). So
`Path Amount startOut endOut` is empty when `startOut` and `endOut` differ.
The design's decay path cannot exist in a discrete amount type. Reading
(O6): `decay` is a map `Progress -> Amount` with fixed end values (a
discrete path). The interval `I` stays for the laws (paths between equal
values, homotopies between proofs).

Linear decay with integer arithmetic and no division:

```text
window * decay t = window * startOut - t * (startOut - minOut)     (0 <= t <= window)
accept o at t   <=> window * o + t * startOut >= window * startOut + t * minOut
```

Both sides are affine in the ciphertexts with the public scalars `window` and
`t`. So the encrypted check is `bind`-free affine evaluation (4.3).

Progress in blocks (Q4 (b)): `t = block - start`, capped at `window`.
`block` is the block number of the call (`Env.block`, O17), `start` is the
start block of the intent, and `window` is a number of blocks. The affine
check above is unchanged.

### 4.2 Atomicity and reclaim

`State` is a set, so a path between a different pre-state and post-state
does not exist. Reading (O12): `settle` is one `State` action (one
transaction, no observable middle state). The failure branch returns the
pre-state: its law is the constant path `refl`. The two transfers are two
`pull` effects of one entry: `pull inTok owner solver amtIn` and
`pull outTok solver owner outAmt`. The kit reverts the whole call when one
token call fails. So "both revert" is a property of the entry, not a proof
object. The ZK proof of the design does not certify atomicity (O12).

The pull model has no escrow. `cancel` marks the nonce of an intent used.
The token state does not change: the reclaim law is `refl` on the token
part of the state.

### 4.3 The chain fragment

The EVM has no FHE operations. Telcoin Network has no FHE coprocessor.
Reading (O11):

| Part | On the chain | Off the chain |
|---|---|---|
| `Enc` | exponential ElGamal on BN254 G1: `(r G, m G + r PK)`, 4 words; affine `bind` by the precompiles `ecAdd` (0x06) and `ecMul` (0x07) | encryption by the user; general `bind` (FHE evaluation) by solvers, accepted only with an opening |
| `open` | DLEQ check of each share (4 `ecMul`, 2 `ecAdd`), Lagrange combination in the exponent (`mulmod` by the group order), `m G` check of the claimed plaintext | the MPC committee (the DAO members) makes the shares |
| `ZKProof` | Sigma-protocol verifiers by Fiat-Shamir (keccak): knowledge of the randomness of each ciphertext, one-hot ballot (disjunctive Chaum-Pedersen), bLSAG membership | the provers |
| intent signature | `ecrecover` (0x01) over the intent hash (O13) | the user signs (gasless) |

`settle` opens only the winning fill: `amtIn`, `outAmt` and the margin of
4.1. The ERC-20 transfers make the two amounts public in any case. Losing
quotes and unfilled intents are never opened. So "selective decryption" is
read as: only the settled fill is opened (O14).

## 5. Laws

| Law (design) | Form in intent-lang |
|---|---|
| auction homomorphism | `decrypt (decayEnc t i) ≡ decay i t`, from the monad morphism law of `decrypt` |
| matching homomorphism | `settle` factors through `decrypt` of the quote: quotes with equal decrypted amounts give equal outcomes (a path by `cong`) |
| privacy path | `observe` paths by `squash` (3.4) |
| atomicity | the `refl` revert law and the one-entry transfer pair (4.2) |
| reclaim | `refl` on the token state (4.2) |
| TCM of settle | `settle i q pi s ≡ if verified and meaning i t (decrypt (outAmt q)) then (some (pullIn, pushOut), s') else (none, s)` |
| DAO laws | the orbit-lang laws 1 to 6, and the tally law of 3.1 |

## 6. Kernel route

orbit-lang at 2162fb2 (S10 closed at ab95113, S11 plan on top) has the
parts that intent-lang needs: the CCHM kernel (Path, `transp`, `hcomp`,
Glue, `ua`), HITs, QITs, HIITs and QIITs (`Orbit`, `Bag n`), fold and
unfold, the BN254 host (field, curve, `ecAdd`, `ecMul`, hash to point), the
bLSAG ballot primitives, the contract writer, the guest/host/EVM
differential and the precompile rows. orbit-lang was made from the same kit,
so its file layout matches this repo.

Route: S2 copies the orbit-lang front end, kernel `.lang` files and tests at
2162fb2, renames the language, and keeps the gate counts. S3 then narrows
the kernel to R1 (`REFUSE_CELL`). Later slices add `Enc`, `open`, the
Sigma-protocol verifiers and the swap entries.

S2 (DONE): the port is `git -C orbit-lang archive 2162fb2 src domain
examples test gen Makefile | tar -x`, the removal of
`examples/inventory.lang` and `test/check/domain-name.lang` (orbit-lang
removed both in 7734007), and the listed doc edits: SPEC.md,
docs/host/README.md, docs/VALIDATION.md, formers/FORMERS.md,
formers/tcc-evm-contract.md and probe/CAPABILITY.md take the orbit text,
with the four name edits that docs/STATUS.md lists. kitshift.py is not
used: it keeps each shared file at the seed text, it drops `*.out` files
such as `test/run/lists.out`, and the rename is not a token map (S2
survey, section 5). The code has no rename site: the 23 `(orbit-lang Sn
...)` comments are provenance and stay. `git archive` gives each file the
commit time of 2162fb2, which is older than a `build/` from before the
port. Thus `make check` uses the old binaries; the gate after a port is
`make -B check`.

## 7. The contract

One contract (O15) with these entries:

| Entry | Effect |
|---|---|
| `cast` | verifies the bLSAG signature and the one-hot proof, adds the encrypted ballot to the encrypted tally (`ecAdd`) |
| `close` | verifies the MPC opening of the tally, computes the Decision by the constitution, stores it |
| `enact` | writes the decided `Params`; `amend` as in orbit-lang |
| `fill` | verifies the intent signature, the intent and quote proofs and the openings, checks 4.1 at `t = block - start` (capped at `window`; `t` comes from the block number `Env.block`, O17, not from `now`), marks the nonce, runs the two `pull` effects, emits `Settled` |
| `cancel` | the owner marks the nonce used, emits `Cancelled` |

Size and gas rows per entry (EIP-170, EIP-3860) come in the contract slice.

## 8. Tests

- Guest files: the DAO and swap examples, one refusal row for each new
  refusal code, evals for each law.
- `langc run` scripts: entry runs on the guest evaluator.
- The differential: the same scripts on the guest evaluator and on geth
  `evm`, as in orbit-lang.
- The precompile rows: BN254 vectors for ElGamal, DLEQ and the Sigma proofs,
  host against `evm`.

## 9. Slices

| Slice | Content | Status |
|---|---|---|
| S0 | Seed: the template with the tcc-evm-contract host, the design verbatim, this plan, the kit gate GREEN, the private remote | DONE |
| S1 | USER rulings on the questions of section 11; record them in this plan | DONE |
| S2 | Kernel port from orbit-lang 2162fb2 (section 6); the gate counts of orbit-lang | DONE: `make -B check` EXIT 0 with the orbit-lang counts: 41 examples, 19 parse, 171 check and 22 kit-only refusals, 159 evals, 2 proves, contracts 2 written and 5 refused, rings 6 built and 2 refused, 28 guest and 14 host differential rows, 5 runs, 10 run refusals, 8 asmtool, 3 builds, 16 lower refusals, 33 build checks, 20 dispatch, 43 evm steps, 14 precompile rows and 128 steps, 13 mock rows, 15 diff rows, 24 emit regressions, 0 failures |
| S3 | R1 narrowing: `REFUSE_CELL`, kernel-derived unit and bind (counit and extend), the free monoid in place of the cons list, the former matrix rewritten as CM and CC rows | DONE: `make -B check` EXIT 0 with the S2 counts, except 42 examples (+1, `examples/freemon.lang`) and 172 check refusals (+1, `test/check/guest-list.lang`); `test/fronttool.c` has 12 new REFUSE_CELL rows, 3 new accepted cell cases and 8 changed rows (no counter); the original mutant (cell checks and guest List refusal off) fails the original 5 rows and guest-list.lang; FORMERS.md section 5 has the CM row and a CC row (S4); O18 to O27 |
| S4 | Cocell comonads: coinductive records with one observation, extend by the corecursor, the laws | DONE (Q-S4-1 .. Q-S4-6 (a)): `cofamily Stream` in domain/domain.lang, the laws in examples/cocell.lang, mutants in docs/VALIDATION.md |
| S5 | `Enc` and `decrypt` (law-only), the monad morphism laws, `observe` and the privacy paths, the host ElGamal | DONE: `make -B check` EXIT 0 with the S4 counts, except 45 examples (+2, `examples/enc.lang`, `examples/enc-ideal.lang`), 182 check refusals (+8: enc-fold, enc-decrypt, enc-leak, enc-annot, enc-proj, enc-relay REFUSE_LAW, enc-state REFUSE_STATE, law-guest REFUSE_DATA), 171 evals (+7) and the new line `elgamal regressions: passed` (`src/front/elgamal.c`, `test/elgamaltool.c`); `test/fronttool.c` has 11 new rows (6 from review); mutants k1 to k6 killed (7 of 7, docs/VALIDATION.md) |
| S6 | `open`: shares, DLEQ, Lagrange in the exponent, the law `open q c ≡ decrypt c`, host and precompile rows | DONE: `make -B check` EXIT 0 with the S5 counts, except 47 examples (+2, `examples/open.lang`, `examples/threshold.lang`), 184 check refusals (+2: open-leak REFUSE_LAW, quorum-state REFUSE_STATE), 177 evals (+6), 134 precompile steps (+6) and the new line `threshold regressions: passed` (`src/front/threshold.c`, `test/thresholdtool.c`, 15 rows); `test/fronttool.c` has 3 new rows; `examples/storage.lang` field `open` renamed `isOpen` (R4); mutants t1 to t4, g1, c1 killed (6 of 6, docs/VALIDATION.md) |
| S7 | `ZKProof` as truncation, `verified`, the Sigma-protocol verifiers (randomness, one-hot), `ecrecover` | DONE: `make -B check` EXIT 0 with the S6 counts, except 49 examples (+2, `examples/zkproof.lang`, `examples/onehot.lang`), 186 check refusals (+2: zk-leak REFUSE_LAW, transcript-state REFUSE_STATE), 188 evals (+11), 143 precompile steps (+9) and the new lines `sigma regressions: passed` (`src/front/sigma.c`, `test/sigmatool.c`, 14 rows) and `ecrecover regressions: passed` (`src/front/secp256k1.c`, `test/secptool.c`, 6 rows); `test/fronttool.c` has 3 new rows; `src/front/bn254.c` fe_add and fe_mul keep the top carry (a modulus near 2^256); mutants m1, m2, c1, r1, r1b, r2, s1 to s4, w1, w2, k1, k2 killed (14 of 14, docs/VALIDATION.md) |
| S8 | Part S: Intent, Bundle, Quote, decay, meaning, settle, cancel, and the laws of section 5 as guest theorems and evals; the guest side of O17 (`Env.block` in the prelude, the evaluator, plus the complete script and harness migration) | DONE: `make -B check` EXIT 0 with the S7 counts, except 52 examples (+3, `examples/intent.lang`, `examples/intentsig.lang`, `examples/blocks.lang`), 188 check refusals (+2: intent-decrypt REFUSE_LAW, intent-state REFUSE_STATE), 213 evals (+25), 6 runs (+1, `test/run/blocks.script`), 11 run refusals (+1, a bad BLOCK) and 17 lower refusals (+1, env-block REFUSE_LOWER); `Env` is `makeEnv now block caller` in the prelude, the evaluator and each script and harness (O17); `test/fronttool.c` has 2 new rows; `test/secptool.c` signs a vector in the low and the high form; records are Prod aliases (O37), the view is a tuple (O38), the intent hash takes `cipherDigest` (O39); mutants e1, e2, e2b, l1, g1 to g5, s1 to s4 killed (13 of 13, docs/VALIDATION.md) |
| S9 | Part D: encrypted ballots, `tallyEnc`, the tally law, Params and the link of 3.3 | DONE (Q-S9-1 .. Q-S9-9 all (a), USER 2026-10-24): `make -B check` EXIT 0 with the S8 counts, except 54 examples (+2, `examples/tally.lang`, `examples/ballot.lang`), 189 check refusals (+1, tally-leak REFUSE_LAW), 231 evals (+18: tally 6, intent 3, ballot 9) and 152 precompile steps (+9, the ballot views); `test/ballottool.c` adds `ballot regressions`; `examples/tally.lang` has tallyEnc, count, hist, lawTallyEnc, lawHist, pass and decide, with no b1 fallback (the FinOf motive probe passed, and lawTallyEnc checks by elim on n); `examples/intent.lang` has Market, settleM, lawWindow, govern and OpensH (O35, O41, O42); the ballot ctx binds the key image (O34); the ballot views are eval rows and precompile steps only (O40); mutants c1, c2, d1, t1, p1, l1, h1 killed (7 of 7, docs/VALIDATION.md) |
| S10 | The contract of section 7: writer, `Env.block` lowered to NUMBER (O17), guest/host/EVM differential with the block number in the prestate, gas and size rows; the cast entry, the encrypted tally state and the `enact` entry (O40) | DONE (Q-S10-1 .. Q-S10-10 (a), USER 2026-10-24; Q-S10-11 (a) and Q-S10-12 (d), USER 2026-10-25): the DAO contract; the fill is out of S10 by Q-S10-12 (d) (row S10R, O46). `make -B check` EXIT 0 with the S9 counts, except 55 examples (+1, `examples/daokit.lang`, O44), 242 evals (+11, the daokit views), 7 runs (+1, `test/run/daokit.script`), 16 lower refusals and 33 checks (-1 each: `test/lower/env-block.lang` leaves the refusal list) and 59 evm steps (+16: the blocks row of O17 and the 15 calls of daokit.script on the EVM chain); the differential stays at 14 host runs, 14 EVM rows and 28 guest evals. The contract is written by hand from the `ballottool dao` constants, NUMBER is set by `evm t8n` (O36, O43), and the writer does not change. New gate lines: `dao regressions: passed` (`test/ballottool.c`), `dao size rows: runtime 16702 bytes (limit 24576), initcode 16737 bytes (limit 49152)` (O15), `dao gas rows` (printed, not checked; docs/VALIDATION.md) and `dao chain: 33 steps, 0 failures` (`test/dao.sh`); mutants n1, n2, c1 .. c5, e1, e2 killed (9 of 9, docs/VALIDATION.md) |
| S10R | The reactor contract (Q-S10-12 (d), O46): fillCipher, fillAuth, fillOpen, fillSettle and cancel in their own contract, with the window of the DAO contract (O15, O35, O41); the fill chain rows, the gas rows and the mutants f1 .. f4; the bound of Q-S10-11 (a) (`times` k <= 8, window <= 8u); the randomness proofs stay host rows (O45). The size cause is the inline lowering (each helper inline at each call): fillSettle 8915, fillOpen 5333, fillCipher 4240, fillAuth 1538, cancel 130 runtime bytes. The input is the S10 b5 work in ~/Documents/intent-lang-work/S10-b5/ (reactor.lang, daokit-full.lang, 7 eval rows). Q-S11-5 (c) moves the bound to `times` k <= 16 and window <= 16u | DONE (Q-S11-1 .. Q-S11-4 and Q-S11-8 (a), Q-S11-5 (c), USER 2026-10-25): the reactor contract `examples/reactor.lang` (the entries fillCipher, fillAuth, fillOpen, fillSettle, cancel and `transfer`; the views windowOf, amountOf and closedOf). The DAO pushes the window: enact pays the new window to the reactor address 0x..72656163746f72, and the reactor entry `transfer` sets the window when the caller is the DAO address (Q-S11-2 (a)). fillSettle takes 6 call words (Q-S11-8 (a)). `make check` EXIT 0 with the S10 counts, except 56 examples (+1, `examples/reactor.lang`), 261 evals (+19: 18 reactor rows and daokit enactPay), 8 runs (+1, `test/run/reactor.script`) and 85 evm steps (+26: the 26 calls of reactor.script on the EVM chain, with a stub token, O47). The DAO size rows are now runtime 16883 bytes and initcode 16918 bytes (+181: the pay of enact). New gate lines (`test/reactor.sh`, after `test/dao.sh`): `reactor size rows: runtime 20571 bytes (limit 24576), initcode 20595 bytes (limit 49152)` (O15), `reactor gas rows` (printed, not checked; docs/VALIDATION.md) and `reactor chain: 40 steps, 0 failures` (the DAO, the reactor and the two `asmtool mock` tokens; the storage of each account carries between steps); mutants f1 .. f9 killed (9 of 9, docs/VALIDATION.md) |
| S11 | Mutants and close | PLANNED |

## 10. Open items

- O1: the name intent-lang. Builder call.
- O2: the kit and the kernel route (section 6). Builder call.
- O3: the reading of R1 (section 2): the ambient LCC and cubical structure
  is not limited; the declared type constructors are the CM and CC classes
  only. RULED: Q1 (a).
- O4: the cell criterion is syntactic (the parameter only in the generator).
  The other choice: any parameterized type with a program-given monad or
  comonad instance and law paths checked by the kernel. RULED: Q2 (a), the
  syntactic criterion ("check from the declaration's shape").
- O5: the DAO slot `Outcome` of orbit-lang is renamed `Decision`, because
  the swap design also names a type `Outcome`. RULED: Q8.
- O6: decay is `Progress -> Amount` with fixed end values, not a path
  (4.1). Progress is the number of blocks since the intent start block,
  from `Env.block` (O17), not seconds from `Env.now`. RULED: Q4 (b), blocks
  (not the plan default).
- O7: `Enc` is the identity cell monad with a sealed eliminator; `decrypt`
  is law-only; `op*` derive from `bind`. The other choice: `Enc` as an
  environment comonad over a key, with `decrypt` as the counit. RULED: Q3
  (a).
- O8: the design's `Intent` record has no `startOut`, but `decay` needs it.
  We add `startOut : Enc Amount`; `minOut` is the end value. RULED: Q7.
- O9: the design's formula `decrypt (intent .minOut) ≤ o` does not use `i`.
  We read the prose: `decay i ≤ o`. The formula is the case `i = window`.
  RULED: Q7.
- O10: the governed parameter is `window`, one field, a number of blocks
  (Q4 (b)). Other choices: a fee, a solver set. RULED: Q5 (a).
- O11: FHE on the chain is additive exponential ElGamal on BN254 (affine
  `bind` only); the MPC committee opens values; general FHE `bind` is off
  the chain. IND-CPA under DDH is a VALIDATION assumption. RULED: Q3 (a).
- O12: atomicity and reclaim are `State` laws, not proof objects (4.2).
- O13: the intent signature is `ecrecover` (one new kit primitive). The
  other choice: a BN254 Schnorr key per owner. RULED: Q6 (a).
- O14: only the settled fill is opened (4.3).
- O15: one contract for the DAO and the reactor, if EIP-170 allows it;
  else two contracts with the reactor reading `Params` from the DAO by a
  view call. RULED: Q6 (a), one contract. If the S10 size row breaks
  EIP-170, the split goes back to the USER.
  Closed in S10 for the DAO contract: runtime 16702 bytes (limit 24576)
  and initcode 16737 bytes (limit 49152), the `dao size rows` line of
  test/dao.sh. With the pay of enact (S10R) the DAO is runtime 16883 bytes
  and initcode 16918 bytes. The full measure (the DAO part and the reactor part in one
  contract) is 37038 runtime bytes, over EIP-170 (Q-S10-12): by (d) the
  reactor part goes to row S10R with its own contract.
  Closed in S10R: two contracts (Q-S10-12 (d)). The reactor does not
  read `Params` by a view call: the DAO pushes the window at enact by one
  `pay` to the reactor address (Q-S11-2 (a)). examples/reactor.lang with
  the 16-step times (Q-S11-5 (c)) was 30185 runtime bytes, over EIP-170
  (the size stop of S10R r1; fillSettle alone 18584). With the 6 call
  words of fillSettle (Q-S11-8 (a)) it is runtime 20571 bytes and
  initcode 20595 bytes, the `reactor size rows` line of test/reactor.sh.
- O16: exponential ElGamal decryption needs a discrete log. The host
  evaluator bounds the plaintexts (for example 2^40) for the tests; the
  chain checks `m G` for a claimed `m` and never solves a discrete log.
- O17 (new in S1, from Q4 (b)): the kit `Env` has only `now` (TIMESTAMP)
  and `caller` (CALLER). Blocks need the NUMBER opcode (0x43). We add a
  field `block : U256` to `Env`, lowered to NUMBER, and a block column in
  the `langc run` scripts. The kit gives `now` the type `Nat`; `block` is
  `U256`, so `block - start` types with `start : U256` and needs no
  conversion. Kit sites (line numbers of the S2 port):
  - `docs/host/README.md` line 78 (`family Env := makeEnv (now : Nat)
    (caller : Addr)`), line 84 (the `Env` prose), line 131 (the script
    format `NOW CALLER NAME ARGS...`), line 249 (`now` is the TIMESTAMP),
    line 282 (the chain test: the TIMESTAMP of a step is `NOW`).
  - `src/front/contract.c` line 8 (the `Env` family of the prelude);
    `src/front/check.c` lines 4300 to 4345 (`make_env` and the script line
    `NOW CALLER NAME ARGS`).
  - `src/lower.c` lines 623 to 625 (the `Env` field names and the refusal
    of other fields); `src/ir.h` lines 56 and 57 (`IR_ENV_NOW`,
    `IR_ENV_CALLER`); `src/evm.c` line 249 (TIMESTAMP or CALLER);
    `src/asm.h` line 25 (the opcode table gets `EVM_OP_NUMBER = 0x43`).
  - `test/evmchain.sh` lines 125 to 128 (the genesis prestate gets the
    block number next to the timestamp) and line 135 (`genesis 0 ''` of
    `deploy`); `test/evm.sh` lines 10 and 11 and the `test/run/*.script`
    files (the new column).
  - New in the S2 port: `test/precompile.sh` lines 22 to 30 (`call` runs
    `step 1`, at TIMESTAMP 1), one more caller of the shared `step`
    helper.

  The S8 script change is one migration of the public call format and all
  its producers and consumers. Use `NOW BLOCK CALLER NAME ARGS...`, keeping
  `NOW : Nat` for timestamps and parsing `BLOCK` as a `U256` literal (for
  example `100u`), independently of `NOW`. Update the parser, diagnostics
  and script-format documentation together. In addition to the sites above:
  - Migrate `test/same-state.script` and the embedded scripts and argument
    checks in `test/run.sh`, `test/review.sh`, `test/runtool.c` and
    `test/diff.sh`, as well as every `test/run/*.script` fixture. Preserve
    each refusal row's intended diagnostic after the column is inserted.
  - Update the column positions in both `test/evm.sh` and `test/diff.sh`
    (including `row` and `script`), then pass the block number through
    `step` to `genesis` for every call. Update deployment and
    `test/mock.sh` callers of these shared helpers at the same time. Decode
    the block literal into the prestate's `number` field; keep `timestamp`
    sourced from `NOW`. This harness plumbing belongs to S8 so the existing
    differential gate stays runnable after the format changes.

  S8 checks that all migrated fixtures retain their behavior and that
  `Env.block` evaluates to the supplied block number. S10 adds block-sensitive
  guest/host/EVM rows: with `start = 100`, `window = 10`, `startOut = 100`
  and `minOut = 50`, a quote of 75 is refused at block 100 and accepted at
  block 105 with the same timestamp. Changing only the timestamp at block
  100 must still refuse it. These rows detect a missing per-call block
  update or an accidental TIMESTAMP/CALLER lowering.

  Plan: the prelude, `make_env` and the complete script and harness migration
  above in S8; NUMBER lowering and the block-sensitive chain rows in S10.
  The line numbers above are those of the S2 port (orbit-lang 2162fb2);
  S3 to S7 can move them, so S8 finds the sites again by name.
  Closed in S10: `IR_ENV_BLOCK` lowers to NUMBER (src/ir.h, src/lower.c,
  `env_op` in src/evm.c, EVM_OP_NUMBER 0x43), and
  test/lower/env-block.lang leaves the refusal list. The block-sensitive
  chain rows: test/run/blocks.script on the EVM at NOW 1, BLOCK 42 (it
  stores 42) and the castEnd rows of test/run/daokit.script and
  test/dao.sh (a castSeal at BLOCK 11 reverts, an enact at BLOCK 0
  reverts). They kill the mutants n1 (TIMESTAMP for NUMBER) and n2 (the
  t8n step drops BLOCK). The quote rows above (block 100 and 105) need
  the fill: row S10R.
- O18 (S3, Q-S3-7): Charter and Ratified fix the rule type R to Size; the
  block has no type parameter.
- O19 (S3, Q-S3-8): Orbit is a family of the front.c orbit splice; def_at
  matches a family declaration; orbitRow is `ua` of an iso (toOrbitN,
  fromOrbitN), not refl. The statement stays.
- O20 (S3): the Parity carrier is Size, not Nat.
- O21 (S3, Q-S3-6): ChoiceBag and OrbitN are families `Size -> Type 0`
  with no type parameter; Choice is written `Sum Unit Unit` in
  domain.lang (R4). An elim on an indexed family needs a motive over all
  its indices, so fromOrbitN dispatches on the size (sel5, OrbAt).
- O22 (S3): Bag is the free commutative monoid, with no Size index (an
  indexed bagOp has no comm path). The count lifts the sizeAdd laws by
  truncExt; the lemma block is copied into hiit.lang and elim.lang. The
  row elim-motive-index moved to Pos.
- O23 (S3, QA1): two generators for one type parameter give REFUSE_CELL
  (fronttool row Two). REFUSE_CELL comes before DOMAIN_FAMILY, so the T row
  moved to a value parameter. Quot is removed.
- O24 (S3, QB1): List, nil, cons and unfold are VIS_CELL. Kit mode,
  domain.lang and the contract prelude keep List (the host ABI); a guest
  use gives REFUSE_CELL at resolve_head, and a guest uses FreeMon. The
  check is by name, so eval output that prints List is not checked again.
- O25 (S3): these kit example rows stay on List. laws.lang xs, noNats,
  foldNil, foldSum and algebra.lang sumList, lengthOf, ones (sumTo): a
  FreeMon fold into Nat needs isSet Nat (none: UIP is refused).
  algebra.lang down and stop: unfold has no FreeMon form. state-aliases.lang
  Bundle: a state field is first order (a FreeMon field gives
  REFUSE_STATE). laws mapId, formers xs and empty, monad single, doubled
  and small moved to FreeMon (eval row `formers xs` has the FreeMon text).
- O26 (S3): the F1 to F15 rows of the FORMERS.md matrix stay as the kit
  record; S3 adds the CM row and a CC row (PLANNED, S4).
- O27 (S3 review): normalize header aliases before the cell-shape check;
  refuse higher-kinded parameters and type indices, which otherwise hide
  non-cell constructors. Admit closed base data as operation labels, as
  specified in section 2. Ten additional fronttool rows cover these cases
  and distinguish fixed labels from parameter-dependent or wrapped
  recursive fields. Seven new rows fail with the original staged checker.
- O28 (Q-S4-2): `Cofree F`, a cocell field `D A -> F (D A)` for a CM `F`.
  Its positions depend on the `F` shape, so the S4 position encoding does
  not give it. It needs M-types (native codata, or the limit of the finite
  approximations). S4 refuses the field with REFUSE_CELL.
- O29 (S6, Q-S6-5): the BSGS walk is affine (one field inverse for each
  step). A Jacobian walk with a batch inverse makes a larger plaintext
  bound practical. S6 keeps every row at bits 16.
- O30 (S6, Q-S6-4): the dealer is trusted (the host deals the Shamir
  shares using fresh private seed entropy for the polynomial coefficients).
  A distributed key generation (DKG) replaces the dealer.
  docs/VALIDATION.md states the assumption.
- O31 (S6, Q-S6-7): the chain takes the Lagrange coefficients as hints and
  does not check them. The check lambda_i prod (x_j - x_i) = prod x_j mod r
  needs a word mulmod (S10, the chain form).
  S10 (Q-S10-7 (a)): the Lagrange constants are contract constants (l1
  = 2 and l2 = -1 mod r for the fixed quorum {1, 2}, from `ballottool
  dao`). The chain does not check them: the word prims have no multiply
  (Q-S10-11).
- O32 (S7, Q-S7-2): `settle` (S8) takes its `ZKProof` as an argument.
  `verified` is a law def, so a guest def cannot make a proof outside a
  law type.
- O33 (S7, Q-S7-9): ECDSA malleability. Precompile 0x01 accepts a high s
  (no EIP-2 rule), so (r, n - s, the other v: 28 for 27, 27 for 28) is a
  second signature of the same signer (secptool row `high s`). S8 replay
  keys must not be the signature words (use the intent hash or a nonce).
- O34 (S7, Q-S7-7): the ballot ctx is a free word. S9 binds it to the
  bLSAG key image; else a copied ballot verifies under a second key image.
  Closed in S9: ballotCtx in examples/ballot.lang is the hash chain from
  ballotTag over I.x, I.y and the poll
  (`hash (hash (hash ballotTag ix) iy) poll`), so the row slotCopied
  (voter 0's slot proof under voter 1's key image) is 0 on the guest and
  the EVM.
- O35 (S8, O10): `progress` and `meaning` take the window w as an
  argument. S9 reads it from `Params` (`window : U256`), so a fill cannot
  select its window. Closed in S9: in examples/intent.lang,
  `Market := Prod Params Swap` (Params is a Size with one field window,
  O37), settleM reads `window (first m)`, and lawWindow states that
  settleM is settleS at that window. A window-4 proof at a window-6
  market is TYPE_MISMATCH (a scratch check in S9 b2), and the mutant l1
  (settleM reads the new Params) fails the check of lawWindow.
  The chain side (fillSettle reads the window from the contract state)
  goes with the fill to row S10R (Q-S10-12 (d)): this row stays open for
  it.
  Closed in S10R: fillSettle of examples/reactor.lang reads the window
  from the reactor state, and only the DAO address sets it (the entry
  `transfer`; the eval rows windowPush and windowOther, test/reactor.sh
  step 28: windowOf 4 after enact).
- O36 (S8, b1): NUMBER on the chain. evm 1.14.12 panics on a genesis
  number more than 0 ("can't commit genesis block with number > 0"), and
  `evm run` has no flag for the block number. Thus `evm run --prestate`
  cannot set NUMBER, and the S10 row text "the block number in the
  prestate" is wrong. S10 needs another route, for example the `evm t8n`
  env field `currentNumber` or `evm statetest`.
  Closed in S10: the `evm t8n` route (`currentNumber` is BLOCK), opt-in
  by `numbered=1` in test/evmchain.sh (O43). The last line of the trace
  is the summary with the return word and the execution gas; its revert
  form is in docs/VALIDATION.md.
- O37 (S8, Q-S8-2, DEVIATION 1): rule R1 refuses a program family in
  guest and kit mode, so Intent, Quote, Transfer and Swap are Prod
  aliases with a constructor def and one accessor def for each field, not
  families. The field names and types are the ruled ones (Q-S8-3). A
  USER question is necessary only if the family form is required; that
  reopens Q-S8-2 (a).
- O38 (S8, Q-S8-7, DEVIATION 2): `view` is not a def. `observe` is
  law-only, so a def with a Prod codomain that calls `observe` gives
  REFUSE_LAW. privacyI and privacyB state the view tuple (pub and four
  observe values) in their Path types; `def View` is the type of the
  tuple.
- O39 (S8, b4 FALLBACK): one chain view over all the intent words takes
  23 arguments, more than the 22 of slotOk. Thus `cipherDigest` hashes
  the 16 ciphertext words, and that digest is one argument of
  `intentHash`. The views are digestOf (18 arguments), hashOf (8), keyOf
  (4) and authOk (7).
- O40 (S9, Q-S9-9): S9 puts the ballot views (ballotCtx, slotBound,
  sumBound, ballotDigest, ballotSig, tallyX, tallyY and the opening views
  of threshold.lang) on the chain as eval rows and precompile steps only.
  S10 (the contract) adds a cast entry that passes one key image to each
  check, the encrypted tally (the sum of the slot ciphertexts) and the
  window field in the state, and an `enact` entry that checks the
  opening before it sets the window.
  Closed in S10 (examples/daokit.lang): castSig, castSlot and castSeal
  (the null N of the key image keys each check), the encrypted tally T0
  and T1 (the sums of the slot ciphertexts) and window in the state, and
  enact checks the opening of the slot 0 tally before it sets the window
  (test/dao.sh steps 29 .. 33).
- O41 (S9, b2, DEVIATION 1): the window fixture is swapped. `meaning` is
  `Accept w t so mo o` = w*(so - o) <= t*(so - mo), so a longer window
  decays slower, and a fill that is short at window 4 is short at window
  6 too. Thus the survey fixture (a fill short at window 4 settles after
  govern sets window 6) cannot hold. The market m6 starts at window 6,
  where fill6 (t 2, o 6, the S8 proof at window 4) is short
  (6*2 > 2*4); govern sets window 4, and fill6 then settles. windowAfter
  is 4, not 6.
  The chain rows of this fixture (fill6 is short at window 6 and settles
  after enact sets window 4) go with the fill to row S10R (Q-S10-12
  (d)): this row stays open for them.
  Closed in S10R: test/run/reactor.script rows 6 .. 11 on the guest and
  the EVM (windowOf 6u, the settle of o 6 at t 2 reverts, a transfer by
  the DAO address sets 4u, windowOf 4u, o 3 at t 8 reverts, o 6 settles)
  and test/reactor.sh with enact of the DAO in place of the transfer
  (the settle of o 6 reverts before enact and passes at step 30).
- O42 (S9, b2, DEVIATION 2): Opens in examples/intent.lang is at Size
  (`Enc Size -> Size -> Type 0`, used by Fill). govern takes
  `OpensH (tallyEnc n bs) h` with `OpensH : Ballot -> Hist -> Type 0`
  (`ZKProof (Path Hist (decrypt Hist c) h)`) in place of a type-indexed
  `Opens Hist`. The S8 Opens and Fill do not change.
- O43 (S10, b1, DEVIATION 1): the t8n route is opt-in. The S10 text
  said: at BLOCK 0 a chain step stays `evm run`, at BLOCK > 0 it is `evm
  t8n`, and a BLOCK > 0 step from a caller that is not the key address
  fails. But the S8 migration gave the current scripts BLOCK = NOW (100u
  .. 113u, 1u .. 9u, 99u) at the callers 0x..aa and 0x..bb, so each
  current row would move to t8n and fail on the caller. Thus a chain sets
  `numbered=1` to get the t8n route: then a step with BLOCK > 0 runs on
  `evm t8n` from the key address 0xa94f..0b. Without it, each step stays
  `evm run --prestate` (NUMBER 0), and all current rows stay
  byte-identical. test/evm.sh sets it for the blocks and daokit chains,
  test/dao.sh for its full chain.
- O44 (S10, b3, DEVIATION 2): the kit file is examples/daokit.lang, not
  examples/dao.lang (Q-S10-3 (a), Q-S10-4 (a)). examples/dao.lang is the
  S7 guest prelude that the S9 writer gate reads (test/gate.sh,
  test/precompile.sh, test/run.sh), and the writer rows do not change,
  so the prelude stays. Thus the run script is test/run/daokit.script
  (test/run.sh runs NAME.script on examples/NAME.lang). It joins the EVM
  chain differential of test/evm.sh, not test/contract/diff.txt: that
  file is the S9 writer differential (`PROG START GUEST PERMUTED BALLOTS
  NAME... => OUTCOME SELF`), and a hand-written kit file has no row in
  that form. `ballottool dao` keeps its mode name.
- O45 (S10, Q-S10-8 (a)): the randomness proofs of the intent and the
  quote (the S7 Sigma verifiers) stay host rows; the reactor entries
  check the amount openings only. This goes with the fill to row S10R.
  Closed in S10R: fillOpen checks the opening of each amount word, and
  fillSettle needs the 3 openings; no reactor entry checks a Sigma
  randomness proof (the `sigma regressions` host rows). Known limit: the
  chain does not refuse a fill whose intent or quote has a bad
  randomness proof.
- O46 (S10, Q-S10-12 (d)): the fill is out of S10. fillCipher, fillAuth,
  fillOpen, fillSettle and cancel, the views amountOf and closedOf, the
  fill chain rows with the two mock tokens (0x..ee in, 0x..ef out), the
  fill gas rows and the mutants f1 .. f4 go to row S10R, with the bound
  of Q-S10-11 (a). S10 b5 wrote the reactor part, ran its 7 eval rows (as
  forecast) and measured the full contract (37038 runtime bytes, O15),
  then took it out of the repo. O35 and O41 stay open for it.
  Closed in S10R: examples/reactor.lang has the entries and the views of
  this row (and windowOf), the chain rows are test/run/reactor.script
  (guest and EVM) and test/reactor.sh (the mocks 0x..ee and 0x..ef), the
  gas rows are `reactor gas rows`, and the mutants are f1 .. f9 (f5 .. f9
  for the new code). Q-S11-5 (c) moves the bound of Q-S10-11 (a) to
  `times` k <= 16 and window <= 16u.
- O47 (S10R, s4, DEVIATION 1): the reactor chain of test/evm.sh has a
  stub token at 0x..ee and 0x..ef, not the `asmtool mock` of Q-S11-3
  (a). The stub runtime `60015f5260205ff3` (PUSH1 1, PUSH0, MSTORE,
  PUSH1 32, PUSH0, RETURN) returns the word 1 for each call. It has no
  storage and writes no logs. The reason: a CALL to an address with no
  code gives empty return data, and the lowering accepts empty return
  data only from an address with code, so each pull of fillSettle
  reverts (the C-K4-14 class; a test fault, not a src/ fault). The mock
  writes one Transfer LOG3 for each move, and these logs are not events
  of the program, so the log rows of the EVM and the guest would not
  agree. test/reactor.sh runs the pulls on the `asmtool mock` tokens and
  checks their balance slots.

## 11. Questions for the USER (S1, S2)

All eight are RULED (S1, 2026-10-22; the quote is in section 1).

- Q1 (O3): reading of R1. (a) ambient Pi, Sigma, Path, U unlimited;
  declared constructors only CM and CC. RECOMMENDED. (b) also treat Pi and
  Sigma as the base-change monad `R -> -` and comonad `E * -` and refuse
  other uses. RULED: (a).
- Q2 (O4): cell criterion. (a) syntactic cell signature, cons lists
  refused, free monoid used. RECOMMENDED. (b) any parameterized type with a
  checked lawful instance. RULED: (a) ("check from the declaration's
  shape").
- Q3 (O7, O11): Enc. (a) identity cell monad with sealed eliminator,
  exponential ElGamal on BN254, MPC opening, general bind off chain.
  RECOMMENDED. (b) environment comonad reading. (c) a real FHE scheme
  (TFHE) in the host only, no chain realization. RULED: (a).
- Q4 (O6): decay. (a) `Progress -> Amount` in seconds. RECOMMENDED. (b) in
  blocks. RULED: (b), blocks (not the recommendation; O17).
- Q5 (O10): governed parameter. (a) `window`. RECOMMENDED. (b) a fee. (c) a
  solver set. RULED: (a), `window` in blocks.
- Q6 (O13, O15): (a) `ecrecover` and one contract. RECOMMENDED. (b) BN254
  Schnorr owner keys. (c) two contracts. RULED: (a).
- Q7 (O8, O9): add `startOut` and read the prose formula. RECOMMENDED.
  RULED: yes.
- Q8 (O5): rename the DAO `Outcome` to `Decision`. RECOMMENDED. RULED: yes.

S2 adds these questions. All five are RULED (S3 step 0, 2026-10-22): the
USER took the RECOMMENDED option of each.

- Q-S2-1 (S2): the bLSAG domain tag of the ported code is the ASCII word
  "orbit" (0x6f72626974: `src/front/blsag.c` line 12, `src/front/blsag.h`
  line 23, `examples/zk.lang` line 2). (a) keep it until S9, where the
  encrypted ballots change the signed message and the ring vectors are
  made again; then use "intent". RECOMMENDED. (b) change it in S3 and make
  the 14 precompile rows again. (c) keep "orbit" for good. RULED: (a).
- Q-S3-1 (S3, O4): the scope of REFUSE_CELL. The only declaration form is
  `family`, and only `domain/domain.lang` can declare one: a guest program
  with a `family` gets REFUSE_DATA (`src/front/check.c` line 3938). (a)
  REFUSE_CELL checks the `family` declarations of `domain/domain.lang` and
  the type builtins of the core-name table (`src/front/check.c` lines 135
  to 138: Prod, Sum, Option, List; Map at line 191 is kit only).
  RECOMMENDED. The expected results: Prod is the ambient non-dependent
  Sigma (Q1 (a)) and stays; Option has the cell shape (`A` only in
  `some`); Sum has the cell shape in `B` if a signature can have a
  parameter (`A` indexes the nullary operations `inl`); List is a cons
  list, so the free monoid replaces it (O4; List has 148 hit lines in 50
  files). (b) REFUSE_CELL checks only the `family` declarations; the
  builtins stay as they are. RULED: (a).
- Q-S3-2 (S3, O3): the type-level defs of type `U -> U` that use only
  ambient formers: isProp, isSet, isContr, fiber, isEquiv and Equiv
  (`domain/domain.lang`), Not (`examples/regimes.lang` and
  `test/check/noselfcon-wrong.lang`) and Bundle
  (`examples/state-aliases.lang`; its body uses List, see Q-S3-1). They
  declare no constructor. (a) they are ambient constructions, and
  REFUSE_CELL does not refuse them. RECOMMENDED. (b) REFUSE_CELL refuses
  each def of type `U -> U`. RULED: (a).
- Q-S3-3 (S3, O4): the four families of `domain/domain.lang` that do not
  have the cell shape: Bag (a cons list: `bagCons` takes an `A` and a
  `Bag A n`; 104 hit lines in 7 files), Quot (two parameters, `A` in
  `quot` and in `quotEq`; 31 lines in 7 files), and the mutual block
  Charter and Ratified (`R` in `adoptTwice` and in `ratify`; 23 lines in
  6 files and 9 lines in 5 files). (a) S3 rewrites each as a cell
  signature (Bag as the free commutative monoid: the generator, the unit,
  an associative and commutative operation and the set squash) or moves
  it to an ambient construction, and changes its uses. RECOMMENDED. (b)
  keep the four as kernel exceptions that REFUSE_CELL does not check.
  RULED: (a).
- Q-S3-4 (S3): `test/fronttool.c` and `test/pathtool.c` embed about 14
  parameterized families as guest text. REFUSE_CELL changes the expected
  result of each row without the cell shape (for example `family T (A :
  Type 0) := leafT (v : A) | nodeT (l : T Nat) (r : T A)` at
  `test/fronttool.c` line 392, which expects DOMAIN_FAMILY). (a) keep the
  rows with the cell shape; change each other row to a family with the
  cell shape that still tests its rule (HIT_BOUNDARY, DOMAIN_FAMILY and
  the other codes); add one REFUSE_CELL row for each refused shape (cons
  list, value parameter, a parameter in no constructor, mutual block).
  RECOMMENDED. (b) change the expected result of each such row to
  REFUSE_CELL. RULED: (a).

The S3 survey (2026-10-22; `~/Documents/intent-lang-work/S3-design-A-check.md`,
`-B-list.md`, `-C-families.md`) adds these questions. All four are RULED
(2026-10-22): the USER took the RECOMMENDED option (a) of each.

- Q-S3-5 (Q-S3-1): guest programs use no List; about 190 of its 218 lines
  are the kit host ABI (entry results, `emit`, storage, the zk and
  ecPairing word lists, the prove and run output). (a) List, nil, cons and
  unfold become kit only (as Map is); a guest List gets REFUSE_CELL; the
  free monoid goes into `domain/domain.lang`; the kit algebra examples move
  to it where they can; the host ABI stays on List. RECOMMENDED. (b) move
  the host ABI to the free monoid too. RULED: (a).
- Q-S3-6 (Q-S3-3, a STOP of the survey): `examples/bagorbit.lang` proves
  `Equiv (OrbitN k) (Bag Choice k)`, which needs the Size index and the
  cons form. (a) two indexed families with no type parameter in
  `domain/domain.lang`, `ChoiceBag : Size -> Type 0` (the old cons Bag at
  `Sum Unit Unit`) and `OrbitN : Size -> Type 0`; the proof stays; Bag
  becomes the free commutative monoid. RECOMMENDED. (b) re-prove over the
  free commutative monoid. (c) the USER narrows the law. RULED: (a).
- Q-S3-7 (Q-S3-3): Charter and Ratified. (a) fix the rule type R to Size;
  the block has no parameter. RECOMMENDED. (b) R := Decision in the front.c
  DAO splice. RULED: (a).
- Q-S3-8 (Q-S3-3): Quot is not a cell (R is a value parameter); Orbit
  becomes a family of the front.c splice. The parity quotient of
  `examples/quot.lang` and `examples/elim.lang` gets the carrier (a) Size;
  Nat stays internal. RECOMMENDED. (b) Nat. RULED: (a).
S4 adds these questions (survey `~/Documents/intent-lang-work/S4-survey.md`).
All six are RULED (S4 session 1, 2026-10-22): the USER took each
recommendation (quote in section 1).

- Q-S4-1 (S4, O3): the realization of a cocell comonad. Survey:
  ~/Documents/intent-lang-work/S4-survey.md; the probe
  ~/Documents/intent-lang-work/S4-probe.lang checks on the S3 kernel with
  no change. (a) a `cofamily` declaration (domain.lang only) that the
  checker elaborates into its position encoding (a closed positions
  family, `D := fun A => D.pos -> A`, the projections, the corecursor by
  fold, the coinduction principle `DBisim` by funExt and elim); each
  generated declaration goes through check_family and check_def, so the
  only new trusted code is the shape check. RECOMMENDED. (b) native codata
  (new lazy value kinds, observation reductions, Kan operations and
  conversion at codata, a coinduction path former). (c) library defs in
  domain.lang only, no declaration form and no shape check. RULED: (a).
- Q-S4-2 (S4, O3): the field `D A -> F (D A)` (Cofree F). Its positions
  depend on the F shape, so the encoding of Q-S4-1 (a) does not give it.
  (a) S4 refuses it with REFUSE_CELL; the CC row of section 2.2 becomes
  "each other field has type `D A -> D A` or `D A -> E -> D A`, E closed
  data"; new open item O28: Cofree F waits for M-types (native codata or
  the limit of approximations). RECOMMENDED. (b) S4 takes Q-S4-1 (b) for
  these fields only. RULED: (a).
- Q-S4-3 (S4, O4): the admitted cocell shape. (a) exactly one parameter,
  a universe; no index; no `and` block; exactly one field of type the
  parameter (the observation); each other field `D A` or `E -> D A` with E
  closed data (the dual of the S3 closed labels, O27); zero other fields
  is the identity comonad. Each other shape is REFUSE_CELL (list in the
  survey, section 4). RECOMMENDED. (b) as (a) without the labelled field
  `E -> D A` (the R1 text only). RULED: (a).
- Q-S4-4 (S4): syntax and names. (a) `cofamily Stream (A : Type 0) :=
  sCorec (sHead : A) (sTail : Stream A)`: the clause name is the
  corecursor, the fields are the observations, the coinduction principle
  is `StreamBisim` (the name of the type plus `Bisim`, checked by R4), the
  positions family and its ctors have internal names with a `.` (`Stream.pos`,
  not an identifier, so a guest cannot use them). extend and duplicate are
  domain.lang defs from the corecursor. RECOMMENDED. (b) the declaration
  names the coinduction principle too. RULED: (a).
- Q-S4-5 (S4, R2): the cofamilies of domain.lang. (a) Stream only, with
  sExtend and sDuplicate; the binary tree, labelled and identity shapes
  are fronttool rows only. RECOMMENDED. (b) Stream and a labelled
  machine (`Moore`, input Size). RULED: (a).
- Q-S4-6 (S4): the EVM side. (a) no lowering: a cofamily value is a
  function; a Stream state field is refused (expected REFUSE_STATE, as a
  FreeMon field, O25) and gets a test/check row. RECOMMENDED. (b) lower a
  finite prefix of observations. RULED: (a).

S5 adds these questions (survey `~/Documents/intent-lang-work/S5-survey.md`;
probe `~/Documents/intent-lang-work/S5-probe.lang`). All six are RULED (S5
build step 0, 2026-10-23): the USER took each recommendation (quote in
section 1).

- Q-S5-1 (S5, O7): the realization of `Enc`. Survey: the probe checks the
  laws on the S4 kernel with one domain line `family Enc (A : Type 0) :=
  encEta (encOf : A)` (the S3 cell check admits it). (a) `sealed family
  Enc` in domain.lang: `sealed` is a domain-only modifier and a new flag of
  FamilyInfo; encBind, encMap and the op* helpers are domain defs by fold.
  RECOMMENDED. (b) a primitive former (an Op, builtins, reduce_op cases and
  conversion rules). RULED: (a).
- Q-S5-2 (S5, O7): how `decrypt` stays law-only. The probe shows two leaks
  of the plain family: a guest fold on Enc is decrypt, and a law applied at
  `i0` computes decrypt (`leakLaw c @ i0`), because a path end point in any
  type in scope is a term. (a) `law def decrypt` in domain.lang (a
  domain-only modifier, a new DefInfo flag); a guest def is law-only when
  its checked type or body mentions, outside a `Trunc1` argument, a
  law-only def or an elim or fold of a sealed family; a law-only guest def
  must have a law type (codomain a Path type or `Trunc1 X`), else the new
  code REFUSE_LAW; kit mode and the domain are exempt. RECOMMENDED. (b)
  dynamic: decrypt reduces only in conversion and is a stuck residual in
  program evaluation (a mode flag, a flush of the lazy def values). (c) the
  seal and a direct-use check only; the `i0` leak stays open. RULED: (a).
- Q-S5-3 (S5, O7): `observe` and `squash`. The kernel has `Trunc1` with the
  path cell `squash1` (domain.lang). (a) `observe := trunc1 A (decrypt A c)`
  in domain.lang (law-only by Q-S5-2 (a), allowed by its Trunc1 codomain);
  the privacy path is a guest theorem by squash1 in examples/enc.lang;
  `‖ A ‖` stays spelled `Trunc1 A`; the bundle view waits for S8.
  RECOMMENDED. (b) as (a) plus a `‖ A ‖` notation in the parser. RULED: (a).
- Q-S5-4 (S5, O11, O16): the host ElGamal. (a) src/front/elgamal.{c,h} on
  bn254.c, not guest visible (the evaluator stays the ideal model):
  encrypt `(r G, m G + r PK)` with r by keccak (no RNG in the repo), add,
  scale by a public scalar, decrypt by `C2 - sk C1` and a bounded
  baby-step giant-step (bits <= 40); a driver test/elgamaltool.c ("elgamal
  regressions: passed") with round trip, add, scale, the bound refusal,
  bits > 40 and an off-curve ciphertext; gate rows at 16 bits.
  RECOMMENDED. (b) guest-visible kit ops elgEnc and elgDec with eval rows.
  (c) move the host ElGamal to S6. RULED: (a).
- Q-S5-5 (S5): the EVM side. (a) no lowering in S5: an `Enc U256` state
  field is REFUSE_STATE (test/check/enc-state.lang, listed in kit.txt); the
  chain form (two G1 points) is S10. RECOMMENDED. (b) lower `Enc U256` now
  as four words. RULED: (a).
- Q-S5-6 (S5): `open` and `Quorum`. (a) both stay in S6 (shares, DLEQ,
  Lagrange in the exponent); S6 reuses elgamal.c. RECOMMENDED. (b) a stub
  `open` in S5. RULED: (a).

S6 adds these questions (survey `~/Documents/intent-lang-work/S6-survey.md`).
Each has a recommended (a). All seven are RULED (S6 build step 0,
2026-10-23; the quote is in section 1).

- Q-S6-1 (S6, O7): the shape of `Quorum`. (a) `family Quorum := quorum
  (quorumT : Size) (quorumN : Size)` in domain.lang, after observe: the
  public part of a threshold opening (t of n), not sealed, no parameter (so
  not a type constructor under R1). The shares, partial decryptions and
  DLEQ proofs are host data, as the ElGamal ciphertext. RECOMMENDED. (b) as
  (a) with Nat fields (Nat literals are kit items in guest mode). (c) a
  Quorum that also holds the share indices (`FreeMon Size`). RULED: (a).
- Q-S6-2 (S6, O7): `open` and its laws. (a) `law def open : (A : Type 0)
  -> Quorum -> Enc A -> A := fun A q c => decrypt A c` in domain.lang. It
  is law-only by its modifier (a plain domain def gets no law-only flag, so
  a plain `def open` leaks decrypt to guest callers). The laws in
  examples/open.lang (program): lawOpen `open q c = decrypt c` and
  lawQuorum `open q c = open p c` by refl, lawTally (open of encOp2 is the
  sum) by the lawOp2 proof. A guest misuse gives REFUSE_LAW by the S5 walk:
  no checker edit. RECOMMENDED. (b) as (a) plus a validity witness `QuorumOk
  q` (t <= n, t >= 1) as an argument of open. (c) a program-visible open on
  a sealed Quorum with no guest constructor. RULED: (a).
- Q-S6-3 (S6, O11): the host layout. (a) new src/front/threshold.{c,h} on
  elgamal.c; elgamal.c exports the BSGS as `elg_log(m, point, bits)` and
  elg_decrypt calls it (a refactor: the S5 rows do not change);
  test/thresholdtool.c prints "threshold regressions: passed". RECOMMENDED.
  (b) all of it in elgamal.c. (c) threshold.c with a copy of the BSGS (no
  S5 file changes). RULED: (a).
- Q-S6-4 (S6, O11): shares and DLEQ. (a) a trusted dealer in the host
  (the DKG is a VALIDATION assumption): Shamir over Fr with keccak
  coefficients (tag "shamir", with fresh private dealer entropy as required
  by S6 review), x_i = i, PK_i = s_i G; D_i =
  s_i C1; a Chaum-Pedersen proof (A, B, z) with w = keccak(nonce tag, s_i,
  C1) mod r (one w per share and ciphertext), e = the hash chain of the
  guest `hash` over DLEQ_TAG, PK_i, C1, D_i, A, B (a raw word, no
  reduction), z = w + (e mod r) s_i; verify z G = A + e PK_i and z C1 = B +
  e D_i; refuse k < t, an index 0, above n or repeated (fe_inv(0) = 0
  gives a wrong sum without an error), an off-curve point. RECOMMENDED. (b)
  the compact proof (e, z): two words, but the chain needs a negation p - y
  (u256Sub), wrong at the point at infinity. (c) e reduced mod r (the guest
  has no mod on words, so the chain cannot verify). RULED: (a).
- Q-S6-5 (S6): the decrypt bound. (a) every S6 row at bits 16 (about 2.9 s
  per BSGS, about 20 s for thresholdtool); the Jacobian walk with a batch
  inverse becomes an open item in section 10. RECOMMENDED. (b) the Jacobian
  walk and batch inverse in S6 (new code, new rows and a new timing table).
  RULED: (a).
- Q-S6-6 (S6, O16): the chain rows. (a) examples/threshold.lang (kit, as
  word literals are kit items) with the views dleqOk (4 ecMul, 2 ecAdd, 10
  hash), combineX and combineY (t = 2), openOk (C2 = m G + K); precompile.sh
  deploys it after precompile.lang (+6 steps); every constant from
  `build/thresholdtool words`, confirmed by a direct `evm run` to 0x06 or
  0x07 before it enters the file; 4 eval rows of closed copies; the gas
  (EIP-1108: ecMul 6000, ecAdd 150; about 69,440 for an opening with t = 2)
  is a VALIDATION table, not a measured row. RECOMMENDED. (b) as (a) plus a
  measured gas row (new code in test/evmchain.sh). (c) no chain rows in S6.
  RULED: (a).
- Q-S6-7 (S6, O16): the Lagrange coefficients on chain. (a) the opener
  gives lambda_i as view arguments and S6 does not check them on chain
  (the guest has no mulmod); soundness rests on the DLEQ proofs and the
  representation problem under DL (a VALIDATION note); the check comes with
  a word mulmod in S10. RECOMMENDED. (b) the coefficients of one fixed
  index set as contract constants (only that quorum opens on chain).
  RULED: (a).

S7 adds these questions (survey `~/Documents/intent-lang-work/S7-survey.md`).
Each has a recommended (a). All nine are RULED (S7 build step 0,
2026-10-23; the quote is in section 1).

- Q-S7-1 (S7, O7): the shape of `ZKProof`. (a) `def ZKProof : Type 0 ->
  Type 0 := fun (W : Type 0) => Trunc1 W` in domain.lang, and the O7 walk
  skips the arguments of an application of ZKProof, as it skips Trunc1 (the
  walk reads the syntax type before normalization, so an alias alone makes
  a decrypt in W law-only). RECOMMENDED. (b) no new name: guest code writes
  `Trunc1 W` (no checker edit). (c) a new HIT family ZKProof with its own
  squash and a family flag for the walk. RULED: (a).
- Q-S7-2 (S7, O7): `verified`. (a) `sealed family Transcript (W : Type 0) :=
  transcript (transcriptOf : W)` (the ideal transcript holds its witness, as
  Enc holds its plaintext) and `law def verified : (W : Type 0) ->
  Transcript W -> ZKProof W` (trunc1 of the elim, the form of observe). No
  Option: a failed check is a host refusal or a chain revert. RECOMMENDED.
  (b) the PLAN row `Transcript -> Option (ZKProof W)` (Option is not a law
  type, so no guest def can use it). (c) a plain def verified and a second
  walk skip for the arguments of Transcript. RULED: (a).
- Q-S7-3 (S7): the guest statements. (a) examples/zkproof.lang: `Opens A c m
  := ZKProof (Path A (decrypt A c) m)`, `OneHot C ind b := ZKProof ((i : C)
  * Path (C -> Size) (decrypt (C -> Size) b) (ind i))` (Size for U256, as
  words are kit), lawZK by squash1, lawVerified by refl, lawOpens by
  verified. RECOMMENDED. (b) OneHot as k slot statements over `FreeMon (Enc
  Size)`. (c) no guest statements in S7 (S9). RULED: (a).
- Q-S7-4 (S7, O11): the host layout. (a) new src/front/sigma.{c,h} on
  threshold.h and elgamal.h; threshold.c does not change (the S6 vectors
  stay); test/sigmatool.c prints "sigma regressions: passed" (14 rows).
  RECOMMENDED. (b) all of it in threshold.c. (c) sigma.c with a generic
  DLEQ and the S6 proof refactored onto it (S6 vectors byte equal).
  RULED: (a).
- Q-S7-5 (S7): the proof of randomness. (a) a DLEQ log_G C1 = log_PK (C2 -
  m G) for a public m: knowledge of the nonce and of the plaintext; e is the
  raw chain of `hash` from RAND_TAG over ctx, PK, C1, C2, m, A, B; the
  nonce comes from the secret; it is also the sum proof of a one-hot ballot
  (m = 1). RECOMMENDED. (b) a Schnorr proof of r on C1 only. (c) both.
  RULED: (a).
- Q-S7-6 (S7, O16): the challenge split of the OR proof. (a) e0 + e1 = e
  modulo 2^256 (`u256Add`, `u256Eq`); the simulated challenge is a full
  word; special soundness holds except with probability about 3/r (a
  VALIDATION note). RECOMMENDED. (b) e0 + e1 = e mod r checked with points
  (e0 G + e1 G = e G: +18,550 gas per slot). (c) e1 = e - e0 put into the
  branch 1 equations (+1 ecMul per slot). RULED: (a).
- Q-S7-7 (S7): the one-hot ballot. (a) k ciphertexts (1 <= k <= 8), one
  disjunctive Chaum-Pedersen proof per slot (chain from ONEHOT_TAG over
  ctx, the slot index j, PK, C1, C2, A0, B0, A1, B1), plus Q-S7-5 (a) with
  m = 1 on the sum; ctx is a word that S9 binds to the bLSAG key image.
  RECOMMENDED. (b) no ctx (a copied ballot verifies). (c) as (a) with k <=
  4. RULED: (a).
- Q-S7-8 (S7, O16): the chain rows. (a) examples/onehot.lang (kit;
  examples/sigma.lang is the F11 example) with the views randOk (5 ecMul, 3
  ecAdd, 12 hash), slotOk (8 ecMul, 5 ecAdd, 16 hash, 22 arguments) and
  sumX, sumY; +6 precompile steps; 5 eval rows; constants from
  `build/sigmatool words`, each confirmed by a direct `evm run`; the gas is
  a VALIDATION table (about 51,222 k + 31,254 for a ballot of k).
  RECOMMENDED. (b) as (a) plus one entry for k = 2 (about 45 arguments).
  (c) no chain rows in S7. RULED: (a).
- Q-S7-9 (S7, R17): `ecrecover`. (a) no guest type and no law in S7 (Addr,
  U256 and ecrecover are kit; the signed Intent of S8 decides); host
  recovery in new src/front/secp256k1.{c,h} on the generic fe_* of
  bn254.h, so a closed ecrecover computes in the evaluator (R17 amended);
  the view signedBy (a signer 0 never matches) in examples/precompile.lang;
  test/secptool.c "ecrecover regressions: passed"; +2 steps, +2 evals.
  RECOMMENDED. (b) no host recovery (signedBy only). (c) (a) plus a guest
  sealed family `Signed A` and a law def `signer`. RULED: (a).

S8 adds these questions (survey `~/Documents/intent-lang-work/S8-survey.md`).
Each has a recommended (a). All nine are RULED (S8 kickoff s3,
2026-10-24; the quote is in section 1).

- Q-S8-1 (S8): the carrier split. (a) examples/intent.lang is a guest
  program over Size (U256, Addr, Flag, Fin and Env are kit: a guest use is
  REFUSE_KIT), with `Enc Size` ciphertexts and the laws of section 5 as
  defs with Path codomains; examples/intentsig.lang (kit) holds the intent
  hash, the replay key and the fill authorization over words;
  examples/blocks.lang (kit) holds the O17 row. This is the S7 split
  (zkproof.lang guest, onehot.lang kit). RECOMMENDED. (b) U256 in the
  guest: U256 and Addr become guest visible and Part S is one file over
  words (a checker edit; `u256Sub` saturates and there is no `u256Mul`).
  (c) all of Part S in kit files (no guest laws: the TCM, atomicity and
  privacy laws need a guest file). RULED: (a).
- Q-S8-2 (S8): the placement of the names. (a) Intent, Quote, Transfer,
  Outcome, Bundle, settle, cancel and the laws are program defs and
  families in examples/intent.lang; domain/domain.lang does not change.
  No checker rule needs the names, and domain names give REFUSE_NAME:
  Outcome is a program def in examples/signature.lang and 5 test/check
  rows, Bundle in examples/state-aliases.lang, settle in examples/enc.lang
  and examples/lists.lang. RECOMMENDED. (b) the names in
  domain/domain.lang, and the clashing program names renamed in those
  examples and rows. RULED: (a).
- Q-S8-3 (S8, O6, O8, O32): the records. (a) `family Intent := intent
  (inTok : Size) (outTok : Size) (amtIn : Enc Size) (startOut : Enc Size)
  (minOut : Enc Size) (decoyIdx : Enc Size) (owner : Size) (nonce : Size)
  (start : Size)`, `family Quote := quote (outAmt : Enc Size) (solver :
  Size)`, `family Transfer := transfer (trToken : Size) (trFrom : Size)
  (trTo : Size) (trAmount : Size)` and `def Outcome : Type 0 := Option
  (Prod Transfer Transfer)`. The design field zk leaves Intent (a field
  type cannot name the earlier fields), so the intent proof is a `settle`
  argument, as the quote proof is (O32 extended). The window (in blocks,
  Q5 (a)) is a `settle` argument (S9 reads it from Params). RECOMMENDED.
  (b) a placeholder field `zk : Unit` in Intent (the record keeps the
  design shape; the proof is still an argument). RULED: (a).
- Q-S8-4 (S8, O7): decay and meaning. (a) the affine check over Size with
  no division: `Accept w t so mo o := Le (w*so + t*mo) (w*o + t*so)`
  (`sizeMul`, `sizeAdd`, `Le a b := (d : Size) * Path Size (sizeAdd a d)
  b`), `progress w start b := sizeMin (sizeSub b start) w`, and `meaning i
  w t o := ZKProof (Accept w t (decrypt Size (startOut i)) (decrypt Size
  (minOut i)) o)`: decrypt is under ZKProof (the Opens form), so meaning
  is not law-only. The encrypted sides lhsEnc and rhsEnc by encMap and
  encOp2, with lawLhs and lawRhs by elim (the auction homomorphism of
  section 5). RECOMMENDED. (b) a plain meaning on the opened Size values,
  with decrypt only in law defs (settle cannot tie o to minOut outside a
  law). (c) no encrypted sides (no lawLhs or lawRhs in S8). RULED: (a).
- Q-S8-5 (S8, O14, O32): settle. (a) `settle : (i : Intent) -> (q :
  Quote) -> (w t a o : Size) -> Fill i q w t a o -> Outcome`, with `Fill
  := Prod (Opens Size (amtIn i) a) (Prod (Opens Size (outAmt q) o)
  (meaning i w t o))`. The proofs are arguments (O32); settle computes
  only on the opened a and o (O14: only the settled fill opens) and gives
  `some (pair (pullIn i (solver q) a) (pushOut i q o))`. RECOMMENDED. (b)
  settle on the Enc amounts (the transfers stay Enc; a ledger move needs a
  decrypt, so settle is law-only). RULED: (a).
- Q-S8-6 (S8): the state laws. (a) `family Swap := swap (ledger : Size ->
  Size -> Size) (used : Size -> Size -> Sum Unit Unit)` (token to account
  to balance; owner to nonce). settleS gives `pair none s` on a missing
  proof, a used (owner, nonce) or a short balance; else it marks the nonce
  and moves a (inTok, owner to solver) and o (outTok, solver to owner)
  after one joint balance check. cancel marks the nonce. lawSettle,
  lawMatch, lawRevert (atomicity) and lawReclaim (`ledger (cancel i s)` is
  `ledger s`) by refl or cong. RECOMMENDED. (b) used nonces only, no
  ledger (atomicity and reclaim are statements on Outcome only; no
  balance evals). RULED: (a).
- Q-S8-7 (S8, O14): the bundle and privacy. (a) `def FinOf : Size -> Type
  0 := fun n => fold n (fun r => Option r) Unit` (n + 1 indices) and
  `Bundle n := FinOf n -> Intent`; b2 probes the fold first, and on a
  failure falls back to `Fin3 := Option (Option Unit)` and Bundle3.
  privacyI and privacyB (the view of a bundle is path-equal to the view
  of a decoy bundle with the same public parts) by squash1 paths and a
  path lambda. RECOMMENDED. (b) the bundle as `FreeMon Intent` (no index
  type; privacyB by elim on the list). (c) Fin3 only (no probe). RULED: (a).
- Q-S8-8 (S8, O33): the replay key. (a) the guest key is (owner, nonce)
  (`used`); the kit key in examples/intentsig.lang is `hash (addrToU256
  owner) nonce` (no r, s or v); intentHash is the `hash` chain from
  intentTag over the intent words; fillAuth is the signedBy logic over
  intentHash. Eval rows from secptool vectors: the low-s signature
  authorizes; the high-s form (r, n - s, the other v) also authorizes and
  gives the same key; a wrong owner gives 0; signer 0 never matches. If
  the view passes 22 arguments, the hash takes the ciphertext digest as
  one argument (b4 decides). RECOMMENDED. (b) no signature in S8:
  intentsig.lang moves to S10. RULED: (a).
- Q-S8-9 (S8, O17): the call format. (a) the prelude `family Env :=
  makeEnv (now : Nat) (block : U256) (caller : Addr)` (field order =
  column order); make_env and run_call read `NOW BLOCK CALLER NAME
  ARGS...`; every script and harness line migrates with BLOCK = NOW plus
  `u` (behavior equal; survey section 7 names each file);
  examples/blocks.lang (kit) with test/run/blocks.script (block differs
  from NOW) and a run refusal row for a bad BLOCK; a `block` use in lower
  stays a refusal, pinned by a new lower refusal row that S10 flips
  (NUMBER). RECOMMENDED. (b) block as the last field of Env (`makeEnv now
  caller block`): the field order differs from the column order of O17.
  RULED: (a).

S9 adds these questions (survey `~/Documents/intent-lang-work/S9-survey.md`).
Each has a recommended (a). All nine are RULED (S9 kickoff s2,
2026-10-24; the quote is in section 1).

- Q-S9-1 (S9): the placement. (a) Part D is a new guest file
  examples/tally.lang (Choice, Hist, Ballot, Ballots, tallyEnc, count,
  hist, the tally laws, pass, decide). The link of 3.3 (Params, Decision,
  Market, enact, settleM, govern and their laws) goes at the end of
  examples/intent.lang, because it needs settleS. A file cannot import a
  file, so intent.lang copies the few tally defs that govern needs.
  RECOMMENDED. (b) Part D and the link in examples/intent.lang only.
  (c) Part D and the link in a new examples/govern.lang with a copy of
  the Part S defs that settleS needs (about 150 lines). RULED: (a).
- Q-S9-2 (S9): the ballots and the n-ary tally. (a) `Hist := Choice ->
  Size`, `Ballot := Enc Hist`, `Ballots n := FinOf n -> Ballot`, and
  `tallyEnc` and `count` by elim on n (the motive mentions FinOf; b1
  probes it first, with the fallback Fin3 and Ballots3). RECOMMENDED.
  (b) the ballots as `FreeMon Ballot` with fmFold (needs `isSet (Enc
  Hist)` and the unit and associativity paths of the encrypted sum). (c)
  two ballots only (the binary lawTally of S6). RULED: (a).
- Q-S9-3 (S9, 3.1): the tally law. (a) the guest theorem `lawTallyEnc :
  (q : Quorum) -> (n : Size) -> (bs : Ballots n) -> Path Hist (open Hist
  q (tallyEnc n bs)) (count n (fun k => decrypt Hist (bs k)))` by
  induction (lawOp2H, trans, a path lambda), plus `lawHist`: when each
  ballot decrypts to the indicator of a vote, the opened tally is the
  histogram of the votes. Eval rows: 3 ballots (yes, yes, no) give 2 and
  1. RECOMMENDED. (b) eval rows only. (c) (a) plus a permutation law (the
  tally does not change when two ballots change places; it needs a
  commutativity proof of sizeAdd). RULED: (a).
- Q-S9-4 (S9, O5, 3.3): Params and Decision. (a) `Params := Size` (one
  field, window, O37), `Decision := Params`, and `decide h old new` is
  new when the yes count is more than the no count, else old (a tie
  keeps old). The DAO prelude slot stays `Outcome` (the O5 rename was not
  done in src/; a Part D decision does not go through a Constitution).
  RECOMMENDED. (b) the prelude slot `Outcome := Params`, with a proof slot
  `isSet Size` and a `menu : Params -> Constitution`. (c) `Decision :=
  Option Params` (none keeps the window). RULED: (a).
- Q-S9-5 (S9, O35, 3.3): the link. (a) `Market := Prod Params Swap`;
  `enact` sets the Params; `settleM` takes `Option (Fill i q (window
  (first m)) t a o)`, so the fill reads the window from the market and
  cannot select it; `govern` takes the opened histogram h and an `Opens
  Hist (tallyEnc n bs) h` proof (the O32 pattern; a def that calls `open`
  outside a law type gives REFUSE_LAW). Laws lawWindow, lawEnact and
  lawGovern by refl. Eval rows: a fill that is short at window 4 settles
  after govern sets window 6. RECOMMENDED. (b) settle keeps the window
  argument w, and a law says w is the window of the market (O35 stays
  open). (c) no guest link in S9 (S10 only). RULED: (a).
- Q-S9-6 (S9, O34, O39): the ctx binding. (a) `ballotCtx ix iy := hash
  (hash (hash ballotTag ix) iy) poll`, computed on the chain from the key
  image. slotBound and sumBound take (ix, iy), not ctx. The election key
  PK is a contract constant, so slotBound has 21 arguments (O39).
  RECOMMENDED. (b) ctx is the nullifier key `hash (hash ix iy) poll` (no
  new tag; ctx and the nullifier are the same word). (c) ctx stays a
  calldata word, and a separate view checks ctx = ballotCtx ix iy (a cast
  must call both). RULED: (a).
- Q-S9-7 (S9): the message of the ring signature. (a) the second
  zkVerify word is `ballotDigest`, a hash chain from a digest tag over
  the 8 ciphertext words of the 2 slots. blsag.c does not change.
  ballotSig has 16 arguments (ring of 3). RECOMMENDED. (b) a new zk
  builtin with a ballot message (checker, evaluator and lower edits). (c)
  sign one slot word only (a changed second slot verifies). RULED: (a).
- Q-S9-8 (S9, O29, O30): the host data. (a) a new test/ballottool.c on
  the sigma, bLSAG, threshold and ElGamal APIs: `words` prints the
  constants of examples/ballot.lang; the election key is the dealer key
  of thresholdtool (n 3, t 2); voters 0, 1 and 2 of a ring of 3 vote yes,
  yes and no; rows: the ctx binding, the digest signature, a copy under a
  second key image fails, the 3-ballot tally opens to (2, 1) at bits 16;
  output `ballot regressions: passed`. RECOMMENDED. (b) new `words` modes
  in sigmatool and thresholdtool. (c) one plain ElGamal key (no opening
  rows on the chain). RULED: (a).
- Q-S9-9 (S9, S10): the chain scope. (a) S9 adds the views ballotCtx,
  slotBound, sumBound, ballotDigest, ballotSig, tallyX and tallyY, and
  the opening views of threshold.lang on the summed slots, as eval rows
  and precompile steps (+9). A cast entry, the encrypted tally in the
  state, the window field and an `enact` entry that checks the opening
  are S10 (the contract), a new O40. RECOMMENDED. (b) (a) plus a kit run
  row now: examples/params.lang with `state State := makeState (window :
  U256)` and an `enact` entry that takes the opened counts as words that
  it does not check. (c) a full cast entry now (more than 22 arguments,
  so a state of partial checks over several calls). RULED: (a).

Questions of the S10 kickoff (2026-10-24, the survey is
~/Documents/intent-lang-work/S10-survey.md). Each has a recommended (a).
All ten are RULED (S10 kickoff s2, 2026-10-24). USER: "Rulings on
Q-S10-1..10: take all recommendations."

- Q-S10-1 (S10, O36): the NUMBER route. (a) a step with BLOCK more than 0
  runs `evm t8n` (env `currentNumber` BLOCK, `currentTimestamp` NOW, one
  signed tx from a fixed test key; the result word and the gas come from
  the trace summary line, the storage from the output alloc). A step at
  BLOCK 0 stays `evm run --prestate`, so all current rows do not change.
  A row at BLOCK more than 0 uses the key address
  0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b as CALLER (probe: NUMBER
  0x2a stored, view word 0x2a, gas 0xf). RECOMMENDED. (b) `evm t8n` for
  every step (every caller and pinned row moves to a key address). (c)
  `evm statetest` (the same caller limit, a state root to pin for each
  row). (d) no chain row with a block more than 0. RULED: (a).
- Q-S10-2 (S10, O17): the lowering. (a) `IR_ENV_BLOCK` lowers to NUMBER
  (0x43) in src/ir.h, src/lower.c, src/evm.c (a switch, no default arm)
  and src/asm.h; test/lower/env-block.lang leaves the refusal list (lower
  refusals 17 to 16); test/run/blocks.script joins the EVM differential
  at BLOCK 42. RECOMMENDED. (b) (a), and env-block.lang stays as an
  accepted row of a new lower-ok list. RULED: (a).
- Q-S10-3 (S10): the written contract. (a) a new kit file
  examples/dao.lang with the entries of section 7, written by hand from
  the host constants; src/front/writer.c and its rows do not change (the
  plain tally of orbit-lang stays the writer reference). RECOMMENDED. (b)
  writer.c gets an encrypted mode that writes the S10 contract from the
  DAO slots (any ring size). (c) (a) now and (b) in S11. RULED: (a).
- Q-S10-4 (S10, O15): one contract. (a) examples/dao.lang holds the DAO
  and the reactor entries. The measured kit runtime of ballot.lang (11
  views) is 10190 bytes, so the forecast is under 24576. If the b4 size
  row is over EIP-170, STOP and ask. RECOMMENDED. (b) two contracts now,
  the reactor reads the window by a view call. RULED: (a).
- Q-S10-5 (S10, O39, O40): the cast. One ballot has 43 words, more than
  22 (O39). (a) three calls under the nullifier N = hash (hash ix iy)
  poll: castSig (14 words: sigOk, then the 8 ciphertext words are stored
  under N), castSlot (15 words: j is an argument, one OR proof on the
  stored slot j), castSeal (7 words: both slot flags, the sum proof, the
  tally add, N used). A second castSig of a pending N starts N again.
  RECOMMENDED. (b) (a), but castSig refuses a pending N. (c) (a) with two
  slot entries castSlot0 and castSlot1 (the OR proof code two times).
  RULED: (a).
- Q-S10-6 (S10, O17): the tally state and the phases. (a) 8 tally words
  (the c1 and c2 points of slot 0 and slot 1) start at 0, the identity of
  ecAdd; `casts`; `castEnd` (a block number set by init); castSeal
  reverts when block is more than castEnd; enact reverts when block is
  not more than castEnd, and a second enact reverts. RECOMMENDED. (b) the
  writer rule: enact when casts is the ring size, no block test. (c) both
  rules. RULED: (a).
- Q-S10-7 (S10, O31, O40): enact. (a) one call of 15 words: the opening
  of the slot 0 tally (two shares of the quorum {1, 2} with DLEQ, the
  Lagrange constants of that quorum), yes = m, no = casts - yes (each
  sealed cast passed slotBound and sumBound), window := decide proposal
  window (a tie keeps the window, Q-S9-4). Fixture: yes 2, no 1, the
  window moves from 6 to 4 (O41). O31 becomes "the Lagrange constants are
  contract constants". RECOMMENDED. (b) open both slots (two open calls,
  then enact). (c) (a) plus a checked Lagrange hint (a new word mulmod in
  the kit). RULED: (a).
- Q-S10-8 (S10, O35, O39): the fill. (a) four calls: fillCipher (16
  words: the digest D and the 12 amount words are stored), fillAuth (9
  words: intentHash over D, authOk, the replay key not used), fillOpen
  (17 words: the opening of amount k of h), fillSettle (h and o: t = min
  (block - start) window, the window from the state, the rule 4.1, the
  replay key used, two pulls, emit Settled); cancel (nonce: the replay
  key of caller, emit Cancelled). o is the plaintext word of the solver
  (the pulls show amtIn and o). The intent and quote randomness proofs
  stay host rows (a new O row). RECOMMENDED. (b) (a) plus the randomness
  check of the 3 intent ciphertexts on the chain (3 more calls). (c) a
  fill with plaintext amounts in S10, the openings in S11. RULED: (a).
- Q-S10-9 (S10): the host data. (a) a new mode `ballottool dao` prints
  the constants of examples/dao.lang (the 3 ballots of S9, the slot 0
  opening of the tally by members 1 and 2, the S8 fill intent with the 3
  amount openings, the secptool signature) and adds `dao regressions`
  rows. RECOMMENDED. (b) a new test/daotool.c. (c) the constants by hand
  from the existing `words` modes. RULED: (a).
- Q-S10-10 (S10): the chain test. (a) a new test/dao.sh (deploy, the
  calls of section 7, the size rows, output `dao chain: N steps, 0
  failures`) and a new test/run/dao.script on the guest and the EVM
  differential. RECOMMENDED. (b) the dao calls in test/precompile.sh.
  RULED: (a).
- Q-S10-11 (S10, b5): rule 4.1 at word level is w*(so - o) <= t*(so -
  mo), and the word prims have no multiply. (a) a bounded multiply in
  the kit, no language change: `times k x` by a flagIf chain over k = 0u
  .. 8u (sums of x); fillSettle reverts when the window is more than 8u
  (t <= w), and a new O row names the bound. RECOMMENDED. (b) a new prim
  u256Mul (check, eval, lower, MUL 0x02, a trap on overflow). (c) the
  fill moves out of S10. USER 2026-10-25: (a).
  RULED: (a).
- Q-S10-12 (S10, b5, O15 SIZE STOP): the DAO part and the reactor part
  together have 37038 runtime bytes (limit 24576; the DAO part 16702,
  the reactor part 20336: fillSettle 8915, fillOpen 5333, fillCipher
  4240, fillAuth 1538, cancel 130), because the lowering puts each
  helper inline at each call. (a) shrink the kit forms. (b) a helper
  used more than once lowers to one internal subroutine. (c) two
  contracts. (d) the fill moves out of S10: S10 closes with the DAO
  contract; the reactor part goes to a new row with its own contract.
  RECOMMENDED. USER 2026-10-25: (d).
  RULED: (d).

Questions of the S11 kickoff (2026-10-25, the survey is
~/Documents/intent-lang-work/S11-survey.md). Each has a recommended (a).
All seven are RULED (S11 kickoff, 2026-10-25): (a) for Q-S11-1 ..
Q-S11-4, Q-S11-6 and Q-S11-7, (c) for Q-S11-5 (the USER answered each
question in the kickoff question form).

- Q-S11-1 (S10R, S11): the order of the two rows. S11 needs the reactor for
  the final gate in the docs/VALIDATION.md header, SPEC.md section 7 (two
  contracts), the known limits and the close of O35, O41, O45 and O46.
  S10R needs nothing from S11, and the route of Q-S11-2 (a) changes the DAO
  contract. (a) S10R first (its own build plan), then S11 closes the plan
  with the reactor in it, so the close docs are written one time.
  RECOMMENDED. (b) S11 first (the mutants and the close of S1 .. S10),
  then S10R as the last row (the close docs change again). (c) S10R leaves
  this plan (a follow-up plan); S11 records O35, O41, O45 and O46 as open.
  USER 2026-10-25: (a).
  RULED: (a).
- Q-S11-2 (S10R, O15): the window route. The kit has no general call:
  `pay` and `pull` are one CALL with the names transfer and transferFrom
  (src/lower.c:792, src/evm.c:316-344), and STATICCALL goes only to the
  precompiles 1, 6, 7 and 8 (src/evm.c:366-384). (a) the DAO pushes the
  window: enact adds one `pay` to the reactor address with the amount w
  (the new window; the to word is not read), and the reactor has an entry
  `transfer (to : Addr) (amount : U256)` that reverts unless the caller is
  the DAO address (a contract constant), and sets window := amount. No kit
  change and no trust change. The build first probes that the entry
  selector is the pay selector (transfer(address,uint256)); if the probe
  fails, STOP and ask (b). A CALL to an address with no code reverts, so
  test/dao.sh puts the reactor code at the reactor address; the enact
  rows, test/run/daokit.out and the DAO size and gas rows change. The
  reactor answers the ERC-20 transfer selector (a known limit).
  RECOMMENDED. (b) a new kit prim for a static call (STATICCALL to a word
  address, one word out, a lower memo; stuck on the guest). (c) the
  reactor keeps its own window, set by an owner entry (a trust change: the
  swap does not follow the vote on the chain). (d) one contract by a
  lowering change (a def used more than once lowers to one internal
  subroutine, Q-S10-12 (b)).
  USER 2026-10-25: (a).
  RULED: (a).
- Q-S11-3 (S10R): the mock tokens. (a) the `build/asmtool mock` runtime of
  test/mock.sh at 0x..ee (in) and 0x..ef (out), with the balances in the
  prestate (no allowance and no balance check); the chain rows read the
  balance slots. RECOMMENDED. (b) a new mock with allowance and balance
  checks (a new asmtool mode and its rows).
  USER 2026-10-25: (a).
  RULED: (a).
- Q-S11-4 (S10R): the files. (a) a new kit file examples/reactor.lang (from
  S10-b5/reactor.lang: its own State with window, keys, fills and addrs;
  the helpers it needs from examples/daokit.lang and
  examples/intentsig.lang copied in), test/run/reactor.script on the
  test/evm.sh chain, the 7 fill eval rows, and a new test/reactor.sh (the
  DAO, the reactor and the two mocks in one prestate: the casts, enact with
  the window push, then the fill rows) with the new gate lines `reactor
  size rows`, `reactor gas rows` and `reactor chain: N steps, 0 failures`;
  test/dao.sh keeps its 33 steps. RECOMMENDED. (b) the fill rows go into
  test/dao.sh (one chain test; the `dao chain` count changes).
  USER 2026-10-25: (a).
  RULED: (a).
- Q-S11-5 (S10R, Q-S10-11 (a)): the window cap. No DAO entry writes
  `proposal` (init 4u, examples/daokit.lang:18 and :391), so the chain
  window is 6u or 4u. (a) a known limit: fillSettle reverts when the
  window is more than 8u, and the window entry stores any amount.
  RECOMMENDED. (b) the window entry reverts when the amount is more than 8u
  (then enact reverts for a large proposal). (c) a longer `times` chain
  (k <= 16; more bytes).
  USER 2026-10-25: (c).
  RULED: (c).
- Q-S11-6 (S11): the mutants. 60 intent-lang mutants are killed (S3 1, S4
  3, S5 7, S6 6, S7 14, S8 13, S9 7, S10 9), and f1 .. f4 go with S10R.
  These refusal codes have no intent-lang mutant: REFUSE_STATE,
  REFUSE_DATA, REFUSE_NAME, REFUSE_REC, REFUSE_MAP, REFUSE_EVENT,
  REFUSE_HISTORY_WRITE and REFUSE_AXIOM; REFUSE_KIT, REFUSE_SIG and
  REFUSE_CONTRACT have orbit-lang mutants only. (a) one mutant for each of
  the 11 codes (each code has a check row as the killer), and the S6 lines
  of S6-mutants.out go into docs/VALIDATION.md. RECOMMENDED. (b) mutants
  for REFUSE_STATE and REFUSE_DATA only; the other codes cite the
  orbit-lang record. (c) no new mutants.
  USER 2026-10-25: (a).
  RULED: (a).
- Q-S11-7 (S11): the close docs. (a) all of them: docs/STATUS.md (the first
  paragraph, Remaining M0 work, Known limits: O16, O28, O29, O30, O31, O37,
  O38, O39, O45, the window cap, the transfer selector of the reactor and
  the gas rows that are not checked; Internal boundaries), SPEC.md
  sections 3 .. 10, the template lines of README.md (:18, :23-24), the
  docs/VALIDATION.md header as the final intent-lang gate (the orbit-lang
  part marked as the port record, its STATUS cites to orbit-lang 2162fb2),
  the R4 text of SPEC.md:70, the stale PLANNED of O26, and O33 closed in
  S8. RECOMMENDED. (b) as (a), but SPEC.md sections 5 and 6 point to PLAN
  section 3. (c) docs/STATUS.md and docs/VALIDATION.md only.
  USER 2026-10-25: (a).
  RULED: (a).
- Q-S11-8 (S10R, O15): the reactor size (the SIZE STOP of S10R r1).
  examples/reactor.lang with the 16-step times (Q-S11-5 (c)) is over the
  limit: `langc: EVM_SIZE` (runtime 30185, 5609 over 24576; fillSettle
  alone is 18584). (a) route (e) of the survey: fillSettle takes so, mo,
  start and amtIn as 4 more call words (6 words: h o so mo st amt) and
  checks each one time against fillWord (a wrong word reverts), so the
  inline copies of times are call-data loads. Measured: initcode 20509
  bytes, runtime 20485 (under 24576 by 4091); the 5 fillSettle eval rows
  give the same answers. RECOMMENDED. (b) times back to k <= 8 and the cap
  8u (Q-S11-5 (a)); not measured on this State. (c) subroutine lowering in
  the kit (no call stmt in the IR today, src/ir.h:100-110): a kit change,
  more than one session.
  USER 2026-10-25: (a).
  RULED: (a).
