const {
    MarcFile,
    createBPSFromFiles,
    parseBPSFile,
    crc32,
} = require('./bps.js');
const fs = require('fs');

// https://github.com/blakesmith/rombp/blob/master/docs/bps_spec.md

module.exports = function patch(original, modified, destination) {
    const originalFile = new MarcFile(original);
    const modifiedFile = new MarcFile(modified);
    const patch = createBPSFromFiles(originalFile, modifiedFile, true);

    // post-process BPS so that header bytes are ignored

    let outputOffset = 0;

    patch.actions.forEach((action) => {
        if (action.type === 0) {
            let { length } = action;

            let usesHeader = false;
            for (let i = 0; length--; i++) {
                if (outputOffset + i < 0x10) {
                    usesHeader = true;
                    break;
                }
            }

            if (usesHeader) {
                action.type = 1;
                action.bytes = Array.from(
                    modifiedFile._u8array.slice(
                        outputOffset,
                        outputOffset + action.length,
                    ),
                );
            }

            outputOffset += action.length;
        } else {
            outputOffset += action.length;
        }
    });

    // reapply the checksum
    patch.patchChecksum = crc32(patch.export(), 0, true);

    fs.writeFileSync(destination, patch.export()._u8array);

    const bps = parseBPSFile(new MarcFile('tetris.bps'));

    // count patch sizes
    let source = 0;
    bps.actions.forEach((action) => {
        if ([0, 2].includes(action.type)) {
            source += action.length;
        }
    });

    return ((source / bps.sourceSize) * 100) | 0;
};
