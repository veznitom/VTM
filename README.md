# VTM (Veznik Tomas Microarchitecture)
Expansion and continuing of the bachelor thesis RISC-V Superscalar Processor. (https://gitlab.fit.cvut.cz/veznitom/bakalarsky-projekt)

## Requirements
1. [Python 3.10>=](https://www.python.org/downloads/)
2. riscv64-unknown-elf-gcc
3. riscv64-unknown-elf-binutils
4. [Git](https://git-scm.com/downloads)
5. [Cmake](https://cmake.org/download/)

## Installation
```
git clone https://gitlab.fit.cvut.cz/veznitom/VTM-official
cd VTM-official
git submodule update --init --recursive
./build-tests.sh
python3.x elfhex.py
```
