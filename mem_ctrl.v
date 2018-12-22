module mem_ctrl(
	input wire 				clk,

	input wire[`Reg_Bus] 	addr_i,
	input wire				we_i, // if write
	input wire[3:0] 		sel_i,
	input wire[`Reg_Bus] 	data_i,
	input wire 				ce;

	output wire 				mem_busy,
	//to ram
	input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output reg[`Reg_Bus]	data_o,
);
//TODO
	reg[3:0] NumtoRead;

	//write
	always @(posedge clk) begin
		if (rst || !ce) begin
			mem_dout <= 8'h00;
			mem_a <= `Zero_Word;
			mem_wr <= `Disabled;
		end
		else if () begin
			mem_a <= addr_i;

		end
	end
endmodule