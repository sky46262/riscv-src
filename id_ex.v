`include "defines.v"
module id_ex(
	input	wire 			clk,
	input	wire 			rst,

	input 	wire[5:0] 				stall,
	input 	wire[`Reg_Bus]			id_pc,
	input 	wire[`Op_Bus] 			id_op,
	input	wire[`Funct3_Bus] 		id_funct3,
	input 	wire		 			id_funct7,
	input 	wire[`Reg_Bus]			id_reg1,
	input 	wire[`Reg_Bus] 			id_reg2,
	input 	wire[`Reg_AddrBus]		id_wd,
	input 	wire 					id_wreg,
	input 	wire[`Reg_Bus] 			id_imm,

	output 	reg[`Reg_Bus]		ex_pc,
	output 	reg[`Op_Bus]		ex_op,
	output 	reg[`Funct3_Bus]	ex_funct3,
	output 	reg					ex_funct7,
	output 	reg[`Reg_Bus] 		ex_reg1,
	output 	reg[`Reg_Bus] 		ex_reg2,
	output	reg[`Reg_AddrBus]	ex_wd,
	output 	reg	 				ex_wreg,
	output 	reg[`Reg_Bus] 		ex_imm
);

	always @(posedge clk) begin
		if (rst) begin
			ex_pc <= `Zero_Word;
			ex_op <= `NOP_CODE;
			ex_funct7 <= `Null_FUNCT7;
			ex_funct3 <= `Null_FUNCT3;
			ex_reg1 <= `Zero_Word;
			ex_reg2 <= `Zero_Word;
			ex_wd <= `Null_RegAddr;
			ex_wreg <= `Disabled;
			ex_imm <= `Zero_Word;
		end 
		else if (!stall[2]) begin
			ex_pc <= id_pc;
			ex_op <= id_op;
			ex_funct7 <= id_funct7;
			ex_funct3 <= id_funct3;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
			ex_imm <= id_imm;
		end
		else if (stall[2] && !stall[3]) begin
			ex_pc <= `Zero_Word;
			ex_op <= `NOP_CODE;
			ex_funct7 <= `Null_FUNCT7;
			ex_funct3 <= `Null_FUNCT3;
			ex_reg1 <= `Zero_Word;
			ex_reg2 <= `Zero_Word;
			ex_wd <= `Null_RegAddr;
			ex_wreg <= `Disabled;
			ex_imm <= `Zero_Word;
		end
	end

endmodule