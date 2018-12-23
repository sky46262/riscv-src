`include "defines.v"
module id(
	input	wire 			rst,
	input 	wire[`Reg_Bus]			pc_i,
	input 	wire[`Inst_Bus]				inst_i,

	input 	wire[`Reg_Bus]				reg1_data_i,
	input 	wire[`Reg_Bus]				reg2_data_i,
	//load data hazard
	input 	wire[`Op_Bus] 				ex_op_i,
	//Forwarding
	input 	wire 						ex_wreg_i,
	input 	wire[`Reg_Bus]				ex_wdata_i,
	input 	wire[`Reg_AddrBus]			ex_wd_i,
	input 	wire 						mem_wreg_i,
	input 	wire[`Reg_Bus]				mem_wdata_i,
	input 	wire[`Reg_AddrBus]			mem_wd_i,

	//branch & jump
	output 	wire 						stallreq_o,
	output 	reg 						branch_flag_o,
	output 	reg[`Reg_Bus] 				branch_address_o,

	output 	reg 						reg1_read_o,
	output 	reg 						reg2_read_o,
	output 	reg[`Reg_AddrBus]			reg1_addr_o,
	output 	reg[`Reg_AddrBus]			reg2_addr_o,
	output 	reg[`Reg_Bus] 				imm_o,
	
	output reg[`Reg_Bus]				pc_o,
	output reg[`Op_Bus] 				op_o,
	output reg[`Funct3_Bus] 			funct3_o,
	output reg 							funct7_o,
	output reg[`Reg_Bus]				reg1_o,
	output reg[`Reg_Bus] 				reg2_o,
	output reg[`Reg_AddrBus] 			wd_o, 			//address of reg
	output reg 							wreg_o			//if written to reg

);

wire[`Op_Bus] 		op = inst_i[`Op_Bus];
wire 				funct7 = inst_i[30];
wire[`Funct3_Bus] 	funct3 = inst_i[14:12];

reg 			inst_valid;
	
	//decode operation
	always @(*) begin
		if (rst) begin
			pc_o <= `Zero_Word;
			reg1_read_o <= `Disabled;
			reg2_read_o <= `Disabled;
			reg1_addr_o <= `Null_RegAddr;
			reg2_addr_o <= `Null_RegAddr;

			op_o <= `NOP_CODE;
			funct3_o <= `Null_FUNCT3;
			funct7_o <= `Null_FUNCT7;
			wd_o <= `Null_RegAddr;
			wreg_o <= `Disabled;

			imm_o <= `Zero_Word;
			inst_valid <= `Inst_Valid;

			branch_flag_o <= `Disabled;
			branch_address_o <= `Zero_Word;
		end
		else begin
			pc_o <= pc_i;
			inst_valid <= `Inst_Invalid;
			op_o <= op;
			case (op) 
				`LUI_CODE: begin
					reg1_read_o <= `Disabled;
					reg2_read_o <= `Disabled;
					reg1_addr_o <= `Null_RegAddr;
					reg2_addr_o <= `Null_RegAddr;
					funct3_o <= `Null_FUNCT3;
					funct7_o <= `Null_FUNCT7;
					wd_o <= inst_i[11:7];
					wreg_o <= `Enabled;
					imm_o <= {inst_i[31:12], {12{1'b0}}};

					branch_flag_o <= `Disabled;
					branch_address_o <= `Zero_Word;

				end
				`AUIPC_CODE: begin
					reg1_read_o <= `Disabled;
					reg2_read_o <= `Disabled;
					reg1_addr_o <= `Null_RegAddr;
					reg2_addr_o <= `Null_RegAddr;
					funct3_o <= `Null_FUNCT3;
					funct7_o <= `Null_FUNCT7;
					wd_o <= inst_i[11:7];
					wreg_o <= `Enabled;
					imm_o <= {inst_i[31:12], {12{1'b0}}};

					branch_flag_o <= `Disabled;
					branch_address_o <= `Zero_Word;
				end

				//load
				`LOAD_CODE: begin
					reg1_read_o <= `Enabled;
					reg2_read_o <= `Disabled;
					reg1_addr_o <= inst_i[19:15];
					reg2_addr_o <= `Null_RegAddr;
					funct3_o <= funct3;
					funct7_o <= `Null_FUNCT7;
					wd_o <= inst_i[11:7];
					wreg_o <= `Enabled;
					imm_o <= {inst_i[31]? {20{1'b1}}: {20{1'b0}}, inst_i[31:20]};

					branch_flag_o <= `Disabled;
					branch_address_o <= `Zero_Word;

				end

				//store
				`STORE_CODE: begin
					reg1_read_o <= `Enabled;
					reg2_read_o <= `Enabled;
					reg1_addr_o <= inst_i[19:15];
					reg2_addr_o <= inst_i[24:20];
					funct3_o <= funct3;
					funct7_o <= `Null_FUNCT7;
					wd_o <= `Null_RegAddr;
					wreg_o <= `Disabled;
					imm_o <= {inst_i[31]? {20{1'b1}}: {20{1'b0}}, inst_i[31:25], inst_i[11:7]};
				
					branch_flag_o <= `Disabled;
					branch_address_o <= `Zero_Word;		
				end

				//immediate
				`OPIMM_CODE: begin
					reg1_read_o <= `Enabled;
					reg2_read_o <= `Disabled;
					reg1_addr_o <= inst_i[19:15];
					reg2_addr_o <= `Null_RegAddr;
					funct3_o <= funct3;
					funct7_o <= funct7;
					wd_o <= inst_i[11:7];
					wreg_o <= `Enabled;
					if ((funct3 == `SLL_FUNCT3) || (funct3 ==  `SRL_SRA_FUNCT3)) begin
						imm_o <= inst_i[24:20];
					end else begin
						imm_o <= {inst_i[31]?{20{1'b1}}: {20{1'b0}}, inst_i[31:20]};
					end
					branch_flag_o <= `Disabled;
					branch_address_o <= `Zero_Word;

				end

				`OP_CODE: begin
					imm_o <= `Zero_Word;

					reg1_read_o <= `Enabled;
					reg2_read_o <= `Enabled;
					reg1_addr_o <= inst_i[19:15];
					reg2_addr_o <= inst_i[24:20];

					funct3_o <= funct3;
					funct7_o <= funct7;
					wreg_o <= `Enabled;
					wd_o <= inst_i[11:7];
					
					branch_flag_o <= `Disabled;
					branch_address_o <= `Zero_Word;
				end

				//branch
				`BRANCH_CODE: begin
					reg1_read_o <= `Enabled;
					reg2_read_o <= `Enabled;
					reg1_addr_o <= inst_i[19:15];
					reg2_addr_o <= inst_i[24:20];

					funct3_o <= funct3;
					funct7_o <= `Null_FUNCT7;
					wreg_o <= `Disabled;
					wd_o <= `Null_RegAddr;
					imm_o <= {inst_i[31]? {19{1'b1}}: {19{1'b0}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
					//??? if reg assigned?
					
					case (funct3)
						`BEQ_FUNCT3: begin
							if (reg1_o == reg2_o) begin
								branch_flag_o <= `Enabled;
								branch_address_o <= imm_o;
							end
							else begin
								branch_flag_o <= `Disabled;
								branch_address_o <= `Zero_Word;
							end
						end
						`BNE_FUNCT3: begin
							if (reg1_o != reg2_o) begin
								branch_flag_o <= `Enabled;
								branch_address_o <= imm_o;
							end
							else begin
								branch_flag_o <= `Disabled;
								branch_address_o <= `Zero_Word;
							end
						end
						`BLE_FUNCT3: begin
							if ($signed(reg1_o) < $signed(reg2_o)) begin
								branch_flag_o <= `Enabled;
								branch_address_o <= imm_o;
							end
							else begin
								branch_flag_o <= `Disabled;
								branch_address_o <= `Zero_Word;
							end
						end
						`BLTU_FUNCT3: begin
							if (reg1_o < reg2_o) begin
								branch_flag_o <= `Enabled;
								branch_address_o <= imm_o;
							end
							else begin
								branch_flag_o <= `Disabled;
								branch_address_o <= `Zero_Word;
							end
						end
						`BGE_FUNCT3: begin
							if ($signed(reg1_o) > $signed(reg2_o)) begin
								branch_flag_o <= `Enabled;
								branch_address_o <= imm_o;
							end
							else begin
								branch_flag_o <= `Disabled;
								branch_address_o <= `Zero_Word;
							end
						end
						`BGEU_FUNCT3: begin
							if (reg1_o > reg2_o) begin
								branch_flag_o <= `Enabled;
								branch_address_o <= imm_o;
							end
							else begin
								branch_flag_o <= `Disabled;
								branch_address_o <= `Zero_Word;
							end
						end
						default: begin
							branch_flag_o <= `Disabled;
							branch_address_o <= `Zero_Word;
						end
					endcase
				end

				//jalr & jal
				`JALR_CODE: begin
					reg1_read_o <= `Enabled;
					reg2_read_o <= `Disabled;
					reg1_addr_o <= inst_i[19:15];
					reg2_addr_o <= `Null_RegAddr;
					funct3_o <= funct3;
					funct7_o <= `Null_FUNCT7;
					wd_o <= inst_i[11:7];
					wreg_o <= `Enabled;
					imm_o <= {inst_i[31]? {20{1'b1}}: {20{1'b0}}, inst_i[31:20]};
					
					branch_flag_o <= `Enabled;
					branch_address_o <= reg1_o + imm_o;
				end
				`JAL_CODE: begin
					reg1_read_o <= `Disabled;
					reg2_read_o <= `Disabled;
					reg1_addr_o <= `Null_RegAddr;
					reg2_addr_o <= `Null_RegAddr;
					funct3_o <= `Null_FUNCT3;
					funct7_o <= `Null_FUNCT7;
					wd_o <= inst_i[11:7];
					wreg_o <= `Enabled;
					imm_o <= {inst_i[31]? {11{1'b1}}: {11{1'b0}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
					
					branch_flag_o <= `Enabled;
					branch_address_o <= imm_o;
				end
				default: begin
					reg1_read_o <= `Disabled;
					reg2_read_o <= `Disabled;
					reg1_addr_o <= `Null_RegAddr;
					reg2_addr_o <= `Null_RegAddr;

					funct3_o <= `Null_FUNCT3;
					funct7_o <= `Null_FUNCT7;
					wd_o <= `Null_RegAddr;
					wreg_o <= `Disabled;

					imm_o <= `Zero_Word;
					
					branch_flag_o <= `Disabled;
				end
			endcase
		end
	end

	reg stallreq_reg1;
	reg stallreq_reg2;
	assign stallreq_o = stallreq_reg1 | stallreq_reg2;
	//assign reg1_o

	always @(*) begin
		if (rst) begin
			reg1_o <= `Zero_Word;
			stallreq_reg1 <= `Disabled;
		end
		else if ((reg1_read_o == `Enabled) &&
			 (ex_wreg_i ==`Enabled) && (ex_wd_i == reg1_addr_o)) begin
			 	stallreq_reg1 <= `Enabled;
		end
		else if ((reg1_read_o == `Enabled) &&
			 (ex_wreg_i ==`Enabled) && (ex_wd_i == reg1_addr_o)) begin
			 	reg1_o <= ex_wdata_i;
			 	stallreq_reg1 <= `Disabled;
		end
		else if ((reg1_read_o == `Enabled) &&
			 (mem_wreg_i ==`Enabled) && (mem_wd_i == reg1_addr_o)) begin
			 	reg1_o <= mem_wdata_i;
			 	stallreq_reg1 <= `Disabled;
		end
		else if (reg1_read_o == `Enabled) begin
				reg1_o <= reg1_data_i;
				stallreq_reg1 <= `Disabled;
		end
		else if (reg1_read_o == `Disabled) begin
				reg1_o <= imm_o;
				stallreq_reg1 <= `Disabled;
		end
		else begin
			reg1_o <= `Zero_Word;
			stallreq_reg1 <= `Disabled;
		end
	end

	//assign reg2_o

	always @(*) begin
		if (rst) begin
			reg2_o <= `Zero_Word;
			stallreq_reg2 <= `Disabled;
		end
		else if ((reg2_read_o == `Enabled) &&
			 (ex_wreg_i ==`Enabled) && (ex_wd_i == reg2_addr_o)) begin
			 	stallreq_reg2 <= `Enabled;
		end
		else if ((reg2_read_o == `Enabled) &&
			 (ex_wreg_i ==`Enabled) && (ex_wd_i == reg2_addr_o)) begin
			 	reg2_o <= ex_wdata_i;
			 	stallreq_reg2 <= `Disabled;
		end
		else if ((reg2_read_o == `Enabled) &&
			 (mem_wreg_i ==`Enabled) && (mem_wd_i == reg2_addr_o)) begin
			 	reg2_o <= mem_wdata_i;
			 	stallreq_reg2 <= `Disabled;
		end
		else if (reg1_read_o == `Enabled) begin
				reg2_o <= reg2_data_i;
				stallreq_reg2 <= `Disabled;
		end
		else if (reg1_read_o == `Disabled) begin
				reg2_o <= imm_o;
				stallreq_reg2 <= `Disabled;
		end
		else begin
			reg1_o <= `Zero_Word;
			stallreq_reg2 <= `Disabled;
		end
	end

endmodule