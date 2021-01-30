const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/high_scores_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-,\'>################qweadzxc###############/##!#########[]()###############.############################################################################################################################################### ';

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));
