const seedFlag = ["TYPE_BOOL", "Seed Enabled", "seedEnabled"];
const seedInput = ["TYPE_HEX", "seed", 6, "set_seed_input"];
const linecapWhen = ["TYPE_CHOICES", "linecap", ["off", "level", "lines"], "linecapWhen"];
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
const hzFlag = ["TYPE_BOOL", "HZ DISPLAY", "hzFlag",];
const inputDisplayFlag = ["TYPE_BOOL", "Input Display", "inputDisplayFlag",];
const disableFlash = ["TYPE_BOOL", "Disable Flash", "disableFlashFlag"];
const darkMode = [
    "TYPE_CHOICES",
    "dark mode",
    ["off", "on", "neon", "lite", "teal", "og"],
    "darkModifier",
];
const paletteSelection = ["TYPE_CHOICES", "palette", ["vanilla", "pride", "white",], "paletteFlag"];

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
const crunchModifier = ["TYPE_NUMBER", "crunch", 16, "crunchModifier"];
const invisibleFlag = ["TYPE_BOOL", "invisible", "invisibleOptionFlag"];
const ghostPiece = ["TYPE_BOOL", "ghost", "ghostPieceFlag"];
const hardDrop = ["TYPE_BOOL", "hardDrop", "hardDropFlag"];
const killX2 = ["TYPE_BOOL", "killX2", "killX2Flag"];

const scrolltris = ["TYPE_BOOL", "scrolltris"];
const horizMirror = ["TYPE_BOOL", "mirror horiz"];
const vertMirror = ["TYPE_BOOL", "mirror vert"];

const presetModifier = ["TYPE_NUMBER", "setups", 8, "presetModifier"];
const typeBModifier = ["TYPE_NUMBER", "type-b height", 9, "typeBModifier"];
const checkerModifier = ["TYPE_NUMBER", "checker height", 9, "checkerModifier"];
const quickTapLeftModifier = ["TYPE_NUMBER", "left cols", 20];
const quickTapRightModifier = ["TYPE_NUMBER", "right cols", 20];
const transitionModifier = ["TYPE_NUMBER", "transition", 16, "transitionModifier"];
const marathonModifier = ["TYPE_NUMBER", "marathon", 5, "marathonModifier"];
const tapqtyModifier = ["TYPE_NUMBER", "qty height", 16, "tapqtyModifier"];
const garbageModifier = ["TYPE_NUMBER", "garbage", 5, "garbageModifier"];
const droughtModifier = ["TYPE_NUMBER", "drought", 20, "droughtModifier"];
const lowStackRowModifier = ["TYPE_NUMBER", "lowstack", 20, "lowStackRowModifier"];

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
        killX2,
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
const goToMods = ["TYPE_SUBMENU", "board", modsSubMenu];
const goToCursed = ["TYPE_SUBMENU", "cursed", cursedSubmenu];
const goToMore = ["TYPE_SUBMENU", "more", moreSubMenu];
const goToDisplay = ["TYPE_SUBMENU", "display", displaySubMenu];
const goToAnydas = ["TYPE_SUBMENU", "anydas", anydasSubMenu];

const optionsSubmenu = {
    "options[mode=default]": [
        goToMods,
        goToCursed,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
};

const goToOptions = ["TYPE_SUBMENU", "options", optionsSubmenu];

const mainMenu = {
    "play tetris[mode=tetris]": [goToOptions, goToTournament],
    "t-spins[mode=tspins]": [goToOptions],
    "setups[mode=presets]": [presetModifier, goToOptions],
    "stacking[mode=stacking]": [goToOptions, goToTournament],
    "b-type[mode=typeb]": [typeBModifier, goToOptions],
    "(quick)tap[mode=tap]": [
        quickTapLeftModifier,
        quickTapRightModifier,
        goToOptions,
    ],
    "tap quantity[mode=tapqty]": [tapqtyModifier, goToOptions],
    "transition[mode=transition]": [transitionModifier, goToOptions, goToTournament],
    "marathon[mode=marathon]": [marathonModifier, goToOptions, goToTournament],
    "drought[mode=drought]": [droughtModifier, goToOptions, goToTournament],
    "checkerboard[mode=checkerboard]": [checkerModifier, goToOptions, goToTournament],
    "garbage[mode=garbage]": [garbageModifier, goToOptions, goToTournament],
    "lowstack[mode=lowstack]": [lowStackRowModifier, goToOptions, goToTournament],
    "tap/roll speed[mode=speed_test]": [goToOptions],
};

const extraSpriteStrings = ["pause", "block", "clear?", "sure?!", "confetti"];

module.exports = { mainMenu, extraSpriteStrings };
