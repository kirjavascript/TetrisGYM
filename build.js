const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

console.log('TetrisGYM buildscript');
console.time('build');

const mappers = { // https://www.nesdev.org/wiki/Mapper
    0: 'NROM',
    1: 'MMC1',
    3: 'CNROM',
    4: 'MMC3',
    5: 'MMC5',
    1000: 'Autodetect MMC1/CNROM',
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
-o  override autodetect mmc1 header with cnrom
-t  run tests (requires cargo)
-T  run single test
-D  ca65 build arg
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

const mapper = args.find((d) => d.startsWith('-m'))?.slice(2) ?? 1000;

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

if (args.includes('-o')) {
    compileFlags.push('-D', 'CNROM_OVERRIDE=1');
    console.log('cnrom override for autodetect');
}

args.forEach((arg, i) => {
    if (arg === '-D') {
        compileFlags.push(...args.slice(i, i+2));
        }
    })

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

const { spawnSync } = require('child_process');

function execArgs(exe, args) {
    const result = spawnSync(exe, args);
    if (result.stderr.length) {
        console.error(result.stderr.toString());
    }
    if (result.stdout.length) {
        console.log(result.stdout.toString());
    }
    if (result.status !== 0){
        process.exit(1);
    }
}

function exec(cmd) {
    const [exe, ...args] = cmd.split(' ');
    execArgs(exe, args)
}

const ca65bin = nativeCC65 ? 'ca65' : 'node ./tools/assemble/ca65.js';
const flags = compileFlags.join(' ');

console.time('assemble');

exec(`${ca65bin} ${flags} -g src/header.asm -o header.o`);
exec(`${ca65bin} ${flags} -l tetris.lst -g src/main.asm -o main.o`);

console.timeEnd('assemble');

// link object files

const ld65bin = nativeCC65 ? 'ld65' : 'node ./tools/assemble/ld65.js';

console.time('link');

exec(`${ld65bin} -m tetris.map -Ln tetris.lbl --dbgfile tetris.dbg -o tetris.nes -C src/tetris.nes.cfg main.o header.o`);

console.timeEnd('link');

// create patch

if (!fs.existsSync('clean.nes')) {
    console.log('clean.nes not found, skipping patch creation');
} else {
    console.time('patch');
    const patcher = require('./tools/patch/create');
    const pct = patcher('clean.nes', 'tetris.nes', 'tetris.bps');
    console.timeEnd('patch');
    console.log(`\nusing ${pct}% of original file`);
}

// stats

console.log();

if (fs.existsSync('tetris.map')) {
    const memMap = fs.readFileSync('tetris.map', 'utf8');

    false && console.log((memMap.match(/PRG_chunk\d+\s+0.+$/gm) || []).join('\n'));

    const used = parseInt(memMap.match(/PRG_chunk1\s+\w+\s+\w+\s+(\w+)/)?.[1]??'', 16) + 0x100; // 0x100 for reset chunk

    console.log(`${0x8000 - used} PRG bytes free`);
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

// tests

if (args.includes('-t')) {
    console.log('\nrunning tests');
    exec('cargo run --release --manifest-path tests/Cargo.toml -- -t');
}

if (args.includes('-T')) {
    const singleTest = args.slice(1+args.indexOf('-T')).join(' ');
    console.log(`\nrunning single test: ${singleTest}`);
    execArgs('cargo', [...'run --release --manifest-path tests/Cargo.toml -- -T'.split(' '), singleTest]);
}
