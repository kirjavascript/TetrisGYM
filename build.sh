make
./tools/flips-linux --create clean.nes tetris.nes tetris.ips
./tools/flips-linux --create clean.nes tetris.nes tetris.bps
stat -c %s tetris.ips
stat -c %s tetris.bps

if [ "$1" == "run" ]; then
    fceux ./tetris.nes
fi
if [ "$1" == "debug" ]; then
    mesen ./tetris.nes
fi
