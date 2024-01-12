# Changelog

## [unreleased]
* Crunch Mode
* Marathon Mode
* Added hidden score option
* Famicom Keyboard support
* MMC3 Support
* MMC5 Support
* Invisible linecap turns entire playfield invisible
* Invisible mode preserves original piece colors
* Floor no longer gobbled up by top line clear
* Floor 0 has original no-burns behaviour again
* Fixed CNROM legal screen CHR bank
* Fixed CNROM legal to title flicker
* Fixed ingame score display at 8 million with Classic Scoring
* Block Tool pieces wrap around
* 0001 seeds are ignored

## [v5 tournament]
* Linecap Menu (from CTM Masters September 2022)
    * Trigger from any level or lines
    * Killscreen x2
    * Floor From Below
    * Invisible
    * Halting
* DAS Only Mode (from CTWC DAS 2022)
* Added option to disable pause
* Show hearts ingame
* Removed garbage / floor spawn delay
* Correctly handle diag inputs for HZ Display
* Fixed a graphics glitch in Block Tool
* Fixed the first mino becoming visible in Invisible
* Other buttons can be pressed when using A+Start to add 10 levels

## [v5]
* Tap Quantity Trainer
* Checkerboard Trainer
* Double Killscreen Trainer
* Made Hard Drop instant
* Added Sonic Drop
* Start on any level
* Rewrite of all scoring code
    * Classic scoring
    * Millions counter 
    * 7 digit score
    * 999999 scorecap 
    * Fixed T-Spin scoring
    * Crash free with no long frames
* Rewrite of all highscore code
    * 8 digit name entry
    * up to 8 score digits
    * Added lines
    * Added start level
    * DAS-like movement for name entry
    * Added ! and ? to name entry
    * Store highscores in clearable save data, if it's available
* 3 digit level counter for levels over 99
* 4 digit line counter for lines over 999 (except in 'Classic' scoring)
* Added hearts to level menu
* Added ready indicator to level menu
* Added new screen for Speed Tester
* Readded original broken colours from level 138+
* Backwards compatible Seed Trainer improvements
* Tap counter wrapping improvement
* Added Block Tool HUD for piece information
* Added option to disable tetris flashing
* Changes made to more closely match the original ROM
    * Restore seed shredding on level menu
    * Hold `select` to start in Qual Mode and reset level cursor 
    * Transition from Legal to Title screen after 512 frames
    * Hide next box between Curtain and Rocket
    * Persist Qual Mode (and menu config) between reset button presses
* CNROM support

### rev01

* Added transition options to Double Killscreen
* Fixed a bug in hard drop where you didn't get lines
* Fixed a bug in hard drop where it crashed if you got a tetris
* Fixed a bug in hard drop where you can spam drop to float at the top of the playfield

### rev02

* Removed transitions in Tap Quantity
* Added scoring to Tap Quantity
* Fixed Hard Drop crashing for real
* Fixed soft drop spamming cheat
* Fixed some top row bugs in Hard Drop

### rev03

* Added letters-based scoring that count 0-9 A-Z then wraps
* Added input log to Speed Test
* Fixed a bug where Rocket wouldn't show with a score between 1.0 and 1.03

## [v4 classic]
- Standard Pause in Qual Mode
- No Next Box allowed in Qual Mode
- Block Tool cannot be used in Qual Mode

## [v4]
- B-Type Trainer (height 0-8)
- Transition Trainer
- Invisible Trainer
- Hard Drop Trainer
- DAS Delay Modifier
- Tap/Roll Speed Tester
- Hz Display
- Goofyfoot support
- Qual Mode (Legal, Title, Curtain, Rocket)
- Show current seed in level select and gameplay screens
- Show current trainer in high score entry screen
- Fixed timing/rendering glitches in T-Spins
- Added still broken, but better scoring for T-Spins
- Improved drought logic
- Rebranded Debug Mode as Block Tool
- Simplified Block Tool controls
- Added DAS-like movement to main menu
- Added DAS-like movement to Block Tool

## [v3.1]
- Added new setup (L/J doubletuck)
- Improved seeds while retaining backwards compatibility
- Improved region detection

## [v3]
- Pace Trainer
- Seed Trainer
- Controller input can be enabled outside of Debug Mode
- PAL Mode now has correct SFX
- Tweaks to make Garbage Trainer more realistic

## [v2]
- Savestates added to Debug Mode
- Controller input added to Debug Mode
- Garbage Trainer
    - Always Tetris Ready
    - Normal Garbage
    - Smart Garbage 
    - Hard Garbage
    - Infinite Digging
- Piece distribution in Setups Trainer is now even
- Added new setup (L/J double spintuck)
- Wraparound on main menu cursor
- Display current trainer during gameplay / level select
- Fixed some NES Tetris bugs;
    - Resetting during a tetris no longer creates an invalid state
    - Tetrimino colours are correct past level 138
    - Game no longer crashes after ~1550 lines

## [v1]
- Tetris Trainer
- T-Spins Trainer
- Stacking Trainer
- Setups Trainer
- Floor Trainer
- (Quick)Tap Trainer
- Drought Trainer
- Debug Mode
- PAL Mode
