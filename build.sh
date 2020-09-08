make
./tools/flips-linux --create clean.nes tetris.nes tetris.ips
# ./tools/flips-linux --apply taus-1-2-0.ips tetris.nes tetris_taus.nes
stat -c %s tetris.ips

if [ "$1" == "run" ]; then
    fceux ./tetris.nes
fi
