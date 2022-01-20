`timescale 1ns / 1ps
`define WORD DM[DMAdd[13:2]]
`define HALF `WORD[16 * DMAdd[1] +: 16]
`define BYTE `WORD[8 * DMAdd[1:0] +: 8]

module DM(
	input [31:0] PC,//for debugging
	input clk,
	input reset,
	input en,
	input [3:0] DMOP,
	input [31:0] DMAdd,
	input [31:0] DMIn,
	output reg [31:0] DMOut
    );

	parameter
	W = 0,
	B = 1,
	H = 2;
	
	integer i;
	reg [31:0] DM [0:4096];
	
	initial begin
		for(i = 0; i < 4096; i = i + 1)
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

	//write logic
	reg [31:0] nextDMIn;
	always @(*) begin
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
			for(i = 0; i < 4096; i = i + 1)
				DM[i] <= 32'd0;
		else if(en) begin
			`WORD <= nextDMIn;
			$display("%d@%h: *%h <= %h", $time, PC, DMAdd, nextDMIn);
		end			
	end
	
endmodule