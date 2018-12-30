`include "defines.v"
module mem_ctrl(
	input wire 				clk,
	input wire 				rst,

	//from mem
	input wire[`Reg_Bus] 	addr_i,
	input wire				we_i, // if write
	input wire[2:0] 		sel_i,
	input wire[`Reg_Bus] 	data_i,
	input wire 				ce,

	//from if
	input wire[`Reg_Bus] 	if_addr_i,
	input wire 				if_signal,

	//to mem and if
	output wire 				mem_busy,
	
	//to ram
	input  wire [ 7:0]          mem_din,		// data input bus
    output reg [ 7:0]          mem_dout,		// data output bus
    output reg [31:0]          mem_a,			// address bus (only 17:0 is used)
    output reg                 mem_wr,			// write/read signal (1 for write)

    //to mem
	output reg[`Reg_Bus]	data_o,

	//to if
	output reg[`Inst_Bus] 	inst_o
);
	reg[2:0] 	cnt;
	initial cnt = 3'b000;
	reg 		if_busy;
	reg 		read_busy;
	reg 		write_busy;
	assign  	mem_busy = if_busy | read_busy | write_busy ;

	//cnt
	always @(posedge clk) begin
		if (if_busy) begin
			if (cnt == 3'b100) begin
				cnt <= 3'b000;
			end
			else begin
				cnt <= cnt + 1'b1;
			end
		end 
		else if (read_busy || write_busy) begin
			if (cnt == sel_i) begin
				cnt <= 3'b000;
			end
			else begin
				cnt <= cnt + 1'b1;
			end
		end
		else begin
			cnt <= 3'b000;
		end 
	end

	//write & read
	always @(*) begin
		if (rst) begin
			mem_dout <= 8'h00;
			mem_a <= `Zero_Word;
			mem_wr <= `Disabled;
			cnt <= 3'b000;
			if_busy <= `Disabled;
			read_busy <= `Disabled;
			write_busy <= `Disabled;
		end
		else if (if_signal) begin
				if (cnt == 3'b000) begin
					if_busy <= `Enabled;
	                mem_a <= if_addr_i;
	                mem_wr <= 1'b0;
				end 
				else if (cnt == 3'b100) begin
					if_busy <= `Disabled;
					inst_o[31:24] <= mem_din;
				end
				else if (cnt == 3'b001) begin
				    mem_a <= if_addr_i + 3'b001;
					inst_o[7:0] <= mem_din;
				end
				else if (cnt == 3'b010) begin
                    mem_a <= if_addr_i + 3'b010;
					inst_o[15:8] <= mem_din;
				end
				else if (cnt == 3'b011) begin
                    mem_a <= if_addr_i + 3'b011;
					inst_o[23:16] <= mem_din;
				end
			end
		else if (we_i) begin
				if (cnt == 3'b000) begin
					write_busy <= `Enabled;
	                mem_a <= addr_i;
	                mem_dout <= data_i[7:0];
	                mem_wr <= 1'b1;
				end
				else if (cnt == sel_i) begin
					write_busy <= `Disabled;
					mem_wr <= 1'b0;
				end
				else if (cnt == 3'b001) begin
					mem_a <= addr_i + 3'b001;
					mem_dout <= data_i[15:8];
				end
				else if (cnt == 3'b010) begin
					mem_a <= addr_i + 3'b010;
					mem_dout <= data_i[23:16];
				end
				else if (cnt == 3'b011) begin
					mem_a <= addr_i + 3'b011;
					mem_dout <= data_i[31:24];
				end
		end
		else if (ce) begin
				if (cnt == 3'b000) begin
					read_busy <= `Enabled;
	                mem_a <= addr_i;
	                mem_wr <= 1'b0;
				end
				else if (cnt == sel_i) begin
					read_busy <= `Disabled;
					data_o[31:24] <= mem_din;
					cnt <= 3'b000;
				end
				else if (cnt == 3'b001) begin
				    mem_a <= addr_i + 3'b001;
					data_o[7:0] <= mem_din;
				end
				else if (cnt == 3'b010) begin
				    mem_a <= addr_i + 3'b010;
					data_o[15:8] <= mem_din;
				end
				else if (cnt == 3'b011) begin
				    mem_a <= addr_i + 3'b011;
					data_o[23:16] <= mem_din;
				end
		end
	end
endmodule