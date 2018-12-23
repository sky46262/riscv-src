//**********	global 		********

`define Zero_Word			32'h00000000	//32bit 0
`define	Null_RegAddr 		5'b00000
`define Enabled				1'b1			
`define Disabled 			1'b0
`define Inst_Valid 			1'b1
`define Inst_Invalid 		1'b0
`define True_v				1'b1			//logic true
`define False_v				1'b0			//logic false

`define Funct3_Bus 			2:0
`define Op_Bus 				7:0


//**********	op code		*******

//opcode
`define LUI_CODE 			7'b0110111
`define AUIPC_CODE			7'b0010111
`define LOAD_CODE 			7'b0000011
`define STORE_CODE			7'b0100011
`define OPIMM_CODE			7'b0010011
`define OP_CODE  			7'b0110011
`define BRANCH_CODE			7'b1100011
`define JALR_CODE			7'b1100111
`define JAL_CODE  			7'b1101111
`define NOP_CODE 			7'b0000000

//funct3

//branch
`define BEQ_FUNCT3			3'b000
`define BNE_FUNCT3			3'b001
`define BLE_FUNCT3 			3'b100 
`define BGE_FUNCT3 			3'b101
`define BLTU_FUNCT3 		3'b110
`define BGEU_FUNCT3 		3'b111

//load
`define LB_FUNCT3			3'b000
`define LH_FUNCT3			3'b001
`define LW_FUNCT3 			3'b010 
`define LBU_FUNCT3			3'b100 
`define LHU_FUNCT3			3'b101

//store
`define SB_FUNCT3 			3'b000
`define SH_FUNCT3 			3'b001
`define SW_FUNCT3 			3'b010

//op / op_imm
`define ADD_SUB_FUNCT3		3'b000
`define SLL_FUNCT3			3'b001
`define SLT_FUNCT3 			3'b010 
`define SLTU_FUNCT3 		3'b011
`define XOR_FUNCT3			3'b100
`define SRL_SRA_FUNCT3		3'b101
`define OR_FUNCT3 			3'b110
`define AND_FUNCT3 			3'b111

`define Null_FUNCT3 		3'b000

//funct7
`define SUB_FUNCT7 			1'b1
`define SRA_FUNCT7 			1'b1
`define OTHER_FUNCT7 		1'b0
`define Null_FUNCT7 		1'b0


//*********		Memory		*******

`define Inst_AddrBus 		16:0
`define Inst_Bus 			31:0
`define Inst_MemNum			131071
`define IO_Port1			20'h30000
`define IO_Port2			20'h30004

//********		Register	*******

`define Reg_AddrBus			4:0
`define Reg_Bus 			31:0
`define Reg_Width			32
`define Reg_Num				32