`include "defines.v"
module regfile(
	input 	wire 				clk,
	input	wire				rst,

	input 	wire				we,
	input 	wire[`Reg_AddrBus]	waddr,
	input 	wire[`Reg_Bus] 		wdata,

	input 	wire 				re1,
	input 	wire[`Reg_AddrBus]	raddr1,
	output 	reg[`Reg_Bus]		rdata1,

	input 	wire 				re2,
	input 	wire[`Reg_AddrBus]	raddr2,
	output 	reg[`Reg_Bus]		rdata2
);

	reg[`Reg_Bus]			regs[0:`Reg_Num - 1];

	always @(posedge clk) begin
		if (rst) begin
			regs[0] <= `Zero_Word;
		end
	end

	//write 
	always @(*) begin
		if (!rst) begin
			if (we && (waddr != 5'h0)) begin
				regs[waddr] <= wdata;
			end
		end	
	end

	//read1
	always @(*) begin
		if (rst) begin
			rdata1 <= `Zero_Word;
		end else if (raddr1 == 5'h0) begin
			rdata1 <= `Zero_Word;
		end else if ((raddr1 == waddr) && we && re1) begin
			rdata1 <= wdata;
		end else if (re1) begin
			rdata1 <= regs[raddr1];
		end else begin
			rdata1 <= `Zero_Word;
		end
	end

	//read2
	always @(*) begin
		if (rst) begin
			rdata2 <= `Zero_Word;
		end else if (raddr2 == 5'h0) begin
			rdata2 <= `Zero_Word;
		end else if ((raddr2 == waddr) && we && re2) begin
			rdata2 <= wdata;
		end else if (re2) begin
			rdata2 <= regs[raddr1];
		end else begin
			rdata2 <= `Zero_Word;
		end
	end

endmodule
