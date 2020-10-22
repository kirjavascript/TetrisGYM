
# TetrisGYM

<div align="center">
    <img src="./screens/menu.png" alt="Menuscreen">
    <br>
</div>
<br>

* [Getting Started](#guide)
* [Trainers](#modes)
    * [Tetris](#tetris)
    * [T-Spins](#t-spins)
    * [Stacking](#stacking)
    * [Setups](#setups)
    * [Floor](#floor)
    * [(Quick)Tap](#%28quick%29-tap)
    * [Drought](#drought)
    * [Debug Mode](#debug-mode)
    * [PAL Mode](#pal-mode)
* [Resources](#resources)

## Getting Started

TetrisGYM is a modification of NES Tetris.

While originally based on the NTSC version of the game, the patched ROM supports PAL and NTSC gameplay types.

TetrisGYM is distributed in the form of a BPS patch and can be applied to the USA version of the game with [Rom PatcherJS](https://www.romhacking.net/patch/) or similar.

A link to the BPS can be found on the [releases page](https://github.com/kirjavascript/TetrisGYM/releases).

## Trainers

Some trainers have additional configuration values; use left and right to change them.

### Tetris

![Tetris](/screens/levelselect.png)

Same gameplay as Type-A, with some improvements: no score cap, no rocket, no curtain, always next box, better pause, extended level select.

### T-Spins

![T-Spins](/screens/tspins.png)

Spawn T-Spins in random X and Y positions. Additional entry delay on successful T-Spin to prepare for the next state.

### Stacking

![Stacking](/screens/stacking.png)

An experiment in highlighting areas of the playfield.

### Setups

![Setups](/screens/setups.png)

Several preset playfields for practising different types of tucks and spins.

### Floor

![Floor](/screens/floor.png)

Fill in the floor to a certain height to force higher stacking. This mode is often referred to as 'handicap'.

Setting the height to zero will result in a game mode with burns disabled.

### (Quick)Tap

![Tap](/screens/tap.png)

For practising tapping and quicktapping pieces over towers. 0-G will have a tower on the left of the screen and H-W will have a tower to the right.

### Drought

Create artificially inflated droughts. Increasing the value causes less I pieces.

0 = normal gameplay I = no line pieces

### Debug Mode

![Tap](/screens/debug.png)

Allows full control of editing the playfield and current / next pieces.

When enabled, press start to go into debug mode.

You can use use the dpad to move around, and select to switch between piece editing and playfield editing.

* Piece editing  
        A/B to change current piece, hold one and press the other to change next piece
* Playfield editing  
        A to draw a block, B to delete a block

This is a config option only, and will enable debug mode globally.

### PAL Mode

Dictate if the NTSC or PAL gameplay mechanics should be used. Should automatically detect region, but can be manually overwritten otherwise.

## Resources

upstream repo: [https://github.com/CelestialAmber/TetrisNESDisasm](https://github.com/CelestialAmber/TetrisNESDisasm)  
disassembly information: [https://github.com/ejona86/taus](https://github.com/ejona86/taus)

