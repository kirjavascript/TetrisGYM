const { mainMenu, extraSpriteStrings } = require("./menudata");
const { writeFileSync } = require("fs");

MAX_LENGTH_NAME = 14;
MAX_LENGTH_VALUE = 8;
DEBUG = false;

labelMap = {
    TYPE_BCD: typeDigit,
    TYPE_HEX: typeDigit,
    TYPE_NUMBER: typeNumber,
    TYPE_FF_OFF: typeNumber,
    TYPE_CHOICES: typeChoices,
    TYPE_MODE_ONLY: getOutputLines,
    TYPE_SUBMENU: typeSubMenu,
    TYPE_BOOL: typeBool,
};

addedStrings = [];
buffer = [];
choiceSetCounts = [];
choiceSetEnums = [];
choiceSetIndexes = [];
choiceSets = [];
index = 0;
items = [];
lookupConstants = [];
memoryBuffer = [];
memoryMap = [];
memoryReservations = {};
menuCount = 0;
menuEnums = [];
newStringLines = [];
pageCountByMenu = [];
pageIndex = 0;
pageLabelText = {};
pagesOutput = [];
startItemByPage = [];
startPageByMenu = [];
unlabeledStringSets = {};

function checkStringSanity(string) {
    if (string.length > MAX_LENGTH_VALUE) {
        throw new Error(`${string} is more than MAX_LENGTH_VALUE chars`);
    }
    if ((match = string.match(/[^- a-z0-9_?!*]/i))) {
        throw new Error(`${string} has invalid char '${match[0]}'`);
    }
}

function cleanWord(word) {
    word = word.toLowerCase().replace(/\b\w/g, (c) => c.toUpperCase());
    return word.replace(/[- *?!(),\/]/g, "");
}

function getStringName(word) {
    return `string${cleanWord(word)}`;
}

function getChoiceSetName(word) {
    return `choiceSet${cleanWord(word)}`;
}

function getStringConstant(name) {
    return `STRING_${cleanWord(name).toUpperCase()}`;
}

function getChoiceSetConstant(name) {
    return `CHOICESET_${cleanWord(name).toUpperCase()}`;
}

function getByteLine(byte) {
    return `    .byte ${byte}`;
}

function getHexByte(number) {
    if (isNaN(number)) return number;
    return `$${number.toString(16).padStart(2, "0").toUpperCase()}`;
}

function getOutputLines(itemType, string, memory) {
    return {
        string: string,
        label: getByteLine(`${itemType} ; ${string}`),
        memory: memory, // has to be processed separately to get output line
    };
}

function getStringByte(c) {
    replaceMap = {
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

function getLineString(string, multiline = false) {
    if (string.length > MAX_LENGTH_NAME) {
        throw new Error(`${string} is more than MAX_LENGTH_NAME chars`);
    }

    return multiline
        ? string
              .split("")
              .map((c) => getByteLine(getStringByte(c)))
              .join("\n")
        : getByteLine(getStringBytes(string));
}

function getPageLines(title, page, pages) {
    DEBUG && console.log(`getPageLines`, title, page, pages);
    pageType = "PAGE_DEFAULT";
    [_, label, mode] = title.match(/([^[]*)(?:\s*\[mode=(\w+)\])?/i);
    const modifier = mode ? `MODE_${mode.toUpperCase()}` : "MODE_DEFAULT";
    const pagelabelsName = `pageLabels${cleanWord(label)}`;

    const endLabel = getByteLine("EOL");
    const endLabelSet = getByteLine("EOF");

    pageLabelTextLines = [];
    pageLabelTextLines.push(`${pagelabelsName}:`);
    padding = [...Array(Math.round((MAX_LENGTH_NAME - label.length) / 2))]
        .map(() => " ")
        .join("");
    pageLabelTextLines.push(getLineString(`${padding}${label}`));
    pageLabelTextLines.push(endLabel);
    page.forEach((p, i) => {
        pageLabelTextLines.push(getLineString(p[1]));
        if (i + 1 != page.length) pageLabelTextLines.push(endLabel);
    });
    pageLabelTextLines.push(endLabelSet);
    joined = pageLabelTextLines.join("\n");
    existing = pageLabelText[joined];
    if (!existing) pageLabelText[joined] = pagelabelsName;

    return {
        label: getByteLine(`${pageType} | ${modifier} ; ${label}`),
        count: getByteLine(`${getHexByte(page.length)} ; ${label}`),
        hibytes: getByteLine(
            `>${existing ? existing : pagelabelsName} ; ${label}`,
        ),
        lobytes: getByteLine(
            `<${existing ? existing : pagelabelsName} ; ${label}`,
        ),
        choicesets: existing ? "" : joined,
    };
}

function typeDigit(label, string, digits, memoryLabel) {
    if (digits < 2 || digits > 8 || digits & 1) {
        throw new Error(`${string}: digits can only be 2, 4, 6 or 8`);
    }
    memory = memoryLabel ? memoryLabel : (digits + 1) >> 1;
    return getOutputLines(`${label} | ${getHexByte(digits)}`, string, memory);
}

function typeChoices(label, string, choiceSet, memoryLabel) {
    DEBUG && console.log(`Choice set ${string} with options ${choiceSet}`);
    stringSet = [...choiceSet].map((c) => cleanWord(c.slice(0, 6))).join("");
    unlabeledStringSets[stringSet] = choiceSet;
    return getOutputLines(
        `${label} | ${getChoiceSetConstant(stringSet)}`,
        string,
        memoryLabel ? memoryLabel : 1,
    );
}

function typeNumber(label, string, limit, memoryLabel) {
    return getOutputLines(
        `${label} | ${getHexByte(limit)}`,
        string,
        memoryLabel ? memoryLabel : 1,
    );
}

function typeBool(label, string, memoryLabel) {
    return typeChoices(
        "TYPE_CHOICES",
        string,
        ["off", "on"],
        memoryLabel ? memoryLabel : 1,
    );
}
function typeSubMenu(label, string) {
    return getOutputLines(
        `${label} | SUBMENU_${cleanWord(string).toUpperCase()}`,
        `${string}`,
    );
}

function getMemoryLabel(string, bytes) {
    if (isNaN(bytes)) return bytes; // if label is specified use that instead
    label = `menuVar${cleanWord(string)}`;
    memoryReservations[label] = bytes;
    return label;
}

processPageSet = (pages, name) => {
    DEBUG && name && console.log(`submenu ${name}`);
    DEBUG && !name && console.log(`main menu`);
    if (name) menuEnums.push(`SUBMENU_${cleanWord(name).toUpperCase()}`);
    startPageByMenu.push(
        `${getByteLine(getHexByte(pageIndex))} ; ${name ? name : "main menu"}`,
    );
    // collect submenus to process after all pages
    let subPageSets = {};
    Object.entries(pages).forEach(([title, page]) => {
        DEBUG && console.log(`${title} with ${page.length} entries`);
        pageIndex++;
        startItemByPage.push(
            getByteLine(`${getHexByte(index)} ; ${cleanWord(title)}`),
        );
        pagesOutput.push(getPageLines(title, page, pages, index));
        page.forEach((item) => {
            items.push(labelMap[item[0]](...item));
            index++;
            if (item[0] === "TYPE_SUBMENU") subPageSets[item[1]] = item[2];
        });
    });
    pageCountByMenu.push(
        getByteLine(
            `${getHexByte(Object.values(pages).length)} ; ${name ? name : "main menu"}`,
        ),
    );

    // process any submenus the same was as the main menu
    Object.entries(subPageSets).forEach(([name, pages]) => {
        processPageSet(pages, name);
    });
};
processPageSet(mainMenu);

items.forEach((i) => {
    line = getByteLine(
        `${i.memory ? "<" + getMemoryLabel(i.string, i.memory) : "NORAM"} ; ${i.string}`,
    );
    memoryMap.push(line);
});

memoryBuffer.push("; generated by menu.js");
memoryBuffer.push("autoMenuVars:");
Object.entries(memoryReservations).forEach(([label, bytes]) =>
    memoryBuffer.push(`${label}: .res ${getHexByte(bytes)}`),
);
memoryBuffer.push("");
// memory into separate file
writeFileSync(__dirname + "/menuram.asm", [...memoryBuffer, ""].join("\n"));

[
    ["extraSpriteStrings", extraSpriteStrings],
    ...Object.entries(unlabeledStringSets),
].forEach(([name, choiceSet], i) => {
    if (!i) newStringLines.push("stringTable:");
    if (i == 1) {
        newStringLines.push(
            '\n.out .sprintf("%d/256 sprite string bytes", * - stringTable)\n',
        );
        newStringLines.push("choiceSetTable:");
    }

    DEBUG && console.log(`stringlist`, name, choiceSet);
    if (name != "extraSpriteStrings") {
        choiceSetEnums.push(getChoiceSetConstant(name));
        choiceSetCounts.push(getByteLine(getHexByte(choiceSet.length)));
        choiceSetIndexes.push(
            getByteLine(`${getChoiceSetName(name)}-choiceSets`),
        );
        choiceSets.push(`${getChoiceSetName(name)}:`);
    }
    DEBUG && console.log(`choiceSet: `, choiceSet);
    choiceSet.forEach((choice) => {
        choice = choice.toLowerCase();
        checkStringSanity(choice);
        if (!addedStrings.includes(choice)) {
            addedStrings.push(choice);
            newStringLines.push(`${getStringName(choice)}:`);
            newStringLines.push(
                getByteLine(
                    `${getHexByte(choice.length)},${getStringBytes(choice)}`,
                ),
            );
        }
        if (name == "extraSpriteStrings") {
            lookupConstants.push(
                `${getStringConstant(choice)} = ${getStringName(choice)}-stringTable`,
            );
        } else {
            choiceSets.push(
                // getByteLine(`${getStringName(choice)}-${getChoiceSetName(name)}`),
                getByteLine(`${getStringName(choice)}-choiceSetTable`),
            );
        }
    });
});
newStringLines.push(
    '\n.out .sprintf("%d/256 choice set bytes", * - choiceSetTable)\n',
);

buffer.push("; generated by menu.js");
buffer.push("; will be overwritten unless built with -M");
buffer.push("");

buffer.push(...lookupConstants);
buffer.push("");

buffer.push(".enum");
buffer.push("MAIN_MENU");
buffer.push(...menuEnums);
buffer.push("MENU_COUNT");
buffer.push(".endenum");
buffer.push('\n.out .sprintf("%d/32 menus", MENU_COUNT)\n');
buffer.push("");

buffer.push(".enum");
buffer.push(...choiceSetEnums);
buffer.push("CHOICESET_COUNT");
buffer.push(".endenum");
buffer.push('\n.out .sprintf("%d/32 choicesets", CHOICESET_COUNT)\n');
buffer.push("");

buffer.push("; index activeMenu");
buffer.push("startPageByMenu:");
buffer.push(...startPageByMenu);
buffer.push("");

buffer.push("pageCountByMenu:");
buffer.push(...pageCountByMenu);
buffer.push("");

buffer.push("; index activePage");
buffer.push("pageTypes:");
buffer.push(...pagesOutput.map((p) => p.label));
buffer.push("");

buffer.push("itemCountByPage:");
buffer.push(...pagesOutput.map((p) => p.count));
buffer.push("");

buffer.push("pageLabelsHi:");
buffer.push(...pagesOutput.map((p) => p.hibytes));
buffer.push("");

buffer.push("pageLabelsLo:");
buffer.push(...pagesOutput.map((p) => p.lobytes));
buffer.push("");

buffer.push("startItemByPage:");
buffer.push(...startItemByPage);
buffer.push("");

buffer.push("; index activeItem");
buffer.push("memoryOffsets:");
buffer.push(...memoryMap);
buffer.push("");

buffer.push("itemTypes:");
buffer.push(...items.map((i) => i.label));
buffer.push("");

buffer.push("choiceSetIndexes:");
buffer.push(...choiceSetIndexes);
buffer.push("");

buffer.push("choiceSetCounts:");
buffer.push(...choiceSetCounts);
buffer.push("");

buffer.push("choiceSets:");
buffer.push(...choiceSets);
buffer.push("");

buffer.push(...newStringLines);
buffer.push("");

buffer.push(...pagesOutput.map((p) => p.choicesets));
buffer.push("");

writeFileSync(__dirname + "/menudata.asm", [...buffer, ""].join("\n"));
