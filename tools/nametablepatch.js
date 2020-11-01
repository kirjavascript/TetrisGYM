const lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>!^()############qweadzxc############################################################################################################################################################################################### ';


const convert = (patch, pos) => {
    const lines = patch.trim().split('\n');
    return lines.map((line, i) => {
        const tiles = [...line].map(ch => lookup.indexOf(ch));
        const addr = pos + (i * 0x20);
        const ending = lines.length - 1 != i ? 0xFE : 0xFD;
        return [addr >> 8, addr & 0xFF, ...tiles, ending];
    });
};

const print = bytes => bytes.map(line => '        .byte   ' + line.map(d => '$' + d.toString(16).padStart(2,'0').toUpperCase()).join`,`).join`\n`;

console.log(print(convert(`
qwwwwwwe
aSLOT  d
a      d
zxxxxxxc
`, 0x22F7)));

const modeNames = `
TETRIS
TSPINS
STACKN
SETUPS
FLOOR
(Q)TAP
GARBGE
DRGHT
`.trim().split('\n').map(line => Array.from({ length: 6 }, (_, i) => (
    lookup.indexOf(line[i] || ' ')
)))

console.log(print(modeNames))
