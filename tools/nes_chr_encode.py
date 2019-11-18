import getopt
import os.path
import png
import sys

CHAR_WIDTH = 8  # character width in pixels
CHAR_HEIGHT = 8  # character height in pixels
BYTES_PER_CHAR = 16  # bytes per character in CHR data
CHARS_PER_ROW = 16  # characters per row in output image

DEFAULT_PALETTE = ("000000", "555555", "aaaaaa", "ffffff")

def decode_color_code(color):
    """Decode an HTML color code (6 hexadecimal digits)."""

    try:
        if len(color) != 6:
            raise ValueError
        color = int(color, 16)
    except ValueError:
        exit("Error: invalid color code.")
    red = color >> 16
    green = (color >> 8) & 0xff
    blue = color & 0xff
    return (red, green, blue)

def parse_arguments():
    """Parse command line arguments using getopt."""

    longOpts = ("color0=", "color1=", "color2=", "color3=")
    try:
        (opts, args) = getopt.getopt(sys.argv[1:], "", longOpts)
    except getopt.GetoptError:
        exit("Error: invalid option. See the readme file.")

    if len(args) != 2:
        exit("Error: invalid number of arguments. See the readme file.")

    opts = dict(opts)

    # colors
    color0 = decode_color_code(opts.get("--color0", DEFAULT_PALETTE[0]))
    color1 = decode_color_code(opts.get("--color1", DEFAULT_PALETTE[1]))
    color2 = decode_color_code(opts.get("--color2", DEFAULT_PALETTE[2]))
    color3 = decode_color_code(opts.get("--color3", DEFAULT_PALETTE[3]))
    palette = (color0, color1, color2, color3)
    if len(set(palette)) < 4:
        exit("Error: the colors are not distinct.")

    # source file
    source = args[0]
    if not os.path.isfile(source):
        exit("Error: the input file does not exist.")

    # target file
    target = args[1]
    if os.path.exists(target):
        exit("Error: the output file already exists.")
    dir = os.path.dirname(target)
    if dir != "" and not os.path.isdir(dir):
        exit("Error: the output directory does not exist.")

    return {
        "palette": palette,
        "source": source,
        "target": target,
    }

def pixel_rows_RGB_to_CHR(pixelRows, settings):
    """Convert PNG pixel rows from RGB triplets to CHR colors (0-3)."""

    # RGB triplet -> CHR color
    tripletToChrColor = dict(
        (triplet, i) for (i, triplet) in enumerate(settings["palette"])
    )

    chrColors = []
    for pixelRow in pixelRows:
        chrColors.clear()
        for pos in range(0, len(pixelRow), 3):
            triplet = tuple(pixelRow[pos:pos+3])
            try:
                chrColor = tripletToChrColor[triplet]
            except KeyError:
                exit("Error: unknown color {:s} in the input file.".format(
                    "".join(format(comp, "02x") for comp in triplet)
                ))
            chrColors.append(chrColor)
        yield chrColors

def encode_character(slice):
    """Convert a one-pixel-tall character slice from 2-bit values to
    a low byte and a high byte."""

    loByte = 0
    hiByte = 0
    for value in slice:
        loByte <<= 1
        hiByte <<= 1
        loByte |= value & 1
        hiByte |= value >> 1
    return (loByte, hiByte)

def generate_character_rows(pixelRows, settings):
    """Convert PNG pixel rows to CHR data rows."""

    for (y, pixelRow) in enumerate(pixel_rows_RGB_to_CHR(pixelRows, settings)):
        # initialize CHR data row every CHAR_HEIGHT pixel rows
        if y % CHAR_HEIGHT == 0:
            chrData = bytearray(CHARS_PER_ROW * BYTES_PER_CHAR)
        # encode pixel row and save bytes to CHR data
        for charX in range(CHARS_PER_ROW):
            charSlice = pixelRow[charX * 8 : (charX+1) * 8]
            (loByte, hiByte) = encode_character(charSlice)
            pos = charX * BYTES_PER_CHAR + y % CHAR_HEIGHT
            chrData[pos] = loByte
            chrData[pos + 8] = hiByte
        # yield CHR data row after every CHAR_HEIGHT pixel rows
        if y % CHAR_HEIGHT == CHAR_HEIGHT - 1:
            yield chrData

def main():
    settings = parse_arguments()

    with open(settings["source"], "rb") as source:
        source.seek(0)
        (width, height, pixelRows, metadata) = png.Reader(source).asRGB8()
        if width != CHARS_PER_ROW * CHAR_WIDTH:
            exit("Error: the width of the input file is invalid.")
        (charRowCount, remainder) = divmod(height, CHAR_HEIGHT)
        if charRowCount == 0 or remainder:
            exit("Error: the height of the input file is invalid.")

        with open(settings["target"], "wb") as target:
            target.seek(0)
            for chrDataRow in generate_character_rows(pixelRows, settings):
                target.write(chrDataRow)

if __name__ == "__main__":
    main()
