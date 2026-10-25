# intent-lang specification (draft)

Status: draft before milestone M0. `intent-lang` is a working name.

Fill each section. The quoted line under each heading says what to write
there. Delete the quoted line when the section is complete.

## 1. Purpose

> Write here: what one program describes, what the compiler checks, and what
> it writes. Name the host and the target. Say that the core types and core
> operations are only those of `design/DESIGN.md`.

intent-lang is a language for <the domain>. Its type formers are F1 to F19 of
`formers/FORMERS.md`. Its core data types and core operations are only the
types and operations of `design/DESIGN.md` (the design).

## 2. Programs

> Write here: the form of a program and the refusal list. Copy the host
> forms from `formers/tcc-evm-contract.md`. Add each fixed first definition that the
> domain needs (for example a size parameter).

A program is a sequence of definitions:

```
def NAME : TYPE := TERM
```

The compiler refuses these host forms in a program: <the list from
`formers/tcc-evm-contract.md`>. It also refuses a definition that uses a core name or
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
core names (rule R4): a definition that holds one gives `REFUSE_NAME`.
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

> Write here: only the deviations from the formers. Do not copy the forms.
> Give each former whose status in `formers/tcc-evm-contract.md` is not DONE, and the
> open item (section 9) that records it.

The type formers are F1 to F19 of `formers/FORMERS.md`. This language uses
the tcc-evm-contract column of the realization matrix. `formers/tcc-evm-contract.md` gives
the host form of each former.

| ID | Status on tcc-evm-contract | Effect on this language | Open item |
|---|---|---|---|
| | | | |

## 4. Structures

> Write here: the carriers of Monad (F5), fold and unfold (F6, F7) and
> filter (F8) that the design uses. Name each carrier that the host does not
> give.

- **Monad**: `pure`, `map`, `bind` on <carriers>.
- **Algebra**: `fold` on <carriers>. `unfold` on <carriers>, or the reason
  that there is no `unfold`.
- **Filterable**: `filter` on <carriers>.

## 5. Core types

> Write here (DOMAIN SLOT): only the types of `design/DESIGN.md`. Give each
> type its meaning in the design and its definition in host forms. Mark each
> definition that a probe fact forces with "probe-forced".

| Type | Meaning (design section) | Definition |
|---|---|---|
| | | |

## 6. Core operations

> Write here (DOMAIN SLOT): only the operations of `design/DESIGN.md`. Give
> each operation its type and its meaning in the design.

| Operation | Type | Meaning (design section) |
|---|---|---|
| | | |

## 7. Target and instance encoding

> Write here: what the compiler writes. For a JSON target, give the instance
> rule and the encoding table. For a contract target, give the storage, the
> entries and the guards. Say how each proof erases.

An instance is a top-level definition whose type is a data type (F14).

| Type | Encoding |
|---|---|
| | |

## 8. Host and target

> Write here: the host, its pinned commit (`PIN`), the facts from
> `probe/CAPABILITY.md` that set the design, and the check that the compiler
> runs on its output (for example the axiom report).

## 9. Open items

> Write here: one item for each open question. Number the items O1, O2 and
> so on. Mark each decision as "RULED YYYY-MM-DD (USER): <the ruling>". Mark
> each fact that a probe found as "Probe-forced".

- O1. <question>.

## 10. Milestones

> Write here: the content of each milestone, and a dated status line under
> the current milestone.

| Milestone | Content |
|---|---|
| M0 | Host probe (`probe/CAPABILITY.md`); the core types construct and check; refusal list; examples and tests |
| M1 | Core operations |
| M2 | Queries and reads, or the contract |
| M3 | Hardening: speed, limits, a checked certificate for the output |
