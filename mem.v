`include "defines.v"
module mem(
	input 	wire 			rst,

	input 	wire[`Op_Bus] 			op_i,
	input 	wire[`Funct3_Bus] 		funct3_i,
 	input 	wire[`Reg_Bus] 			mem_addr_i,
	input 	wire[`Reg_Bus] 			reg_i,

	input 	wire[`Reg_AddrBus] 	wd_i,
	input 	wire 				wreg_i,
	input 	wire[`Reg_Bus] 		wdata_i,

	//from mem_ctrl
	input 	wire[`Reg_Bus] 		mem_data_i,
	input 	wire 				mem_busy_i,

	//for stall
	input 	wire[2:0] 			cnt_i,
	output 	reg[2:0]			cnt_o,

	output 	reg 				stallreq_o,

	//to mem_ctrl
	output 	reg[`Reg_Bus] 		mem_addr_o,
	output 	reg					mem_we_o,
	output 	reg[2:0] 			mem_sel_o,
	output 	reg[`Reg_Bus] 		mem_data_o,
	output 	reg 				mem_ce_o,


	//to wb	
	output 	reg[`Reg_AddrBus] 	wd_o,
	output 	reg 				wreg_o,
	output 	reg[`Reg_Bus] 		wdata_o
);

	
	always @(*) begin
		if (rst) begin
			wd_o <= `Null_RegAddr;
			wreg_o <= `Disabled;
			wdata_o <= `Zero_Word;
			mem_addr_o <= `Zero_Word;
			mem_we_o <= `Disabled;
			mem_sel_o <= 3'b000;
			mem_data_o <= `Zero_Word;
			mem_ce_o <= `Disabled;
			stallreq_o <= `Disabled;
			cnt_o <= 3'b000;
		end
		else if (mem_busy_i) begin
			wd_o <= `Null_RegAddr;
			wreg_o <= `Disabled;
			wdata_o <= `Zero_Word;
			mem_addr_o <= `Zero_Word;
			mem_we_o <= `Disabled;
			mem_sel_o <= 3'b000;
			mem_data_o <= `Zero_Word;
			mem_ce_o <= `Disabled;
			stallreq_o <= `Enabled;
			cnt_o <= 3'b000;
		end 
		else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			if (op_i == `LOAD_CODE) begin
				mem_we_o <= `Disabled;
				mem_data_o <= `Zero_Word;

				case (funct3_i)
					`LB_FUNCT3: begin
						if (cnt_i == 3'b000) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_sel_o <= 3'b001;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b001) begin
							wdata_o <= mem_data_i;
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end
					end
					`LH_FUNCT3: begin
						if (cnt_i < 3'b010) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_sel_o <= 3'b010;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b010) begin
							wdata_o <= mem_data_i;
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end

					end
					`LW_FUNCT3: begin
						if (cnt_i < 3'b100) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_sel_o <= 3'b100;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b100) begin
							wdata_o <= mem_data_i;
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end
					end

					//??? U
					`LBU_FUNCT3: begin
						if (cnt_i == 3'b000) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_sel_o <= 3'b001;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b001) begin
							wdata_o <= mem_data_i;
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end
					end
					`LHU_FUNCT3: begin
						if (cnt_i < 3'b010) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_sel_o <= 3'b010;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b010) begin
							wdata_o <= mem_data_i;
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end
					end
					default: begin
						mem_addr_o <= `Zero_Word;
						mem_ce_o <= `Disabled;
						mem_sel_o <= 3'b000;
						wdata_o <= wdata_i;
						stallreq_o <= `Disabled;
						cnt_o <= 3'b000;
					end
				endcase
			end else if (op_i == `STORE_CODE) begin
				wdata_o <= wdata_i;
				case (funct3_i)
					`SB_FUNCT3: begin
						if (cnt_i < 3'b001) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_we_o <= `Enabled;
							mem_data_o <= reg_i;
							mem_sel_o <= 3'b001;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b001) begin
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_we_o <= `Disabled;
							mem_data_o <= `Zero_Word;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end
					end
					`SH_FUNCT3: begin
						if (cnt_i < 3'b010) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_we_o <= `Enabled;
							mem_data_o <= reg_i;
							mem_sel_o <= 3'b010;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b001) begin
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_we_o <= `Disabled;
							mem_data_o <= `Zero_Word;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end
					end
					`SW_FUNCT3: begin
						if (cnt_i < 3'b100) begin
							mem_addr_o <= mem_addr_i;
							mem_ce_o <= `Enabled;
							mem_we_o <= `Enabled;
							mem_data_o <= reg_i;
							mem_sel_o <= 3'b100;
							stallreq_o <= `Enabled;
							cnt_o <= cnt_i + 1'b1;
						end
						else if (cnt_i == 3'b100) begin
							mem_addr_o <= `Zero_Word;
							mem_ce_o <= `Disabled;
							mem_we_o <= `Disabled;
							mem_data_o <= `Zero_Word;
							mem_sel_o <= 3'b000;
							stallreq_o <= `Disabled;
							cnt_o <= 3'b000;
						end
					end
					default: begin
						mem_addr_o <= `Zero_Word;
						mem_ce_o <= `Disabled;
						mem_we_o <= `Disabled;
						mem_data_o <= `Zero_Word;
						mem_sel_o <= 3'b000;
						stallreq_o <= `Disabled;
						cnt_o <= 3'b000;
					end
				endcase 
			end else begin
				wdata_o <= wdata_i;
				mem_addr_o <= `Zero_Word;
				mem_we_o <= `Disabled;
				mem_sel_o <= 3'b000;
				mem_data_o <= `Zero_Word;
				mem_ce_o <= `Disabled;
				cnt_o <= 3'b000;
				stallreq_o <= `Disabled;
			end
		end
	end

endmodule