make
./tools/flips-linux --create clean.nes tetris.nes tetris.bps
stat -c %s tetris.bps

if [ "$1" == "fceux" ]; then
    fceux ./tetris.nes
fi
if [ "$1" == "mesen" ]; then
    mesen ./tetris.nes
fi
