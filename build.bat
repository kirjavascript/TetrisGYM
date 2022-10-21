: create nametables

node src/nametables/build.js

: PNG -> CHR

python tools/nes-util/nes_chr_encode.py src/gfx/title_menu_tileset.png src/gfx/title_menu_tileset.chr
python tools/nes-util/nes_chr_encode.py src/gfx/game_tileset.png src/gfx/game_tileset.chr
python tools/nes-util/nes_chr_encode.py src/gfx/rocket_tileset.png src/gfx/rocket_tileset.chr

: slower but more portable JS alternative
: npx img2chr gfx/title_menu_tileset.png gfx/title_menu_tileset.chr
: npx img2chr gfx/game_tileset.png gfx/game_tileset.chr
: npx img2chr gfx/rocket_tileset.png gfx/rocket_tileset.chr

: build object files

ca65 -g src/header.asm -o header.o
ca65 -l tetris.lst -g src/main.asm -o main.o

: link object files

ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o

: create patch

"./tools/flips-windows" --create clean.nes tetris.nes tetris.bps

: show some stats

sha1sum tetris.nes
sed -n '19,22p' < tetris.map
stat -c %s tetris.bps
