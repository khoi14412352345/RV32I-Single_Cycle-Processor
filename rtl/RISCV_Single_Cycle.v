module RISCV_Single_Cycle (
	input wire clk,
	input wire rst_n
);
	wire [31:0] PC_in_top, PC_out_top, Instruction_out_top, PC_Plus4_top;
	wire [31:0] Addr_instr_mem;
	wire [31:0] DataA_top, DataB_top, DataD_top, ALU_out_top, Imm_top;
	wire [31:0] Mux_ALU_DataA_top, Mux_ALU_DataB_top, DataR_top;
	reg  [31:0] LoadData_top, StoreData_top;
	wire [7:0] LoadByte_top;
	wire [15:0] LoadHalf_top;
	wire [3:0] ALUSel_top;
	wire PCSel_top, RegWEn_top, MemRW_top, Asel_top, Bsel_top;
	wire BrUn_top, BrEq_top, BrLt_top;
	wire [1:0] WBSel_top;
	wire [2:0] ImmSel_top;
	wire IsJALR_top;

	assign IsJALR_top = (Instruction_out_top[6:0] == 7'b1100111);

	assign PC_in_top = PCSel_top ? (IsJALR_top ? {ALU_out_top[31:1], 1'b0} : ALU_out_top) : PC_Plus4_top;

	assign PC_Plus4_top = PC_out_top + 32'd4;
	assign Mux_ALU_DataA_top = Asel_top ? PC_out_top : DataA_top;
	assign Mux_ALU_DataB_top = Bsel_top ? Imm_top : DataB_top;

	assign LoadByte_top = (ALU_out_top[1:0] == 2'b00) ? DataR_top[7:0] :
						  (ALU_out_top[1:0] == 2'b01) ? DataR_top[15:8] :
						  (ALU_out_top[1:0] == 2'b10) ? DataR_top[23:16] :
													DataR_top[31:24];

	assign LoadHalf_top = ALU_out_top[1] ? DataR_top[31:16] :
											 DataR_top[15:0];

	// RV32I loads are little-endian. funct3 selects the loaded width and
	// whether the byte/halfword is sign-extended or zero-extended.
	always @(*) begin
		case (Instruction_out_top[14:12])
			3'b000: LoadData_top = {{24{LoadByte_top[7]}}, LoadByte_top}; // LB
			3'b001: LoadData_top = {{16{LoadHalf_top[15]}}, LoadHalf_top}; // LH
			3'b010: LoadData_top = DataR_top;                              // LW
			3'b100: LoadData_top = {24'b0, LoadByte_top};                  // LBU
			3'b101: LoadData_top = {16'b0, LoadHalf_top};                  // LHU
			default: LoadData_top = DataR_top;
		endcase
	end

	// DMEM stores complete words. For SB and SH, merge the selected part of
	// rs2 with the old memory word before the rising-edge write.
	always @(*) begin
		StoreData_top = DataB_top;
		case (Instruction_out_top[14:12])
			3'b000: begin // SB
				case (ALU_out_top[1:0])
					2'b00: StoreData_top = {DataR_top[31:8], DataB_top[7:0]};
					2'b01: StoreData_top = {DataR_top[31:16], DataB_top[7:0], DataR_top[7:0]};
					2'b10: StoreData_top = {DataR_top[31:24], DataB_top[7:0], DataR_top[15:0]};
					2'b11: StoreData_top = {DataB_top[7:0], DataR_top[23:0]};
				endcase
			end
			3'b001: begin // SH; naturally aligned offsets are 0 and 2
				if (ALU_out_top[1])
					StoreData_top = {DataB_top[15:0], DataR_top[15:0]};
				else
					StoreData_top = {DataR_top[31:16], DataB_top[15:0]};
			end
			default: StoreData_top = DataB_top; // SW
		endcase
	end

	assign DataD_top = (WBSel_top == 2'b00) ? LoadData_top :
					   (WBSel_top == 2'b01) ? ALU_out_top :
					   PC_Plus4_top;

	assign Addr_instr_mem = {2'b0, PC_out_top[31:2]};

	control_unit Control_logic_inst (
	.opcode_eff (Instruction_out_top[6:2]),
	.funct7_if  (Instruction_out_top[30]),
	.funct3     (Instruction_out_top[14:12]),
	.BrEq       (BrEq_top),
	.BrLT       (BrLt_top),
	.PCSel      (PCSel_top),
	.ImmSel     (ImmSel_top),
	.RegWEn     (RegWEn_top),
	.BrUn       (BrUn_top),
	.ASel       (Asel_top),
	.BSel       (Bsel_top),
	.ALUSel     (ALUSel_top),
	.MemRW      (MemRW_top),
	.WBSel      (WBSel_top)
	);

	Program_Counter PC_inst (
	.clk    (clk),
	.rst_n  (rst_n),
	.PC_in  (PC_in_top),
	.PC_out (PC_out_top)
	);

	Instruction_Memory IMEM_inst (
	.addr (Addr_instr_mem),
	.inst (Instruction_out_top)
	);

	Immediate_Generator Imm_Gen_inst (
	.Inst   (Instruction_out_top),
	.ImmSel (ImmSel_top),
	.Imm    (Imm_top)
	);

	RegisterFile Reg_inst (
	.clk       (clk),
	.reset     (rst_n),
	.addrA     (Instruction_out_top[19:15]),
	.addrB     (Instruction_out_top[24:20]),
	.addrD     (Instruction_out_top[11:7]),
	.dataD     (DataD_top),
	.reg_write (RegWEn_top),
	.dataA     (DataA_top),
	.dataB     (DataB_top)
	);

	Branch_Comp Branch_Comp_inst (
	.operand_0 (DataA_top),
	.operand_1 (DataB_top),
	.BrUn      (BrUn_top),
	.BrEq      (BrEq_top),
	.BrLT      (BrLt_top)
	);

	ALU ALU_mod_inst (
	.operand_0 (Mux_ALU_DataA_top),
	.operand_1 (Mux_ALU_DataB_top),
	.ALU_Sel   (ALUSel_top),
	.result    (ALU_out_top)
	);

	Data_Memory DMEM_inst (
	.clk   (clk),
	.MemRW (MemRW_top),
	.addr  (ALU_out_top),
	.DataW (StoreData_top),
	.DataR (DataR_top)
	);

endmodule
