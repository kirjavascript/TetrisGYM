const { MarcFile, createBPSFromFiles } = require('./bps.js');
const fs = require('fs');

module.exports = function patch(original, modified, destination) {
    const patch = createBPSFromFiles(
        new MarcFile(original),
        new MarcFile(modified),
        true,
    ).export('')._u8array;

    fs.writeFileSync(destination, patch);
}
