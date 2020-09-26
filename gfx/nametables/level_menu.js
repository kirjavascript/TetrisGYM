const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/level_menu_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>################qweadzxc###############/##!###########()############################################################################################################################################################### ';

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(9472 + i) : d).join``

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));

const tiles = `
W0W################################
WWW################################
W#W###qwwwwwwwwwwwwwwwwwwwwwwwwe###
W#W###a                        d###
W#W###a                        d###
W#W###a                        d###
W#W###a                        d###
W#W###a    #######             d###
X0W###a    #LEVEL#             d###
XWW###a    #######             d###
X#W###a  ###########           d###
X#W###a  #0#1#2#3#4#           d###
X#W###a  ###########           d###
X#W###a  #5#6#7#8#9#           d###
X#W###a  ###########           d###
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
    // TODO: patch logo
    if (d !== '#') {
        practise[i] = lookup.indexOf(d);
    }
});
writeFileSync(__dirname + '/level_menu_nametable_practise.bin', practise);
