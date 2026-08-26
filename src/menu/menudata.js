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
const vitsScoreFlag = ["TYPE_BOOL", "vits scoring", "vitsScoreFlag"];
const tetrisOnlyFlag = ["TYPE_BOOL", "tetris only", "tetrisOnlyFlag"];

const scoringModifier = [
    "TYPE_CHOICES",
    "scoring",
    ["classic", "letters", "7digit", "m", "capped", "hidden"],
    "scoringModifier",
];

const ghostPiece = ["TYPE_BOOL", "ghost", "ghostPieceFlag"];
const modernLinesFlag = ["TYPE_BOOL", "modern lines", "modernLinesFlag"];
const paceModifier = ["TYPE_FF_OFF", "Pace *100k", 16, "paceModifier"];
const hzFlag = ["TYPE_BOOL", "HZ DISPLAY", "hzFlag"];
const inputDisplayFlag = ["TYPE_BOOL", "Input Display", "inputDisplayFlag"];
const disableFlash = ["TYPE_BOOL", "Disable Flash", "disableFlashFlag"];
const secretGrading = ["TYPE_BOOL", "Secret Grading", "secretGradingFlag"];
const darkMode = [
    "TYPE_CHOICES",
    "dark mode",
    ["off", "on", "neon", "lite", "teal", "og"],
    "darkModifier",
];

const paletteSelection = [
    "TYPE_CHOICES",
    "palette",
    ["vanilla", "pride", "white", "custom"],
    "paletteModifier",
];

const customPaletteMenu = {
    "custom palette[mode=default]": [
        ["TYPE_HEX", "0", 6, "customLevel0"],
        ["TYPE_HEX", "1", 6, "customLevel1"],
        ["TYPE_HEX", "2", 6, "customLevel2"],
        ["TYPE_HEX", "3", 6, "customLevel3"],
        ["TYPE_HEX", "4", 6, "customLevel4"],
        ["TYPE_HEX", "5", 6, "customLevel5"],
        ["TYPE_HEX", "6", 6, "customLevel6"],
        ["TYPE_HEX", "7", 6, "customLevel7"],
        ["TYPE_HEX", "8", 6, "customLevel8"],
        ["TYPE_HEX", "9", 6, "customLevel9"],
        ["TYPE_CUSTOM", "load vanilla", "LOAD_VANILLA"],
        ["TYPE_CUSTOM", "load pride", "LOAD_PRIDE"],
        ["TYPE_CUSTOM", "load white", "LOAD_WHITE"],
        ["TYPE_CUSTOM", "load bugged", "LOAD_BUGGED"],
        ["TYPE_NUMBER", "bug offset", 0, "buggedModifier"],
    ],
};

const goToCustomPalette = ["TYPE_SUBMENU", "custom palette", customPaletteMenu];
const crashModifier = [
    "TYPE_CHOICES",
    "crash",
    ["off", "show", "top", "crash"],
    "crashModifier",
];
const strictCrashFlag = ["TYPE_BOOL", "strict crash", "strictFlag"];
const disablePause = ["TYPE_BOOL", "disable pause", "disablePauseFlag"];
const debugFlag = ["TYPE_BOOL", "block tool", "debugFlag"];
const palFlag = ["TYPE_BOOL", "pal mode", "palFlag"];
const keyboardFlag = ["TYPE_BOOL", "keyboard", "keyboardFlag"];
const qualFlag = ["TYPE_BOOL", "qual", "qualFlag"];
const goofyFlag = ["TYPE_BOOL", "goofy foot", "goofyFlag"];
const swapDutyFlag = ["TYPE_BOOL", "swap duty cycles", "swapDutyCyclesFlag"];
const disableScoreSaving = ["TYPE_BOOL", "no high scores", "disableScoreSaving"];
const clearScores = ["TYPE_CUSTOM", "clear scores", "CLEAR_SCOREBOARD"];
const resetDefaults = ["TYPE_CUSTOM", "reset defaults", "RESET_DEFAULTS"];

const floorModifier = ["TYPE_NUMBER", "floor", 19, "floorModifier"];
const crunchLeftModifier = [
    "TYPE_NUMBER",
    "crunch left",
    4,
    "crunchLeftModifier",
];
const crunchRightModifier = [
    "TYPE_NUMBER",
    "crunch right",
    4,
    "crunchRightModifier",
];
const invisibleFlag = ["TYPE_BOOL", "invisible", "invisibleOptionFlag"];

const horizMirror = ["TYPE_BOOL", "mirror horiz", "mirrorHorizFlag"];
const vertMirror = ["TYPE_BOOL", "mirror vert", "mirrorVertFlag"];
const teppozFlag = ["TYPE_BOOL", "teppoz", "teppozFlag"];
const sxtoklFlag = ["TYPE_BOOL", "sxtokl", "sxtoklFlag"];
const palpepFlag = ["TYPE_BOOL", "palpep", "palpepFlag"];
const splitSquareFlag = ["TYPE_BOOL", "split squares", "splitSquareFlag"];

const fillType = [
    "TYPE_CHOICES",
    "fill type",
    ["none", "b", "checker"],
    "fillType",
];

// shared for fill, btype & checker
const rowsModifier = ["TYPE_NUMBER", "rows", 19, "rowsModifier"];
const heightModifier = ["TYPE_NUMBER", "height", 9, "heightModifier"];
const heightOrRows = [
    "TYPE_CHOICES",
    "height/rows",
    ["height", "rows"],
    "heightOrRows",
];

const headStartFlag = ["TYPE_BOOL", "enabled", "headStartFlag"];
const startScore = ["TYPE_NUMBER", "score *100k", 16, "startScore"];
const startLines = ["TYPE_NUMBER", "lines *10", 31, "startLines"];

const presetModifier = [
    "TYPE_CHOICES",
    "setup",
    ["z", "t/s", "t", "i", "buco", "various", "ljspin", "ljdouble"],
    "presetModifier",
];

const typeBSeed = ["TYPE_HEX", "bseed", 4, "b_seed_input"];
const typeBSeedFlag = ["TYPE_BOOL", "bseed enabled", "typeBSeedFlag"];
const bTypeLines = ["TYPE_BCD", "lines", 2, "bTypeLines"];
const quickTapLeftModifier = ["TYPE_NUMBER", "left", 20, "tapLeftModifier"];
const quickTapRightModifier = ["TYPE_NUMBER", "right", 20, "tapRightModifier"];
const quickTapLeftColumn = [
    "TYPE_CHOICES",
    "left column",
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
    "tapLeftColumn",
];
const quickTapRightColumn = [
    "TYPE_CHOICES",
    "right column",
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
    "tapRightColumn",
];
const practisePiece = [
    "TYPE_CHOICES",
    "piece",
    ["T", "J", "Z", "O", "S", "L", "I"],
    "practisePiece",
];
const marathonScoreFlag = [
    "TYPE_CHOICES",
    "fixed score",
    ["on", "off"],
    "marathonScoreFlag",
];
const marathonLevelModifier = [
    "TYPE_CHOICES",
    "level up",
    ["fixed", "normal", "zero"],
    "marathonLevelModifier",
];

const tapqtyModifier = ["TYPE_NUMBER", "height", 16, "tapqtyModifier"];
const noLineClearDelayFlag = [
    "TYPE_BOOL",
    "no line clear",
    "noLineClearDelayFlag",
];
const garbageModifier = [
    "TYPE_CHOICES",
    "mode",
    ["tetris", "normal", "smart", "hard", "infinite"],
    "garbageModifier",
];
const droughtModifier = ["TYPE_NUMBER", "modifier", 20, "droughtModifier"];
const lowStackRowModifier = [
    "TYPE_NUMBER",
    "height",
    20,
    "lowStackRowModifier",
];

const noWallChargeFlag = ["TYPE_BOOL", "no wall charge", "noWallChargeFlag"];
const disableDasFlag = ["TYPE_BOOL", "disable das", "disableDasFlag"];
const anydasDas = ["TYPE_NUMBER", "delay", 31, "dasModifier"];
const anydasArr = ["TYPE_NUMBER", "arrrr", 31, "arrModifier"];
const anydasEntryDelay = [
    "TYPE_CHOICES",
    "entry charge",
    ["off", "hydrant", "kitaru"],
    "entryChargeModifier",
];
const no5TapFlag = ["TYPE_BOOL", "no 5 taps", "no5TapFlag"];
const hardDrop = ["TYPE_BOOL", "hardDrop", "hardDropFlag"];

const trtFlag = ["TYPE_BOOL", "tetris rate", "trtFlag"];
const dasMeterFlag = ["TYPE_BOOL", "das meter", "dasMeterFlag"];
const gameTimerFlag = ["TYPE_BOOL", "game timer", "gameTimerFlag"];
const nextBoxStart = [
    "TYPE_CHOICES",
    "next piece",
    ["shown", "hidden"],
    "nextBoxStart",
];
const tapQtyMenu = {
    "tap quantity[mode=tapqty]": [tapqtyModifier, noLineClearDelayFlag],
};
const marathonMenu = {
    "marathon[mode=marathon]": [marathonScoreFlag, marathonLevelModifier],
};
const droughtMenu = {
    "drought[mode=drought]": [droughtModifier],
};
const checkerMenu = {
    "checkerboard[mode=checkerboard]": [
        heightModifier,
        rowsModifier,
        heightOrRows,
    ],
};
const garbageMenu = {
    "garbage[mode=garbage]": [garbageModifier],
};
const lowstackMenu = {
    "lowstack[mode=lowstack]": [lowStackRowModifier],
};

const bMenu = {
    "b-type[mode=typeb]": [
        heightModifier,
        rowsModifier,
        heightOrRows,
        typeBSeed,
        typeBSeedFlag,
        bTypeLines,
    ],
};
const setupsMenu = {
    "setups[mode=presets]": [presetModifier, debugFlag],
};
const quickTapMenu = {
    "(quick)tap[mode=tap]": [
        quickTapLeftModifier,
        quickTapRightModifier,
        quickTapLeftColumn,
        quickTapRightColumn,
        practisePiece,
        debugFlag,
    ],
};

const scoreLinesMenu = {
    "head start[mode=default]": [headStartFlag, startScore, startLines],
};

const boardFillMenu = {
    "board fill[mode=default]": [
        fillType,
        heightModifier,
        rowsModifier,
        heightOrRows,
        typeBSeed,
        typeBSeedFlag,
    ],
};

const mainMenu = {
    "play tetris[mode=tetris]": [
        ["TYPE_GAMEMODE", "t-spins", "MODE_TSPINS"],
        ["TYPE_GAMEMODE", "stacking", "MODE_STACKING"],
        ["TYPE_SUBMENU", "setups", setupsMenu],
        ["TYPE_SUBMENU", "b-type", bMenu],
        ["TYPE_SUBMENU", "(quick)tap", quickTapMenu],
        ["TYPE_SUBMENU", "marathon", marathonMenu],
        ["TYPE_SUBMENU", "tap quantity", tapQtyMenu],
        ["TYPE_SUBMENU", "checkerboard", checkerMenu],
        ["TYPE_SUBMENU", "garbage", garbageMenu],
        ["TYPE_SUBMENU", "drought", droughtMenu],
        ["TYPE_SUBMENU", "lowstack", lowstackMenu],
        ["TYPE_GAMEMODE", "kill*2", "MODE_KILLX2"],
        ["TYPE_GAMEMODE", "tap/roll speed", "MODE_SPEED_TEST"],
    ],
    "tournament[mode=default]": [
        seedInput,
        seedFlag,
        linecapWhen,
        linecapHow,
        linecapLevel,
        linecapLines,
        dasOnly,
        tetrisOnlyFlag,
        vitsScoreFlag,
    ],
    "general[mode=default]": [
        crashModifier,
        strictCrashFlag,
        disablePause,
        debugFlag,
        goofyFlag,
        swapDutyFlag,
        qualFlag,
        palFlag,
        keyboardFlag,
        disableScoreSaving,
        ["TYPE_GAMEMODE", "calibrate", "MODE_CALIBRATE"],
        clearScores,
        resetDefaults,
    ],

    "modify game[mode=default]": [
        floorModifier,
        crunchLeftModifier,
        crunchRightModifier,
        invisibleFlag,
        horizMirror,
        vertMirror,
        splitSquareFlag,
        teppozFlag,
        palpepFlag,
        sxtoklFlag,
        ["TYPE_SUBMENU", "head start", scoreLinesMenu],
        ["TYPE_SUBMENU", "board fill", boardFillMenu],
    ],

    "display[mode=default]": [
        scoringModifier,
        modernLinesFlag,
        hzFlag,
        inputDisplayFlag,
        darkMode,
        disableFlash,
        paceModifier,
        trtFlag,
        dasMeterFlag,
        gameTimerFlag,
        secretGrading,
        ghostPiece,
        nextBoxStart,
        paletteSelection,
        goToCustomPalette,
    ],

    "handling[mode=default]": [
        anydasDas,
        anydasArr,
        anydasEntryDelay,
        noWallChargeFlag,
        disableDasFlag,
        no5TapFlag,
        hardDrop,
    ],
};

const extraSpriteStrings = [
    "pause",
    "block",
    "clear?",
    "sure?!",
    "confetti",
    "wait",
];

module.exports = { mainMenu, extraSpriteStrings };
