# Host capability probe: tcc-evm-contract

Date: 2026-10-25. Host tree: `/Users/oobi/Documents/intent-lang` at
b28c283 (tree e2f2a3f7), read only: `git archive` copies the tree into a
new temporary directory (probe.log:5, :10). Driver: `build/langc`, built on
2026-10-25 by `make build/langc` in that copy (probe.log:11-16), with tcc
0.9.28rc 2026-09-04 mob@0fb54300 (AArch64 Darwin) and go-ethereum `evm`
1.14.12-stable (probe.log:8-9). The repo has no `PIN` file, and no gate
script reads `probe/` or `PIN`. Other work loaded the machine (load
averages 11.59 to 26.62, probe.log:4, probe2.log:2). Thus each wall time is
an upper bound. A cite `probe.log:N` or `probe2.log:N` is a line of a run
log in `intent-lang-work/P1/`, outside the repo.

To run the probe again: `zsh probe.sh > probe.log 2>&1`, then `zsh
probe2.sh > probe2.log 2>&1` (in `intent-lang-work/P1/`). Each step is one
`step` line of a script; to run some steps, keep the setup lines and those
`step` lines. probe.sh runs the base span. probe2.sh runs the kit-type
steps again with `--kit` and the cost rows on a `Size` chain. Each step
runs below `probe/guard.py`, which stops a command above 4096 MB resident
memory or above its time limit, 120 s (probe.sh:7). The probe writes only
below a new temporary directory. The largest process in the probe used
408.6 MB (probe.log:44, the base-span build of `examples/dao.lang`).

The base span: `langc check` refuses a program with a `Nat`, an event or
another kit item. The line is REFUSE_KIT `NAME: Nat is a kit item outside
the base span (PLAN section 4); only the kit mode langc --kit admits it`
(probe.log:35, :53, :87). The gate runs the kit-type programs with `--kit`
(`test/gate.sh:54`, `test/build.sh:64`), and so does probe2.sh.
`examples/intent.lang` checks `ok` in the base span (probe.log:31), and so
does a chain of `Size` definitions (probe2.log:112, :120).

## Questions

Each host must answer these questions. Each answer is one numbered section
below. An answer sets the status of a former in `formers/tcc-evm-contract.md`.

| Question | Section | Formers |
|---|---|---|
| Which commands check a file, print a normal form, build and run? | 1 | all |
| Does the host take several files, or must the driver join them? | 2 | all |
| Which recursion does the host accept, and how does it refuse the rest? | 3 | F6, F7 |
| Which `Nat` primitives exist? Does `Nat` have an eliminator? | 4 | F6, F7 |
| How does a result leave the host? | 5 | target |
| What do check and build cost (time and resident memory) at N = 100 and N = 1000? | 6 | all |
| Can a family take a parameter? Can a constructor of such a family appear in a term? | 7 | F4, F12, F15 |
| Can a program project a Sigma? Does the kernel accept Sigma eta? | 8 | F11 |
| How does a program use paths: `Path`, `transport`, `cong`, an index type? | 9 | F12, F13 |
| How does the host report an axiom? | 10 | R2 |

## 1. Commands

| Job | Command | Result |
| --- | --- | --- |
| Check | `build/langc [--kit] check FILE` | `ok` and exit 0 (probe.log:31), or one line `langc: CODE: NAME: TEXT` and exit 1 (probe.log:35) |
| Print normal form | `build/langc [--kit] eval FILE NAME [ARGS...]` | The normal form of NAME: `1200` for `offered` in `examples/sigma.lang` (probe2.log:15), `szS (szS (szS sz0))` for a `Size` (probe2.log:116). Exit 0, also after a trap (section 4), or 1 after a refusal |
| Build | `build/langc [--kit] build FILE [-o OUT] [--runtime]` | One hex line: `wc -c` gives 537 for `examples/storage.lang`, and 75 with `--runtime` (probe2.log:21, :23) |
| Run | `build/langc [--kit] run FILE SCRIPT`; `evm --verbosity 0 run --code HEX` | `run` prints each call with its events, then the final state: 5 calls and `state makeState 7u` for `test/same-state.lang` (probe2.log:31-41). `evm run` on the creation code of `examples/storage.lang` prints one line of 77 characters by `wc -c` (probe2.log:27) |

- `langc` with no command prints the usage of 8 commands and exits 2:
  `check`, `eval`, `run`, `ir`, `abi`, `build`, `prove` and `contract`.
  Each command except `contract` takes `--kit` (probe.log:17-29).
- One file for each command (section 2).
- In the base span, a build of `examples/dao.lang` gives REFUSE_LOWER `a
  build needs a state and def init : State` after 2.089 s at 408.6 MB
  (probe.log:43-44). Thus the base-span `evm run` step got no code
  (probe.log:46-48).
- Not probed: `ir`, `abi`, `prove`, `contract`, `evm statetest` and `evm
  t8n`.

## 2. Several files

No. A program is one file, with no import form. A file that starts with
`import domain` gives PARSE_EXPECT `expected 'def', 'axiom', 'family',
'cofamily', 'state', 'event', 'sealed' or 'law', found a name`
(probe.log:57). The build embeds `domain/domain.lang` into `build/langc`
(`tcc -run gen/embed.c domain/domain.lang build/domain.c`, probe.log:13),
and a program uses the domain names with no import (probe2.log:111-118).
Thus a driver must join the parts of a program into one file, which comes
after the domain.

## 3. Recursion and totality

No recursive definition checks. `def rec` gives REFUSE_REC `def rec is
refused (rule R3); use fold or unfold` (probe.log:62). With `--kit`, a call
of the definition itself (`test/check/self.lang`) or of a later name
(`test/check/later.lang`) gives REFUSE_REC `NAME is this definition or a
later one; a definition can use only earlier ones (rule R3)`
(probe2.log:45, :49). In the base span these two files stop first at
REFUSE_KIT, because they use `Nat` (probe.log:67, :73). Recursion is
`fold` and `unfold`, as the REFUSE_REC line says; the domain uses `fold`
(`domain/domain.lang:145`). The probe ran no `fold` or `unfold` of its own.

## 4. Nat

The primitives are `natAdd`, `natSub`, `natDiv` and `natMod`, with the
comparisons `natEq` and `natLe` (`src/front/check.c:187-190`, :202-203).
`natMul` gives NAME_UNKNOWN `unknown name natMul` (probe2.log:80). The
steps below run with `--kit`, because the base span refuses `Nat`
(probe.log:87). `natSub 4 9` is 0 (probe2.log:57). The largest value is
18446744073709551615, that is 2^64 - 1 (probe2.log:61). `natAdd` of that
value and 1, `natDiv 7 0` and `natMod 7 0` give EVAL_OVERFLOW `an
operation trapped: a Nat or U256 overflow, or a U256 division by 0`, then
print `trap` and exit 0 (probe2.log:65-68, :70-73, :75-78). The literal
2^64 gives LEX_NAT_RANGE `a Nat literal is larger than 2^64 - 1`
(probe2.log:84). A definition cannot recurse on a `Nat` (section 3). The
base span counts with the domain family `Size` (`family Size := sz0 | szS
(szPred : Size)`, `domain/domain.lang:47`, probe.log:149).

## 5. How a result leaves the host

As printed text or as one EVM contract. `eval` prints the normal form
(probe2.log:15), and `run` prints each call, its events and the final state
(probe2.log:31-41). `build` prints the creation code as one hex line, and
`build --runtime` prints the runtime code (probe2.log:21, :23). `evm
--verbosity 0 run --code HEX` runs the creation code and prints the code
that it returns (probe2.log:27).

## 6. Cost

Each file has N chained `Size` definitions (`def dI : Size := szS dJ`,
probe2.sh:43). Check and Print normal form run in the base span. Build runs
with `--kit` on the chain followed by `examples/storage.lang`. Each cell
gives the wall time and the peak resident memory, the larger of the two
`probe/guard.py` peaks (probe2.log:119-142).

| Step | N = 100 | N = 1000 |
| --- | --- | --- |
| Check (`langc check FILE`) | 0.025 s, 10.5 MB | 0.051 s, 14.9 MB |
| Print normal form (`langc eval FILE dN`) | 0.028 s, 10.4 MB | 0.052 s, 18.0 MB |
| Build (`langc --kit build FILE`) | 0.048 s, 14.9 MB | 0.078 s, 19.5 MB |
| Run | not probed | not probed |

- The eval output is 602 and 6002 characters by `wc -c` (probe2.log:124,
  :136).
- The build output stays 537 characters, the same as for
  `examples/storage.lang` alone (probe2.log:128, :140, :21). The build
  does not lower the unused chain definitions.
- The eval and build rows run in `zsh -c "... | wc -c"`, so their peak
  includes the shell and `wc`.
- probe.log:161-186 has the same rows on a `Nat` chain. Each step stops at
  REFUSE_KIT.

## 7. Parametric families

A program cannot declare a family: `test/check/data.lang` gives
REFUSE_DATA `a program cannot declare a family (rule R1); only
domain/domain.lang can` (probe.log:78). In `domain/domain.lang`, `Trunc1`,
`Trunc0`, `Bag` and `FreeMon` take a type parameter, and so does the
cofamily `Stream` (probe.log:147-148, :150, :153-154). `Pos`, `Word`,
`ChoiceBag` and `OrbitN` take a `Size` index (probe.log:156-159). A
constructor of a parametric family appears in a term: `examples/trunc.lang`
uses `trunc1 Nat` (`examples/trunc.lang:6-7`) and checks `ok` with `--kit`
(probe2.log:92). `examples/quot.lang` checks `ok` with `--kit`
(probe2.log:96). Probe files: `examples/trunc.lang` and
`examples/quot.lang`.

## 8. Sigma projection and eta

`witness` and `payload` check: `examples/sigma.lang:4-5` checks `ok` with
`--kit` (probe2.log:11), and `offered` (`witness offer`) evaluates to 1200
(probe2.log:15). A Sigma pattern does not parse: `fun (pack n e) => n`
gives PARSE_EXPECT `expected ':', found ')'` (probe.log:119). The kernel
accepts Sigma eta: for `p : Sigma (n : Nat) (Path Nat n n)`, `refl` checks
at `Path (Sigma (n : Nat) (Path Nat n n)) (pack (witness p) (payload p))
p` (probe2.sh:36, probe2.log:88).

## 9. Equality

A program writes `Path A x y`, `refl` and `cong` (`examples/paths.lang:6`).
`transport`, `J` and `trans` are definitions in `domain/domain.lang:8`, :13
and :21 (probe.log:143-145). The families with path constructors are `S1`,
`Trunc1` and `Trunc0` (probe.log:146-148); the domain has no `Quot` family
(probe.log:146-160). `examples/paths.lang`, `examples/equality.lang` and
`examples/circle.lang` check `ok` with `--kit` (probe2.log:100, :104,
:108); the circle check uses 187.8 MB (probe2.log:109). `Trunc1` and
`Trunc0` take their type as a parameter, so one family serves each index
type.

## 10. Axiom detection

No command lists the axioms of a file (the usage, probe.log:19-26).
`build/langc check FILE` prints only `ok` for a file with no axiom, with 0
`axiom` lines (probe.log:31, probe2.log:11, :112). The domain has no axiom:
its laws are `law def` with a proof term (`domain/domain.lang:144-147`). A
file with one axiom (`test/check/axiom.lang`, `axiom magic : Nat`) gives
REFUSE_AXIOM `an axiom has no proof (rule R2)` and exit 1
(probe.log:81-85).

## Consequences for M0

1. A program is one file, after the domain that `build/langc` embeds
   (section 2).
2. No `def rec`, and no call of the definition itself or of a later one:
   recursion is `fold` and `unfold` (section 3, R3).
3. A program with a kit type (`Nat`, an event) runs with `langc --kit`, as
   the gate does. The base span refuses it with REFUSE_KIT (sections 1
   and 4).
4. A `Nat` is at most 2^64 - 1. An overflow and a division by 0 trap with
   EVAL_OVERFLOW, and `natSub` stops at 0 (section 4).
