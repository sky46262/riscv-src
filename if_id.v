`include "defines.v"
module if_id(
	input	wire		clk,
	input	wire		rst,
	input 	wire[5:0]	stall,
 
	input	wire[`Reg_Bus]			if_pc,
	input 	wire[`Inst_Bus]			if_inst,

	input 	wire[2:0] 				if_cnt_i,

	output 	reg[2:0] 				if_cnt_o,

	output	reg[`Reg_Bus]		id_pc,
	output	reg[`Inst_Bus]			id_inst
);

	always @(posedge clk) begin
		if (rst) begin
			id_pc <= `Zero_Word;
			id_inst <= `Zero_Word;
			if_cnt_o <= 3'b000;
		end
		else if (!stall[1]) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
			if_cnt_o <= 3'b000;
		end
		else if (stall[1] && !stall[2]) begin
			id_pc <= `Zero_Word;
			id_inst <= `Zero_Word;
			if_cnt_o <= if_cnt_i;
		end else begin
			if_cnt_o <= if_cnt_i;
		end
	end

endmodule