module mem_wb(
	input 	wire 		clk,
	input 	wire 		rst,
	input 	wire[5:0] 	stall,

	input 	wire[`Reg_AddrBus] 	mem_wd;
	input 	wire  				mem_wreg;
	input 	wire[`Reg_Bus] 		mem_wdata;

	output 	reg[`Reg_AddrBus] 	wb_wd;
	output 	reg 				wb_wreg;
	output 	reg[`Reg_Bus] 		wb_wdata;
);

	always @(posedge clk) begin
		if (rst) begin
			wb_wd <= `Null_RegAddr;
			wb_wreg <= `Disabled;
			wb_wdata <= `Zero_Word;
		end
		else if (!stall[4]) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
		end else begin
			wb_wd <= `Null_RegAddr;
			wb_wreg <= `Disabled;
			wb_wdata <= `Zero_Word;
		end
	end