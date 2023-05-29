import pathlib
import argparse
from glob import glob


def to_hex(elf_file, debug, direct):
    with open(elf_file, 'rb') as elf_read:
        hex_strings = list()
        data = elf_read.read()
        data = bytearray(data)
        for i in range(0, len(data), 4):
            tpm = (data[i] + (data[i+1] * (2 ** 8)) +
                   (data[i+2] * (2 ** 16)) + (data[i+3] * (2 ** 24)))
            hex_strings.append(
                f'{(data[i] + (data[i+1] * (2 ** 8)) + (data[i+2] * (2 ** 16)) + (data[i+3] * (2 ** 24))):08x}')
        if not direct:
            hex_strings = hex_strings[1024:]
            hex_strings.reverse()
            last = 0
            for i in range(0, len(hex_strings)):
                if (hex_strings[i] == '00000073'):
                    last = i
                    break
            hex_strings = hex_strings[last:]
            hex_strings.reverse()
        return hex_strings


def write_hex(filename, hex_strings, debug):
    with open(filename+'.hex', 'w') as hex_write:
        for line in hex_strings:
            hex_write.write(line+'\n')
        if debug:
            return f'{filename}.hex'


def convert(source, dest, debug, direct):
    elf_dir = pathlib.Path(source)
    hex_dir = pathlib.Path(dest)
    if (not elf_dir.is_dir()) or (not hex_dir.is_dir()):
        raise Exception('Not a directory.')
    elf_dir = str(elf_dir.resolve())
    hex_dir = str(hex_dir.resolve())
    elf_files = list(set(glob(elf_dir+'/rv32ui*'))-set(glob(elf_dir+'/*.hex')))
    if len(elf_files) == 0:
        raise Exception('Empty directory (no rv32ui files).')
    if debug:
        print('Source elf files:')
        for elf_file in elf_files:
            print('\t'+elf_file)
        print('\nDestination hex files:')
    for elf_file in elf_files:
        filename = pathlib.Path(elf_file).name
        tmp = write_hex(str(pathlib.Path(hex_dir, filename).resolve()),
                        to_hex(elf_file, debug, direct), debug)
        if debug:
            print('\t' + tmp)


def main():
    parser = argparse.ArgumentParser(
        prog='elf_to_hex.py',
        description='Simple convertor from an elf file to a hex file.')
    parser.add_argument('-s', '--src', action='store', default='rv32i-tests/isa/elf', dest='source',
                        help='Path to the directory with the elf files.')
    parser.add_argument('-d', '--dst', action='store', default='rv32i-tests/hex', dest='dest',
                        help='Path to the directory where for the hex files.')
    parser.add_argument('--debug', action='count', default=0, dest='debug',
                        help='Enables file location printing.')
    parser.add_argument('-c', '--custom', action='count', default=0, dest='custom',
                        help='Turns on direct conversion (use with custom elf binnary files).')
    args = parser.parse_args()
    try:
        convert(args.source, args.dest, args.debug > 0, args.custom > 0)
    except Exception as e:
        print(e)


if __name__ == "__main__":
    main()
