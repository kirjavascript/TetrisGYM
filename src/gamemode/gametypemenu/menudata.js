aItem = [
    "TYPE_CHOICES",
    "aaaaaaaaaaaa",
    [
        "a",
        "aa",
        "aaa",
        "aaaa",
        "aaaaa",
        "aaaaaa",
        "aaaaaaa",
        "aaaaaaaa",
    ],
]

aPage = {
    "aaaaaaaaaaaaaa": [
        aItem,
        aItem,
        aItem,
        aItem,
        aItem,
        aItem,
        aItem,
        aItem,
    ]
}


dbgPage = [
    [
        "TYPE_NUMBER",
        "menu",
        0,
        "activeMenu",
    ],
    [
        "TYPE_NUMBER",
        "page",
        0,
        "activePage",
    ],
    [
        "TYPE_NUMBER",
        "row",
        0,
        "activeRow",
    ],
    [
        "TYPE_NUMBER",
        "col",
        0,
        "activeColumn",
    ],
    [
        "TYPE_NUMBER",
        "ptr",
        0,
        "menuStackPtr",
    ],
]

digitsExample = {
    "BCD": [
        [
            "TYPE_BCD",
            "2",
            2,
            "menuVar8",
        ],
        [
            "TYPE_BCD",
            "4",
            4,
            "menuVar8",
        ],
        [
            "TYPE_BCD",
            "6",
            6,
            "menuVar8",
        ],
        [
            "TYPE_BCD",
            "8",
            8,
        ],
    ],
    "Hex": [
        [
            "TYPE_HEX",
            "2",
            2,
            "menuVar8+3",
        ],
        [
            "TYPE_HEX",
            "4",
            4,
            "menuVar8+2",
        ],
        [
            "TYPE_HEX",
            "6",
            6,
            "menuVar8+1",
        ],
        [
            "TYPE_HEX",
            "8",
            8,
        ],
    ],
    "dbg": dbgPage,
}

tournamentSubmenu = {
    "Tournament[mode=default]": [
        [
            "TYPE_HEX",
            "SEED",
            6,
            "set_seed_input",
        ],
        [
            "TYPE_BOOL",
            "linecap",
            "linecapFlag",
        ],
        [
            "TYPE_CHOICES",
            "when",
            [
                "lines",
                "level",
            ],
            "linecapWhen",
        ],
        [
            "TYPE_CHOICES",
            "how",
            [
                "KS*2",
                "Floor",
                "Inviz",
                "Halt",
            ],
            "linecapHow",
        ],
        [
            "TYPE_NUMBER",
            "Level",
            0,
            "linecapLevel",
        ],
        [
            "TYPE_HEX",
            "Lines",
            4,
            "linecapLines",
        ],
        [
            "TYPE_BOOL",
            "Das",
            "dasOnlyFlag",
        ],
        [
            "TYPE_BOOL",
            "Qual",
            "qualFlag",
        ],
    ],
    "dbg": dbgPage,
}

displaySubmenu = {
    "Display": [
        [
            "TYPE_CHOICES",
            "Scoring",
            [
                "Classic",
                "Letters",
                "7digit",
                "M",
                "Capped",
                "Hidden",
            ],
            "scoringModifier",
        ],
        [
            "TYPE_FF_OFF",
            "Pace",
            16,
            "paceModifier",
        ],
        [
            "TYPE_BOOL",
            "HZ DISPLAY",
            "hzFlag",
        ],
        [
            "TYPE_BOOL",
            "Input Display",
            "inputDisplayFlag",
        ],
        [
            "TYPE_BOOL",
            "Disable Flash",
            "disableFlashFlag",
        ],
        [
            "TYPE_CHOICES",
            "Dark Mode",
            [
                "Off",
                "On",
                "Neon",
                "Lite",
                "Teal",
                "OG",
            ],
            "darkModifier",
        ],
    ],
    "dbg": dbgPage,
}

settingsSubmenu = {
    "Settings": [
        [
            "TYPE_CHOICES",
            "Crash",
            [
                "off",
                "show",
                "top",
                "crash",
            ],
            "crashModifier",
        ],
        [
            "TYPE_BOOL",
            "Strict Crash",
            "strictFlag",
        ],
        [
            "TYPE_BOOL",
            "Disable Pause",
            "disablePauseFlag",
        ],
        [
            "TYPE_BOOL",
            "Goofy Foot",
            "goofyFlag",
        ],
        [
            "TYPE_BOOL",
            "Block Tool",
            "debugFlag",
        ],
        [
            "TYPE_BOOL",
            "Pal Mode",
            "palFlag",
        ],
    ],
    "dbg": dbgPage,
}


numberExample = {
    "Numbers": [
        [
            "TYPE_NUMBER",
            "MAX 2",
            2,
        ],
        [
            "TYPE_NUMBER",
            "MaX 30",
            31,
            "menuVarMax2",
        ],
        [
            "TYPE_NUMBER",
            "no max",
            0,
            "menuVarMax2",
        ],
        [
            "TYPE_FF_OFF",
            "-1 is off",
            0,
            "menuVarMax2",
        ],
        [
            "TYPE_CHOICES",
            "words",
            [
                "off",
                "on",
                "a",
                "b",
                "show",
                "top",
                "crash",
                "Neon",
                "Lite",
                "Teal",
                "OG",
                "Classic",
                "Letters",
                "7digit",
                "M",
                "Capped",
                "Hidden",
                "lines",
                "level",
                "KS*2",
                "Floor",
                "Inviz",
                "Halt",
                "TET",
                "TSP",
                "SEE",
                "STA",
                "PAC",
                "SET",
                "B-T",
                "FLO",
                "CRU",
                "QCK",
                "TRN",
                "MAR",
                "TAP",
                "CKR",
                "GAR",
                "LOB",
                "DAS",
                "LOW",
                "KIL",
                "INV",
                "HRD",
                "a",
                "aa",
                "aaa",
                "aaaa",
                "aaaaa",
                "aaaaaa",
                "aaaaaaa",
                "aaaaaaaa",
            ],
        ],
        [
            "TYPE_HEX",
            "by digit",
            2,
            "menuVarWords",
        ],
        [
            "TYPE_BCD",
            "by bcd digit",
            2,
            "menuVarWords",
        ],
    ],
    "dbg": dbgPage,
}

booleanExample = {
    "boolean": [
        [
            "TYPE_BOOL",
            "A",
        ],
        [
            "TYPE_CHOICES",
            "B",
            [
                "On",
                "Off",
            ],
            "menuVarA",
        ],
        [
            "TYPE_NUMBER",
            "C",
            2,
            "menuVarA",
        ],
        [
            "TYPE_CHOICES",
            "D",
            [
                "a",
                "b",
            ],
            "menuVarA",
        ],
    ],
    "dbg": dbgPage,
}
debugVars = {
    "dbg": dbgPage,
}

maxDigits = {
    "07**": [
        [
            "TYPE_HEX",
            "00-03",
            8,
            "highscores",
        ],
        [
            "TYPE_HEX",
            "04-07",
            8,
            "highscores+4",
        ],
        [
            "TYPE_HEX",
            "08-0B",
            8,
            "highscores+8",
        ],
        [
            "TYPE_HEX",
            "0C-0F",
            8,
            "highscores+12",
        ],
        [
            "TYPE_HEX",
            "10-13",
            8,
            "highscores+16",
        ],
        [
            "TYPE_HEX",
            "14-17",
            8,
            "highscores+20",
        ],
        [
            "TYPE_HEX",
            "18-1B",
            8,
            "highscores+24",
        ],
        [
            "TYPE_HEX",
            "1C-1F",
            8,
            "highscores+28",
        ],
    ]
}


mainMenu = {
    "(new menu,*)?!": [
        [
            "TYPE_SUBMENU",
            "booleans",
            booleanExample,
        ],
        [
            "TYPE_SUBMENU",
            "numbers",
            numberExample,
        ],
        [
            "TYPE_SUBMENU",
            "Digits",
            digitsExample,
        ],
        [
            "TYPE_SUBMENU",
            "32 bytes",
            maxDigits,
        ],
        [
            "TYPE_SUBMENU",
            "debug",
            debugVars,
        ],
        [
            "TYPE_SUBMENU",
            "a",
            aPage,
        ],
    ],
    "kinda working": [
        [
            "TYPE_CHOICES",
            "practise",
            [
                "TET",
                "TSP",
                "SEE",
                "STA",
                "PAC",
                "SET",
                "B-T",
                "FLO",
                "CRU",
                "QCK",
                "TRN",
                "MAR",
                "TAP",
                "CKR",
                "GAR",
                "LOB",
                "DAS",
                "LOW",
                "KIL",
                "INV",
                "HRD",
            ],
            "practiseType",
        ],
        [
            "TYPE_SUBMENU",
            "Tournament",
            tournamentSubmenu,
        ],
        [
            "TYPE_SUBMENU",
            "Display",
            displaySubmenu,
        ],
        [
            "TYPE_SUBMENU",
            "Settings",
            settingsSubmenu,
        ],
    ],
    "dbg": dbgPage,
}

extraSpriteStrings = [
    "Pause",
    "Block",
    "Clear?",
    "Sure?!",
    "Confetti",
]

module.exports = {mainMenu, extraSpriteStrings}
