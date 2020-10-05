const { readFileSync, writeFileSync } = require('fs');

const buffer = readFileSync(__dirname + '/game_type_menu_nametable.bin');

let lookup = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-.\'>################qweadzxc###############/##!#########[]()############################################################################################################################################################### ';

lookup = [...lookup].map((d, i) => d === '#' ? String.fromCharCode(/*9472+*/9726-i):d).join``

console.log(lookup.match(/.{16}/g).join('\n'));

const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');

console.log(chars.join('').match(/.{35}/g).join('\n'));
`
0123456789ABCDEF
GHIJKLMNOPQRSTUV
WXYZ-.'>◖◕◔◓◒◑◐●
◎◍◌○◊◉◈◇qweadzxc
▾▽▼▻►▹▸▷▶▵▴△▲▱▰/
▮▭!▫▪▩▨▧▦▥▤▣▢□()
▞▝▜▛▚▙▘▗▖▕▔▓▒░▐▏
▎▍▌▋▊▉█▇▆▅▄▃▂▁▀╿
╾╽╼╻╺╹╸╷╶╵╴╳╲╱╰╯
╮╭╬╫╪╩╨╧╦╥╤╣╢╡╠╟
╞╝╜╛╚╙╘╗╖╕╔╓╒║═╏
╎╍╌╋╊╉╈╇╆╅╄╃╂╁╀┿
┾┽┼┻┺┹┸┷┶┵┴┳┲┱┰┯
┮┭┬┫┪┩┨┧┦┥┤┣┢┡┠┟
┞┝├┛┚┙┘┗┖┕└┓┒┑┐┏
┎┍┌┋┊┉┈┇┆┅┄┃│━─
`

const tiles = `
W0W################################
WWW#########qwwwwwwwwwwwwe#########
W#W#qwwwwwww] ╎╍╌╋╊╉╈╇╆╅ [wwwwwwwe#
W#W#a         ┾┽┼┻┺┹┸┷┶┵         d#
W#W#a         ┮┭┬┫┪┩┨┧┦┥         d#
W#W#a         ┞┝├┛┚┙┘┗┖┕         d#
W#W#a         ┎┍┌┋┊┉┈┇┆┅         d#
W#W#a                            d#
X0W#a                            d#
XWW#a                            d#
X#W#a                            d#
X#W#a   PLAY                     d#
X#W#a   T-SPINS                  d#
X#W#a   PARITY                   d#
X#W#a   SETUPS                   d#
X#W#a   FLOOR                    d#
Y0W#a   (QUICK)TAP               d#
YWW#a   DROUGHT                  d#
Y#W#a   DEBUG MODE               d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Y#W#a                            d#
Z0W#a                            d#
ZWW#a                            d#
Z#W#aV1                   KIRJAVAd#
Z#W#zxxxxxxxxxxxxxxxxxxxxxxxxxxxxc#
Z#W################################
Z#W################################
`;

// tiles
const practise = Buffer.from(buffer);
[...tiles.trim().split('\n').join('')].forEach((d, i) => {
    if (d !== '#') {
        practise[i] = lookup.indexOf(d);
    }
});

// palettes
// DR - DL - UR - UL
const palettes = p => p.trim().match(/.+\n.+$/gm)
    .flatMap(line=>(
        [t,b]=line.split('\n'),
        t.trim().match(r=/../g).map((d,i)=>d+b.trim().match(r)[i])
    ))
    .map(d=>+('0b'+[...d].reverse().map(d=>(+d).toString(2).padStart(2,0)).join``));

[
    [1053, palettes(`
        2222222222222222
        2222211111122222
        2222211111122222
        2222211111122222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
    `)],
    [1088, palettes(`
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
        2222222222222222
    `)],
].forEach(([index, attributes]) => attributes.forEach((byte, i) => { practise[i+index] = byte; }));

writeFileSync(__dirname + '/game_type_menu_nametable_practise.bin', practise);
