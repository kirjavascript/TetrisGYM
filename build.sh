#!/bin/sh

while getopts 'm:kv' flag; do
  case "${flag}" in
    m) ines_mapper=${OPTARG} ;;
    k) keyboard_arg='-D KEYBOARD' ;;
    v) set -x ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

# build / compress nametables

node src/nametables/build.js

# PNG -> CHR

png2chr() {
    node tools/png2chr/convert.js src/chr
}

# build CHR if it doesnt already exist

if [ "$(find src/chr/*.chr 2>/dev/null | wc -l)" = 0 ]; then
    echo "building CHR for the first time"
    png2chr
else

    # if it does exist check if the PNG has been modified

    pngTimes=$(stat -c "%Y" src/chr/*.png)
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

touch src/chr/*.png
touch "$0"

# build object files

ca65 -D INES_MAPPER="${ines_mapper:-1}" $keyboard_arg -g src/header.asm -o header.o
ca65 -D INES_MAPPER="${ines_mapper:-1}" $keyboard_arg -l tetris.lst -g src/main.asm -o main.o

# link object files

ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o

# create patch

./tools/flips-linux --create clean.nes tetris.nes tetris.bps

# show some stats

sha1sum tetris.nes
sed -n '23,27p' < tetris.map
stat -c %s tetris.bps
