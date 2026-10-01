module ALU_decoder (
    input  wire [4:0] opcode_eff,
    input  wire       funct7_if,
    input  wire [2:0] funct3,
    output reg  [3:0] ALUSel
);

    // These values must match the operation encoding in ALU.v.
    localparam ADD_OP  = 4'h0;
    localparam SUB_OP  = 4'h1;
    localparam AND_OP  = 4'h2;
    localparam OR_OP   = 4'h3;
    localparam XOR_OP  = 4'h4;
    localparam SLL_OP  = 4'h5;
    localparam SRL_OP  = 4'h6;
    localparam SRA_OP  = 4'h7;
    localparam SLT_OP  = 4'h8;
    localparam SLTU_OP = 4'h9;
    localparam PASS_B  = 4'hA;

    // instruction[6:2] values used by the ALU decoder. LUI passes its
    // generated U-immediate through operand B without using rs1.
    localparam OP_REG = 5'b01100;
    localparam OP_IMM = 5'b00100;
    localparam OP_LUI = 5'b01101;

    always @(*) begin
        ALUSel = ADD_OP;

        if (opcode_eff == OP_LUI) begin
            ALUSel = PASS_B;
        end
        else if ((opcode_eff == OP_REG) || (opcode_eff == OP_IMM)) begin
            case (funct3)
                3'b000: begin
                    // SUB exists only in the register-register class.
                    if ((opcode_eff == OP_REG) && funct7_if)
                        ALUSel = SUB_OP;
                    else
                        ALUSel = ADD_OP;
                end

                3'b001: ALUSel = SLL_OP;
                3'b010: ALUSel = SLT_OP;
                3'b011: ALUSel = SLTU_OP;
                3'b100: ALUSel = XOR_OP;

                3'b101: begin
                    // Bit 30 distinguishes logical and arithmetic shifts
                    // for both OP and OP-IMM instructions.
                    if (funct7_if)
                        ALUSel = SRA_OP;
                    else
                        ALUSel = SRL_OP;
                end

                3'b110: ALUSel = OR_OP;
                3'b111: ALUSel = AND_OP;
                default: ALUSel = ADD_OP;
            endcase
        end
    end

endmodule
