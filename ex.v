module ex(
	input 	wire 		rst,

	input 	wire[`Reg_Bus] 	pc_i,
	input 	wire[`Op_Bus]			op_i,
	input 	wire[`Funct3_Bus]		funct3_i,
	input 	wire 					funct7_i,
	input 	wire[`Reg_Bus] 			reg1_i,
	input 	wire[`Reg_Bus] 			reg2_i,
	input 	wire[`Reg_AddrBus] 		wd_i,
	input 	wire 					wreg_i,
	input 	wire[`Reg_Bus] 			imm_i,

	output 	wire 					stallreq_o,
	
	//to mem
	output 	wire[`Op_Bus] 			op_o,
	output 	wire[`Funct3_Bus]		funct3_o,
 	output 	wire[`Reg_Bus] 			mem_addr_o,
	output 	wire[`Reg_Bus] 			reg_o,
	
	//to wb
	output 	reg[`Reg_AddrBus] 		wd_o,		//address of written register
	output 	reg 					wreg_o,		//if writen
	output 	reg[`Reg_Bus] 			wdata_o 	
  	
);
	assign op_o = op_i;
	assign funct3_o = funct3_o;
	assign mem_addr_o = reg1_i + imm_o;
	assign reg_o = reg2_i; //only used if store
	
	//TODO
	assign  stallreq_o = 1'b0;
	//caculate
	always @(*) begin
		if (rst) begin
			wd_o <= `Null_RegAddr;
			wreg_o <= `Disabled;
			wdata_o <= `Zero_Word;
		end
		else begin
			case (op_i) 
				`LUI_CODE: begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					wdata_o <= reg1_i;
				end
				`AUIPC_CODE: begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					wdata_o <= pc_i + reg1_i;
				end

				//load
				`LOAD_CODE: begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					wdata_o <= `Zero_Word;
				end

				//store
				`STORE_CODE: begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					wdata_o <= `Zero_Word;
				end

				//branch 
				// no operation

				//jalr & jal
				`JALR_CODE: begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					wdata_o <= reg1_i + imm_i;
				end
				`JAL_CODE: begin
					wd_o <= wd_i;
					wreg_o <= wreg_i;
					wdata_o <= imm_i;
				end

				default: begin
					if ((op == `OPIMM_CODE) || (op == `OP_CODE)) begin
						wd_o <= wd_i;
						wreg_o <= wreg_i;
						case (funct3_i)
							`ADD_SUB_FUNCT3: begin
								if (funct7_i == `SUB_FUNCT7) begin
									wdata_o <= reg1_i - reg2_i;
								end else begin
									wdata_o <= reg1_i + reg2_i;
								end
							end
							`SLL_FUNCT3: begin
								wdata_o <= reg1_i << reg2_i[4:0];
							end
							`SLT_FUNCT3: begin
								//wdata_o <= (reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && (reg1_i < reg2_i)
								//			|| (reg1_i[31] && reg2[i] && ((~reg1_i + 1) > (~reg2_i + 1)));
								wdata_o <=  $signed(reg1_i) < $signed(reg2_i);
		
							end
							`SLTU_FUNCT3: begin
								wdata_o <= reg1_i < reg2_i;
							end
							`XOR_FUNCT3: begin
								wdata_o <= reg1_i ^ reg2_i;
							end
							`SRL_SRA_FUNCT3: begin
								if (funct7 = `SRA_FUNCT7) begin
									//sra
									//wdata_o <= ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4:0]})) | reg1_i >> reg2_i[4:0];
									wdata_o <= reg1_i >>> reg2_i[4:0];
								end
								else begin
									//srl
									wdata_o <= reg1_i >> reg2_i[4:0];
								end
							end
							`OR_FUNCT3: begin
								wdata_o <= reg1_i | reg2_i;
							end
							`AND_FUNCT3: begin
								wdata_o <= reg1_i & reg2_i;
							end
							default: begin
								wdata_o <= `Zero_Word;
							end
					end else begin
						wd_o <= `Null_RegAddr;
						wreg_o <= `Disabled;
						wdata_o <= `Zero_Word;
					end
				end
		end
	end

