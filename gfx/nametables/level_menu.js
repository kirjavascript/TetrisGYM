const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/level_menu_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-,\'>rtyfhvbn########qweadzxc############jkl/ui!###g@######()############^$#.############################################################################################################################################### ';

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(9472 + i) : d).join``

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
XXX################################
XXX################################
XXX###qwwwwwwwwwwwwwwwwwwwwwwwwe###
XXX###a                        d###
XXX###a               qwwwwwwe d###
XXX###a               a      d d###
XXX###a               zxxxxxxc d###
XXX###a    ╄╅╅╅╅╅╆             d###
XXX###a    ╇LEVEL╈             d###
XXX###a    ╉╊╊╊╊╊╋             d###
XXX###a  rtututututg           d###
XXX###a  f0f1f2f3f4f           d###
XXX###a  jbkbkbkbkbkb@         d###
XXX###a  f5f6f7f8f9f$h         d###
XXX###a  vbibibibibibn         d###
XXX###a                        d###
XXX###a                        d###
XXX###a ###################### d###
XXX###a #    NAME  SCORE  LV # d###
XXX###a ###################### d###
XXX###a # 1                  # d###
XXX###a #                    # d###
XXX###a # 2                  # d###
XXX###a #                    # d###
XXX###a # 3                  # d###
XXX###a ###################### d###
XXX###a                        d###
XXX###zxxxxxxxxxxxxxxxxxxxxxxxxc###
XXX################################
XXX################################
XXX##########################    ##
XXX#000000##000000#########AAAAAAAA
`;

// heart

// rtutututututy
// f0f1f2f3f4f^h
// jbkbkbkbkbkbl

const practise = Buffer.from(buffer);
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    if (d !== '#') {
        practise[i] = lookup.indexOf(d);
    }
});

// palettes
// DR - DL - UR - UL
const palettes = p => p.trim().match(/.+\n.+$/gm)
    .flatMap(line=>(
        [t,b]=line.split('\n'),
        t.trim().match(r=/../g).map((d,i)=>d+b.trim().match(r)[i])
    ))
    .map(d=>+('0b'+[...d].reverse().map(d=>(+d).toString(2).padStart(2,0)).join``));

[
    [1053, palettes(`
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2223333333222222
        2223333333222222
        2223333333222222
    `)],
    [1088, palettes(`
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
    `)],
].forEach(([index, attributes]) => attributes.forEach((byte, i) => { practise[i+index] = byte; }));

writeFileSync(
    __dirname + '/level_menu_nametable_practise.bin',
    require('./rle')(practise),
);
