#!/bin/sh

# build / compress nametables

node gfx/nametables/build.js

# PNG -> CHR

function png2chr {

    python tools/nes-util/nes_chr_encode.py gfx/title_menu_tileset.png gfx/title_menu_tileset.chr
    python tools/nes-util/nes_chr_encode.py gfx/game_tileset.png gfx/game_tileset.chr
    python tools/nes-util/nes_chr_encode.py gfx/rocket_tileset.png gfx/rocket_tileset.chr

    # slower but more portable JS alternative
    # npx img2chr gfx/title_menu_tileset.png gfx/title_menu_tileset.chr
    # npx img2chr gfx/game_tileset.png gfx/game_tileset.chr
    # npx img2chr gfx/rocket_tileset.png gfx/rocket_tileset.chr
}

# build CHR if it doesnt already exist

if [ `ls -1 gfx/*.chr 2>/dev/null | wc -l` == 0 ]; then
    echo "building CHR for the first time"
    png2chr
else

    # if it does exist check if the PNG has been modified

    pngTimes=$(stat -c "%Y" gfx/*.png)
    scriptTime=$(stat -c "%X" "$0")

    for pngTime in $pngTimes; do
        if [ "$pngTime" -gt "$scriptTime" ]; then
            echo "converting PNG to CHR"
                png2chr
            break;
        fi
    done
fi

# touch this file to store the last modified / checked date

touch gfx/*.png
touch "$0"

# build object files

ca65 -l tetris.lst -g tetris.asm -o tetris.o
ca65 -g main.asm -o main.o
ca65 -g tetris-ram.asm -o tetris-ram.o

# link object files

ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C tetris.nes.cfg main.o tetris-ram.o tetris.o

# create patch

./tools/flips-linux --create clean.nes tetris.nes tetris.bps

# show some stats

sha1sum tetris.nes
sed -n '18p;19p;24,26p' < tetris.map
stat -c %s tetris.bps
