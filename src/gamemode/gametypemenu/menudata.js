const seedToggle = ["TYPE_BOOL", "Seed Enabled"];
const seedInput = ["TYPE_HEX", "seed", 6];
const linecapWhen = ["TYPE_CHOICES", "linecap when", ["off", "lines", "level"]];
const linecapHow = [
    "TYPE_CHOICES",
    "linecap how",
    ["ks*2", "floor", "inviz", "halt"],
];
const linecapLevel = ["TYPE_NUMBER", "linecap level", 0];
const linecapLines = ["TYPE_HEX", "linecap lines", 4];
const dasOnly = ["TYPE_BOOL", "das only"];

const scoringModifier = [
    "TYPE_CHOICES",
    "scoring",
    ["classic", "letters", "7digit", "m", "capped", "hidden"],
];
const paceModifier = ["TYPE_FF_OFF", "Pace", 16];
const hzFlag = ["TYPE_BOOL", "HZ DISPLAY"];
const inputDisplayFlag = ["TYPE_BOOL", "Input Display"];
const disableFlash = ["TYPE_BOOL", "Disable Flash"];
const darkMode = [
    "TYPE_CHOICES",
    "dark mode",
    ["off", "on", "neon", "lite", "teal", "og"],
];
const paletteSelection = ["TYPE_CHOICES", "palette", ["vanilla", "pride"]];

const crashModifier = [
    "TYPE_CHOICES",
    "crash",
    ["off", "show", "top", "crash"],
];
const strictCrashFlag = ["TYPE_BOOL", "strict crash"];
const disablePause = ["TYPE_BOOL", "disable pause"];
const goofyFlag = ["TYPE_BOOL", "goofy foot"];
const debugFlag = ["TYPE_BOOL", "block tool"];
const palFlag = ["TYPE_BOOL", "pal mode"];
const keyboardFlag = ["TYPE_BOOL", "keyboard"];
const qualFlag = ["TYPE_BOOL", "qual"];

const floorModifier = ["TYPE_NUMBER", "floor", 16];
const crunchModifier = ["TYPE_NUMBER", "crunch", 16];
const invisibleFlag = ["TYPE_BOOL", "invisible"];
const ghostPiece = ["TYPE_BOOL", "ghost"];
const hardDrop = ["TYPE_BOOL", "hardDrop"];
const instantClear = ["TYPE_BOOL", "no line clear"];

const scrolltris = ["TYPE_BOOL", "scrolltris"];
const horizMirror = ["TYPE_BOOL", "mirror horiz"];
const vertMirror = ["TYPE_BOOL", "mirror vert"];

const presetModifier = ["TYPE_NUMBER", "setups", 8];
const typeBModifier = ["TYPE_NUMBER", "type-b height", 9];
const checkerModifier = ["TYPE_NUMBER", "checker height", 9];
const quickTapLeftModifier = ["TYPE_NUMBER", "left cols", 20];
const quickTapRightModifier = ["TYPE_NUMBER", "right cols", 20];
const transitionModifier = ["TYPE_NUMBER", "transition", 16];
const marathonModifier = ["TYPE_NUMBER", "marathon", 5];
const tapqtyModifier = ["TYPE_NUMBER", "qty height", 16];
const tapqtyLineClear = ["TYPE_BOOL", "lineclear", 16];
const garbageModifier = ["TYPE_NUMBER", "garbage", 5];
const droughtModifier = ["TYPE_NUMBER", "drought", 20];
const lowStackRowModifier = ["TYPE_NUMBER", "lowstack", 20];

const anydasDas = ["TYPE_NUMBER", "das", 32];
const anydasArr = ["TYPE_NUMBER", "arr", 32];
const anydasEntryDelay = [
    "TYPE_CHOICES",
    "entry delay",
    ["off", "hydrant", "kitaru"],
];

const modsSubMenu = {
    "board[mode=default]": [
        floorModifier,
        crunchModifier,
        invisibleFlag,
        ghostPiece,
        hardDrop,
        instantClear,
    ],
};

const cursedSubmenu = {
    "modifiers[mode=default]": [scrolltris, horizMirror, vertMirror],
};

const anydasSubMenu = {
    "anydas[mode=default]": [anydasDas, anydasArr, anydasEntryDelay],
};

const displaySubMenu = {
    "display[mode=default]": [
        scoringModifier,
        paceModifier,
        hzFlag,
        inputDisplayFlag,
        disableFlash,
        darkMode,
        paletteSelection,
    ],
};

const settingsSubMenu = {
    "settings[mode=default]": [
        crashModifier,
        strictCrashFlag,
        disablePause,
        goofyFlag,
        debugFlag,
        palFlag,
        qualFlag,
        keyboardFlag,
    ],
};

const tournamentSubMenu = {
    "tournament[mode=default]": [
        seedToggle,
        seedInput,
        linecapHow,
        linecapWhen,
        linecapLevel,
        linecapLines,
        dasOnly,
    ],
};

const goToTournament = ["TYPE_SUBMENU", "tournament", tournamentSubMenu];
const goToMods = ["TYPE_SUBMENU", "board", modsSubMenu];
const goToCursed = ["TYPE_SUBMENU", "cursed", cursedSubmenu];
const goToSettings = ["TYPE_SUBMENU", "settings", settingsSubMenu];
const goToDisplay = ["TYPE_SUBMENU", "display", displaySubMenu];
const goToAnydas = ["TYPE_SUBMENU", "anydas", anydasSubMenu];

const optionsSubmenu = {
    "options[mode=tetris]": [
        goToTournament,
        goToMods,
        goToCursed,
        goToSettings,
        goToDisplay,
        goToAnydas,
    ],
};

const goToOptions = ["TYPE_SUBMENU", "options", optionsSubmenu];

const mainMenu = {
    "play tetris[mode=tetris]": [goToOptions],
    "t-spins[mode=tspins]": [goToOptions],
    "setups[mode=presets]": [presetModifier, goToOptions],
    "b-type[mode=typeb]": [typeBModifier, goToOptions],
    "(quick)tap[mode=tap]": [
        quickTapLeftModifier,
        quickTapRightModifier,
        goToOptions,
    ],
    "tap quantity[mode=tapqty]": [tapqtyModifier, tapqtyLineClear, goToOptions],
    "transition[mode=transition]": [transitionModifier, goToOptions],
    "marathon[mode=marathon]": [marathonModifier, goToOptions],
    "drought[mode=drought]": [droughtModifier, goToOptions],
    "checkerboard[mode=checkerboard]": [checkerModifier, goToOptions],
    "garbage[mode=garbage]": [garbageModifier, goToOptions],
    "lowstack[mode=garbage]": [lowStackRowModifier, goToOptions],
    "tap/roll speed[mode=speed_test]": [lowStackRowModifier, goToOptions],
};

const extraSpriteStrings = ["pause", "block", "clear?", "sure?!", "confetti"];

module.exports = { mainMenu, extraSpriteStrings };
