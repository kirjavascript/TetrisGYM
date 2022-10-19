node gfx/nametables/build.js
make
sha1sum tetris.nes
sed -n '18p;19p;24,26p' < tetris.map
./tools/flips-linux --create clean.nes tetris.nes tetris.bps
stat -c %s tetris.bps
