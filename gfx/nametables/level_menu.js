const {
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    drawAttrs,
    flatLookup,
} = require('./nametables');

const buffer = readStripe(__dirname + '/level_menu_nametable.bin');

let lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-,˙>rtyfhvbn
########qweadzxc
############jkl/
ui!###g@######()
############^$#.
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

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(9472 + i) : d).join``;

printNT(buffer, lookup);

// heart

// XXX###a  rtutututututy         d###
// XXX###a  f0f1f2f3f4f^h         d###
// XXX###a  jbkbkbkbkbkbl         d###

drawTiles(buffer, lookup, `
################################
################################
###qwwwwwwwwwwwwwwwwwwwwwwwwe###
###a                        d###
###a               qwwwwwwe d###
###a               a      d d###
###a               zxxxxxxc d###
###a    ╄╅╅╅╅╅╆             d###
###a    ╇LEVEL╈             d###
###a    ╉╊╊╊╊╊╋             d###
###a  rtututututg           d###
###a  f0f1f2f3f4f           d###
###a  jbkbkbkbkbkb@         d###
###a  f5f6f7f8f9f$h         d###
###a  vbibibibibibn         d###
###a                        d###
###a                        d###
###a ###################### d###
###a #    NAME  SCORE  LV # d###
###a ###################### d###
###a # 1                  # d###
###a #                    # d###
###a # 2                  # d###
###a #                    # d###
###a # 3                  # d###
###a ###################### d###
###a                        d###
###zxxxxxxxxxxxxxxxxxxxxxxxxc###
################################
################################
`);

drawAttrs(buffer, [`
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
    2223333333222222
    2223333333222222
    2223333333222222
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
