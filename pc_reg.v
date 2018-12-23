`include "defines.v"
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