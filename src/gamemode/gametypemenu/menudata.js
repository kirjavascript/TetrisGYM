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
const crunchModifier = ["TYPE_NUMBER", "crunch", 16, "crunchModifier"];
const invisibleFlag = ["TYPE_BOOL", "invisible", "invisibleOptionFlag"];
const ghostPiece = ["TYPE_BOOL", "ghost", "ghostPieceFlag"];
const hardDrop = ["TYPE_BOOL", "hardDrop", "hardDropFlag"];
const killX2 = ["TYPE_BOOL", "killX2", "killX2Flag"];

const horizMirror = ["TYPE_BOOL", "mirror horiz", "mirrorHorizFlag"];
const vertMirror = ["TYPE_BOOL", "mirror vert", "mirrorVertFlag"];

const presetModifier = ["TYPE_NUMBER", "setups", 8, "presetModifier"];
const typeBModifier = ["TYPE_NUMBER", "type-b height", 9, "typeBModifier"];
const checkerModifier = ["TYPE_NUMBER", "checker height", 9, "checkerModifier"];
const quickTapLeftModifier = [
    "TYPE_NUMBER",
    "left cols",
    20,
    "tapLeftModifier",
];
const quickTapRightModifier = [
    "TYPE_NUMBER",
    "right cols",
    20,
    "tapRightModifier",
];
const transitionModifier = [
    "TYPE_NUMBER",
    "transition",
    16,
    "transitionModifier",
];
const marathonModifier = ["TYPE_NUMBER", "marathon", 5, "marathonModifier"];
const tapqtyModifier = ["TYPE_NUMBER", "qty height", 16, "tapqtyModifier"];
const garbageModifier = ["TYPE_NUMBER", "garbage", 5, "garbageModifier"];
const droughtModifier = ["TYPE_NUMBER", "drought", 20, "droughtModifier"];
const lowStackRowModifier = [
    "TYPE_NUMBER",
    "lowstack",
    20,
    "lowStackRowModifier",
];

const anydasDas = ["TYPE_NUMBER", "das", 32, "dasModifier"];
const anydasArr = ["TYPE_NUMBER", "arr", 32, "arrModifier"];
const anydasEntryDelay = [
    "TYPE_CHOICES",
    "entry delay",
    ["off", "hydrant", "kitaru"],
    "entryDelayModifier",
];
const trtFlag = ["TYPE_BOOL", "trt", "trtFlag"];

const modsSubMenu = {
    "board[mode=default]": [
        floorModifier,
        crunchModifier,
        invisibleFlag,
        ghostPiece,
        hardDrop,
        killX2,
        horizMirror,
        vertMirror,
    ],
};

const anydasSubMenu = {
    "anydas[mode=default]": [anydasDas, anydasArr, anydasEntryDelay, trtFlag,],
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
const goToMore = ["TYPE_SUBMENU", "more", moreSubMenu];
const goToDisplay = ["TYPE_SUBMENU", "display", displaySubMenu];
const goToAnydas = ["TYPE_SUBMENU", "anydas", anydasSubMenu];

const mainMenu = {
    "play tetris[mode=tetris]": [
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "t-spins[mode=tspins]": [goToMods, goToDisplay, goToAnydas, goToMore],
    "setups[mode=presets]": [
        presetModifier,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "stacking[mode=stacking]": [
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "b-type[mode=typeb]": [
        typeBModifier,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "(quick)tap[mode=tap]": [
        quickTapLeftModifier,
        quickTapRightModifier,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "tap quantity[mode=tapqty]": [
        tapqtyModifier,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "transition[mode=transition]": [
        transitionModifier,
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "marathon[mode=marathon]": [
        marathonModifier,
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "drought[mode=drought]": [
        droughtModifier,
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "checkerboard[mode=checkerboard]": [
        checkerModifier,
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "garbage[mode=garbage]": [
        garbageModifier,
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "lowstack[mode=lowstack]": [
        lowStackRowModifier,
        goToTournament,
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
    "tap/roll speed[mode=speed_test]": [
        goToMods,
        goToDisplay,
        goToAnydas,
        goToMore,
    ],
};

const extraSpriteStrings = ["pause", "block", "clear?", "sure?!", "confetti"];

module.exports = { mainMenu, extraSpriteStrings };
