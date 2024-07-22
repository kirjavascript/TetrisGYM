const {
    writeRLE,
    blankNT,
    drawTiles,
    drawAttrs,
    flatLookup,
} = require('./nametables');


const buffer = blankNT();

let lookup = flatLookup(`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-,˙>rtyfhvbn
########qweadzxc
############jkl/
ui!###g@######()
############^$#.
################
################
################
################
################
################
################
################
###############
`);

drawTiles(buffer, lookup, `
╲▂╢╢╢▀░▀╃▃╢╲╠╡▂▐▃╲▐▁▃▂╢▂╢╲╢▀▁▁▃╲
╲qwwwwwwwwwwwwwwwwwwwwwwwwwwwwe□
▂a                            d╢
▀a  GOOD GAME                 d□
╢a                            d╢
╂a  YOU ARE A TETRIS MASTER   d□
▂a                            d▀
╢a                            d╡
╀a                            d╱
▂a                            d▀
╠a                            d▃
╰a                            d▃
╠a                            d╢
╰a                            d╀
▀a                            d▂
╢a                            d╢
╀a                            d╲
▂a                            d╲
▃a                            d▂
▀a                            d▀
▀a                            d▃
▐a                            d▀
╲a                            d▃
▂a                            d▀
▃a                            d▀
▀a                            d╡
▀a                            d╱
▁a                            d╢
╠zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc□
╰╱╰╱▐▃▀▁□╲■▁▃▂╀▃▂▀╂╀▃▀░▀╂╲╢╰╱╲▂╢
`);

drawAttrs(buffer, [`
    2222222222222222
    2222222222222222
    2222222222222222
    2222233333322222
    2222222222222222
    2222222222222222
    2222222222222222
    2222222222222222
`,`
    2000000000000002
    2000000000000002
    2000000000000002
    2000000000000002
    2000000000000002
    2000000000000002
    2222222222222222
    2222222222222222
`]);

writeRLE(
    __dirname + '/enter_high_score_nametable_practise.bin',
    buffer,
);
