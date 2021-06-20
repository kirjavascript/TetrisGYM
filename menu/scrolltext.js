const scrollText = `
    TETRIS
    T-SPINS
    SEED
    STACKING
    PACE
    SETUPS
    FLOOR
    (QUICK)TAP
    GARBAGE
    DROUGHT
    INPUT DISPLAY
    DEBUG MODE
    PAL MODE
`.trim().split(/\s\s+/g);

console.log(scrollText);

const chars = `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.>!^()`;
const toNum = char => chars.includes(char) ? chars.indexOf(char) : 0xFF;
const toBytes = text => [...text].map(d=>'$'+toNum(d).toString(16)).join(',');

const header = scrollText.map((_,i) => `\t\t.byte scrollText${i}-scrollText`).join('\n');
const items = scrollText.map((text,i) => `scrollText${i}:\t.byte ${toBytes(text)} ; ${text}`).join('\n');


const template = `scrollText:
    ${header}
${items}
`;


require('fs').writeFileSync(__dirname + '/scrolltext.asm', template, 'utf8');


console.log(`bytes >> ${scrollText.length + scrollText.reduce((a, c) => a+ c.length, 0)}`)
