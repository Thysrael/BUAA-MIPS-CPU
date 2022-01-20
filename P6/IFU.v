`timescale 1ns / 1ps

module IFU
	(
		input clk,
		input reset,
		input en,
		input [31:0] nextPC,
		output reg [31:0] PC
	);
	
	initial begin
		PC <= 32'h0000_3000;
	end
	
	always @(posedge clk) begin
		if(reset)
			PC <= 32'h0000_3000;
		else if(en)
			PC <= nextPC;
	end
	
endmodule 