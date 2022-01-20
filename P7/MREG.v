`timescale 1ns / 1ps

module MREG
	(
		input clk,
		input reset,
		input en,
		input Req,
		
		input [31:0] instrIn,
		input [31:0] PCIn,
		input [31:0] ALUOutIn,
		input [31:0] rtOutIn,
		input [31:0] rsOutIn,
		input [31:0] EXTOutIn,
		input [31:0] MDUOutIn,
		input flag1In,
		input flag2In,
		input BDIn,
		input [4:0] ExcCodeIn,
		output reg [31:0] instrOut,
		output reg [31:0] PCOut,
		output reg [31:0] ALUOutOut,
		output reg [31:0] rtOutOut,
		output reg [31:0] rsOutOut,
		output reg [31:0] EXTOutOut,
		output reg [31:0] MDUOutOut,
		output reg flag1Out,
		output reg flag2Out,
		output reg BDOut,
		output reg [4:0] ExcCodeOut
	);
	
	reg [31:0] nextPC;
	
	always @(*) begin
		if(reset) nextPC = 32'h3000;
		else if(Req) nextPC = 32'h4180;
		else if(en) nextPC = PCIn;
		else nextPC = PCOut; //stay at value
	end
	
	initial begin
		instrOut <= 32'd0;
		PCOut <= 32'h3000;
		ALUOutOut <= 32'd0;
		rsOutOut <= 32'd0;
		rtOutOut <= 32'd0;
		EXTOutOut <= 32'd0;
		MDUOutOut <= 32'd0;
		flag1Out <= 1'd0;
		flag2Out <= 1'd0;
		BDOut <= 0;
		ExcCodeOut <= 0;
	end
	
	always @(posedge clk) begin
		if(reset | Req) begin
			instrOut <= 32'd0;
			ALUOutOut <= 32'd0;
			rsOutOut <= 32'd0;
			rtOutOut <= 32'd0;
			EXTOutOut <= 32'd0;
			MDUOutOut <= 32'd0;
			flag1Out <= 1'd0;
			flag2Out <= 1'd0;
			BDOut <= 0;
			ExcCodeOut <= 0;
		end
		else if(en) begin
			instrOut <= instrIn;
			ALUOutOut <= ALUOutIn;
			rsOutOut <= rsOutIn;
			rtOutOut <= rtOutIn;
			EXTOutOut <= EXTOutIn;
			MDUOutOut <= MDUOutIn;
			flag1Out <= flag1In;
			flag2Out <= flag2In;
			BDOut <= BDIn;
			ExcCodeOut <= ExcCodeIn;
		end
		
		PCOut <= nextPC;
	end
	
endmodule 