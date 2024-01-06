const { MarcFile, createBPSFromFiles, parseBPSFile } = require('./bps.js');
const fs = require('fs');

// https://github.com/blakesmith/rombp/blob/master/docs/bps_spec.md

module.exports = function patch(original, modified, destination) {
    const patch = createBPSFromFiles(
        new MarcFile(original),
        new MarcFile(modified),
        true,
    ).export('');

    fs.writeFileSync(destination, patch._u8array);

    const bps = parseBPSFile(new MarcFile('tetris.bps'));

    // count patch sizes
    let source = 0;
    bps.actions.forEach(action => {
        if ([0, 2].includes(action.type)) {
            source += action.length;
        }
    });

    return (source / bps.sourceSize) * 100 | 0;
}
