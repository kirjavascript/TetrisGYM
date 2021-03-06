const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/game_nametable.bin');

const lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>!^()############qweadzxc############################################################################################################################################################################################### ';

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
W0W################################
WWW################################
W#W###########qwwwwwwwwwweqwwwwwwe#
W#W##qwwwwwwe#a LINES-000da      d#
W#W##a      d#zxxxxxxxxxxcaTOP   d#
W#W##zxxxxxxc#############a      d#
W#W############          #a      d#
W#W############          #aSCORE d#
X0W#qwwwwwwwwe#          #a000000d#
XWW#a########d#          #a      d#
X#W#a        d#          #zxxxxxxc#
X#W#a ###    d#          ##########
X#W#a ###000 d#          ##########
X#W#a ###    d#          ##NEXT####
X#W#a ###000 d#          ##    ####
X#W#a ##     d#          ##    ####
Y0W#a ###000 d#          ##    ####
YWW#a ##     d#          ##    ####
Y#W#a ## 000 d#          ##########
Y#W#a ###    d#          #qwwwwwe##
Y#W#a ###000 d#          #aLEVELd##
Y#W#a ###    d#          #a     d##
Y#W#a ###000 d#          #zxxxxxc##
Y#W#a        d#          ##########
Z0W#a ###000 d#          ##########
ZWW#a        d#          ##########
Z#W#zxxxxxxxxc#####################
Z#W################################
Z#W################################
Z#W################################
Z#W           ###  ######  #Y######
Z#W#Y####  #Y####  ######  FFFFFFFF
`;
const game = Buffer.from(buffer);
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    if (d !== '#') {
        game[i] = lookup.indexOf(d);
    }
});

// patch movement of statistics tiles
for (let i = 0; i < 8; i++) {
    game[320 + i] = 0x68 + i;
}

writeFileSync(__dirname + '/game_nametable_practise.bin', game);
