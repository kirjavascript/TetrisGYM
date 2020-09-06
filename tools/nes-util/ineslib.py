"""A library for parsing/encoding iNES ROM files (.nes).
See http://wiki.nesdev.com/w/index.php/INES"""

_INES_ID = b"NES\x1a"

# Smallest possible PRG ROM bank sizes for mappers in KiB (32 = no bankswitching).
# Source: http://wiki.nesdev.com/w/index.php/List_of_mappers
# These are the mappers used by at least three games among my 1951 verified good dumps ("[!]"),
# except that mapper 215 is omitted because I'm not sure about it.
_MIN_PRG_BANK_SIZES_KIB = {
    0: 32,  # NROM
    1: 16,  # SxROM, MMC1
    2: 16,  # UxROM
    3: 32,  # CNROM
    4: 8,  # TxROM, MMC3, MMC6
    5: 8,  # ExROM, MMC5
    7: 32,  # AxROM
    9: 8,  # PxROM, MMC2
    10: 16,  # FxROM, MMC4
    11: 32,  # Color Dreams
    15: 8,  # 100-in-1 Contra Function 16
    16: 16,  # some Bandai FCG boards
    18: 8,  # Jaleco SS8806
    19: 8,  # Namco 163
    23: 8,  # VRC2b, VRC4e
    25: 8,  # VRC4b, VRC4d
    33: 8,  # Taito TC0190
    34: 32,  # BNROM, NINA-001
    64: 8,  # RAMBO-1
    66: 32,  # GxROM, MxROM
    69: 8,  # FME-7, Sunsoft 5B
    70: 16,  # (unnamed)
    71: 16,  # Camerica/Codemasters
    75: 8,  # VRC1
    79: 32,  # NINA-003/NINA-006
    80: 8,  # Taito X1-005
    83: 8,  # Cony/Yoko
    87: 32,  # (unnamed)
    88: 8,  # (unnamed)
    90: 8,  # J.Y. Company ASIC
    91: 8,  # (unnamed)
    99: 8,  # (used by Vs. System games)
    112: 8,  # (unnamed)
    113: 32,  # NINA-003/NINA-006??
    115: 16,  # Kasheng SFC-02B/-03/-004
    118: 8,  # TxSROM, MMC3
    119: 8,  # TQROM, MMC3
    139: 32,  # Sachen 8259
    141: 32,  # Sachen 8259
    146: 32,  # NINA-003-006
    148: 32,  # Sachen SA-008-A / Tengen 800008
    150: 32,  # Sachen SA-015/SA-630
    163: 32,  # Nanjing
    185: 32,  # CNROM with protection diodes
    196: 8,  # MMC3 variant
    209: 8,  # Jingtai / J.Y. Company ASIC
    232: 16,  # Camerica/Codemasters Quattro
    234: 32,  # Maxi 15 multicart
    243: 32,  # Sachen SA-020A
}

class iNESError(Exception):
    """An exception for iNES file format related errors."""

def get_mapper_PRG_bank_size(mapper):
    """Get the smallest PRG ROM bank size the mapper supports (8 KiB for unknown mappers).
    mapper: iNES mapper number (0-255)
    return: bank size in bytes (8/16/32 KiB)"""

    return _MIN_PRG_BANK_SIZES_KIB.get(mapper, 8) * 1024

def get_PRG_bank_size(fileInfo):
    """Get PRG ROM bank size of an iNES file. (The result may be too small.)
    fileInfo: from parse_iNES_header()
    return: bank size in bytes (8/16/32 KiB)"""

    return min(get_mapper_PRG_bank_size(fileInfo["mapper"]), fileInfo["PRGSize"])

def is_PRG_bankswitched(fileInfo):
    """Does the iNES file use PRG ROM bankswitching? (May give false positives.)
    fileInfo: from parse_iNES_header()"""

    return fileInfo["PRGSize"] > get_mapper_PRG_bank_size(fileInfo["mapper"])

def parse_iNES_header(handle):
    """Parse an iNES header. Return a dict. On error, raise an exception with an error message."""

    if handle.seek(0, 2) < 16:
        raise iNESError("file_smaller_than_ines_header")

    # read the header, extract fields
    handle.seek(0)
    header = handle.read(16)
    (id_, PRGSize16KiB, CHRSize8KiB, flags6, flags7) \
    = (header[0:4], header[4], header[5], header[6], header[7])

    # validate id
    if id_ != _INES_ID:
        raise iNESError("invalid_id")

    # get the size of PRG ROM, CHR ROM and trainer
    PRGSize = (PRGSize16KiB if PRGSize16KiB else 256) * 16 * 1024
    CHRSize = CHRSize8KiB * 8 * 1024
    trainerSize = bool(flags6 & 0x04) * 512

    # validate file size
    if handle.seek(0, 2) < 16 + trainerSize + PRGSize + CHRSize:
        raise iNESError("file_too_small")

    # get type of name table mirroring
    if flags6 & 0x08:
        mirroring = "four-screen"
    elif flags6 & 0x01:
        mirroring = "vertical"
    else:
        mirroring = "horizontal"

    return {
        "PRGSize": PRGSize,
        "CHRSize": CHRSize,
        "mapper": (flags7 & 0xf0) | (flags6 >> 4),
        "mirroring": mirroring,
        "trainerSize": trainerSize,
        "saveRAM": bool(flags6 & 0x02),
    }

def create_iNES_header(PRGSize, CHRSize, mapper=0, mirroring="h", saveRAM=False):
    """Return a 16-byte iNES header as bytes. On error, raise an exception with an error message.
    PRGSize: PRG ROM size (16 * 1024 to 4096 * 1024 and a multiple of 16 * 1024)
    CHRSize: CHR ROM size (0 to 2040 * 1024 and a multiple of 8 * 1024)
    mapper: mapper number (0-255)
    mirroring: name table mirroring ('h'=horizontal, 'v'=vertical, 'f'=four-screen)
    saveRAM: does the game have save RAM"""

    # get PRG ROM size in 16-KiB units; encode 256 as 0
    (PRGSize16KiB, remainder) = divmod(PRGSize, 16 * 1024)
    if not 1 <= PRGSize16KiB <= 256 or remainder:
        raise iNESError("invalid_prg_rom_size")
    PRGSize16KiB %= 256

    # get CHR ROM size in 8-KiB units
    (CHRSize8KiB, remainder) = divmod(CHRSize, 8 * 1024)
    if not 0 <= CHRSize8KiB <= 255 or remainder:
        raise iNESError("invalid_chr_rom_size")

    # encode flags
    flags6 = (mapper & 0x0f) << 4
    if mirroring == "v":
        flags6 |= 0x01
    elif mirroring == "f":
        flags6 |= 0x08
    elif mirroring != "h":
        raise iNESError("invalid_mirroring_type")
    if saveRAM:
        flags6 |= 0x02
    flags7 = mapper & 0xf0

    return _INES_ID + bytes((PRGSize16KiB, CHRSize8KiB, flags6, flags7)) + 8 * b"\x00"

