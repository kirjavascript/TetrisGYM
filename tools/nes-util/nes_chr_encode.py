"""Convert an image file into an NES CHR data file."""

import argparse
import os
import sys
from PIL import Image  # Pillow
import neslib

def decode_color_code(color):
    """Decode a 6-digit hexadecimal color code. Return (R, G, B)."""

    try:
        if len(color) != 6:
            raise ValueError
        color = int(color, 16)
    except ValueError:
        sys.exit("Invalid hexadecimal color code.")
    return (color >> 16, (color >> 8) & 0xff, color & 0xff)

def parse_arguments():
    """Parse and validate command line arguments using argparse."""

    parser = argparse.ArgumentParser(
        description="Convert an image file into an NES CHR (graphics) data file.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument(
        "-p", "--palette", nargs=4, default=("000000", "555555", "aaaaaa", "ffffff"),
        help="PNG palette (which colors correspond to CHR colors 0-3). Four 6-digit hexadecimal "
        "RRGGBB color codes (\"000000\"-\"ffffff\") separated by spaces. Must be all distinct."
    )
    parser.add_argument(
        "input_file",
        help="The image file to read (e.g. PNG). The width must be 128 pixels. The height must be "
        "a multiple of 8 pixels. There must be four unique colors or less. --palette must contain "
        "all the colors in the image, but the image need not contain all the colors in --palette."
    )
    parser.add_argument(
        "output_file",
        help="The NES CHR data file to write. The size will be a multiple of 256 bytes."
    )

    args = parser.parse_args()

    if not os.path.isfile(args.input_file):
        sys.exit("Input file not found.")
    if os.path.exists(args.output_file):
        sys.exit("Output file already exists.")
    if len(set(decode_color_code(c) for c in args.palette)) < 4:
        sys.exit("All colors in --palette must be distinct.")

    return args

def validate_number_of_colors(img):
    """Make sure the image has four unique colors or less."""

    if img.mode in ("P", "L"):
        # count indexes or shades of gray
        histogram = img.histogram()
        if sum(1 for i in range(256) if histogram[i]) > 4:
            sys.exit("Too many unique indexes or shades of gray.")
    else:
        # count color from every pixel
        colors = set()
        for y in range(img.height):
            for x in range(img.width):
                colors.add(img.getpixel((x, y)))
                if len(colors) > 4:
                    sys.exit("Too many unique colors.")

def reorder_palette(img, paletteArg):
    """Reorder the image palette. paletteArg: colors from command line arguments."""

    oldPalette = img.getpalette()
    oldPalette = [tuple(oldPalette[i*3:i*3+3]) for i in range(256)]  # [(R, G, B), ...]

    paletteArg = [decode_color_code(c) for c in paletteArg]  # [(R, G, B), ...]

    # make sure all image colors are defined
    histogram = img.histogram()
    undefinedColors = set(oldPalette[i] for i in range(256) if histogram[i]) - set(paletteArg)
    if undefinedColors:
        sys.exit(
            "The following color(s) in the image are not defined by --palette: " +
            ", ".join("{:02x}{:02x}{:02x}".format(*RGB) for RGB in sorted(undefinedColors))
        )

    # map new indexes 0-3 to colors in the command line argument
    return img.remap_palette(oldPalette.index(c) for c in paletteArg)

def prepare_image(img, palette):
    """Validate and prepare an image for converting it into NES CHR data.
    palette: from command line arguments"""

    # validate image
    if img.width != 128:
        sys.exit("Invalid image width.")
    if img.height == 0 or img.height % 8:
        sys.exit("Invalid image height.")
    if img.mode not in ("P", "L", "RGB"):
        sys.exit('The mode of the image must be "P", "L" or "RGB".')
    validate_number_of_colors(img)

    # convert grayscale/RGB image into indexed color
    if img.mode in ("L", "RGB"):
        img = img.convert("P", dither=Image.NONE, palette=Image.ADAPTIVE)

    # reorder image palette
    return reorder_palette(img, palette)

def encode_image(img):
    """in: Pillow Image (width 128, height 8n, 2-bit palette)
    yield: one NES CHR data row (16*1 characters, 256 bytes) for every 128*8 pixels"""

    charData = bytearray(256)
    for y in range(img.height):
        for charX in range(16):
            # encode 8*1 pixels of one character into two bytes
            charSlice = tuple(img.getpixel((charX * 8 + x, y)) for x in range(8))
            targetPos = charX * 16 + y % 8
            # LSBs, MSBs
            (charData[targetPos], charData[targetPos+8]) = neslib.encode_tile_slice(charSlice)
        if y % 8 == 7:
            yield charData

def main():
    """The main function."""

    args = parse_arguments()
    try:
        with open(args.input_file, "rb") as source:
            # open and prepare image
            source.seek(0)
            img = Image.open(source)
            img = prepare_image(img, args.palette)
            # encode image
            with open(args.output_file, "wb") as target:
                target.seek(0)
                for chrDataRow in encode_image(img):
                    target.write(chrDataRow)
    except OSError:
        sys.exit("Error reading/writing files.")

if __name__ == "__main__":
    main()
