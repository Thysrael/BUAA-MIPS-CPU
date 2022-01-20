`timescale 1ns / 1ps

module DREG
	(
		input clk,
		input reset,
		input Req,
		input en,
		
		input [31:0] instrIn,
		input [31:0] PCIn,
		input [4:0] ExcCodeIn,
		input BDIn,
		output reg [4:0] ExcCodeOut,
		output reg BDOut,
		output reg [31:0] instrOut,
		output reg [31:0] PCOut
	);
	
	reg [31:0] nextPC;
	
	always @(*) begin
		if(reset) nextPC = 32'h3000;
		else if(Req) nextPC = 32'h4180;
		else if(en) nextPC = PCIn;
		else nextPC = PCOut; //stay at value
	end
	
	initial begin
		instrOut <= 32'h0;
		PCOut <= 32'h3000;
		ExcCodeOut <= 0;
		BDOut <= 0;
	end
	
	always @(posedge clk) begin
		if(reset | Req) begin
			instrOut <= 32'h0;
			ExcCodeOut <= 0;
			BDOut <= 0;
		end
		else if(en) begin
			instrOut <= instrIn;
			ExcCodeOut <= ExcCodeIn;
			BDOut <= BDIn;
		end
	end
	
	always @(posedge clk) begin
		PCOut <= nextPC;
	end
	
endmodule 