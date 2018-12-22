module pc_reg(
	input 	wire				clk,
	input 	wire				rst,
	
	input 	wire[5:0] 			stall,
	input 	wire 				branch_flag_i,
	input 	wire[`Reg_Bus] 		branch_target_address_i,

	output	reg[`Reg_Bus]		pc,
	output  reg 				ce
);

	always @(posedge clk) begin
		if (rst) begin
			ce <= `Disabled;
		end
		else begin
			ce <= `Enabled;
		end
	end

	always @(posedge clk) begin
		if (!ce) begin
			pc <= `Zero_Word;
		end
		else if (stall[0] == `Disabled) begin
			if (branch_flag_i) begin
				pc <= branch_target_address_i;
			end
			else begin
				pc <= pc + 4'h4;
			end
		end
	end

endmodule

module regfile(
	input 	wire 				clk,
	input	wire				rst,

	input 	wire				we,
	input 	wire				waddr,
	input 	wire 				wdata,

	input 	wire 				re1,
	input 	wire[`Reg_AddrBus]	raddr1,
	output 	wire[`Reg_Bus]		rdata1,

	input 	wire 				re2,
	input 	wire[`Reg_AddrBus]	raddr2,
	output 	wire[`Reg_Bus]		rdata2,
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
