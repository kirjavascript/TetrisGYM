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

const header = scrollText.map((_,i) => `\t\t.byte scrollText${i}-scrollText`).join('\n');
const items = scrollText.map((text,i) => `scrollText${i}:\n\t\t.byte "${text}"`).join('\n');

const template = `

scrollText:
    ${header}
${items}
`;

console.log(template);

console.log(`bytes >> ${scrollText.length + scrollText.reduce((a, c) => a+ c.length, 0)}`)
