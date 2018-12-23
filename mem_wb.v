`include "defines.v"
module mem_wb(
	input 	wire 		clk,
	input 	wire 		rst,
	input 	wire[5:0] 	stall,

	input 	wire[`Reg_AddrBus] 	mem_wd,
	input 	wire  				mem_wreg,
	input 	wire[`Reg_Bus] 		mem_wdata,

	input 	wire[2:0] 			mem_cnt_i,

	output 	reg[2:0] 			mem_cnt_o,

	output 	reg[`Reg_AddrBus] 	wb_wd,
	output 	reg 				wb_wreg,
	output 	reg[`Reg_Bus] 		wb_wdata
);

	always @(posedge clk) begin
		if (rst) begin
			wb_wd <= `Null_RegAddr;
			wb_wreg <= `Disabled;
			wb_wdata <= `Zero_Word;
			mem_cnt_o <= 3'b000;
		end
		else if (!stall[4]) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
			mem_cnt_o <= 3'b000;
		end else if (stall[4] && !stall[5]) begin
			wb_wd <= `Null_RegAddr;
			wb_wreg <= `Disabled;
			wb_wdata <= `Zero_Word;
			mem_cnt_o <= mem_cnt_i;
		end
		else begin
			mem_cnt_o <= mem_cnt_i;
		end
	end
endmodule