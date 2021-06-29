const { readFileSync, writeFileSync } = require('fs');
const { strip } = require('./rle');

function readStripe(filename) {
    const bin = readFileSync(filename);
    return strip(bin);
}

function printNT(lookup, buffer) {
    const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');
    console.log(chars.join('').match(/.{32}/g).join('\n'));
}

function drawNT(lookup, buffer, tiles) {
    [...tiles.trim().split('\n').join('')].forEach((d, i) => {
        if (d !== '#') {
            buffer[i] = lookup.indexOf(d);
        }
    });
}

function drawTiles(x, y, w, h, offset) {
    x += 3;
    const pixel = x+ (y*32);
    for (let i=0;w>i;i++) {
        for (let j=0;h>j;j++) {
            practise[pixel + i + (j * 32)] = offset+i + (j * 0x10);
        }
    }
}

module.exports = {

};
