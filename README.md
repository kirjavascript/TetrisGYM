
# TetrisGYM

<div align="center">
    <img src="./screens/menu.png" alt="Menuscreen">
    <br>
</div>
<br>

* [Getting Started](#guide)
* [Modes](#modes)
    * [Play](#play)
    * [T-Spins](#tspins)
    * [Stacking](#stacking)
    * [Setups](#setups)
    * [Floor](#floor)
    * [(Quick)Tap](#tap)
    * [Drought](#drought)
    * [Debug Mode](#debug)
    * [PAL Mode](#pal)
* [Resources](#resources)

## Getting Started

TetrisGYM is a modification of the USA version of NES Tetris.

While it is originally based on the USA NTSC version, after patching it will detect your console region, and gameplay will either match the corresponding NTSC or PAL versions of the game.

TetrisGYM is distributed in the form of an BPS patch and can be applied with [Rom PatcherJS](https://www.romhacking.net/patch/) or similar.

A link to the BPS can be found in the releases page. [TODO ADD LINK]

## Modes

Some modes have additional configuration values; use left and right to change them.

### Play

![Play](/screens/play.png)

Same gameplay as Type-A, with some improvements. No score cap, no rocket, no curtain, always next box, better pause, extended level select.

There are various other small changes

### T-Spins

![T-Spins](/screens/tspins.png)

Spawn T-Spins in random X and Y positions. Additional entry delay on successful T-Spin to prepare for the next state.

### Stacking

![Stacking](/screens/stacking.png)

An experiment to highlight bad areas of the playfield in an attempt to improve stacking.

### Setups

![Setups](/screens/setups.png)

Several preset playfields for practising different types of tucks and spins.

### Floor

![Floor](/screens/floor.png)

Fill in the floor to a certain height to force higher stacking. This mode is often referred to as 'handicap'.

Setting the height to zero will result in a game mode with burns disabled.

### (Quick)Tap

![Tap](/screens/tap.png)

A mode for practising tapping and quicktapping pieces over towers. 0-G will have a tower on the left of the screen and H-W will have a tower to the right.

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

This is a config option only, and will enable debug mde globally.

### PAL Mode

Dictate if the NTSC or PAL gameplay mechanics should be used. Should automatically detect region, but can be manually overwritten otherwise.

## Resources

upstream repo: [https://github.com/CelestialAmber/TetrisNESDisasm](https://github.com/CelestialAmber/TetrisNESDisasm)  
disassembly information: [https://github.com/ejona86/taus](https://github.com/ejona86/taus)

