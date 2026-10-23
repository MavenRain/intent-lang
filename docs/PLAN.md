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
| CC, cocell comonad | The cofree coalgebra comonad of a cocell signature: a coinductive record with one observation `eps : D A -> A`; each other field has type `D A -> D A` or `D A -> F (D A)` for a fixed CM `F`. | counit = `eps`; extend = the corecursor; the laws are paths by coinduction | `Stream`, `Cofree F` |

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
| S2 | Kernel port from orbit-lang 2162fb2 (section 6); the gate counts of orbit-lang | PLANNED |
| S3 | R1 narrowing: `REFUSE_CELL`, kernel-derived unit and bind (counit and extend), the free monoid in place of the cons list, the former matrix rewritten as CM and CC rows | PLANNED |
| S4 | Cocell comonads: coinductive records with one observation, extend by the corecursor, the laws | PLANNED |
| S5 | `Enc` and `decrypt` (law-only), the monad morphism laws, `observe` and the privacy paths, the host ElGamal | PLANNED |
| S6 | `open`: shares, DLEQ, Lagrange in the exponent, the law `open q c ≡ decrypt c`, host and precompile rows | PLANNED |
| S7 | `ZKProof` as truncation, `verified`, the Sigma-protocol verifiers (randomness, one-hot), `ecrecover` | PLANNED |
| S8 | Part S: Intent, Bundle, Quote, decay, meaning, settle, cancel, and the laws of section 5 as guest theorems and evals; the guest side of O17 (`Env.block` in the prelude, the evaluator, plus the complete script and harness migration) | PLANNED |
| S9 | Part D: encrypted ballots, `tallyEnc`, the tally law, Params and the link of 3.3 | PLANNED |
| S10 | The contract of section 7: writer, `Env.block` lowered to NUMBER (O17), guest/host/EVM differential with the block number in the prestate, gas and size rows | PLANNED |
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
- O16: exponential ElGamal decryption needs a discrete log. The host
  evaluator bounds the plaintexts (for example 2^40) for the tests; the
  chain checks `m G` for a claimed `m` and never solves a discrete log.
- O17 (new in S1, from Q4 (b)): the kit `Env` has only `now` (TIMESTAMP)
  and `caller` (CALLER). Blocks need the NUMBER opcode (0x43). We add a
  field `block : U256` to `Env`, lowered to NUMBER, and a block column in
  the `langc run` scripts. The kit gives `now` the type `Nat`; `block` is
  `U256`, so `block - start` types with `start : U256` and needs no
  conversion. Kit sites:
  - `docs/host/README.md` line 68 (`family Env := makeEnv (now : Nat)
    (caller : Addr)`), line 74 (the `Env` prose), line 239 (`now` is the
    TIMESTAMP), line 272 (the chain test: the TIMESTAMP of a step is
    `NOW`).
  - `src/front/contract.c` line 7 (the `Env` family of the prelude);
    `src/front/check.c` lines 2024 to 2069 (`make_env` and the script line
    `NOW CALLER NAME ARGS`).
  - `src/lower.c` lines 491 to 493 (the `Env` field names and the refusal
    of other fields); `src/ir.h` lines 55 and 56 (`IR_ENV_NOW`,
    `IR_ENV_CALLER`); `src/evm.c` line 239 (TIMESTAMP or CALLER);
    `src/asm.h` line 25 (the opcode table gets `EVM_OP_NUMBER = 0x43`).
  - `test/evmchain.sh` lines 125 to 128 (the genesis prestate gets the
    block number next to the timestamp); `test/evm.sh` lines 10 and 11 and
    the `test/run/*.script` files (the new column).

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
  S2 ports orbit-lang, so the line numbers above can move; S8 finds the
  sites again by name.

## 11. Questions for the USER (S1)

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
