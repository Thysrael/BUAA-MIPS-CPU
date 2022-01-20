`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:49 10/23/2021 
// Design Name: 
// Module Name:    gray 
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
module gray(
    input Clk,
    input Reset,
    input En,
    output [2:0] Output,
    output Overflow);
    
	parameter
	s0 = 'b000,
	s1 = 'b001,
	s2 = 'b011,
	s3 = 'b010,
	s4 = 'b110,
	s5 = 'b111,
	s6 = 'b101,
	s7 = 'b100;
	
    reg[2:0] status, nextStatus;
    reg over, nextOver;
	
	initial
	begin
		status <= s0;
		over <= 0;
	end
    
    always @(posedge Clk) 
    begin
        if(Reset)
            status <= s0;
        else
			status <= nextStatus;
    end
	
	always @(*)
	begin
		case(status)
		s0:
			if(En)
				nextStatus = s1;
			else
				nextStatus = status;
		s1:
			if(En)
				nextStatus = s2;
			else
				nextStatus = status;
		s2:
			if(En)
				nextStatus = s3;
			else
				nextStatus = status;
		s3:
			if(En)
				nextStatus = s4;
			else
				nextStatus = status;
		s4:
			if(En)
				nextStatus = s5;
			else
				nextStatus = status;
		s5:
			if(En)
				nextStatus = s6;
			else
				nextStatus = status;
		s6:
			if(En)
				nextStatus = s7;
			else
				nextStatus = status;				
		s7:
			if(En)
				nextStatus = s0;
			else
				nextStatus = status;
		endcase
	end

	assign Output = status;
	
	always @(posedge Clk)
	begin
		if(Reset)
			over <= 0;
		else
			over <= nextOver;
	end
	
	always @(*)
	begin
		case(status)
			3'b100:
				nextOver = 1;
			default:
				if(Reset)
					nextOver = 0;
				else
					nextOver = over;
		endcase
	end


	assign Overflow = over;
	
endmodule
