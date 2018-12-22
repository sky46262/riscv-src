module ex_mem(
	input 	wire 		clk,
	input 	wire 		rst,
	input 	wire[5:0] 	stall,

	input 	wire[`Reg_AddrBus] 	ex_wd,
	input 	wire				ex_wreg,
	input 	wire[`Reg_Bus] 		ex_wdata,

	input 	wire[`Op_Bus]			ex_op,
	input 	wire[`Funct3_Bus] 		ex_funct3,
 	input 	wire[`Reg_Bus] 			ex_mem_addr,
	input 	wire[`Reg_Bus] 			ex_reg,


	output 	reg[`Reg_AddrBus] 		mem_wd,
	output 	reg 					mem_wreg,
	output 	reg[`Reg_Bus] 			mem_wdata

	output 	reg[`Op_Bus]			mem_op,
	output 	reg[`Funct3_Bus] 		mem_funct3,
 	output 	reg[`Reg_Bus] 			mem_mem_addr,
	output 	reg[`Reg_Bus] 			mem_reg,
);

	always @(posedge clk) begin
		if (rst) begin
			mem_wd <= `Null_RegAddr;
			mem_wreg <= `Disabled;
			mem_wdata <= `Zero_Word;
			mem_op <= `NOP_CODE;
			mem_funct3 <= `Null_FUNCT3;
			mem_mem_addr <= `Zero_Word;
			mem_reg <= `Zero_Word;
		end
		else if (!stall[3]) begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;

			mem_op <= ex_op;
			mem_funct3 <= ex_funct3;
			mem_mem_addr <= ex_mem_addr;
			mem_reg <= ex_reg;
		end
		else begin
			mem_wd <= `Null_RegAddr;
			mem_wreg <= `Disabled;
			mem_wdata <= `Zero_Word;

			mem_op <= `NOP_CODE;
			mem_funct3 <= `Null_FUNCT3;
			mem_mem_addr <= `Zero_Word;
			mem_reg <= `Zero_Word;
		end
	end

endmodule