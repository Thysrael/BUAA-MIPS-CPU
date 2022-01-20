`timescale 1ns / 1ps
`include "CONST.v"

module IFU
	(
		input clk,
		input reset,
		input Req,
		input en,
		input D_eret,
		input [31:0] nextPC,
		input [31:0] EPC,
		output [31:0] PC,
		output AdEL
	);
	
	//tmpPC起了真正PC寄存器的作用
	reg [31:0] tmpPC;
	
	assign PC = (D_eret)? EPC : tmpPC;
	
	initial begin
		tmpPC <= 32'h3000;
	end
	
	always @(posedge clk) begin
		if(reset)
			tmpPC <= 32'h3000;
		else if(Req)
			tmpPC <= 32'h4180;
		else if(en)
			tmpPC <= nextPC;
	end
	
	//about the AdEL
	 assign AdEL = ((|PC[1:0]) || (PC < `IMLL) || (PC > `IMUL));
	 //assign AdEL = ((PC[1:0]) || (PC < `IMLL) || (PC > `IMUL)) && (~D_eret);
	 
	
endmodule 