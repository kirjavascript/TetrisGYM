const {
    writeRLE,
    blankNT,
    drawTiles,
    flatLookup,
    drawAttrs,
} = require('./nametables');

const legal = blankNT();
const rocket = blankNT();

const lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-.˙>qweadzxc
################
################
################
################
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

drawTiles(rocket, lookup, `
################################
################################
################################
################################
################################
################################
############          ##########
############  BUS     ##SCORE###
############  SCREEN  ##########
############          ##########
############          ##########
############          ##LINES###
############          ##########
############          ##########
############          ##########
############          ##LEVEL###
############          ##########
############          ##########
############          ##########
############          ##START###
############          ##########
############          ##########
############          ##########
############          ##########
############          ##########
############          ##########
################################
################################
################################
################################
`);

// drawRect(rocket, -2, 11, 9, 6, 0x30);

drawTiles(legal, lookup, `
################################
################################
################################
################################
################################
################################
################################
################################
################################
################################
################################
#########LEGAL  SCREEN##########
################################
################################
################################
################################
################################
################################
################################
################################
################################
################################
################################
######SOMETHING TO DO WITH######
######## FISH AND CHIPS ########
################################
################################
################################
################################
################################
`);

drawAttrs(rocket, [`
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
`,`
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
`]);

drawAttrs(legal, [`
    0000000000000000
    0000000000000000
    0000000000000000
    0000000000000000
    0000000000000000
    0000000000000000
    0000000000000000
    0000000000000000
`,`
    0000000000000000
    0000000000000000
    0000000000000000
    0000000000000000
    1111111111111111
    1111111111111111
    1111111111111111
    1111111111111111
`]);

writeRLE(
    __dirname + '/rocket_nametable.bin',
    rocket,
);

writeRLE(
    __dirname + '/legal_nametable.bin',
    legal,
);
