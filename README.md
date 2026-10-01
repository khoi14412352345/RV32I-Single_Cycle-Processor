# RV32I Single-Cycle Processor

This project contains the starter files and build flow for an RV32I single-cycle processor. 

## Project structure

```text
.
|-- Makefile
|-- README.md
|-- libraries/
|   |-- LEF/
|   `-- TIMING/
|-- mem/
|   |-- dmem_init.hex
|   `-- imem.hex
|-- rtl/
|   |-- ALU.v
|   |-- ALU_decoder.v
|   |-- Branch_Comp.v
|   |-- control_unit.v
|   |-- DMEM.v
|   |-- IMEM.v
|   |-- Imm_Gen.v
|   |-- main_decoder.v
|   |-- Program_Counter.v
|   |-- RegisterFile.v
|   `-- RISCV_Single_Cycle.v
|-- scripts/
|   |-- run_lec.tcl
|   |-- run_syn.tcl
|   `-- run_xmsim.tcl
|-- sw/
|   |-- crt0.S
|   |-- linker.ld
|   `-- test.c or test.S
`-- tb/
    `-- tb_RISCV_Single_Cycle.v
```

Directory roles:

- `rtl/`: processor RTL and supporting modules.
- `tb/`: the student-visible, self-checking testbench.
- `sw/`: bare-metal test program, startup code, and linker script.
- `mem/`: instruction and data memory images generated from the software.
- `scripts/`: Xcelium, Genus, and Conformal command scripts.
- `libraries/`: technology files used by synthesis and equivalence checking.

## Software test source

Keep exactly one test program in `sw/`:

- `sw/test.c` for a C test program; or
- `sw/test.S` for a RISC-V assembly test program.

Do **not** keep both files at the same time. The Makefile intentionally stops with an error if both are present. The required startup and linker files must retain their standard names:

```text
sw/crt0.S
sw/linker.ld
```

The software is compiled for `rv32i` with the `ilp32` ABI. The generated images are:

```text
mem/imem.hex
mem/dmem_init.hex
```

Each image contains **256 32-bit hexadecimal words**.

## Required tools

The complete flow uses:

- RISC-V GNU toolchain:
  - `riscv32-unknown-elf-gcc`
  - `objcopy`
  - `objdump`
  - `readelf`
  - `size`
- Cadence Xcelium
- Cadence Genus
- Cadence Conformal LEC
- Standard Linux utilities:
  - `make`
  - `dd`
  - `hexdump`

On a server that uses environment modules, load the available Cadence module before running the flow. For example:

```bash
module avail
module load xcelium/2403
```

If the RISC-V toolchain is installed under `/opt/riscv32` but is not already in `PATH`, use:

```bash
export PATH=/opt/riscv32/bin:/opt/riscv32/riscv32-unknown-elf/bin:$PATH
```

Confirm the tools before building:

```bash
make check_sw
command -v xmvlog xmelab xmsim genus lec
```

The Makefile uses **LSF** by default. On a machine where the tools are already allocated interactively or where `bsub` is unavailable, append `USE_LSF=0` to the command.

## Common commands

Show the available targets:

```bash
make help
```

Build the software and generate the memory images:

```bash
make hex
```

Generate an annotated disassembly:

```bash
make disasm
```

Compile, elaborate, and run the RTL simulation:

```bash
make run
```

`make sim` is an alias of `make run`. Both commands rebuild the HEX files when their software inputs have changed.

Open the generated waveform database in SimVision:

```bash
make wave
```

Run synthesis:

```bash
make syn
```

The clock-period sweep can be overridden from the command line:

```bash
make syn START_PERIOD=1 END_PERIOD=6 STEP=0.1
```

Run logical equivalence checking after synthesis:

```bash
make lec
```

## Remove generated files:

```bash
make clean
```

For a server without LSF, an example simulation command is:

```bash
make run USE_LSF=0
```


