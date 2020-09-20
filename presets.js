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
        `XXX    XXX`,
        `XX      XX`,
        `X        X`,
        `          `,
        `X        X`,
        `XX      XX`,
        `XXX    XXX`,
        `XX      XX`,
        `X        X`,
    ],
];
const tab = '        ';
let out = 'presets:\n';
presets.forEach((_, i) => {
    out += `${tab} .byte preset${i}-presets-1\n`;
});

presets.forEach((preset, i) => {
    preset.length < 20 &&
        preset.splice(0, 0, ...Array.from({ length: 20 - preset.length }, () => ''));
    preset = preset.map(d => d.padEnd(10, ' '));
    const bytes = [...preset.join('')]
        .map((ch, i) => ch === 'X' ? i : ' ')
        .filter(d => d !== ' ');
    out += `preset${i}:\n`;
    out += `${tab} .byte ${bytes.map(b => '$' + b.toString(16)).join(', ')}, $FF\n`;

});

console.log(out);
require('fs').writeFileSync('./presets.asm', out, 'utf8');
