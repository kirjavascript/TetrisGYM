const { readFileSync, writeFileSync } = require('fs');
const { konamiComp } = require('./rle');

function strip(_array) {
    const array = [..._array];
    const stripped = [];
    while (array.length) {
        const next = array.splice(0, 35);
        stripped.push(...next.slice(3));
    }
    return stripped;
}

function readStripe(filename) {
    const bin = readFileSync(filename);
    return strip(bin);
}

function writeRLE(filename, buffer) {
    const compressed = Buffer.from(konamiComp(Array.from(buffer)));
    // console.log(`${filename.split('/').pop()} ${buffer.length} -> ${compressed.length}`);
    writeFileSync(filename, compressed);
}

const STR_OFFSET = 512;

function printNT(buffer, lookup) {
    const chars = [...buffer].map(value => {
        const char = lookup[value];

        if (char === '#') {
            return String.fromCharCode(value + STR_OFFSET);
        }

        return char;
    });

    console.log(chars.join('').match(/.{32}/g).join('\n'));
}

function blankNT() {
    return Array.from({ length: 1024 }, () => 0xFF);
}

function drawTiles(buffer, lookup, tiles, offset = 0) {
    [...tiles.trim().split('\n').join('')].forEach((d, i) => {
        if (d !== '#') {
            const charCode = d.charCodeAt(0);
            if (charCode > STR_OFFSET) {
                buffer[o + i] = charCode - STR_OFFSET;
            } else {
                buffer[o + i] = lookup.indexOf(d);
            }
        }
    });
}

function drawRect(buffer, x, y, w, h, offset) {
    x += 3;
    const pixel = x+ (y*32);
    for (let i=0;w>i;i++) {
        for (let j=0;h>j;j++) {
            buffer[pixel + i + (j * 32)] = offset+i + (j * 0x10);
        }
    }
}

function drawAttrs(buffer, attrs) {
    const palettes = p => p.trim().match(/.+\n.+$/gm)
        .flatMap(line=>{
            const [t,b]=line.split('\n');
            return t.trim().match(r=/../g).map((d,i)=>d+b.trim().match(r)[i])
        })
        .map(d=>+('0b'+[...d].reverse().map(d=>(+d).toString(2).padStart(2,0)).join``));

    [
        [30 * 32, palettes(attrs[0])],
        [31 * 32, palettes(attrs[1])],
    ].forEach(([index, attributes]) => {
        attributes.forEach((byte, i) => { buffer[i+index] = byte; });
    });
}

function flatLookup(lookup) {
    return lookup.trim().split('\n').map(d=>d.padEnd(16).slice(0, 16)).join('');
}

module.exports = {
    strip,
    readStripe,
    writeRLE,
    printNT,
    blankNT,
    drawTiles,
    drawRect,
    drawAttrs,
    flatLookup,
};
