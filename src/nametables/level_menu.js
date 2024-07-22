const {
    blankNT,
    writeRLE,
    drawTiles,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const buffer = blankNT();

let lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-,˙>rtyfhvbn
########qweadzxc
####ĄąĆćĈĉĊċjkl/
ui!###g@ß#####()
###########æ^$#.
################
################
################
################
################
################
################
################
###############
`);

drawTiles(buffer, lookup, `
ɠɡɠɡɢʂɢʐʃɢɢɢʂʀʑʀʑɰɱɢʂʀʁʁʃʐʃɢɢʀʁʑ
ɰqwwwwwwwwwwwwwwwwwwwwwwwwwwwweʂ
ʀa                            dɡ
ʀa                            dɱ
ɢa                            dʃ
ɲa                            dʑ
ʠa          HIGHSCORES        dɲ
ʐa                            dʂ
ʂa                            dʑ
ɠa                            dʂ
ɰa                            dʑ
ʀa                            dʂ
ɢa                            dʀ
ɲa                            dʃ
ɲa                            dʃ
ʂa                            dʃ
ɢa                            dʑ
ʠa                      LEVEL dɲ
ɢa                            dʂ
╂a                            dʑ
ʂa                      rttty dʂ
ʀa                      f   h dʑ
ɠa                      vbbbn dʂ
ɰa                            dʀ
ɢa                            dʃ
ɲa                            dʃ
ɲa                            dɡ
ʂa                            dɱ
ɢzxxxxxxxxxxxxxxxxxxxxxxxxxxxxcɢ
ɲʀʡʀ╁ʃɢʂʀ╃ʃʀʡɢɲɢɰɱʂʀʁʡɢʂɠɡʠʃʠʃʀ╁
`);

drawAttrs(buffer, [`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
`,`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
`]);

writeRLE(
    __dirname + '/level_menu_nametable_practise.bin',
    buffer,
);
