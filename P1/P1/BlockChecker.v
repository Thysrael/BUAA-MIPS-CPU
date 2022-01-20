`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:56:57 10/23/2021 
// Design Name: 
// Module Name:    BlockChecker 
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
module BlockChecker(
    input clk,
	input reset,
	input [7:0] in,
	output result);
	
	parameter
	s0 = 0,
	s1 = 1,
	s2 = 2,
	s3 = 3,
	s4 = 4,
	s5 = 5,
	s6 = 6,
	s7 = 7,
	s8 = 8,
	s9 = 9,
	s10 = 10,
	s11 = 11,
	s12 = 12;
	
	reg [3:0] status, nextStatus;
	reg [31:0] cnt, nextCnt;
	
	initial
	begin
		status <= s0;
		cnt <= 0;
	end
	
	always @(posedge clk, posedge reset)
	begin
		if(reset)
			status <= s0;
		else
			status <= nextStatus;
	end
	
	always @(*)
	begin
		case(status)
			s0:
			begin
				if(in == "B" || in == "b")
					nextStatus = s1;
				else if(in == "E" || in == "e")
					nextStatus = s2;
				else if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s1:
			begin
				if(in == "E" || in == "e")
					nextStatus = s4;
				else if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s2:
			begin
				if(in == "N" || in == "n")
					nextStatus = s5;
				else if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s3:
			begin
				if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s4:
			begin
				if(in == "G" || in == "g")
					nextStatus = s6;
				else if(in == " ")
					nextStatus = s0;
				else 
					nextStatus = s3;
			end
			
			s5:
			begin
				if(in == "D" || in == "d")
					nextStatus = s7;
				else if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s6:
			begin
				if(in == "I" || in == "i")
					nextStatus = s8;
				else if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s7:
			begin
				if(in == " " && cnt == 0)
					nextStatus = s12;
				else if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s10;
			end
			
			s8:
			begin
				if(in == "N" || in == "n")
					nextStatus = s9;
				else if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s9:
			begin
				if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s11;
			end
			
			s10:
			begin
				if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s11:
			begin
				if(in == " ")
					nextStatus = s0;
				else
					nextStatus = s3;
			end
			
			s12:
				nextStatus = status;
		endcase
	end
	
	always @(posedge clk, posedge reset)
	begin
		if(reset)
			cnt <= 0;
		else
			cnt <= nextCnt;
	end

	always @(*)
	begin
		if(status == s12)
			nextCnt = -1;
		else if(cnt[31] == 1)
			nextCnt = cnt;
		if(status == s7 || status == s11)
			nextCnt = cnt - 1;
		else if(status == s9 || status == s10)
			nextCnt = cnt + 1;
		else
			nextCnt = cnt;
	end	
	
	assign result = (nextCnt == 0)? 1:0;
	
endmodule
