const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/level_menu_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-,\'>rtyfhvbn########qweadzxc############jkl/ui!###g#######()############@$#.############################################################################################################################################### ';

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(9472 + i) : d).join``

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
W0W################################
WWW################################
W#W###qwwwwwwwwwwwwwwwwwwwwwwwwe###
W#W###a                        d###
W#W###a               qwwwwwwe d###
W#W###a               a      d d###
W#W###a               zxxxxxxc d###
W#W###a     ╄╅╅╅╅╅╆            d###
X0W###a     ╇LEVEL╈            d###
XWW###a     ╉╊╊╊╊╊╋            d###
X#W###a  rtututututg           d###
X#W###a  f0f1f2f3f4f           d###
X#W###a  jbkbkbkbkbkbl         d###
X#W###a  f5f6f7f8f9f$h         d###
X#W###a  vbibibibibibn         d###
X#W###a                        d###
Y0W###a                        d###
YWW###a ###################### d###
Y#W###a #    NAME  SCORE  LV # d###
Y#W###a ###################### d###
Y#W###a # 1                  # d###
Y#W###a #                    # d###
Y#W###a # 2                  # d###
Y#W###a #                    # d###
Z0W###a # 3                  # d###
ZWW###a ###################### d###
Z#W###a                        d###
Z#W###zxxxxxxxxxxxxxxxxxxxxxxxxc###
Z#W################################
Z#W################################
Z#W##########################    ##
Z#W#000000##000000#########AAAAAAAA
`;

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
