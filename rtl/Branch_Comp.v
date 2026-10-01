module Branch_Comp (
    input  wire [31:0] operand_0,
    input  wire [31:0] operand_1,
    input  wire        BrUn,
    output wire        BrEq,
    output wire        BrLT
);

    // Equality is identical for signed and unsigned values.
    assign BrEq = (operand_0 == operand_1);

    // BrUn selects the interpretation used by BLTU/BGEU. All other
    // branch comparisons use signed two's-complement values.
    assign BrLT = BrUn
                ? (operand_0 < operand_1)
                : ($signed(operand_0) < $signed(operand_1));

endmodule
