: create nametables

node src/nametables/build.js

: PNG -> CHR

node tools/png2chr/convert.js src/chr

: build object files

ca65 -g src/header.asm -o header.o
ca65 -l tetris.lst -g src/main.asm -o main.o

: link object files

ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o

: create patch

"./tools/flips-windows" --create clean.nes tetris.nes tetris.bps

: show some stats

sha1sum tetris.nes
sed -n '23,27p' < tetris.map
stat -c %s tetris.bps
