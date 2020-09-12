#!/usr/bin/env python3

import sys, re, subprocess

trace_filename = sys.argv[1]
elf_filename = sys.argv[2]

insns = dict()

with subprocess.Popen(["riscv32-unknown-elf-objdump", "-d", elf_filename], stdout=subprocess.PIPE) as proc:
    while True:
        line = proc.stdout.readline().decode("ascii")
        if line == '': break
        match = re.match(r'^\s*([0-9a-f]+):\s+([0-9a-f]+)\s*(.*)', line)
        if match: insns[int(match.group(1), 16)] = (int(match.group(2), 16), match.group(3).replace("\t", " "))

with open(trace_filename, "r") as f:
    for line in f:
        raw_data = int(line.replace("x", "0"), 16)
        pc = raw_data & 0xffffffff

        if pc in insns:
            insn_opcode, insn_desc = insns[pc]
            opname = insn_desc.split()[0]

            opcode_fmt = "%08x" if (insn_opcode & 3) == 3 else "    %04x"
            print(("%08x | " + opcode_fmt + " | %s") % (pc, insn_opcode, insn_desc))
        else:
            print("** NO INFORMATION ON INSN AT %08x! **" % (pc))

