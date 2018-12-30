// RISCV32I CPU top module
// port modification allowed for debugging purposes

`include "pc_reg.v"
`include "regfile.v"
`include "if.v"
`include "id.v"
`include "ex.v"
`include "mem.v"
`include "ctrl.v"
`include "if_id.v"
`include "id_ex.v"
`include "ex_mem.v"
`include "mem_wb.v"
`include "mem_ctrl.v"

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)
	//between pc_reg and if
	wire 					ce;
	wire[`Reg_Bus] 			pc;

	//between if and if_id
	wire[`Reg_Bus] 			if_pc_o;
	wire[`Inst_Bus]			if_inst_o;

	wire[2:0] 				if_cnt_o;
	wire[2:0] 				if_cnt_i; 

	//between if_id and id
	wire[`Reg_Bus] 			id_pc_i;
	wire[`Inst_Bus] 		id_inst_i;

	//between id and id_ex
	wire[`Reg_Bus] 				id_pc_o;
	wire[`Op_Bus]				id_op_o;
	wire[`Funct3_Bus] 			id_funct3_o;
	wire						id_funct7_o;
	wire[`Reg_Bus] 				id_reg1_o;
	wire[`Reg_Bus] 				id_reg2_o;
	wire 						id_wreg_o;
	wire[`Reg_AddrBus] 			id_wd_o;
	wire[`Reg_Bus] 				id_imm_o;

	//between id_ex and ex
	wire[`Reg_Bus] 				ex_pc_i;
	wire[`Op_Bus]				ex_op_i;
	wire[`Funct3_Bus] 			ex_funct3_i;
	wire 						ex_funct7_i;
	wire[`Reg_Bus] 				ex_reg1_i;
	wire[`Reg_Bus] 				ex_reg2_i;
	wire 						ex_wreg_i;
	wire[`Reg_AddrBus] 			ex_wd_i;
	wire[`Reg_Bus] 				ex_imm_i;

	//between ex and ex_mem

	wire[`Op_Bus] 			ex_op_o;
	wire[`Funct3_Bus] 		ex_funct3_o;
 	wire[`Reg_Bus] 			ex_mem_addr_o;
	wire[`Reg_Bus] 			ex_reg_o;

	wire 					ex_wreg_o;
	wire[`Reg_AddrBus] 		ex_wd_o;
	wire[`Reg_Bus] 			ex_wdata_o;

	//between ex_mem and mem
	wire[`Op_Bus] 			mem_op_i;
	wire[`Funct3_Bus] 		mem_funct3_i;
 	wire[`Reg_Bus] 			mem_mem_addr_i;
	wire[`Reg_Bus] 			mem_reg_i;

	wire 					mem_wreg_i;
	wire[`Reg_AddrBus] 		mem_wd_i;
	wire[`Reg_Bus] 			mem_wdata_i;

	//between mem and mem_wb
	wire 					mem_wreg_o;
	wire[`Reg_AddrBus] 		mem_wd_o;
	wire[`Reg_Bus] 			mem_wdata_o;

	wire[2:0] 				mem_cnt_o;
	wire[2:0] 				mem_cnt_i;


	//between mem_wb and regfile
	wire 					wb_wreg_i;
	wire[`Reg_AddrBus] 		wb_wd_i;
	wire[`Reg_Bus] 			wb_wdata_i;

	//between id and regfile
	wire 					reg1_read;
	wire 					reg2_read;
	wire[`Reg_AddrBus] 		reg1_addr;
	wire[`Reg_AddrBus] 		reg2_addr;
	wire[`Reg_Bus] 			reg1_data;
	wire[`Reg_Bus] 			reg2_data;

	//ctrl stall
	wire 					stallreq_from_id;
	wire 					stallreq_from_ex;
	wire 					stallreq_from_if;
	wire 					stallreq_from_mem;
	wire[5:0]				stall;

	//branch
	wire 					branch_flag; //decide in id
	wire[`Reg_Bus]			branch_address; //decide in ex
  	

	//between mem and mem_ctrl
	wire[`Reg_Bus] 			mem_data_o;
	wire[`Reg_Bus] 			mem_addr_o;
	wire 					mem_we_o;
	wire[2:0] 				mem_sel_o;
	wire  					mem_ce_o;

	wire[`Reg_Bus] 			mem_data;

	//between if and mem_ctrl
	wire[`Reg_Bus] 			mem_if_addr;
	wire 					mem_if_signal;

	wire [`Inst_Bus] 		mem_if_inst;

	//mem_ctrl
	wire 					mem_ctrl_busy;

  	//ctrl
	ctrl ctrl0(
		.rst(rst_in),
		.stallreq_from_if(stallreq_from_if),
		.stallreq_from_id(stallreq_from_id),
		.stallreq_from_ex(stallreq_from_ex),
		.stallreq_from_mem(stallreq_from_mem),
		.stall(stall)
	);
	//pc
	pc_reg pc_reg0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),

		.branch_flag_i(branch_flag),
		.branch_target_address_i(branch_address),

		.pc(pc),
		.ce(ce)
	);

	_if _if0(
		.rst(rst_in),
		.pc_i(pc),
		.ce_i(ce),

		.mem_busy(mem_ctrl_busy),
		.mem_inst_i(mem_if_inst),

		.cnt_i(if_cnt_i),
		.cnt_o(if_cnt_o),

		.addr_o(mem_if_addr),
		.signal_o(mem_if_signal),

		.stallreq_o(stallreq_from_if),
		.pc_o(if_pc_o),
		.inst_o(if_inst_o)
	);

	if_id if_id0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),

		.if_pc(if_pc_o),
		.if_inst(if_inst_o),

		.if_cnt_i(if_cnt_o),
		.if_cnt_o(if_cnt_i),

		.id_pc(id_pc_i),
		.id_inst(id_inst_i)
	);

	id id0(
		.rst(rst_in),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		.ex_op_i(ex_op_o),

		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),


		.stallreq_o(stallreq_from_id),
		.branch_flag_o(branch_flag),
		.branch_address_o(branch_address),

		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read),
		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr),

		.pc_o(id_pc_o),
		.op_o(id_op_o),
		.funct3_o(id_funct3_o),
		.funct7_o(id_funct7_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.imm_o(id_imm_o)
	);

	regfile regfile0(
		.clk(clk_in),
		.rst(rst_in),

		.we(wb_wreg_i),
		.waddr(wb_wd_i),
		.wdata(wb_wdata_i),

		.re1(reg1_read),
		.raddr1(reg1_addr),
		.rdata1(reg1_data),

		.re2(reg2_read),
		.raddr2(reg2_addr),
		.rdata2(reg2_data)
	);

	id_ex id_ex0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),

		.id_pc(id_pc_o),
		.id_op(id_op_o),
		.id_funct3(id_funct3_o),
		.id_funct7(id_funct7_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.id_imm(id_imm_o),

		.ex_pc(ex_pc_i),
		.ex_op(ex_op_i),
		.ex_funct3(ex_funct3_i),
		.ex_funct7(ex_funct7_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_imm(ex_imm_i)
	);

	ex ex0(
	    .rst(rst_in),
		.pc_i(ex_pc_i),
		.op_i(ex_op_i),
		.funct3_i(ex_funct3_i),
		.funct7_i(ex_funct7_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		.imm_i(ex_imm_i),

		.stallreq_o(stallreq_from_ex),

		.op_o(ex_op_o),
		.funct3_o(ex_funct3_o),
		.mem_addr_o(ex_mem_addr_o),
		.reg_o(ex_reg_o),

		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o)
	);

	ex_mem ex_mem(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),

		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.ex_op(ex_op_o),
		.ex_funct3(ex_funct3_o),
		.ex_mem_addr(ex_mem_addr_o),
		.ex_reg(ex_reg_o),

		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.mem_op(mem_op_i),
		.mem_funct3(mem_funct3_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_reg(mem_reg_i)
	);

	mem mem0(
		.rst(rst_in),

		.op_i(mem_op_i),
		.funct3_i(mem_funct3_i),
		.mem_addr_i(mem_mem_addr_i),
		.reg_i(mem_reg_i),

		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),

		.mem_data_i(mem_data),
		.mem_busy_i(mem_ctrl_busy),

		.cnt_i(mem_cnt_i),
		.cnt_o(mem_cnt_o),

		.stallreq_o(stallreq_from_mem),

		.mem_addr_o(mem_addr_o),
		.mem_we_o(mem_we_o),
		.mem_sel_o(mem_sel_o),
		.mem_data_o(mem_data_o),
		.mem_ce_o(mem_ce_o),

		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o)
	);

	mem_wb mem_wb0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),

		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),

		.mem_cnt_i(mem_cnt_o),
		.mem_cnt_o(mem_cnt_i),

		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)
	);

	mem_ctrl mem_ctrl0(
		.clk(clk_in),
		.rst(rst_in),

	 	.addr_i(mem_addr_o),
		.we_i(mem_we_o),
		.sel_i(mem_sel_o),
 		.data_i(mem_data_o),
		.ce(mem_ce_o),

		.if_addr_i(mem_if_addr),
		.if_signal(mem_if_signal),

		.mem_busy(mem_ctrl_busy),

        .mem_din(mem_din),		// data input bus
        .mem_dout(mem_dout),	// data output bus
        .mem_a(mem_a),			// address bus (only 17:0 is used)
       	.mem_wr(mem_wr),		// write/read signal (1 for write)

		.data_o(mem_data),
		.inst_o(mem_if_inst)
	);
endmodule