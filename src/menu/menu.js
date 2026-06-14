const fs = require('fs');
const path = require('path');

const type = {
    // jmp: { size: 0 },
    nav: { size: 0 },
    byte: { size: 1 },
    bool: { size: 1 },
    seed: { size: 3 },
    ord: { size: 1 },
};

const typeIdents = Object.entries(type).map(([key, value]) => {
    value.ident = `MENU_TYPE_${key.toUpperCase()}`;
    value.key = key;
    return value.ident;
});

// menu definitions

const mainMenu = () => [
    [type.nav, 'SEED MENU', seedMenu],
    [type.byte, 'FOO', 0xa14, 'fooModifier'], // TODO helper
    [type.bool, 'BAR', 0, 'barModifier'],
    [type.ord, 'ORDINAL', ['FOO', 'BAR', 'BAZ'], 'ordModifier'],
];

const seedMenu = () => [
    [type.seed, 'SEED', 0, 'seedModifier'],
    [type.bool, 'BAR', 0, 'bar2Modifier'],
    [type.nav, 'BACK', mainMenu],
];

const menus = Object.entries({ mainMenu, seedMenu });

// generation

const typeASM = `.enum
${typeIdents.join('\n')}
.endenum`;

// generate menu list

const listASM = `menuList:
${menus.map(([key]) => `    .addr ${key}`).join('\n')}`;

const lengthsASM = `menuLengths:
${menus.map(([key]) => `    MENU_LENGTH (${key}, ${key}End)`).join('\n')}`;

// generate menu data

const getStringIdent = s => (
    s.toLowerCase().replace(/\s+(.)/g, (_,c)=>c.toUpperCase()) + 'Text'
);

const menusASM = menus.map(([ident, menu]) => {
    const items = menu().map(([_type, text, _config]) => {
        let config = 0;

        if (_type.key === 'byte') {
            config = _config;
        } else if (_type.key === 'nav') {
            config = menus.findIndex(([, value]) => value === _config);
        } else if (_type.key === 'ord') {
            config = _config.length;
        } else if (['bool', 'seed'].includes(_type.key)) {
            // noop
        } else {
            console.error(`Unhandled type ${_type.key}`);
        }

        return `    MENU_ITEM ${_type.ident} ${getStringIdent(text)}, $${config.toString(16).toUpperCase()}`;
    }).join('\n');

    return `${ident}:\n${items}\n${ident}End:`;
}).join('\n\n');

// generate strings

const strings = new Set();

menus.forEach(([,menu]) => {
    menu().forEach(([_type, text, config]) => {
        strings.add(text);

        if (_type.key === 'ord') {
            config.forEach(confItem => strings.add(confItem));
        }
    });
})

const stringsASM = [...strings].map(string => {
    return `${getStringIdent(string)}:
    .byte $${string.length.toString(16)}, ${JSON.stringify(string)}`
}).join('\n\n');

// generate RAM

const offsets = [];

menus.forEach(([, menu]) => {
    menu().forEach(([_type, _text, _config, _ident]) => {
        const { size } = _type;

        if (size > 0) {
            if (!_ident) {
                console.error(`Items with RAM must have an ident (${_text})`);
            }

            offsets.push([_ident, size]);
        }
    });
});

let cursor = 0;

const ramASM = offsets.map(([ident, size]) => {
    const addr = cursor;
    cursor += size;
    return `betaPrefix_${ident} := menuData+${addr}`;
}).join('\n');

// generate type sizes

const typeSizesASM = `menuTypeSizes:
${Object.values(type).map(t => `    .byte ${t.size} ; ${t.key.toUpperCase()}`).join('\n')}`;

// output

const output = `${typeASM}

${typeSizesASM}

${listASM}

${lengthsASM}

${menusASM}

${stringsASM}

${ramASM}
`;

const outputPath = path.join(__dirname, 'data.generated.asm');
fs.writeFileSync(outputPath, output);
