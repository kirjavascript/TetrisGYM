#!/bin/bash

compile_flags=()

help () {
    echo "Usage: $0 [-v] [-m <1|3>] [-a] [-s] [-k] [-h]"
    echo "-v  verbose"
    echo "-m  mapper"
    echo "-a  faster aeppoz + press select to end game"
    echo "-s  disable highscores/SRAM"
    echo "-k  Famicom Keyboard support"
    echo "-h  you are here"
}

while getopts "vm:askh" flag; do
  case "${flag}" in
    v) set -x ;;
    m)
        if ! [[ "${OPTARG}" =~ ^[13]$ ]]; then
            echo "Valid INES_MAPPER (-m) options are 1 or 3"
            exit 1
        fi
        compile_flags+=("-D INES_MAPPER=${OPTARG}")
        echo "INES_MAPPER set to ${OPTARG}"  ;;
    a)
        compile_flags+=("-D AUTO_WIN=1")
        echo "AUTO_WIN enabled"  ;;
    s)
        compile_flags+=("-D SAVE_HIGHSCORES=0")
        echo "SAVE_HIGHSCORES disabled"  ;;
    k)
        compile_flags+=("-D KEYBOARD=1")
        echo "KEYBOARD enabled"  ;;
    h)
        help; exit ;;
    *)
        help; exit 1 ;;
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

ca65 ${compile_flags[*]} -g src/header.asm -o header.o
ca65 ${compile_flags[*]} -l tetris.lst -g src/main.asm -o main.o

# link object files

ld65 -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o

# create patch

./tools/flips-linux --create clean.nes tetris.nes tetris.bps

# show some stats

sha1sum tetris.nes
sed -n '23,27p' < tetris.map
stat -c %s tetris.bps
