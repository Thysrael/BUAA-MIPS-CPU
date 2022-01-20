`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:59:38 11/14/2021 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
	input [31:0] SrcA,
	input [31:0] SrcB,
	input [4:0] SHF,
	output reg [31:0] ALUOut,
	input [3:0] ALUOP
    );
	
	parameter
	ADD = 0,
	SUB = 1,
	OR = 2;
	
	always @(*) begin
		case(ALUOP)
			ADD:
				ALUOut = SrcA + SrcB;
			SUB:
				ALUOut = SrcA - SrcB;
			OR:
				ALUOut = SrcA | SrcB;
			default:
				ALUOut = 32'dx;
		endcase
	end

endmodule
