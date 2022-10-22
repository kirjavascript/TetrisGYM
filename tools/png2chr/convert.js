const { PNG } = require('./png.js');
const fs = require('fs');

function png2chr(inFile, outFile) {
    const png = PNG.sync.read(fs.readFileSync(inFile));

    const palettes = png.palette.map((arr) => String(arr));

    // get an array of pixel indices

    const pixels = [];
    for (let cursor = 0; cursor < png.data.length; cursor += 4) {
        const chunk = png.data.slice(cursor, cursor + 4);
        const paletteIndex = palettes.indexOf(String([...chunk]));
        if (paletteIndex === -1) {
            console.error('Palette index not found');
        }
        pixels.push(paletteIndex);
    }

    // rearrange into groups of tiles

    const tilePixels = [];

    function offset(i) {
        return (i % 8) + ((i / 8) | 0) * png.width;
    }

    for (let tile = 0; tile < 256; tile++) {
        const index = tile * 8 + ((tile / 16) | 0) * png.width * 7;

        for (let i = 0; i < 64; i++) {
            tilePixels.push(pixels[index + offset(i)]);
        }
    }

    // replace original array

    pixels.splice(0, pixels.length, ...tilePixels);

    // convert tiles into bytes

    const bytes = [];

    for (let cursor = 0; cursor < pixels.length; cursor += 64) {
        const indices = pixels.slice(cursor, cursor + 64);
        const indicesBin = indices.map((idx) => idx.toString(2).padStart(2, 0));

        for (let i = 0; i < 64; i += 8) {
            bytes.push(
                parseInt(
                    indicesBin
                    .slice(i, i + 8)
                    .map((idx) => idx[1])
                    .join(''),
                    2,
                ),
            );
        }

        for (let i = 0; i < 64; i += 8) {
            bytes.push(
                parseInt(
                    indicesBin
                    .slice(i, i + 8)
                    .map((idx) => idx[0])
                    .join(''),
                    2,
                ),
            );
        }
    }

    fs.writeFileSync(outFile, Uint8Array.from(bytes));
}

const [, , inFile, outFile] = process.argv;

if (inFile && outFile) {
    // convert one file
    png2chr(inFile, outFile);
} else if (inFile) {
    // convert all PNG in a directory
    fs.readdirSync(inFile)
        .filter(name => name.endsWith('.png'))
        .forEach(name => {
            png2chr(inFile + '/' + name, inFile + '/' + name.replace('.png', '.chr'));
        });
}

module.exports = png2chr;
