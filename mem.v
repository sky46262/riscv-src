module mem(
	input 	wire 			rst,

	input 	wire[`Op_Bus] 			op_i,
	input 	wire[`Funct3_Bus] 		funct3_i,
 	input 	wire[`Reg_Bus] 			mem_addr_i,
	input 	wire[`Reg_Bus] 			reg_i,

	input 	wire[`Reg_AddrBus] 	wd_i,
	input 	wire 				wreg_i,
	input 	wire[`Reg_Bus] 		wdata_i,

	//to mem_ctrl
	input 	wire[`Reg_Bus] 		mem_data_i,
	input 	wire 					mem_busy_i,

	output 	reg 				stallreq_o,
	//to mem_ctrl
	output 	reg[`Reg_Bus] 		mem_addr_o,
	output 	wire				mem_we_o,
	output 	reg[3:0] 			mem_sel_o,
	output 	reg[`Reg_Bus] 		mem_data_o,
	output 	reg 				mem_ce_o,


	//to wb	
	output 	reg[`Reg_AddrBus] 	wd_o,
	output 	reg 				wreg_o,
	output 	reg[`Reg_Bus] 		wdata_o
);

	//TODO
	always @(*) begin
		if (rst) begin
			wd_o <= `Null_RegAddr;
			wreg_o <= `Disabled;
			wdata_o <= `Zero_Word;
			mem_addr_o <= `Zero_Word;
			mem_we <= `Disabled;
			mem_sel_o <= 4'b0000;
			mem_data_o <= `Zero_Word;
			mem_ce_o <= `Disabled;
			stallreq_o <= `Disabled;
		end
		else if (mem_busy_i) begin
			wd_o <= `Null_RegAddr;
			wreg_o <= `Disabled;
			wdata_o <= `Zero_Word;
			mem_addr_o <= `Zero_Word;
			mem_we <= `Disabled;
			mem_sel_o <= 4'b0000;
			mem_data_o <= `Zero_Word;
			mem_ce_o <= `Disabled;
			stallreq_o <= `Enabled;
		end 
		else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			if (op_i == `LOAD_CODE) begin
				mem_we <= `Disabled;
				mem_data_o <= `Zero_Word;

				case (funct3_i)
					`LB_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_sel_o <= 4'b0001;
						wdata_o <= mem_data_i;
					end
					`LH_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_sel_o <= 4'b0010;
						wdata_o <= mem_data_i;
					end
					`LW_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_sel_o <= 4'b0100;
						wdata_o <= mem_data_i;
					end
					`LBU_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_sel_o <= 4'b0001;
						wdata_o <= mem_data_i;
					end
					`LHU_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_sel_o <= 4'b0100;
						wdata_o <= mem_data_i;
					end
					default: begin
						mem_addr_o <= `Zero_Word;
						mem_ce <= `Disabled;
						mem_sel_o <= 4'b0000;
						wdata_o <= wdata_i;
					end

			end else if (op_i == `STORE_CODE) begin
				wdata_o <= wdata_i;
				case (funct3_i)
					`SB_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_we <= `Enabled;
						mem_data_o <= reg_i;
						mem_sel_o <= 4'b0001;
					end
					`SH_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_we <= `Enabled;
						mem_data_o <= reg_i;
						mem_sel_o <= 4'b0010;
					end
					`SW_FUNCT3: begin
						mem_addr_o <= mem_addr_i;
						mem_ce <= `Enabled;
						mem_we <= `Enabled;
						mem_data_o <= reg_i;
						mem_sel_o <= 4'b0100
					end
					default: begin
						mem_addr_o <= `Zero_Word;
						mem_ce <= `Disabled;
						mem_we <= `Disabled;
						mem_data_o <= `Zero_Word;
						mem_sel_o <= 4'b0000;
					end
			end else begin
				wdata_o <= wdata_i;
				mem_addr_o <= `Zero_Word;
				mem_we <= `Disabled;
				mem_sel_o <= 4'b0000;
				mem_data_o <= `Zero_Word;
				mem_ce_o <= `Disabled;
			end
		end
	end

endmodule