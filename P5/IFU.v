`timescale 1ns / 1ps

module IFU
	(
		input clk,
		input reset,
		input en,
		input [31:0] nextPC,
		output [31:0] instr,
		output reg [31:0] PC
	);
	
	reg [31:0] IM[3072:7167];
	
	assign instr = IM[PC[14:2]];
	
	initial begin
		PC <= 32'h0000_3000;
		$readmemh("code.txt", IM);
	end
	
	always @(posedge clk) begin
		if(reset)
			PC <= 32'h0000_3000;
		else if(en)
			PC <= nextPC;
	end
	
endmodule 