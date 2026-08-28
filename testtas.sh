#!/usr/bin/env bash

cargo build --release --manifest-path tests/Cargo.toml

node build.js

while read -r -d '' tas; do
    clean="${tas%.*}"-clean.log
    if test -f "$clean"; then
        ./tests/target/release/gym-tests parity "$tas"
    fi
done < <(find tases/ -name "*.fm2" -print0)
