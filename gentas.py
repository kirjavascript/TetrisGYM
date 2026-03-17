import argparse
import logging

logger = logging.getLogger(__name__)
OFFSET=2
INPUT_LETTERS = "RLDUTSBA"
INPUT_VALUES = dict(
    right=0x80,
    left=0x40,
    down=0x20,
    up=0x10,
    start=0x08,
    select=0x04,
    b=0x02,
    a=0x01,
)


# TASLINE = "|0|........|||"
def get_tas_line(input_byte: int):
    result = []
    result.extend("|0|")
    binary = f"{input_byte & 0xFF:08b}"
    for i, char in enumerate(binary):
        result.append(INPUT_LETTERS[i] if char == "1" else ".")
    result.extend("|||")
    return "".join(result)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("frames", type=int, help="length of tas")
    parser.add_argument(
        "-R",
        "--right",
        type=int,
        nargs="+",
        default=[],
    )
    parser.add_argument(
        "-L",
        "--left",
        type=int,
        nargs="+",
        default=[],
    )
    parser.add_argument(
        "-D",
        "--down",
        type=int,
        nargs="+",
        default=[],
    )
    parser.add_argument(
        "-U",
        "--up",
        type=int,
        nargs="+",
        default=[],
    )
    parser.add_argument(
        "-T",
        "--start",
        type=int,
        nargs="+",
        default=[],
    )
    parser.add_argument(
        "-S",
        "--select",
        type=int,
        nargs="+",
        default=[],
    )
    parser.add_argument(
        "-B",
        "--b",
        type=int,
        nargs="+",
        default=[],
    )
    parser.add_argument(
        "-A",
        "--a",
        type=int,
        nargs="+",
        default=[],
    )
    args = parser.parse_args()

    output = bytearray(args.frames)
    for label, value in INPUT_VALUES.items():
        for frame in vars(args)[label]:
            # if frame < OFFSET:
            #     raise RuntimeError(f"{frame} needs to be less than {OFFSET}")
            output[frame+OFFSET] |= value

    print('\n'.join(get_tas_line(f) for f in output))


if __name__ == "__main__":
    main()
