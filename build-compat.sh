#!/bin/sh

# build / compress nametables

node src/nametables/build.js

# PNG -> CHR

node tools/png2chr/convert.js src/chr

# build object files

ca65 -D INES_MAPPER="${1:-1}" -g src/header.asm -o header.o
ca65 -D INES_MAPPER="${1:-1}" -l tetris.lst -g src/main.asm -o main.o

# link object files

ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o
