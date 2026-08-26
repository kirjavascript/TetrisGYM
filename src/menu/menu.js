const { mainMenu, extraSpriteStrings } = require("./menudata");
const { writeFileSync } = require("fs");

const MAX_LENGTH_NAME = 14;
const MAX_LENGTH_VALUE = 8;

const labelMap = {
    TYPE_BCD: typeDigit,
    TYPE_HEX: typeDigit,
    TYPE_NUMBER: typeNumber,
    TYPE_FF_OFF: typeNumber,
    TYPE_CHOICES: typeChoices,
    TYPE_GAMEMODE: typeGameMode,
    TYPE_SUBMENU: typeSubMenu,
    TYPE_BOOL: typeBool,
    TYPE_CUSTOM: typeCustom,
};

const bssMap = [];
const choiceSetEnums = [];
const choiceSetIndexes = [];
const choiceSets = [];
const items = [];
const memoryMap = [];
const menuEnums = [];
const newWords = new Set();
const pageCountByMenu = [];
const pageLabels = {};
const pagesOutput = [];
const startItemByPage = [];
const startPageByMenu = [];
const unlabeledStringSets = {};

let index = 0;
let pageIndex = 0;

function checkStringSanity(string) {
    if (string.length > MAX_LENGTH_VALUE) {
        throw new Error(`${string} is more than MAX_LENGTH_VALUE chars`);
    }
    let match;
    if ((match = string.match(/[^-/ a-z0-9_?!*]/i))) {
        throw new Error(`${string} has invalid char '${match[0]}'`);
    }
}

function cleanWord(word) {
    word = word.toLowerCase().replace(/\b\w/g, (c) => c.toUpperCase());
    return word.replace(/[- *?!(),/]/g, "");
}

function getStringConstant(word) {
    return `str_${cleanWord(word)}`.toUpperCase();
}

function getChoiceSetName(word) {
    return `choiceSet${cleanWord(word)}`;
}

function getChoiceSetConstant(name) {
    return `CHOICESET_${cleanWord(name).toUpperCase()}`;
}

function getByteLine(byte) {
    return `    .byte ${byte}`;
}

function getWordLine(word) {
    return `    .word ${word}`;
}

function getHexByte(number) {
    if (isNaN(number)) return number;
    return `$${number.toString(16).padStart(2, "0").toUpperCase()}`;
}

function getHexWord(number) {
    if (isNaN(number)) return number;
    return `$${number.toString(16).padStart(4, "0").toUpperCase()}`;
}

function getOutputLines(itemType, string, memory, length) {
    return {
        string: string,
        label: getByteLine(`${itemType} ; ${string}`),
        memory: memory, // has to be processed separately to get output line
        length: length,
    };
}

function getStringByte(c) {
    const replaceMap = {
        ",": "$25",
        "/": "$4F",
        "(": "$5E",
        ")": "$5F",
        "*": "$69", // KSx2 x
        " ": "$EF",
    };
    return replaceMap[c] ? replaceMap[c] : `"${c.toUpperCase()}"`;
}

function getStringBytes(string) {
    return [...string.split("").map((c) => getStringByte(c))].join(",");
}

function getPageLines(title, page) {
    let label;
    let mode;
    [, label, mode] = title.match(/([^[]*)(?:\s*\[mode=(\w+)\])?/i);
    const padding = getHexByte(
        (Math.round((MAX_LENGTH_NAME - label.length) / 2) << 5) & 0xff,
    );
    const modifier = mode ? `MODE_${mode.toUpperCase()}` : "MODE_DEFAULT";
    const pagelabelsName = `pageLabels${cleanWord(label)}`;
    newWords.add(label.toUpperCase());

    if (!pageLabels[`${pagelabelsName}`]) {
        pageLabels[`${pagelabelsName}`] = [
            getWordLine(getStringConstant(label)),
            ...page.map((p) => getWordLine(getStringConstant(p[1]))),
        ];
    }
    page.forEach((p) => {
        newWords.add(p[1].toUpperCase());
    });
    return {
        label: getByteLine(`${padding} | ${modifier} ; ${label}`),
        index: getWordLine(
            `${getHexWord(page.length << 11)} | (${pagelabelsName} - pageLabels)`,
        ),
        newsets: `${pagelabelsName}:`,
    };
}

function typeDigit(label, string, digits, memoryLabel, defaultValue) {
    if (digits < 2 || digits > 8 || digits & 1) {
        throw new Error(`${string}: digits can only be 2, 4, 6 or 8`);
    }
    return getOutputLines(
        `${label} | ${getHexByte(digits)}`,
        string,
        memoryLabel,
        (digits + 1) >> 1,
    );
}

function typeChoices(label, string, choiceSet, memoryLabel) {
    const stringSet = [...choiceSet]
        .map((c) => cleanWord(c.slice(0, 6)))
        .join("");
    unlabeledStringSets[stringSet] = choiceSet;
    return getOutputLines(
        `${label} | ${getChoiceSetConstant(stringSet)}`,
        string,
        memoryLabel,
        1,
    );
}

function typeNumber(label, string, limit, memoryLabel, defaultValue) {
    return getOutputLines(
        `${label} | ${getHexByte(limit)}`,
        string,
        memoryLabel,
        1,
    );
}

function typeBool(_, string, memoryLabel) {
    return typeChoices("TYPE_CHOICES", string, ["off", "on"], memoryLabel, 1);
}
function typeSubMenu(label, string) {
    return getOutputLines(
        `${label} | SUBMENU_${cleanWord(string).toUpperCase()}`,
        `${string}`,
    );
}

function typeGameMode(label, string, mode) {
    return {
        string: string,
        label: getByteLine(`${label} | ${mode} ; ${string}`),
        memory: 0,
    };
}
function typeCustom(label, string, subroutine, memoryLabel) {
    return getOutputLines(
        `${label} | ${subroutine}`,
        `${string}`,
        memoryLabel,
    );
}

const subMenus = [];
const processPageSet = (pages, name) => {
    if (name) {
        const enunName = `SUBMENU_${cleanWord(name).toUpperCase()}`;
        if (!menuEnums.includes(enunName)) menuEnums.push(enunName);
    }
    startPageByMenu.push(
        `${getByteLine(getHexByte(pageIndex))} ; ${name ? name : "main menu"}`,
    );
    // collect submenus to process after all pages
    let subPageSets = {};
    Object.entries(pages).forEach(([title, page]) => {
        pageIndex++;
        startItemByPage.push(
            getByteLine(`${getHexByte(index)} ; ${cleanWord(title)}`),
        );
        pagesOutput.push(getPageLines(title, page));
        page.forEach((item) => {
            const output = labelMap[item[0]](...item);

            const resLine = `${output.memory}: .res ${output.length} ; ${output.string}`;

            if (output.memory && (bssMap.indexOf(resLine) < 0))
                bssMap.push(resLine);

            items.push(output);
            index++;
            if (item[0] === "TYPE_SUBMENU") {
                // submenus are expected to be unique by name
                // skip if the submenu has been processed, it already exists
                if (subMenus.indexOf(item[1]) < 0) {
                    subMenus.push(item[1]);
                    subPageSets[item[1]] = item[2];
                }
            }
        });
    });
    pageCountByMenu.push(
        getByteLine(
            `${getHexByte(Object.values(pages).length)} ; ${name ? name : "main menu"}`,
        ),
    );

    // process any submenus the same way as the main menu
    Object.entries(subPageSets).forEach(([name, pages]) => {
        processPageSet(pages, name);
    });
};
processPageSet(mainMenu);

items.forEach((i) => {
    const line = getByteLine(
        `${i.memory ? "<" + i.memory : "NORAM"} ; ${i.string}`,
    );
    memoryMap.push(line);
});

[
    ["extraSpriteStrings", extraSpriteStrings],
    ...Object.entries(unlabeledStringSets),
].forEach(([name, choiceSet]) => {
    if (name != "extraSpriteStrings") {
        choiceSetEnums.push(getChoiceSetConstant(name));
        choiceSetIndexes.push(
            getWordLine(
                `${getHexWord((choiceSet.length - 2) << 11)} | (${getChoiceSetName(name)} - choiceSets)`,
            ),
        );
        choiceSets.push(`${getChoiceSetName(name)}:`);
    }
    choiceSet.forEach((choice) => {
        choice = choice.toLowerCase();
        checkStringSanity(choice);
        newWords.add(choice.toUpperCase());
        if (name !== "extraSpriteStrings") {
            choiceSets.push(
                // getByteLine(`${getStringName(choice)}-${getChoiceSetName(name)}`),
                getWordLine(getStringConstant(choice)),
            );
        }
    });
});

/*
 * create a blob of words
 */
let wordTable = "";
const sortedWords = [...newWords].sort((a, b) => b.length - a.length);

sortedWords.forEach((w) => {
    let index = wordTable.search(RegExp.escape(w));
    index < 0 && (wordTable = wordTable + w);
});

if (wordTable.length > 1023) {
    throw new Error(`is 1024 bytes of words not enough?`);
}

function wordConstants() {
    return sortedWords.map((w) => {
        let index = wordTable.search(RegExp.escape(w));
        return `${getStringConstant(w)} = ${getHexWord(((w.length - 1) << 12) | index)}`;
    });
}

function wordChunks() {
    return wordTable
        .match(/.{1,8}/g)
        .map((w) => getByteLine(getStringBytes(w)));
}
const menuram = `
; generated by menu.js
; will be overwritten unless built with -M


${bssMap.join("\n")}
`;
const output = `
; generated by menu.js
; will be overwritten unless built with -M

.enum
MAIN_MENU
${menuEnums.join("\n")}
MENU_COUNT
.endenum
.out .sprintf("%d/32 menus", MENU_COUNT)

.enum
${choiceSetEnums.join("\n")}
CHOICESET_COUNT
.endenum
.out .sprintf("%d/32 choicesets", CHOICESET_COUNT)


; index activeMenu

startPageByMenu:
${startPageByMenu.join("\n")}

pageCountByMenu:
${pageCountByMenu.join("\n")}

; index activePage
; PPPMMMMM
; P = padding
; M = mode
pageTypes:
${pagesOutput.map((p) => p.label).join("\n")}

; CCCCCOOO OOOOOOOO
; C = item count
; O = offset from pageIndexes

pageIndexes:
${pagesOutput.map((p) => p.index).join("\n")}

pageLabels:
${Object.entries(pageLabels)
    .map(([k, v]) => [k + ":", ...v].join("\n"))
    .join("\n")}

startItemByPage:
${startItemByPage.join("\n")}

; index activeItem

memoryOffsets:
${memoryMap.join("\n")}

; TTTVVVVV
; T = type
; V = value
itemTypes:
${items.map((i) => i.label).join("\n")}

; CCCCCOOO OOOOOOOO
; C = choicecount - 2
; O = offset from choiceSets
choiceSetIndexes:
${choiceSetIndexes.join("\n")}

choiceSets:
${choiceSets.join("\n")}

strTable:
${wordChunks().join("\n")}

; LLLLOOOO OOOOOOOO
; L = length - 1
; O = offset from strTable;

${wordConstants().join("\n")}
`;

writeFileSync(__dirname + "/menuram.asm", menuram);
writeFileSync(__dirname + "/menudata.asm", output);
