import argparse


def shuffle_rng(rng):
    rng_hi = rng >> 8
    rng_lo = rng & 0xFF
    newbit = ((rng_hi ^ rng_lo) & 2) << 6
    new_hi = newbit | rng_hi >> 1
    new_lo = ((rng_hi & 1) << 7) | (rng_lo >> 1)
    return new_hi << 8 | new_lo


def hex_int(arg):
    try:
        arg = arg.replace("0x", "")
        return int(arg, 16) & 0xFFFF
    except:
        raise argparse.ArgumentTypeError("requires valid hex int")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("state", type=hex_int)
    parser.add_argument("-c", "--count", type=int, default=1)
    args = parser.parse_args()
    state = args.state
    for _ in range(args.count):
        print(f"{state:04X}")
        state = shuffle_rng(state)


if __name__ == "__main__":
    main()
