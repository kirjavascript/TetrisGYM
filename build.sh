node gfx/nametables/build.js
python tools/nes-util/nes_chr_encode.py gfx/title_menu_tileset.png gfx/title_menu_tileset.chr
python tools/nes-util/nes_chr_encode.py gfx/game_tileset.png gfx/game_tileset.chr
python tools/nes-util/nes_chr_encode.py gfx/rocket_tileset.png gfx/rocket_tileset.chr
/usr/bin/ca65 -l tetris.lst -g tetris.asm -o tetris.o
/usr/bin/ca65 -l tetris.lst -g main.asm -o main.o
/usr/bin/ca65 -l tetris.lst -g tetris-ram.asm -o tetris-ram.o
/usr/bin/ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C tetris.nes.cfg main.o tetris-ram.o tetris.o
sha1sum tetris.nes
sed -n '18p;19p;24,26p' < tetris.map
./tools/flips-linux --create clean.nes tetris.nes tetris.bps
stat -c %s tetris.bps
