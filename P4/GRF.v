`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:41:03 11/14/2021 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
	input [31:0] PC,
	input clk,
	input reset,
	input [4:0] RegAdd1,
	input [4:0] RegAdd2,
	input [4:0] RegAdd3,
	input [31:0] RegIn,
	output [31:0] RegOut1,
	output [31:0] RegOut2,
	input RegWrite,
	input [3:0] GRFOP
    );
	
	parameter
	FULL = 0,
	LUI = 1,
	LINK = 2,
	SET = 3;
	
	integer i;
	reg [31:0] nextRegIn, nextRegAdd3;	
	reg [31:0] GRF [0:31];
	
	assign RegOut1 = GRF[RegAdd1];
	assign RegOut2 = GRF[RegAdd2];
	

	initial begin
		for(i = 0; i < 32; i = i + 1) begin
			GRF[i] <= 0;
		end
	end
	
	always @(*) begin
		case(GRFOP)
			FULL:
				nextRegIn = RegIn;
			LINK:
				nextRegIn = PC + 4;
			LUI:
				nextRegIn = (RegIn << 16);
			SET:
				nextRegIn = 32'd1;
			default:
				nextRegIn = 32'dx;
		endcase
	end
	
	always @(*) begin
		case(GRFOP)
			FULL,
			LUI,
			SET:
				nextRegAdd3 = RegAdd3;
			LINK:
				nextRegAdd3 = 5'd31;
			default:
				nextRegAdd3 = RegAdd3;
		endcase
	end
	
	always @(posedge clk) begin
		if(reset)
			for(i = 0; i < 32; i = i + 1) begin
				GRF[i] <= 0;
			end
		else if(RegWrite)
			if(nextRegAdd3) begin 
				GRF[nextRegAdd3] <= nextRegIn;
				$display("@%h: $%d <= %h", PC, nextRegAdd3, nextRegIn);
			end	
	end


endmodule
