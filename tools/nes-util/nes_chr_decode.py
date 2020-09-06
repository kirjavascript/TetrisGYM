"""Convert NES CHR data into a PNG file."""

import argparse
import itertools
import os
import sys
from PIL import Image  # Pillow
import ineslib
import neslib

def parse_arguments():
    """Parse and validate command line arguments using argparse."""

    parser = argparse.ArgumentParser(
        description="Convert NES CHR (graphics) data into a PNG file.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument(
        "-p", "--palette", nargs=4, default=("000000", "555555", "aaaaaa", "ffffff"),
        help="Output palette (which colors correspond to CHR colors 0-3). Four 6-digit hexadecimal "
        "RRGGBB color codes (\"000000\"-\"ffffff\") separated by spaces."
    )
    parser.add_argument(
        "input_file",
        help="The file to read. Either a raw NES CHR data file (the size must be a multiple of 256 "
        "bytes) or an iNES ROM file (.nes) to read CHR ROM data from."
    )
    parser.add_argument(
        "output_file",
        help="The PNG image file to write. Its width will be 128 pixels, height a multiple of 8 "
        "pixels. It will have 1-4 unique colors."
    )

    args = parser.parse_args()

    if not os.path.isfile(args.input_file):
        sys.exit("Input file not found.")
    if os.path.exists(args.output_file):
        sys.exit("Output file already exists.")

    return args

def decode_color_code(color):
    """Decode a 6-digit hexadecimal color code. Return (R, G, B)."""

    try:
        if len(color) != 6:
            raise ValueError
        color = int(color, 16)
    except ValueError:
        sys.exit("Invalid command line color argument.")
    return (color >> 16, (color >> 8) & 0xff, color & 0xff)

def decode_pixel_rows(source, charRowCount):
    """in: NES character data file
    yield: one pixel row per call (128*1 px, 2-bit values)"""

    indexedPixelRow = []
    for i in range(charRowCount):
        charDataRow = source.read(256)
        for pxY in range(8):
            indexedPixelRow.clear()
            for charX in range(16):
                i = charX * 16 + pxY
                bitplanes = (charDataRow[i], charDataRow[i+8])  # LSBs, MSBs
                indexedPixelRow.extend(neslib.decode_tile_slice(*bitplanes))
            yield indexedPixelRow

def get_CHR_data_position(handle):
    """Get the start address and size of CHR data in the file. Return (address, size)."""

    # raw CHR data?
    fileSize = handle.seek(0, 2)
    if fileSize > 0 and fileSize % 256 == 0:
        return (0, fileSize)

    # iNES ROM file?
    try:
        iNESInfo = ineslib.parse_iNES_header(handle)
    except ineslib.iNESError as error:
        sys.exit(
            "The input file is neither a valid iNES ROM file (error: {:s}) nor valid raw CHR data "
            "(invalid file size).".format(str(error))
        )
    if iNESInfo["CHRSize"] == 0:
        sys.exit("The iNES file has no CHR ROM.")
    return (16 + iNESInfo["trainerSize"] + iNESInfo["PRGSize"], iNESInfo["CHRSize"])

def decode_file(source, palette):
    """Convert NES CHR data into a Pillow image."""

    (CHRStart, CHRSize) = get_CHR_data_position(source)
    charRowCount = CHRSize // 256  # 16 characters/row

    img = Image.new("P", (128, charRowCount * 8), 0)
    img.putpalette(itertools.chain.from_iterable(palette))

    source.seek(CHRStart)
    for (y, pixelRow) in enumerate(decode_pixel_rows(source, charRowCount)):
        for (x, value) in enumerate(pixelRow):
            img.putpixel((x, y), value)

    return img

def main():
    """The main function."""

    settings = parse_arguments()
    palette = tuple(decode_color_code(color) for color in settings.palette)
    try:
        # decode
        with open(settings.input_file, "rb") as source:
            img = decode_file(source, palette)
        # save
        with open(settings.output_file, "wb") as target:
            target.seek(0)
            img.save(target, "png")
    except OSError:
        sys.exit("Error reading/writing files.")

if __name__ == "__main__":
    main()
