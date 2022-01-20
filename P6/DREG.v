`timescale 1ns / 1ps

module DREG
	(
		input clk,
		input reset,
		input en,
		input [31:0] instrIn,
		input [31:0] PCIn,
		output reg [31:0] instrOut,
		output reg [31:0] PCOut
	);
	
	initial begin
		instrOut <= 32'h0;
		PCOut <= 32'h0000_3000;
	end
	
	always @(posedge clk) begin
		if(reset)
			instrOut <= 32'h0;
		else if(en)
			instrOut <= instrIn;
	end
	
	always @(posedge clk) begin
		if(reset)
			PCOut <= 32'h0000_3000; //这里有疑问
		else if(en)
			PCOut <= PCIn;
	end
	
endmodule 