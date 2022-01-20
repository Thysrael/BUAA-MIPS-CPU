`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:14:18 10/23/2021
// Design Name:   string
// Module Name:   E:/learn/semester3/ComputerSystem/verilog/P1/string_tb.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: string
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module string_tb;

	// Inputs
	reg clk;
	reg clr;
	reg [7:0] in;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	string uut (
		.clk(clk), 
		.clr(clr), 
		.in(in), 
		.out(out)
	);

	initial
	begin
		clk = 0;
	end
	
	always #5 clk = ~clk;
	
	initial 
	begin
		clr = 1;
		#2
		clr = 0;
	end
    
	initial
	begin
	in = "1";
	#10 in = "+";
	#10 in = "2";
	#10 in = "*";
	#10 in = "3";
	#10 in = "+";
	#10 in = "4";
	#10 in = "5";
	#10 in = "6";
	#10 in = "+";
	#10 in = "7";
	#10 in = "*";
	#10 in = "8";
	#10 in = "+";
	
	end
	
endmodule

