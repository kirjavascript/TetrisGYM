const presets = [
    [
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `          `,
        `  X       `,
        `       X  `,
        `  X   X   `,
        `      X   `,
        `X X X  XX `,
    ],
    [
        `       XX `,
        `XXX      X`,
        `X        X`,
        `XX       X`,
    ],
    [
        `XXX    XXX`,
        `XX      XX`,
        `X        X`,
    ],
    [
        ` XX       `,
        `X        X`,
        `X         `,
        `X      X X`,
    ],
    [
        `    X X`,
        `     X`,
        `     X`,
        `  X X X X`,
        `  X X X X`,
    ],
    [
        `    XXX`,
        `    X`,
        `    XXX`,
        `      X`,
        `    XXXX`,
        `    X`,
        `    XXX`,
    ],
];
const tab = '        ';
let out = 'presets:\n';
presets.forEach((_, i) => {
    out += `${tab} .byte preset${i}-presets-1\n`;
});

let total = presets.length;

presets.forEach((preset, i) => {
    preset.length < 20 &&
        preset.splice(0, 0, ...Array.from({ length: 20 - preset.length }, () => ''));
    preset = preset.map(d => d.padEnd(10, ' '));
    const bytes = [...preset.join('')]
        .map((ch, i) => ch === 'X' ? i : ' ')
        .filter(d => d !== ' ');
    out += `preset${i}:\n`;
    out += `${tab} .byte ${bytes.map(b => '$' + b.toString(16)).join(', ')}, $FF\n`;
    total += 1 + bytes.length;
});

console.log(out);
require('fs').writeFileSync(__dirname + '/presets.asm', out, 'utf8');

console.log(`>> bytes: ${total}`)
