# intent-lang specification

Status: the plan is closed after row S11 (2026-10-25), and row P1 filled
the probe file. M0 to M2 are DONE, and M3 is PARTIAL (section 10).
`intent-lang` is a working name.

## 1. Purpose

intent-lang is a language for two parts of one system: a zero-knowledge,
homomorphically encrypted, multi-party self-referential DAO (the DAO of
MavenRain/orbit-lang) and the private intent swap protocol that the DAO
governs. A program declares the DAO and the swap protocol. The compiler
checks the program and its laws, and writes the EVM bytecode of the
contract. The host is TinyCC, and the target is EVM bytecode for any EVM
chain (`docs/PLAN.md` rules R3 and R4). Its type formers are F1 to F19 of
`formers/FORMERS.md`. Its core data types and core operations are only the
types and operations of `design/DESIGN.md` (the design).

## 2. Programs

A program is a sequence of definitions:

```
def NAME : TYPE := TERM
```

The compiler refuses these host forms in a program: a `family` declaration
(REFUSE_DATA), an `axiom` (REFUSE_AXIOM), and a use of the definition
itself or of a later one (REFUSE_REC). It also refuses a definition that uses a core name or
a prelude name. Thus a program cannot add a data type, an unproved fact or
general recursion. Recursion comes only from `fold` and `unfold` (F6, F7).
The compiler writes the target; a program cannot.

Only `domain/domain.lang` declares a family; a `family` in a program gives
`REFUSE_DATA`. A family with a type parameter is a type constructor, so it
must be a cell signature (rule R1, S3): only type parameters, no `and`
block, each type parameter the one field of exactly one generator
constructor, and each other point field closed base data (independent of
the parameters and earlier fields), the family at its own parameters or
a path in it. Universe aliases in headers are normalized before this
shape check. Higher-kinded parameters and type indices are refused: type
arguments must be uniform universe parameters of a cell signature.
Else the checker gives `REFUSE_CELL`.
The cons list `List` (with `nil`, `cons` and `unfold`) is the kit host ABI:
a guest program that names one gives `REFUSE_CELL` and uses `FreeMon` of
`domain/domain.lang` in its place.
The dual of a cell monad is the cofree comonad of a cocell signature (S4,
O28). Only `domain/domain.lang` declares one: `cofamily D (A : Type n) :=
c (o : A) (f : D A) (g : E -> D A)`. A `cofamily` in a program gives
`REFUSE_DATA`. The shape: one type parameter, no index, no `and` block,
one clause with no result and no boundary, exactly one observation field
of the type `A`, and each other field a cofield `D A` or a labelled
cofield `E -> D A` with `E` closed base data in a universe at most `n`.
Else the checker gives `REFUSE_CELL`.
Closed labels are checked after normalization; erased references to the
parameter or earlier fields do not make a label dependent. The checked
closed label core is retained for `D.g.E`.
The checker elaborates the
cofamily to text (choice (ii)) and checks each generated declaration:
the positions `family D.pos := D.here | D.f (D.f.rest : D.pos) |
D.g (D.g.label : D.g.E) (D.g.rest : D.pos)` (with `def D.g.E := E`),
`def D := fun A => D.pos -> A`, the destructors `o : D A -> A` (the
position `D.here`), `f : D A -> D A` and `g : D A -> E -> D A`, the walk
`D.walk` (a fold over the positions that applies the steps from the
seed), the corecursor `c : (A S : Type n) -> (S -> A) -> steps -> S ->
D A` and the bisimulation principle `DBisim`. The steps and the
hypotheses of `DBisim` follow the field order. The generated names are
reserved core names: a definition that holds one gives `REFUSE_NAME`
(the name reservation, `docs/PLAN.md` O50).
The head of a corecursor value is the observation of the seed, and its
tail is the corecursor at the next seed, by conversion. A state field of
a cofamily type is a function type, so it gives `REFUSE_STATE`.
The modifiers `sealed family` and `law def` are domain only (rule O7,
S5). A program that uses one gives `REFUSE_DATA`. The domain declares
`sealed family Enc (A : Type 0) := encEta (encOf : A)`, the identity cell
monad with a sealed eliminator, with `encBind`, `encMap` and `encOp2`.
It also declares two law defs: `decrypt : (A : Type 0) -> Enc A -> A` (the
counit) and `observe : (A : Type 0) -> Enc A -> Trunc1 A` (decrypt under
`Trunc1`). The law-only roots are a law def, an `elim` or a `fold` of a
sealed family, and a projection of a field of a sealed family's
constructor. A guest definition that uses a root or a law-only guest
definition is law-only too. The checker walks the checked declared type
before normalization, its quoted normal form, and the body of each guest
definition. Explicit binder annotations are retained for this walk, even
when their variables are unused. The walk does not enter an application of
the type former `Trunc1` (the constructor `trunc1` has no exemption). A
law-only guest definition must have a law type: after its Pi binders,
the codomain is a `Path` or a `Trunc1`. Else the checker gives
`REFUSE_LAW`. Kit mode records the law-only flag and does not refuse. A
state field of type `Enc A` gives `REFUSE_STATE`. The host model is
exponential ElGamal over BN254 G1 (`src/front/elgamal.c`, not guest
visible). The domain also declares `family Quorum := quorum (quorumT :
Size) (quorumN : Size)` (S6), the public part of a threshold opening (t
of n). Quorum is not sealed and has no parameter. The law def `open : (A
: Type 0) -> Quorum -> Enc A -> A` is `decrypt` for each quorum. A guest
use of `open` outside a law type gives `REFUSE_LAW`, as `decrypt` does. A
state field of type `Quorum` gives `REFUSE_STATE`. The shares, the partial
decryptions and their DLEQ proofs are host data (`src/front/threshold.c`).
The dealer requires fresh private seed entropy for its polynomial
coefficients; public coefficients expose sk from one share.
The chain checks one proof and the opening with `ecMul`, `ecAdd` and
`hash` (`examples/threshold.lang`).
The domain declares `def ZKProof : Type 0 -> Type 0 := fun W => Trunc1
W` (S7): a proof of W is the truncation of W, and zero knowledge is the
squash cell. ZKProof is a def, not a family. The O7 walk does not enter
an application of `ZKProof`, as it does not enter one of `Trunc1`: the
checked declared type is walked before normalization, where `ZKProof W`
is still an application of the def. The domain also declares `sealed
family Transcript (W : Type 0) := transcript (transcriptOf : W)`. In the
ideal model a transcript holds its witness, as an `Enc` holds its
plaintext. The law def `verified : (W : Type 0) -> Transcript W ->
ZKProof W` truncates the witness. A guest use of `verified` outside a law
type gives `REFUSE_LAW`, as `decrypt` does. A state field of type
`Transcript W` gives `REFUSE_STATE`. A failed check is a host refusal or
a chain revert, so the codomain is not an `Option`. The real proofs are
host data (`src/front/sigma.c`): a proof of randomness (a Chaum-Pedersen
DLEQ) and a one-hot ballot (one disjunctive proof for each slot, bound to
a context word ctx, and a proof of randomness for the sum). The chain
checks them with `ecMul`, `ecAdd` and `hash` (`examples/onehot.lang`).
Rule R17 (S7): a closed `ecrecover` computes in `langc eval`
(`src/front/secp256k1.c`) by the rules of precompile 0x01: v is 27 or 28
and 1 <= r, s < n, else the address 0. A high s is accepted (0x01 has no
EIP-2 rule). An open `ecrecover` is stuck and lowers to a STATICCALL to
0x01. A closed `ecAdd` or `ecMul` computes; `ecPairing` stays stuck.
A domain family can have an index telescope after its
parameters: `family ChoiceBag : Size -> Type 0 := ...`, a Pi
telescope that ends in `Type 0`. Each constructor of an indexed family
states its result after its fields: `choiceNil : ChoiceBag sz0`. A path
constructor states it after its interval fields and before its boundary.
A constructor with no result, a result whose head is not the family at its
parameters, or an end of a path constructor at another index gives
`HIT_INDEX`. The keyword `and` joins the sorts of an inductive-inductive
block: `family Charter := ... and Ratified : Charter -> Type 0 := ...`
(no type parameter: S3 fixes the rule type to `Size`, rule R1). The headers bind first, then the point
constructors of all sorts, then the path constructors. A header that names
its own sort or a later sort of its block gives `BLOCK_ORDER`. A fold over
an indexed family has one constant target, as a fold over a uniform family
does. A fold over a block of n sorts takes n target types (one for each
sort in declaration order), then one case for each constructor of each
sort (sort by sort, in declaration order), then the value. The sorts share
the parameter telescope of the scrutinee (F18, F19).

`elim` also takes a domain family with path constructors (F16, USER ruling
S7). The motive binds the indices and then the value: `P : (n : Size) ->
Bag A n -> Type 0`. A point case takes the fields and an induction binder
after each recursive field or path field. A path case is a PathP over the
motive, and a squash case is a square over the motive. A block sort is
outside `elim`. The DAO prelude (`Config`, `Constitution`, `Aggregation`,
`Tally`, `aggregate`, `gov` and `amend`) follows the last of `orbitProj`
and `outcomeSet`. The program gives the proof slot `def outcomeSet : isSet
Outcome` after `Outcome`, and the slot `def menu : Outcome ->
Constitution` after the prelude. A slot at another type, or a program
definition of a prelude name, gives `REFUSE_SIG`. The domain families
`Pos : Size -> Type 0` (the positions of a bag) and `Word : Size -> Type
0` (the words of adjacent swaps) give the guest theorem `bagOrbit : (n :
Size) -> Equiv (OrbitN n) (Bag Choice n)` (`examples/bagorbit.lang`).

Part S (S8): `examples/intent.lang` gives intents with encrypted amounts
as guest defs over `Size`. Rule R1 refuses a program family, and Q-S8-2
(a) keeps the domain, so `Intent`, `Quote`, `Transfer` and `Swap` are
`Prod` aliases with a constructor def and one accessor def for each field
(DEVIATION 1, PLAN O37). The decay rule has no division: `Accept w t so
mo o` is `Le (w * so + t * mo) (w * o + t * so)`, so the bound on the
output o moves from the start output so at t = 0 to the minimum output
mo at t = w. `progress w st b` is b - st, capped at w. `meaning i w t o`
is the `ZKProof` of `Accept` on the decrypted start and minimum outputs
of i. `settle` takes the opened amounts a and o and a `Fill` (two `Opens`
proofs and the `meaning` proof) as arguments (O32). It gives the move of
a from the owner to the solver and the move of o from the solver to the
owner. `settleS` adds the state `Swap`: a `Ledger` of balances and a
`Used` set of (owner, nonce). A missing proof, a used (owner, nonce) or a
short balance gives `pair none s`; else `settleS` marks the nonce and
moves a and o. `cancel` marks the nonce and keeps the ledger. The laws of
PLAN section 5 are defs with a `refl` proof or a path over the solver
path (`lawSettle`, `lawMatch`, `lawRevert`, `lawReclaim`). `FinOf n` is a
chain of `Option` over `Unit` (n + 1 indices), and `Bundle n` is `FinOf n
-> Intent`. `observe` is law-only, so the view of an intent is the tuple
in the `Path` types of `privacyI` and `privacyB`, not a def (DEVIATION 2,
PLAN O38). The kit `examples/intentsig.lang` gives the chain side:
`cipherDigest` hashes the 16 ciphertext words; `intentHash` hashes a tag,
the two tokens, that digest, the owner, the nonce and the start (PLAN
O39); `replayKey` hashes the owner and the nonce and no signature word
(O33); `fillAuth` refuses the owner 0, else it compares the `ecrecover`
of the hash with the owner. The prelude has `family Env := makeEnv (now :
Nat) (block : U256) (caller : Addr)` (O17). `langc run` reads `BLOCK`
from each script line, and K4c refuses a read of `block` until S10.

Part D (S9): `examples/tally.lang` gives encrypted ballots and the tally
law as guest defs over `Size`. A `Ballot` is an `Enc Hist`, where `Hist`
is `Choice -> Size` and `ind v` is the one-hot histogram of the vote v.
`Ballots n` is `FinOf n -> Ballot`. `tallyEnc n bs` sums the n + 1
ballots under `Enc` by `encOp2` (elim on the size, with a motive that
mentions `FinOf`), and `count` is the same sum on plain histograms.
`lawTallyEnc` (by elim on n) states that `open Hist q (tallyEnc n bs)` is
the `count` of the decrypted ballots. `lawHist` adds the premise that
each ballot decrypts to `ind (v k)`: then the opening is `hist n v`, the
histogram of the votes, so the tally shows no ballot. A guest def that
opens the tally has a law type (rule O7), so `yesCount` and `noCount`
have the codomain `Trunc1 Size` and print `trunc1 Size (..)`. `histYes`,
`histNo`, `passed` and `kept` read the plain histogram `hist n v`, and
`lawHist` ties the two. `pass` gives yes (inl) when the yes count is more
than the no count, so a tie fails, and `decide h old new` takes new on a
pass, else old. `test/check/tally-leak.lang` opens the tally in a def
with a `Params` codomain (REFUSE_LAW). The link in `examples/intent.lang`
(PLAN 3.3): `Params` is a `Size` with one field `window` (O10, O37),
`Market` is `Prod Params Swap`, and `settleM` is `settleS` at `window
(first m)` (`lawWindow`), so a fill cannot select its window (O35).
`enact` sets the window. `govern` decides on an opened histogram h with
an `OpensH (tallyEnc n bs) h` proof (PLAN O42), so it does not open the
tally itself. The fixture market starts at window 6, where the S8 fill
is short, and govern sets window 4, where it settles (PLAN O41). The kit
`examples/ballot.lang` gives the chain views: `ballotCtx` is the hash
chain from `ballotTag` over the key image and the poll (O34),
`slotBound` and `sumBound` check the proofs of `onehot.lang` under that
ctx, `ballotSig` checks the ring signature over `ballotDigest` (the hash
chain from `digestTag` over the 8 slot ciphertext words), `tallyX` and
`tallyY` add two slot ciphertext points, and `dleqOk`, `combineX`,
`combineY` and `openOk` are the opening views of `threshold.lang` on the
summed slots. These views are
eval rows and precompile steps only until S10 (PLAN O40).

Part S10 (the DAO contract): the kit file `examples/daokit.lang` (PLAN
O44) is the DAO part of the contract of PLAN section 7, written by hand
from the `ballottool dao` constants (the writer does not change).
`Env.block` lowers to NUMBER (O17). The state holds the null set `used`,
the pending ballot words `pend` and their stage flags, the encrypted
tally T0 and T1 (the ecAdd sums of the slot ciphertexts), the cast
count, castEnd, the proposal and the window. A cast is three calls:
castSig checks the ring signature over the ballot digest and keeps the 8
ciphertext words under the null N of the key image; castSlot checks the
one-hot proof of one slot; castSeal (at a block up to castEnd) checks
both slot flags and the sum proof, adds the slots to the tally and marks
N used. After castEnd, enact checks the threshold opening of the slot 0
tally by the quorum {1, 2} (the Lagrange constants are contract
constants, O31), sets yes = m and no = casts - yes, and sets the window
to the proposal when yes > no (a tie keeps the window). A second enact
reverts. The reactor part (the fill) is not in S10 (Q-S10-12 (d), PLAN
O46): it goes to row S10R with its own contract, because one contract
with both parts has 37038 runtime bytes, over EIP-170 (O15).

Part S10R (the reactor contract, PLAN row S10R): the kit file
`examples/reactor.lang` is the reactor part of the contract of PLAN
section 7, in its own contract (Q-S10-12 (d)). The state holds the
window, the replay keys, the fill words and the addresses. A fill is
four calls: fillCipher keeps the 12 amount words under their digest;
fillAuth checks that the replay key of (owner, nonce) is not used and
that the owner signed the intent hash h (`ecrecover`, O13), then keeps
the record of h; fillOpen checks the opening of one amount word,
requiring its integer value to be below the BN254 subgroup order;
fillSettle takes h o so mo st amt (Q-S11-8 (a)), checks each word one
time against the record of h, needs the 3 openings and block >= start,
and accepts o by rule 4.1 at t = min (block - start) window. Then it
marks the replay key, pulls amtIn of inTok from the owner to the
caller and o of outTok from the caller to the owner, and emits
Settled. A window more than 16u reverts, and `times` goes to k <= 16
(Q-S11-5 (c)). cancel marks the replay key of (caller, nonce). The DAO
sets the window: enact pays the new window to the reactor address (a
tie pays the old window), and the reactor entry `transfer (to : Addr)
(amount : U256)` sets the window to amount when the caller is the DAO
address (Q-S11-2 (a)); another caller reverts. Thus the reactor answers
the ERC-20 transfer selector. The randomness proofs of the intent and
the quote stay host rows (O45).

## 3. Type formers

The type formers are F1 to F19 of `formers/FORMERS.md`. This language uses
the tcc-evm-contract column of the realization matrix
(`formers/FORMERS.md:422-438`) and the slice rows S5 to S7 (:442-444).
`formers/tcc-evm-contract.md` gives the host form of each former (:4,
:39). Rule R1 admits only cell monads (CM) and their duals (CC) as type
constructors (slice S3). The EVM cells of the matrix say PLANNED, as in
the kit record (O26): since K4 the first-order word residual lowers, and
any other residual gives REFUSE_LOWER (`formers/tcc-evm-contract.md:39-42`).
The table gives each former that has a deviation.

| ID | Status on tcc-evm-contract | Effect on this language | Open item |
|---|---|---|---|
| F7 | DONE into `List`, with a `Nat` step limit (`formers/FORMERS.md:430`) | `List`, `nil`, `cons` and `unfold` are VIS_CELL: a guest gets REFUSE_CELL. `unfold` has no FreeMon form. The cocell comonads (`cofamily Stream`, S4) give the corecursion. | O24 |
| F15 | PARTIAL (`formers/FORMERS.md:438`) | Only `domain/domain.lang` declares an indexed family. A program `family` gives REFUSE_DATA. | O37 |
| F16 to F19 | No matrix row (the headings `formers/FORMERS.md:241`, :269, :299, :336) | The slice rows S5 (Glue, :442), S6 (the index telescope, :443) and S7 (`elim`, :444) are DONE in check and eval. | O26 |

## 4. Structures

- **Monad**: `pure`, `map`, `bind` on `Option`, `Sum E` and `List`
  (`formers/FORMERS.md:428`). The domain adds `fmMap` and `fmBind` on
  FreeMon (`domain/domain.lang:122`, :127; the bind is the fold `fmFold`)
  and `encMap`, `encBind` and `encOp2` on `Enc` (:137-141, S5).
- **Algebra**: `fold` on `Nat`, `List` and each domain family
  (`formers/FORMERS.md:429`), and `fmFold` on FreeMon
  (`domain/domain.lang:115`). `unfold` runs into `List` with a `Nat` step
  limit (:430), but a guest cannot use it (VIS_CELL, O24). The guest
  corecursion is the cocell comonad `Stream` (S4, section 2).
- **Filterable**: `filter` on `Option` and `List` (`formers/FORMERS.md:431`).

## 5. Core types

| Type | Meaning (design section) | Definition |
|---|---|---|
| Token, Amount | `design/DESIGN.md:63-64` | `Size` words: `inTok outTok : Size`, and an amount is `Enc Size` (`examples/intent.lang:9`) |
| `Enc A` | `design/DESIGN.md:42`, :71 | The sealed monad of S5 (`domain/domain.lang:137-150`); exponential ElGamal over BN254 G1 in the host |
| Intent | `design/DESIGN.md:36`, :76-83 | `def Intent : Type 0` (`examples/intent.lang:6`): a Prod alias with a constructor def and one accessor def for each field (O37) |
| Quote | `design/DESIGN.md:92-95` | `def Quote : Type 0 := Prod (Enc Size) Size` (`examples/intent.lang:21`) |
| Transfer | `design/DESIGN.md:99` | `Prod Size (Prod Size (Prod Size Size))` (`examples/intent.lang:26`) |
| Outcome | `design/DESIGN.md:53`, :98-100 | `Option (Prod Transfer Transfer)` (`examples/intent.lang:34`): `some` is Settled, `none` is Unfilled |
| `ZKProof W` | `design/DESIGN.md:48`, :83 | `Trunc1 W` (`domain/domain.lang:159`; section 2, :104-116) |
| Quorum | The parties of the threshold opening (S6) | `domain/domain.lang:149` |

The DAO types (the ballots and `Params`) follow orbit-lang. Section 2
gives them (Part D, :189-221).

## 6. Core operations

The Part S signatures below are those of `examples/intent.lang`. Decay
is the acceptance type `Accept` (the inequality of PLAN section 4.1),
and `meaning i w t o` is `ZKProof` of that acceptance type. The window
`w`, elapsed time `t` and opened amounts `a`, `o` are `Size` values.

| Operation | Type | Meaning (design section) |
|---|---|---|
| decay (`Accept`) | `(w t so mo o : Size) -> Type 0` | `design/DESIGN.md:32`, :67; `examples/intent.lang:45-50` (no division, O37) |
| meaning | `(i : Intent) -> (w t o : Size) -> Type 0` | `design/DESIGN.md:38`, :86; `examples/intent.lang:54-55` |
| settle | `(i : Intent) -> (q : Quote) -> (w t a o : Size) -> Fill i q w t a o -> Outcome` | `design/DESIGN.md:55`, :102; `examples/intent.lang:115-120` (Fill contains the openings and acceptance proof) |
| decrypt | `(A : Type 0) -> Enc A -> A`, law-only | `design/DESIGN.md:44`, :72; `domain/domain.lang:144` |
| observe | `(A : Type 0) -> Enc A -> Trunc1 A`, law-only | The privacy path, `design/DESIGN.md:113`; `domain/domain.lang:146` |
| open | `(A : Type 0) -> Quorum -> Enc A -> A`, law-only | The threshold opening (S6); `domain/domain.lang:150` |
| verified | `(W : Type 0) -> Transcript W -> ZKProof W`, law-only | `design/DESIGN.md:48`; `domain/domain.lang:161` |
| encMap, encBind, encOp2 | The `Enc` monad | The homomorphism, `design/DESIGN.md:44`, :111; `domain/domain.lang:137-141` |

The laws of the design (`design/DESIGN.md:109-114`: the auction
homomorphism, matching, privacy and atomicity) are guest theorems and
evals (section 2, Part S).

## 7. Target and instance encoding

The compiler writes the EVM bytecode of a contract (rule R4). An instance
is a top-level definition whose type is a data type (F14). A state field
is a word, a `List T` of words or a `Map K V`. Another shape gives
REFUSE_LOWER, REFUSE_MAP or REFUSE_STATE (`formers/tcc-evm-contract.md:20-26`).
An entry is first-order word code: `some (pair STATE OUT)` stores the
fields, `none` reverts, and a trap reverts with `Trap()` (:27-29). A view
returns one word (:30). `pay` and `pull` are token CALLs, and `emit` needs
a named event (:37-38). Section 2 gives the entries of the DAO contract
(Part S10) and of the reactor contract (Part S10R). `ZKProof` is a def
over `Trunc1`, and `verified` is law-only: a failed check is a revert of
the chain, so the codomain is not an `Option` (:104-116).

| Type | Encoding |
|---|---|
| `Nat`, `Flag`, `U256`, `Addr` | One word |
| `List T` | Words |
| `Map K V` | One word for each key |
| A path, a HIT value, an indexed value, a block value, a proof | Erased (`formers/tcc-evm-contract.md:65-66`, :88-91, :101-104) |

## 8. Host and target

The host is TinyCC: `tcc -v` gives 0.9.28rc (mob 0fb54300). The repo has
no `PIN` file. The target is EVM bytecode, and the gate runs it on
go-ethereum `evm` 1.14.12. `probe/CAPABILITY.md` has the host probe of
row P1 (2026-10-25, at b28c283). The host facts of the design
come from the kit slices K2 to K4 (`formers/tcc-evm-contract.md`). The
checks on the output are in `make -B check` (the header of
docs/VALIDATION.md): test/evm.sh runs the contracts on `evm`, test/diff.sh
compares `langc run` with `evm run`, the differential rows compare the
guest, the host and the EVM, and test/dao.sh and test/reactor.sh check the
size rows against EIP-170 (24576 runtime bytes) and EIP-3860 (49152
initcode bytes) and run the two chains.

## 9. Open items

The open items are the O rows of `docs/PLAN.md` section 10 (O1 to O50).
Each row gives its slice, its ruling (the rulings of section 11, each with
its USER date) and its state: built, closed in a later slice, or open.
O48 to O50 are the deviations of S11. The items that stay open after S11
are the known limits of `docs/STATUS.md`: O16, O28, O29, O30, O31, O37,
O38, O39 and O45.

## 10. Milestones

The plan does not map the kit milestones to its slices (`docs/PLAN.md`
section 9). The map below follows the content of each milestone.

| Milestone | Slices | Content | Commits (date) | Status |
|---|---|---|---|---|
| M0 | S0 to S3 | The kit host and its gate; the kernel port of orbit-lang 2162fb2; the core types construct and check; the refusal list (with REFUSE_CELL, rule R1); examples and tests | 56821a7, 599f84d, aacc8ad, 32c1d13 (2026-10-22) | DONE (P1 filled the probe file) |
| M1 | S4 to S9 | The core operations: the cocell comonads, `Enc` and `decrypt`, `open`, `ZKProof` and `verified`, Part S and Part D | 4b36026, 1b65dec, 9b99528, ef5abe8 (2026-10-23); c6636f1, 3df9d96 (2026-10-24) | DONE |
| M2 | S10, S10R | The contract: the DAO contract and the reactor contract | 79e1898, 3aa7361 (2026-10-25) | DONE |
| M3 | S11 | Hardening: a mutant for each refusal code; the size rows under EIP-170 | b28c283 (2026-10-25) | PARTIAL: no speed work, no checked certificate for the output |

Status 2026-10-25 (S11 closed, P1 filled the probe file): M0 to M2 are
DONE and M3 is PARTIAL. The plan is closed after row S11.
