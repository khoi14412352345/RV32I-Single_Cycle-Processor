module main_decoder (
    input  wire [4:0] opcode_eff,
    output reg  [2:0] ImmSel,
    output reg        RegWEn,
    output reg        ASel,
    output reg        BSel,
    output reg        MemRW,
    output reg  [1:0] WBSel,
    output reg        Branch,
    output reg        Jump
);

    // Immediate formats used by Immediate_Generator.
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_J = 3'b011;
    localparam IMM_U = 3'b100;

    // Write-back source selection used by RISCV_Single_Cycle.v.
    localparam WB_MEM = 2'b00;
    localparam WB_ALU = 2'b01;
    localparam WB_PC4 = 2'b10;

    // instruction[6:2] values. The low two opcode bits are always 2'b11
    // for the 32-bit base instructions supported by this processor.
    localparam OP_LOAD   = 5'b00000;
    localparam OP_IMM    = 5'b00100;
    localparam OP_AUIPC  = 5'b00101;
    localparam OP_STORE  = 5'b01000;
    localparam OP_REG    = 5'b01100;
    localparam OP_LUI    = 5'b01101;
    localparam OP_BRANCH = 5'b11000;
    localparam OP_JALR   = 5'b11001;
    localparam OP_JAL    = 5'b11011;

    always @(*) begin
        // Safe defaults for unsupported or invalid opcodes.
        ImmSel = IMM_I;
        RegWEn = 1'b0;
        ASel   = 1'b0;
        BSel   = 1'b0;
        MemRW  = 1'b0;
        WBSel  = WB_ALU;
        Branch = 1'b0;
        Jump   = 1'b0;

        case (opcode_eff)
            OP_LOAD: begin
                ImmSel = IMM_I;
                RegWEn = 1'b1;
                ASel   = 1'b0;
                BSel   = 1'b1;
                WBSel  = WB_MEM;
            end

            OP_STORE: begin
                ImmSel = IMM_S;
                ASel   = 1'b0;
                BSel   = 1'b1;
                MemRW  = 1'b1;
            end

            OP_REG: begin
                RegWEn = 1'b1;
                ASel   = 1'b0;
                BSel   = 1'b0;
                WBSel  = WB_ALU;
            end

            OP_IMM: begin
                ImmSel = IMM_I;
                RegWEn = 1'b1;
                ASel   = 1'b0;
                BSel   = 1'b1;
                WBSel  = WB_ALU;
            end

            OP_BRANCH: begin
                ImmSel = IMM_B;
                ASel   = 1'b1;
                BSel   = 1'b1;
                Branch = 1'b1;
            end

            OP_JAL: begin
                ImmSel = IMM_J;
                RegWEn = 1'b1;
                ASel   = 1'b1;
                BSel   = 1'b1;
                WBSel  = WB_PC4;
                Jump   = 1'b1;
            end

            OP_JALR: begin
                ImmSel = IMM_I;
                RegWEn = 1'b1;
                ASel   = 1'b0;
                BSel   = 1'b1;
                WBSel  = WB_PC4;
                Jump   = 1'b1;
            end

            OP_AUIPC: begin
                ImmSel = IMM_U;
                RegWEn = 1'b1;
                ASel   = 1'b1;
                BSel   = 1'b1;
                WBSel  = WB_ALU;
            end

            OP_LUI: begin
                ImmSel = IMM_U;
                RegWEn = 1'b1;
                ASel   = 1'b0;
                BSel   = 1'b1;
                WBSel  = WB_ALU;
            end

            default: begin
                // Retain the safe defaults.
            end 
        endcase
    end

endmodule
