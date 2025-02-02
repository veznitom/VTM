import pathlib
import argparse
from glob import glob


def to_hex(elf_file, bytes, reverse, memory, fill):
    hex = list()
    with open(elf_file, 'rb') as elf_read:
        data = elf_read.read()
        data = bytearray(data)
        data = data[4096:]
        if memory:
            hex.append(
                'memory_initialization_radix=16;\nmemory_initialization_vector=')
        for i in range(0, fill, 4):
            word = data[i:i+4].copy()
            if (reverse):
                word.reverse()
            if i < len(data):
                hex.append(
                    ''.join(f'{x:02x}{' ' if bytes and not memory else ''}' for x in word)+(',' if memory else ''))
            else:
                hex.append(
                    ''.join(f'{0:02x}{' ' if bytes and not memory else ''}' for x in range(4))+(',' if memory else ''))
    return hex


def convert(source, dest, bytes, reverse, memory, all, fill):
    source = pathlib.Path(source)
    dest = pathlib.Path(dest)
    if (source.is_dir()):
        elf_dir = str(source.resolve())
        hex_dir = str(dest.resolve())
        if all:
            elf_files = list(set(glob(elf_dir+'/*.elf')))
        else:
            elf_files = list(set(glob(elf_dir+'/rv32*.elf')))
        if len(elf_files) == 0:
            raise Exception('No *.elf files.')
        for elf_file in elf_files:
            filename = pathlib.Path(elf_file).stem
            hex = to_hex(elf_file, bytes=bytes, reverse=reverse,
                         memory=memory, fill=fill)
            file = filename + ('-b' if bytes else '') + \
                ('-r' if reverse else '') + ('.coe' if memory else '.hex')
            with open(dest.joinpath(file), 'w') as hex_write:
                for line in hex:
                    hex_write.write(line+'\n')
    elif (source.is_file()):
        filename = source.stem
        hex = to_hex(source, bytes=bytes, reverse=reverse,
                     memory=memory, fill=fill)
        file = filename + ('-b' if bytes else '') + \
            ('-r' if reverse else '') + ('.coe' if memory else '.hex')
        with open(dest.joinpath(file), 'w') as hex_write:
            for line in hex:
                hex_write.write(line+'\n')
    else:
        raise Exception('Wrong input.')


def main():
    parser = argparse.ArgumentParser(
        prog='elf_to_hex.py',
        description='Simple convertor from an elf file to a hex file.')
    parser.add_argument('-s', '--src', action='store', default='', dest='source',
                        help='Path to the source elf directory/file.')
    parser.add_argument('-d', '--dst', action='store', default='', dest='dest',
                        help='Path to the destination elf directory')
    parser.add_argument('-f', '--fill', action='store', default=0x10000, dest='fill', type=int,
                        help='Fills the rest of the file with zeros up to fill bytes.', required=False)
    parser.add_argument('-b', '--bytes', action='count', default=0, dest='bytes',
                        help='Saves instructions as 4 byte values.')
    parser.add_argument('-r', '--reverse', action='count', default=0, dest='reverse',
                        help='Flips the byte order of the instruction.')
    parser.add_argument('-m', '--memory', action='count', default=0, dest='memory',
                        help='Will format output for BRAM initialization.')
    parser.add_argument('-a', '--all', action='count', default=0, dest='all',
                        help='Patter matching will grab all ".elf" files instead "rv32*.elf" files.')
    args = parser.parse_args()
    try:
        convert(source=args.source,
                dest=args.dest,
                bytes=bool(args.bytes),
                reverse=bool(args.reverse),
                all=bool(args.all),
                memory=bool(args.memory),
                fill=args.fill)
    except Exception as e:
        print(e)


if __name__ == "__main__":
    main()
