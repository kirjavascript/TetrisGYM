const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { spawnSync } = require('child_process');

console.log('TetrisGYM buildscript');
console.time('build');

const mappers = { // https://www.nesdev.org/wiki/Mapper
    1: 'MMC1',
    3: 'CNROM',
    4: 'MMC3',
    5: 'MMC5',
};

// options handling

const args = process.argv.slice(2);

if (args.includes('-h')) {
    console.log(`usage: node build.js [-h] [-v] [-m<${Object.keys(mappers).join('|')}>] [-a] [-s] [-k] [-w]

-m  mapper
-a  faster aeppoz + press select to end game
-s  disable highscores/SRAM
-k  Famicom Keyboard support
-w  force WASM compiler
-c  force PNG to CHR conversion
-h  you are here
`);
    process.exit(0);
}

const compileFlags = [];

// compiler options

const nativeCC65 = args.includes('-w')
    ? false
    : process.env.PATH.split(path.delimiter).some((dir) =>
          fs
              .statSync(path.join(dir, 'cc65'), { throwIfNoEntry: false })
              ?.isFile(),
      );

console.log(`using ${nativeCC65 ? 'system' : 'wasm'} ca65/ld65`);

// mapper options

const mapper = args.find((d) => d.startsWith('-m'))?.slice(2) ?? 1;

if (!mappers[mapper]) {
    console.error(
        `invalid INES_MAPPER - options are ${Object.keys(mappers)
            .map((d) => `-m${d}`)
            .join(', ')}`,
    );
    process.exit(0);
}

// compileFlags

compileFlags.push('-D', `INES_MAPPER=${mapper}`);

console.log(`using ${mappers[mapper]}`);

if (args.includes('-a')) {
    compileFlags.push('-D', 'AUTO_WIN=1');
    console.log('using fast aeppoz');
}

if (args.includes('-k')) {
    compileFlags.push('-D', 'KEYBOARD=1');
    console.log('using Famicom Keyboard support');
}

if (args.includes('-s')) {
    compileFlags.push('-D', 'SAVE_HIGHSCORES=0');
    console.log('highscore saving disabled');
}

console.log();

// build / compress nametables

console.time('nametables');
require('./src/nametables/build');
console.timeEnd('nametables');

// PNG -> CHR

console.time('CHR');

const png2chr = require('./tools/png2chr/convert');

const dir = path.join(__dirname, 'src', 'chr');

fs.readdirSync(dir)
    .filter((name) => name.endsWith('.png'))
    .forEach((name) => {
        const png = path.join(dir, name);
        const chr = path.join(dir, name.replace('.png', '.chr'));

        const pngStat = fs.statSync(png, { throwIfNoEntry: false });
        const chrStat = fs.statSync(chr, { throwIfNoEntry: false });

        const staleCHR = !chrStat || chrStat.mtime < pngStat.mtime;

        if (staleCHR || args.includes('-c')) {
            console.log(`${name} => ${path.basename(chr)}`);
            fs.writeFileSync(chr, png2chr(fs.readFileSync(png)));
        }
    });

console.timeEnd('CHR');

// build object files

function handleSpawn(exe, ...args) {
    const output = spawnSync(exe, args).output.flatMap(
        (d) => d?.toString() || [],
    );
    if (output.length) {
        console.log(output.join('\n'));
        process.exit(0);
    }
}

const ca65bin = nativeCC65 ? ['ca65'] : ['node', './tools/assemble/ca65.js'];

console.time('assemble');

handleSpawn(
    ...ca65bin,
    ...compileFlags,
    ...'-g src/header.asm -o header.o'.split(' '),
);

handleSpawn(
    ...ca65bin,
    ...compileFlags,
    ...'-l tetris.lst -g src/main.asm -o main.o'.split(' '),
);

console.timeEnd('assemble');

// link object files

const ld65bin = nativeCC65 ? ['ld65'] : ['node', './tools/assemble/ld65.js'];

console.time('link');

handleSpawn(
    ...ld65bin,
    ...'-m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o'.split(
        ' ',
    ),
);

console.timeEnd('link');

// create patch

if (!fs.existsSync('clean.nes')) {
    console.log('clean.nes not found, skipping patch creation');
} else {
    console.time('patch');
    const patcher = require('./tools/patch/create');
    patcher('clean.nes', 'tetris.nes', 'tetris.bps');
    console.timeEnd('patch');
}

// stats

console.log();

if (fs.existsSync('tetris.map')) {
    const memMap = fs.readFileSync('tetris.map', 'utf8');

    console.log((memMap.match(/PRG_chunk\d+\s+0.+$/gm) || []).join('\n'));
}

function hashFile(filename) {
    if (fs.existsSync(filename)) {
        const shasum = crypto.createHash('sha1');
        shasum.update(fs.readFileSync(filename));
        console.log(`\n${filename} => ${shasum.digest('hex')}`);
        console.log(`${fs.statSync(filename).size} bytes`);
    }
}

hashFile('tetris.nes');
hashFile('tetris.bps');

console.log();

console.timeEnd('build');
