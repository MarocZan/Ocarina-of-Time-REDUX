#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..'))

import argparse
import json
import re
from subprocess import check_call as call
from rom_diff import create_diff
from ntype import BigStream
from crc import calculate_crc

parser = argparse.ArgumentParser()
parser.add_argument('--pj64sym', help="Output path for PJ64 debugging symbols")
parser.add_argument('--compile-c', action='store_true', help="Recompile C modules")
parser.add_argument('--dump-obj', action='store_true', help="Dumps extra object info for debugging purposes. Does nothing without --compile-c")
parser.add_argument('--diff-only', action='store_true', help="Creates diff output without running armips")
parser.add_argument('--nocompress', action='store_true', help="Skip ROM compress at end of operations")
parser.add_argument('--compress32', action='store_true', help="Uses 32-bit compressor instead of 64-bit one")

args = parser.parse_args()
pj64_sym_path = args.pj64sym
compile_c = args.compile_c
dump_obj = args.dump_obj
diff_only = args.diff_only
nocompress = args.nocompress
compress32 = args.compress32

root_dir = os.path.dirname(os.path.realpath(__file__))
tools_dir = os.path.join(root_dir, 'tools')
os.environ['PATH'] = tools_dir + os.pathsep + os.environ['PATH']

run_dir = root_dir

# Compile code

os.chdir(run_dir)
if compile_c:
    clist = ['make']
    if dump_obj:
        clist.append('RUN_OBJDUMP=1')
    call(clist)

if not diff_only:
    os.chdir(run_dir + '/src')
    call(['armips', '-sym2', '../build/asm_symbols.txt', 'build.asm'])

os.chdir(run_dir)

with open('build/asm_symbols.txt', 'rb') as f:
    asm_symbols_content = f.read()
asm_symbols_content = asm_symbols_content.replace(b'\r\n', b'\n')
asm_symbols_content = asm_symbols_content.replace(b'\x1A', b'')
with open('build/asm_symbols.txt', 'wb') as f:
    f.write(asm_symbols_content)

# Parse symbols

c_sym_types = {}

with open('build/c_symbols.txt', 'r') as f:
    for line in f:
        m = re.match('''
                ^
                [0-9a-fA-F]+
                .*
                \.
                ([^\s]+)
                \s+
                [0-9a-fA-F]+
                \s+
                ([^.$][^\s]+)
                \s+$
            ''', line, re.VERBOSE)
        if m:
            sym_type = m.group(1)
            name = m.group(2)
            c_sym_types[name] = 'code' if sym_type == 'text' else 'data'

symbols = {}

with open('build/asm_symbols.txt', 'r') as f:
    for line in f:
        parts = line.strip().split(' ')
        if len(parts) < 2:
            continue
        address, sym_name = parts
        if address[0] != '8':
            continue
        if sym_name[0] in ['.', '@']:
            continue
        sym_type = c_sym_types.get(sym_name) or ('data' if sym_name.isupper() else 'code')
        symbols[sym_name] = {
            'type': sym_type,
            'address': address,
        }

# Output symbols

os.chdir(run_dir)

data_symbols = {}
for (name, sym) in symbols.items():
    if sym['type'] == 'data':
        addr = int(sym['address'], 16)
        if 0x80400000 <= addr < 0x80420000:
            addr = addr - 0x80400000 + 0x03480000
        else:
            continue
        data_symbols[name] = '{0:08X}'.format(addr)
with open('data/symbols.json', 'w') as f:
    json.dump(data_symbols, f, indent=4, sort_keys=True)

if pj64_sym_path:
    pj64_sym_path = os.path.realpath(pj64_sym_path)
    with open(pj64_sym_path, 'w') as f:
        key = lambda pair: pair[1]['address']
        for sym_name, sym in sorted(symbols.items(), key=key):
            f.write('{0},{1},{2}\n'.format(sym['address'], sym['type'], sym_name))

# Update CRC

with open('roms/patched.z64', 'r+b') as stream:
    buffer = bytearray(stream.read(0x101000))
    crc = calculate_crc(BigStream(buffer))
    stream.seek(0x10)
    stream.write(bytearray(crc))

# Patch output ROM

if not diff_only:
    try:
        os.chdir(run_dir + '/patch')
        call(['flips', '--ignore-checksum', 'patch.bps', '../roms/patched.z64'])
    except Exception:
        pass

# Diff ROMs

os.chdir(run_dir)

create_diff('roms/base.z64', 'roms/patched.z64', 'data/rom_patch.txt')

# Compress ROM

os.chdir(run_dir)

if not nocompress:
    if compress32:
        compressor_path = "Compress/Compress32.exe"
    else:
        compressor_path = "Compress/Compress.exe"
    
    call([compressor_path, 'roms/patched.z64', 'Output_ROM/Better_Ocarina_of_Time.z64'])
    os.remove('Archive.bin')
