const seedFlag = ["TYPE_BOOL", "Seed Enabled", "seedEnabled"];
const seedInput = ["TYPE_HEX", "seed", 6, "set_seed_input"];
const linecapWhen = [
    "TYPE_CHOICES",
    "linecap",
    ["off", "level", "lines"],
    "linecapWhen",
];
const linecapHow = [
    "TYPE_CHOICES",
    "linecap how",
    ["ks*2", "floor", "inviz", "halt"],
    "linecapHow",
];
const linecapLevel = ["TYPE_NUMBER", "linecap level", 0, "linecapLevel"];
const linecapLines = ["TYPE_BCD", "linecap lines", 4, "linecapLines"];
const dasOnly = ["TYPE_BOOL", "das only", "dasOnlyFlag"];

const scoringModifier = [
    "TYPE_CHOICES",
    "scoring",
    ["classic", "letters", "7digit", "m", "capped", "hidden"],
    "scoringModifier",
];
const paceModifier = ["TYPE_FF_OFF", "Pace", 16, "paceModifier"];
const hzFlag = ["TYPE_BOOL", "HZ DISPLAY", "hzFlag"];
const inputDisplayFlag = ["TYPE_BOOL", "Input Display", "inputDisplayFlag"];
const disableFlash = ["TYPE_BOOL", "Disable Flash", "disableFlashFlag"];
const darkMode = [
    "TYPE_CHOICES",
    "dark mode",
    ["off", "on", "neon", "lite", "teal", "og"],
    "darkModifier",
];
const paletteSelection = [
    "TYPE_CHOICES",
    "palette",
    ["vanilla", "pride", "white"],
    "paletteFlag",
];

const crashModifier = [
    "TYPE_CHOICES",
    "crash",
    ["off", "show", "top", "crash"],
    "crashModifier",
];
const strictCrashFlag = ["TYPE_BOOL", "strict crash", "strictFlag"];
const disablePause = ["TYPE_BOOL", "disable pause", "disablePauseFlag"];
const goofyFlag = ["TYPE_BOOL", "goofy foot", "goofyFlag"];
const debugFlag = ["TYPE_BOOL", "block tool", "debugFlag"];
const palFlag = ["TYPE_BOOL", "pal mode", "palFlag"];
const keyboardFlag = ["TYPE_BOOL", "keyboard"];
const qualFlag = ["TYPE_BOOL", "qual", "qualFlag"];

const floorModifier = ["TYPE_FF_OFF", "floor", 16, "floorModifier"];
const crunchLeftModifier = ["TYPE_NUMBER", "crunch left", 4, "crunchLeftModifier"];
const crunchRightModifier = ["TYPE_NUMBER", "crunch right", 4, "crunchRightModifier"];
const invisibleFlag = ["TYPE_BOOL", "invisible", "invisibleOptionFlag"];
const ghostPiece = ["TYPE_BOOL", "ghost", "ghostPieceFlag"];
const hardDrop = ["TYPE_BOOL", "hardDrop", "hardDropFlag"];

const horizMirror = ["TYPE_BOOL", "mirror horiz", "mirrorHorizFlag"];
const vertMirror = ["TYPE_BOOL", "mirror vert", "mirrorVertFlag"];

const presetModifier = ["TYPE_NUMBER", "preset", 8, "presetModifier"];
const typeBModifier = ["TYPE_NUMBER", "height", 9, "typeBModifier"];
const checkerModifier = ["TYPE_NUMBER", "height", 9, "checkerModifier"];
const quickTapLeftModifier = [
    "TYPE_NUMBER",
    "left",
    20,
    "tapLeftModifier",
];
const quickTapRightModifier = [
    "TYPE_NUMBER",
    "right",
    20,
    "tapRightModifier",
];
const transitionModifier = [
    "TYPE_NUMBER",
    "modifier",
    17,
    "transitionModifier",
];
const marathonModifier = ["TYPE_NUMBER", "modifier", 5, "marathonModifier"];
const tapqtyModifier = ["TYPE_NUMBER", "height", 16, "tapqtyModifier"];
const garbageModifier = ["TYPE_NUMBER", "modifier", 5, "garbageModifier"];
const droughtModifier = ["TYPE_NUMBER", "modifier", 20, "droughtModifier"];
const lowStackRowModifier = [
    "TYPE_NUMBER",
    "height",
    20,
    "lowStackRowModifier",
];

const noWallChargeFlag = [
    "TYPE_CHOICES",
    "wall charge",
    ["on", "off"],
    "noWallChargeFlag",
];
const disableDasFlag = ["TYPE_CHOICES", "das", ["on", "off"], "disableDasFlag"];
const anydasDas = ["TYPE_NUMBER", "delay", 32, "dasModifier"];
const anydasArr = ["TYPE_NUMBER", "arrrr", 32, "arrModifier"];
const anydasEntryDelay = [
    "TYPE_CHOICES",
    "entry charge",
    ["off", "hydrant", "kitaru"],
    "entryChargeModifier",
];
const trtFlag = ["TYPE_BOOL", "tetris rate", "trtFlag"];
const dasMeterFlag = ["TYPE_BOOL", "das meter", "dasMeterFlag"];

const modsSubMenu = {
    "mods[mode=default]": [
        floorModifier,
        crunchLeftModifier,
        crunchRightModifier,
        invisibleFlag,
        ghostPiece,
        hardDrop,
        horizMirror,
        vertMirror,
    ],
};

const dasSubMenu = {
    "das[mode=default]": [
        anydasDas,
        anydasArr,
        anydasEntryDelay,
        disableDasFlag,
        noWallChargeFlag,
    ],
};

const infoSubMenu = {
    "info[mode=default]": [
        hzFlag,
        inputDisplayFlag,
        paceModifier,
        trtFlag,
        dasMeterFlag,
    ],
};

const displaySubMenu = {
    "display[mode=default]": [
        scoringModifier,
        disableFlash,
        darkMode,
        paletteSelection,
    ],
};

const moreSubMenu = {
    "more options[mode=default]": [
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
        seedInput,
        seedFlag,
        linecapWhen,
        linecapHow,
        linecapLevel,
        linecapLines,
        dasOnly,
    ],
};

const goToTournament = ["TYPE_SUBMENU", "tournament", tournamentSubMenu];
const goToMods = ["TYPE_SUBMENU", "mods", modsSubMenu];
const goToDisplay = ["TYPE_SUBMENU", "display", displaySubMenu];
const goToDas = ["TYPE_SUBMENU", "das", dasSubMenu];
const goToInfo = ["TYPE_SUBMENU", "info", infoSubMenu];
const goToMore = ["TYPE_SUBMENU", "more", moreSubMenu];

const shared = [goToMods, goToInfo, goToDisplay, goToDas, goToMore];

const mainMenu = {
    "play tetris[mode=tetris]": [goToTournament, ...shared],
    "t-spins[mode=tspins]": [...shared],
    "setups[mode=presets]": [presetModifier, ...shared],
    "stacking[mode=stacking]": [goToTournament, ...shared],
    "b-type[mode=typeb]": [typeBModifier, ...shared],
    "(quick)tap[mode=tap]": [
        quickTapLeftModifier,
        quickTapRightModifier,
        ...shared,
    ],
    "tap quantity[mode=tapqty]": [tapqtyModifier, ...shared],
    "transition[mode=transition]": [
        transitionModifier,
        goToTournament,
        ...shared,
    ],
    "marathon[mode=marathon]": [marathonModifier, goToTournament, ...shared],
    "drought[mode=drought]": [droughtModifier, goToTournament, ...shared],
    "checkerboard[mode=checkerboard]": [
        checkerModifier,
        goToTournament,
        ...shared,
    ],
    "garbage[mode=garbage]": [garbageModifier, goToTournament, ...shared],
    "lowstack[mode=lowstack]": [lowStackRowModifier, goToTournament, ...shared],
    "tap/roll speed[mode=speed_test]": [...shared],
    "kill*2[mode=killX2]": [...shared],
};

const extraSpriteStrings = ["pause", "block", "clear?", "sure?!", "confetti"];

module.exports = { mainMenu, extraSpriteStrings };
