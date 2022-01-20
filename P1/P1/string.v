`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:00:30 10/23/2021 
// Design Name: 
// Module Name:    string 
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
module string(
    input clk,
	input clr,
	input [7:0] in,
	output out);
	
	parameter
	s0 = 0,
	s1 = 1,
	s2 = 2,
	s3 = 3;
	
	reg [1:0] status, nextStatus;
	wire isNum, isOp;
	
	initial
	begin
		status <= s0;
	end
	
	assign isNum = (in >= "0" && in <= "9")? 1:0;
	assign isOp = (in == "+" || in == "*")? 1:0;
	
	always @(posedge clk, posedge clr)
	begin
		if(clr)
			status <= s0;
		else
			status <= nextStatus;
	end
	
	always @(*)
	begin
		case(status)
			s0:
			begin
				if(isNum)
					nextStatus = s2;
				else
					nextStatus = s1;
			end	
			
			s1:
			begin
				nextStatus = s1;
			end
			
			s2:
			begin
				if(isOp)
					nextStatus = s3;
				else
					nextStatus = s1;
			end
			
			s3:
			begin
				if(isNum)
					nextStatus = s2;
				else
					nextStatus = s1;
			end
		endcase
	end
	
	assign out = (status == s2)?1:0;

endmodule
