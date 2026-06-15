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
    [type.nav, 'TEST', seedMenu],
    [type.nav, 'TEST', seedMenu],
    [type.nav, 'TEST', seedMenu],
    [type.nav, 'TEST', seedMenu],
    [type.nav, 'TEST', seedMenu],
    [type.nav, 'TEST', seedMenu],
    [type.nav, 'TEST', seedMenu],
    [type.byte, 'FOO', 0xa14, 'fooModifier'], // TODO helper
    [type.bool, 'BAR', 0, 'barModifier'],
    [type.ord, 'ORDINAL', ['FOO', 'BAR', 'BAZABC'], 'ordModifier'],
    [type.ord, 'ORDINAL', ['FOO', 'BARB', 'BARBY'], 'ord2Modifier'],
];

const seedMenu = () => [
    [type.nav, 'BACK', mainMenu],
    [type.seed, 'SEED', 0, 'seedModifier'],
    [type.bool, 'BAR', 0, 'bar2Modifier'],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
    [type.nav, 'BACK', mainMenu],
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
${menus.map(([key]) => `    MENU_LENGTH ${key}, ${key}End`).join('\n')}`;

// generate menu data

const getStringIdent = s => (
    s.toLowerCase().replace(/\s+(.)/g, (_,c)=>c.toUpperCase()) + 'Text'
);

const menusASM = menus.map(([ident, menu]) => {
    const items = menu().map(([_type, text, _config, _ident]) => {
        let config = 0;

        if (_type.key === 'byte') {
            config = _config;
        } else if (_type.key === 'nav') {
            config = menus.findIndex(([, value]) => value === _config);
        } else if (_type.key === 'ord') {
            config = `ordTable_${_ident}`;
        } else if (['bool', 'seed'].includes(_type.key)) {
            // noop
        } else {
            console.error(`unhandled type ${_type.key}`);
        }

        const configStr = typeof config === 'number' ? "$" + config.toString(16).toUpperCase() : config;
        return `    MENU_ITEM ${_type.ident}, ${getStringIdent(text)}, ${configStr}`;
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

// generate ordinal lookup tables

const ordTables = [];
menus.forEach(([, menu]) => {
    menu().forEach(([_type, _text, _config, _ident]) => {
        if (_type.key === 'ord') {
            const maxLen = Math.max(..._config.map(opt => opt.length));
            const addrs = _config.map(opt => `    .addr ${getStringIdent(opt)}`).join('\n');
            ordTables.push(`ordTable_${_ident}:\n    .byte ${_config.length}, ${maxLen}\n${addrs}`);
        }
    });
});

const ordTablesASM = ordTables.join('\n\n');

// generate RAM

const seen = new Set();
const offsets = [];

menus.forEach(([, menu]) => {
    menu().forEach(([_type, _text, _config, _ident]) => {
        const { size } = _type;

        if (size > 0) {
            if (!_ident) {
                console.error(`items with RAM must have an ident (${_text})`);
            } else if (seen.has(_ident)) {
                console.error(`duplicate RAM ident (${_ident})`);
            } else {
                seen.add(_ident);
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

// generate per-menu data offsets

let dataCursor = 0;
const menuDataOffsetsValues = menus.map(([, menu]) => {
    const offset = dataCursor;
    menu().forEach(([_type]) => { dataCursor += _type.size; });
    return offset;
});

const menuDataOffsetsASM = `menuDataOffsets:
${menuDataOffsetsValues.map(o => `    .byte ${o}`).join('\n')}`;

// output

const output = `${typeASM}

${typeSizesASM}

${listASM}

${lengthsASM}

${menuDataOffsetsASM}

${menusASM}

${stringsASM}

${ordTablesASM}

${ramASM}
`;

const outputPath = path.join(__dirname, 'data.generated.asm');
fs.writeFileSync(outputPath, output);
