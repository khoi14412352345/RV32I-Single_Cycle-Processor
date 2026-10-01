# VNCHIP RISCV Computer Structure

## Lab 6: RV32I Single Cycle

## Objective

In this laboratory, students design, integrate, and verify the control
path for a 32-bit RISC-V single-cycle processor. The datapath follows
the organization presented in class and in the course textbook. Students
complete the missing RTL modules, integrate them with the provided
datapath blocks, and verify the processor with self-checking programs
generated from assembly or C source code.

## Tasks

-   Design the following RTL units:
    -   Control units with decoders for the ALU and other units.
    -   **Immediate Generator** which generates immediate values based
        on the instruction encoding.
    -   **Branch Comparison** to generate the control signal for branch
        decisions.
    -   **ALU_decoder.v**
    -   **main_decoder.v**
-   The top-level design, ALU, DMEM, IMEM, register file, and PC are
    provided.
-   Design the top-level testbench and use generated software programs
    to test the core thoroughly.

Debugging HDL hardware designs requires a disciplined approach that
relies on clear cause-effect relationships. Speculative debugging often
wastes time and effort.

# 1. Lab Setup

Copy:

`/VNCHIP/TP2026/1_RTL/0_COMMON/0707_RTL_LAB/Lab6`

The RTL directory should contain:

-   ALU_decoder.v *(design)*
-   ALU.v *(provided)*
-   Branch_Comp.v *(design)*
-   control_unit.v *(design)*
-   DMEM.v *(provided)*
-   IMEM.v *(provided)*
-   Imm_Gen.v *(design)*
-   main_decoder.v *(design)*
-   Program_Counter.v *(provided)*
-   RegisterFile.v *(provided)*
-   RISCV_Single_Cycle.v *(provided)*

# 2. Hierarchy of RISCV Single Cycle Core

## 2.1 Top-level RTL

Keep `RISCV_Single_Cycle.v` exactly the same so the TA can test your
design.

## 2.2 IMEM and DMEM

Keep instruction and data memories unchanged so the TA's testbench can
load `imem.hex` and `dmem.hex`.

## 2.3 Control Unit

The control unit contains: - Main decoder - ALU decoder

It uses signals from the Branch Comparator to generate control outputs.

## 2.4 Top-level Testbench

The testbench should: - Generate clock and reset. - Load `imem.hex` and
`dmem.hex`. - Include a mechanism to verify final results automatically.

# 3. Performance Expectation

A single-cycle core completes one instruction per clock cycle regardless
of complexity. The simulation should run for the number of instructions
plus one cycle and verify the final results.

# 4. Submission

After completing the design and verification, ask a TA to test your
implementation using the golden testbench to ensure all instruction
types pass.
