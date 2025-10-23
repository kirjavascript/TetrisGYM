const fs = require('fs');
const path = require('path');

function format(line) {
    line = line.trimEnd().replace(/^\t+/, (_) => ' '.repeat(4 * _.length));

    if (!line.trim().startsWith(';')) {
        line = line.replace(/^(\s+\w+)(\s+)([^;\s]+)/, '$1 $3');
    }

    return line;

}

(function processFiles(directory) {
    const files = fs.readdirSync(directory);

    files.forEach(file => {
        const filePath = path.join(directory, file);
        const stat = fs.statSync(filePath);

        if (stat.isDirectory()) {
            processFiles(filePath);
        } else if (file.endsWith('.asm')) {
            const content = fs.readFileSync(filePath, 'utf8');
            let formatted = content.split('\n').map(format).join('\n');
            if (formatted.at(-1) !== '\n') {
                formatted += '\n';
            }
            fs.writeFileSync(filePath, formatted);
        }
    });
})(process.cwd());
