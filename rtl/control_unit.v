module control_unit (
    input  wire [4:0] opcode_eff,
    input  wire       funct7_if,
    input  wire [2:0] funct3,
    input  wire       BrEq,
    input  wire       BrLT,
    output wire       PCSel,
    output wire [2:0] ImmSel,
    output wire       RegWEn,
    output wire       BrUn,
    output wire       ASel,
    output wire       BSel,
    output wire [3:0] ALUSel,
    output wire       MemRW,
    output wire [1:0] WBSel
);

    wire Branch;
    wire Jump;
    reg  BranchTaken;

    main_decoder Main_decoder_inst (
        .opcode_eff (opcode_eff),
        .ImmSel     (ImmSel),
        .RegWEn     (RegWEn),
        .ASel       (ASel),
        .BSel       (BSel),
        .MemRW      (MemRW),
        .WBSel      (WBSel),
        .Branch     (Branch),
        .Jump       (Jump)
    );

    ALU_decoder ALU_decoder_inst (
        .opcode_eff (opcode_eff),
        .funct7_if  (funct7_if),
        .funct3     (funct3),
        .ALUSel     (ALUSel)
    );

    // BLTU and BGEU request an unsigned comparison. BrUn is kept low
    // for every non-branch instruction.
    assign BrUn = Branch && funct3[1];

    always @(*) begin
        BranchTaken = 1'b0;

        if (Branch) begin
            case (funct3)
                3'b000: BranchTaken =  BrEq; // BEQ
                3'b001: BranchTaken = ~BrEq; // BNE
                3'b100: BranchTaken =  BrLT; // BLT
                3'b101: BranchTaken = ~BrLT; // BGE
                3'b110: BranchTaken =  BrLT; // BLTU
                3'b111: BranchTaken = ~BrLT; // BGEU
                default: BranchTaken = 1'b0;
            endcase
        end
    end

    assign PCSel = Jump || BranchTaken;

endmodule
