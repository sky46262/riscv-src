`include "defines.v"
module _if(	
	input 	wire 			rst,

	input 	wire[`Reg_Bus] 					pc_i,
	input	wire 							ce_i,

	//from mem_ctrl
	input 	wire 							mem_busy,
	input 	wire[`Inst_Bus] 				mem_inst_i,

	//for stall
	input 	wire[2:0] 						cnt_i,

	output 	reg[2:0]						cnt_o, 

	//to mem_ctrl
	output 	reg[`Reg_Bus] 					addr_o,
	output 	reg 							signal_o,

	output  reg 							stallreq_o,
	output 	reg[`Reg_Bus]					pc_o,
	output  reg[`Inst_Bus]					inst_o
);
	
	always @(*) begin
		if (rst) begin
			stallreq_o <= `Disabled;
			pc_o <= `Zero_Word;
			inst_o <= `Zero_Word;
			cnt_o <= 0;
			addr_o <= `Zero_Word;
			signal_o <= `Disabled;
		end
		else if (mem_busy) begin
			stallreq_o <= `Enabled;
			pc_o <= `Zero_Word;
			inst_o <= `Zero_Word;
			cnt_o <= 0;
			addr_o <= `Zero_Word;
			signal_o <= `Disabled;
		end
		else begin
			if (cnt_i < 3'b100)begin
				//stallreq_o
				//pc_o
				//inst_o
				addr_o <= pc_o;
				signal_o <= 1'b1;
				cnt_o <= cnt_i + 1'b1;
			end
			else if (cnt_i == 3'b100) begin
				if (mem_inst_i[`Op_Bus] == `BRANCH_CODE || mem_inst_i[`Op_Bus] == `JAL_CODE 
					|| mem_inst_i[`Op_Bus] == `JALR_CODE) begin
					stallreq_o <= `Enabled;
				end
				else begin
					stallreq_o <= `Disabled;
				end
				pc_o <= pc_i;
				inst_o <= mem_inst_i;
				cnt_o <= 3'b000;
				addr_o <= `Zero_Word;
				signal_o <= `Disabled;
			end
		end
	end
endmodule