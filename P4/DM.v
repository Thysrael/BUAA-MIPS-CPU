`timescale 1ns / 1ps
`define WORD DM[DMAdd[11:2]]
`define HALF `WORD[16 * DMAdd[1] +: 16]
`define BYTE `WORD[8 * DMAdd[1:0] +: 8]
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:30:58 11/14/2021 
// Design Name: 
// Module Name:    DM 
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
module DM(
	input [31:0] PC,
	input clk,
	input reset,
	input [31:0] DMAdd,
	input [31:0] DMIn,
	output reg [31:0] DMOut,
	input MemWrite,
	input [3:0] DMOP
    );

	parameter
	W = 0,
	B = 1,
	H = 2;
	
	integer i;
	reg [31:0] DM [0:1023];
	
	
	initial begin
		for(i = 0; i < 1024; i = i + 1)
			DM[i] <= 32'd0;
	end
	
	//read logic
	wire [15:0] half;
	wire [7:0] Byte;
	assign half = `HALF;
	assign Byte = `BYTE;
	always @(*) begin
		case(DMOP)
			W:
				DMOut = `WORD;
			H:
				DMOut = {{16{half[15]}}, half};
			B:
				DMOut = {{24{Byte[7]}}, Byte};
			default
				DMOut = 32'dx;
		endcase
	end

	//write logic, I can't seperate it into two parts, it's complicated
	reg [31:0] nextDMIn;
	always @(*) begin
		//initial，先取出要覆盖的值，然后再修改，然后再赋值
		nextDMIn = `WORD;
		case(DMOP)
			H:
				nextDMIn[16 * DMAdd[1] +: 16] = DMIn[15:0];
			B:
				nextDMIn[8 * DMAdd[1:0] +: 8] = DMIn[7:0];
			default:
				nextDMIn = DMIn;
		endcase
	end
	
	always @(posedge clk) begin
		if(reset)
			for(i = 0; i < 1024; i = i + 1)
				DM[i] <= 32'd0;
		else if(MemWrite) begin
			DM[DMAdd[11:2]] <= nextDMIn;
			$display("@%h: *%h <= %h", PC, DMAdd, nextDMIn);//这里好像不能正确de出值，因为不考虑HALF和BYTE
		end			
	end
	
endmodule
