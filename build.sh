make
# ca65 -l tetris.lst -g main.asm -o main.o
# ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C tetris.nes.cfg main.o tetris-ram.o tetris.o
sha1sum tetris.nes
sed -n '18p;19p;24,26p' < tetris.map
./tools/flips-linux --create clean.nes tetris.nes tetris.bps
stat -c %s tetris.bps
