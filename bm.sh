#!/usr/bin/bash
node build.js -m1
mv tetris.nes tetrismmc1.nes
node build.js -m3
mv tetris.nes tetriscnrom.nes
node build.js -m4
mv tetris.nes tetrismmc3.nes
node build.js -m5
mv tetris.nes tetrismmc5.nes

