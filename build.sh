#!/bin/sh

# build / compress nametables

node src/nametables/build.js

# PNG -> CHR

png2chr() {
    node tools/png2chr/convert.js src/gfx
}

# build CHR if it doesnt already exist

if [ "$(find src/gfx/*.chr 2>/dev/null | wc -l)" = 0 ]; then
    echo "building CHR for the first time"
    png2chr
else

    # if it does exist check if the PNG has been modified

    pngTimes=$(stat -c "%Y" src/gfx/*.png)
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

touch src/gfx/*.png
touch "$0"

# build object files

ca65 -g src/header.asm -o header.o
ca65 -l tetris.lst -g src/main.asm -o main.o

# link object files

ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o

# create patch

./tools/flips-linux --create clean.nes tetris.nes tetris.bps

# show some stats

sha1sum tetris.nes
sed -n '23,27p' < tetris.map
stat -c %s tetris.bps
