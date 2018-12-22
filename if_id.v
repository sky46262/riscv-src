module if_id(
	input	wire		clk,
	input	wire		rst,
	input 	wire[5:0]	stall,
 
	input	wire[`Reg_Bus]			if_pc,
	input 	wire[`Inst_Bus]			if_inst,
	output	reg[`Inst_AddrBus]		id_pc,
	output	reg[`Inst_Bus]			id_inst
);

	always @(posedge clk) begin
		if (rst) begin
			id_pc <= `Zero_Word;
			id_inst <= `Zero_Word;
		end
		else if (!stall[1]) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
		else begin
			id_pc <= `Zero_Word;
			id_inst <= `Zero_Word;
		end
	end

endmodule