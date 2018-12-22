module _if(
	input 	wire 			clk,
	input 	wire 			rst,

	input 	reg[`Reg_Bus] 					pc_i,
	input	reg 							ce_i,
	input 	wire 							mem_busy

	output  reg 							stallreq_o,
	output 	reg[`Reg_Bus]					pc_o,
	output  reg[`Inst_Bus]					inst_o
);
//if branch then stall
//TODO
	always @(posedge clk) begin
		if (rst) begin
			stallreq_o <= `Disabled;
			pc_o <= `Zero_Word;
			inst_o <= `Zero_Word;
		end
		else if (mem_busy) begin
			stallreq_o <= `Enabled;
			pc_o <= `Zero_Word;
			inst_o <= `Zero_Word;
		end
		else begin
			
		end
	end