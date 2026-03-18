#!/usr/bin/env bash

mkdir -p tases

for i in {100..2000..100}; do
    python gentas.py $i -f tases/no-start-$(printf '%04d' $i).fm2
done

python gentas.py 300 -T 265 -f tases/earliest-start.fm2
python gentas.py 1800 -T 1794 -f tases/latest-start.fm2
python gentas.py 300 -T 265 270 274 286 -f tases/fastest-999999-start.fm2

python gentas.py 500 -T  400 420 440 460 -f tases/start-pattern-a.fm2
python gentas.py 800 -T  700 720 740 -f tases/start-pattern-b.fm2
python gentas.py 1000 -T 900 920 940 -f tases/start-pattern-c.fm2


while read -r -d '' tas; do
    clean="${tas%.*}"-clean.log
    if ! test -f "$clean"; then
        echo $clean not found, running test
        time cargo run --release --manifest-path tests/Cargo.toml -- \
            parity "$tas" -w
    fi
done < <(find tases/ -name "*.fm2" -print0)
