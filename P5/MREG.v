`timescale 1ns / 1ps

module MREG
	(
		input clk,
		input reset,
		input en,
		input [31:0] instrIn,
		input [31:0] PCIn,
		input [31:0] ALUOutIn,
		input [31:0] rtOutIn,
		input [31:0] EXTOutIn,
		input CMPOutIn,
		output reg [31:0] instrOut,
		output reg [31:0] PCOut,
		output reg [31:0] ALUOutOut,
		output reg [31:0] rtOutOut,
		output reg [31:0] EXTOutOut,
		output reg CMPOutOut
	);
	
	initial begin
		instrOut <= 32'd0;
		PCOut <= 32'h3000;
		ALUOutOut <= 32'd0;
		rtOutOut <= 32'd0;
		EXTOutOut <= 32'd0;
		CMPOutOut <= 1'd0;	
	end
	
	always @(posedge clk) begin
		if(reset) begin
			instrOut <= 32'd0;
			PCOut <= 32'h3000;
			ALUOutOut <= 32'd0;
			rtOutOut <= 32'd0;
			EXTOutOut <= 32'd0;
			CMPOutOut <= 1'd0;
		end
		else if(en) begin
			instrOut <= instrIn;
			PCOut <= PCIn;
			ALUOutOut <= ALUOutIn;
			rtOutOut <= rtOutIn;
			EXTOutOut <= EXTOutIn;
			CMPOutOut <= CMPOutIn;
		end
	end
	
endmodule 