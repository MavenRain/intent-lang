#!/bin/sh
# The reactor chain gate (S10R, Q-S11-4 (a)). Deploy examples/reactor.lang and
# examples/daokit.lang, check the size limits of the reactor (O15: the runtime
# at most 24576 bytes, EIP-170; the initcode at most 49152 bytes, EIP-3860),
# then run one chain on 4 accounts: the DAO at the receiver address, the
# reactor at 0x$reactor and the `build/asmtool mock` token at 0x..ee (inTok)
# and 0x..ef (outTok) (Q-S11-3 (a)): the owner has 100 inTok, the key address
# (the solver) has 100 outTok. Each step calls one account, and the storage of
# each account carries to the next step. The fill words are the call lines of
# test/run/reactor.script, the cast and enact words the ones of test/dao.sh
# (`build/ballottool dao` and `build/ballottool words`). The settle of o 6 at
# BLOCK 102 (t 2) is short at window 6u and passes after enact pays the reactor
# the window 4u (O41, Q-S11-2 (a)); o 3 at BLOCK 108 and the replay revert; a
# cancel by another caller leaves nonce 8 open, a cancel by the owner closes
# it. Then the mock balances must show the two pulls. The line `reactor gas
# rows` gives the execution gas of deploy, fillCipher, fillAuth, fillOpen,
# enact (with the pay), fillSettle and cancel; the gate does not check it. It
# needs evm (go-ethereum), bc, od, build/asmtool and build/ballottool. Run it
# from the kit root.
set -u
fail=0
steps=0
tmp=${TMPDIR:-/tmp}/langc-reactor.$$
mkdir -p "$tmp"
. test/evmchain.sh

rprog=examples/reactor.lang
dprog=examples/daokit.lang
script=test/run/reactor.script
voter=0x00000000000000000000000000000000000000aa
owner=eb3025e7ac2764040384316b33476e048961a71f
intok=00000000000000000000000000000000000000ee
outtok=00000000000000000000000000000000000000ef
dao=$receiver
from=
numbered=1
{ build/ballottool dao && build/ballottool words; } >"$tmp/words" || { echo "FAIL reactor: ballottool"; exit 1; }
build/asmtool mock >"$tmp/mock" || { echo "FAIL reactor: asmtool mock"; exit 1; }

# ws PREFIX NAMES..., sig V, slot V J, seal V, opening M: the cast and enact
# arguments of test/dao.sh.
ws() {
  _p=$1
  shift
  printf '%s\n' "$@" | awk -v p="$_p" 'NR == FNR { if (!($1 in v)) v[$1] = $2; next } { print v[p $1] "u" }' "$tmp/words" -
}
sig() { ws "b$1" ix iy j0c1x j0c1y j0c2x j0c2y j1c1x j1c1y j1c2x j1c2y c1 s1 s2 s3; }
slot() {
  ws "b$1" ix iy
  echo "$2u"
  ws "b$1j$2" a0x a0y b0x b0y a1x a1y b1x b1y e0 e1 z0 z1
}
seal() { ws "b$1" ix iy sumax sumay sumbx sumby sumz; }
opening() {
  ws ty d1x d1y a1x a1y b1x b1y z1 d2x d2y a2x a2y b2x b2y z2
  echo "$1u"
}

# fw K: the arguments of call line K of test/run/reactor.script.
fw() { awk 'NF && $1 != "--"' "$script" | awk -v k="$1" 'NR == k { for (i = 5; i <= NF; i++) print $i }'; }

# at ADDR PROG: the next calls go to the account ADDR with the program PROG.
# tmp/code and tmp/raw get its code and storage (tmp/c.ADDR, tmp/s.ADDR),
# alloc the other 3 accounts.
at() {
  receiver=$1 prog=$2
  cp "$tmp/c.$1" "$tmp/code"
  cp "$tmp/s.$1" "$tmp/raw"
  alloc=
  for _a in $dao $reactor $intok $outtok; do
    [ "$_a" = "$1" ] || alloc="$alloc,\"0x$_a\":{\"balance\":\"0x0\",\"code\":\"0x$(cat "$tmp/c.$_a")\",\"storage\":{$(
      awk '{ printf "%s\"0x%s\":\"0x%s\"", (NR > 1 ? "," : ""), $1, $2 }' "$tmp/s.$_a")}}"
  done
}

# call WANT NAME BLOCK ARGS...: one step of the entry or view NAME of the
# account of `at` with ARGS at NOW = BLOCK, as in test/dao.sh: at BLOCK 0 an
# `evm run` step from the voter (or from $from when it is set), at BLOCK > 0 a
# t8n step from the key address. `at` first: alloc gets the storage of the other
# accounts after the last step; tmp/s.ADDR gets the storage of each account
# after this step. The result must equal WANT: `out HEX`, ok or revert.
call() {
  _want=$1 _name=$2 _block=$3
  shift 3
  steps=$((steps + 1))
  at "$receiver" "$prog"
  _from=${from:-$voter}
  [ "$_block" = 0 ] || _from=0x$key
  _input=$(input "$prog" "$_name" "$@")
  if ! step "$_block" "${_block}u" "$_from" "$_input"; then
    echo "FAIL reactor $_name (step $steps): evm: $(head -n 1 "$tmp/dump")"
    fail=$((fail + 1))
    return
  fi
  for _a in $dao $reactor $intok $outtok; do acct "$_a" >"$tmp/s.$_a"; done
  own
  case $result in
    "out "*) _hex=${result#out }
      [ ${#_hex} -eq 64 ] && result="out $(hexnorm "$_hex")" ;;
  esac
  if [ "$result" != "$_want" ]; then
    echo "FAIL reactor $_name (step $steps): want $_want, got $result"
    fail=$((fail + 1))
  fi
}

# gasrow NAME: as in test/dao.sh, the execution gas of the last call.
gasrows=
gasrow() {
  [ "$stepped" = t8n ] || gas=$(evm run --prestate "$tmp/pre.json" --receiver "0x$receiver" --sender "$_from" \
    --input "$_input" --statdump 2>&1 >/dev/null | awk '$1 == "EVM" { print $4 }')
  gasrows="$gasrows, $1 $gas"
}

# cast V: the 4 calls of voter V at BLOCK 0.
cast() {
  call ok castSig 0 $(sig "$1")
  call ok castSlot 0 $(slot "$1" 0)
  call ok castSlot 0 $(slot "$1" 1)
  call ok castSeal 0 $(seal "$1")
}

# tokens TOKEN ROWS: one step; the storage rows of the mock TOKEN must equal
# ROWS (ADDR:VALUE, hex).
tokens() {
  steps=$((steps + 1))
  for _r in $2; do echo "$(pad "${_r%:*}") ${_r#*:}"; done | norm >"$tmp/twant"
  norm <"$tmp/s.$1" >"$tmp/tgot"
  if ! cmp -s "$tmp/twant" "$tmp/tgot"; then
    echo "FAIL reactor balances $1: want $(tr '\n' ' ' <"$tmp/twant"), got $(tr '\n' ' ' <"$tmp/tgot")"
    fail=$((fail + 1))
  fi
}

for _p in "$rprog" "$dprog"; do
  if ! deploy "$_p"; then
    echo "FAIL reactor deploy $_p: $(head -n 1 "$tmp/dump")"
    rm -rf "$tmp"
    echo "reactor chain: 0 steps, 1 failures"
    exit 1
  fi
  [ "$_p" = "$dprog" ] && _a=$dao || _a=$reactor
  cp "$tmp/code" "$tmp/c.$_a"
  cp "$tmp/raw" "$tmp/s.$_a"
done
init=$(build/langc --kit build "$rprog")
# The deploy gas: the genesis gas limit minus the gas left (test/dao.sh).
dgas=$((30000000 - $(evm run --prestate "$tmp/pre.json" --create --code "$init" --statdump 2>&1 >/dev/null |
  awk '$1 == "EVM" { print $4 }')))
ibytes=$((${#init} / 2))
rbytes=$(awk '{ print length($0) / 2; exit }' "$tmp/c.$reactor")
echo "reactor size rows: runtime $rbytes bytes (limit 24576), initcode $ibytes bytes (limit 49152)"
[ "$rbytes" -le 24576 ] || { echo "FAIL reactor size: runtime $rbytes > 24576 (O15)"; fail=$((fail + 1)); }
[ "$ibytes" -le 49152 ] || { echo "FAIL reactor size: initcode $ibytes > 49152 (O15)"; fail=$((fail + 1)); }
cp "$tmp/mock" "$tmp/c.$intok"
cp "$tmp/mock" "$tmp/c.$outtok"
echo "$(pad "$owner") $(pad 64)" >"$tmp/s.$intok"
echo "$(pad "$key") $(pad 64)" >"$tmp/s.$outtok"

# The fill of nonce 7 at BLOCK 0, the window 6u: the settle at BLOCK 102 is
# short, and a transfer by the voter (not the DAO) reverts.
at "$reactor" "$rprog"
call ok fillCipher 0 $(fw 1)
gasrow fillCipher
call ok fillAuth 0 $(fw 2)
gasrow fillAuth
call ok fillOpen 0 $(fw 3)
gasrow fillOpen
call ok fillOpen 0 $(fw 4)
call ok fillOpen 0 $(fw 5)
# Reject each noncanonical amount without replacing the stored opening.
call revert fillOpen 0 $(fw 21)
call revert fillOpen 0 $(fw 22)
call revert fillOpen 0 $(fw 23)
call "out 3" amountOf 0 $(fw 24)
call "out 8" amountOf 0 $(fw 25)
call "out 4" amountOf 0 $(fw 26)
call "out 6" windowOf 0
call revert fillSettle 102 $(fw 7)
call revert transfer 0 $(fw 8)

# The DAO: voters 0, 1 and 2 cast at BLOCK 0, enact (m 2) at BLOCK 11 sets the
# window 4 and pays it to the reactor.
at "$dao" "$dprog"
cast 0
cast 1
cast 2
call ok enact 11 $(opening 2)
gasrow enact

# The reactor at window 4u: o 3 at BLOCK 108 (t 8 > 4) reverts, o 6 at BLOCK
# 102 settles, its replay reverts. A cancel by the voter keeps nonce 8 of the
# owner open; a cancel by the owner closes it.
at "$reactor" "$rprog"
call "out 4" windowOf 0
call revert fillSettle 108 $(fw 10)
call ok fillSettle 102 $(fw 11)
gasrow fillSettle
call revert fillSettle 102 $(fw 12)
call "out 1" closedOf 0 $(fw 13)
call ok cancel 0 $(fw 14)
call ok fillAuth 0 $(fw 15)
call "out 0" closedOf 0 $(fw 16)
from=0x$owner
call ok cancel 0 $(fw 17)
gasrow cancel
from=
call "out 1" closedOf 0 $(fw 18)
call revert fillAuth 0 $(fw 19)

# The pulls of the settle: amtIn 3 inTok from the owner to the solver, o 6
# outTok from the solver to the owner.
tokens "$intok" "$owner:61 $key:3"
tokens "$outtok" "$key:5e $owner:6"

rm -rf "$tmp"
echo "reactor gas rows: deploy $dgas$gasrows"
echo "reactor chain: $steps steps, $fail failures"
[ "$fail" -eq 0 ]
