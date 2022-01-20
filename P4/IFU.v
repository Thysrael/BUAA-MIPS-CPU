`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:25:10 11/14/2021 
// Design Name: 
// Module Name:    IFU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module IFU(
	input clk,
	input reset,
	input [31:0] nextPC,
	output reg [31:0] PC,
	output [31:0] instr
    );

	reg [31:0] IM [0:1023];

	initial begin
		PC <= 32'h0000_3000;
		$readmemh("code.txt", IM);
	end
	
	always @(posedge clk) begin
		if(reset)
			PC <= 32'h0000_3000;
		else
			PC <= nextPC;
	end
	
	assign instr = IM[PC[11:2]];

endmodule
