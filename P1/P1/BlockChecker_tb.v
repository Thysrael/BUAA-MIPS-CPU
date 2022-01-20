`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:40:00 10/23/2021
// Design Name:   BlockChecker
// Module Name:   E:/learn/semester3/ComputerSystem/verilog/P1/BlockChecker_tb.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BlockChecker
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module BlockChecker_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	BlockChecker uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.result(result)
	);

	initial
	begin
		clk = 0;
	end
	
	always #5 clk = ~clk;
	
	initial 
	begin
		reset = 1;
		#2 reset = 0;
	end
	
	initial
	begin
		in = "a";
		#10 in = "B";
		#10 in = "E";
		#10 in = "G";
		#10 in = "I";
		#10 in = "N";
		#10 in = " ";
		#10 in = "B";
		#10 in = "E";
		#10 in = "G";
		#10 in = "I";
		#10 in = "N";
		#10 in = " ";
		#10 in = "b";
		#10 in = "e";
		#10 in = "g";
		#10 in = "i";
		#10 in = "n";
		#10 in = " ";		
		#10 in = "e";
		#10 in = "n";
		#10 in = "d";
		#10 in = " ";
		#10 in = "E";
		#10 in = "N";
		#10 in = "D";
		#10 in = " ";
		#10 in = "E";
		#10 in = "N";
		#10 in = "D";
		#10 in = "C";
		#10 in = " ";
		#10 in = " ";
		#10 in = "e";
		#10 in = "n";
		#10 in = "d";
		#10 in = " ";
	end
	
      
endmodule

