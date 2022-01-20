`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:08:34 10/23/2021
// Design Name:   gray
// Module Name:   E:/learn/semester3/ComputerSystem/verilog/P1/tb_gray.v
// Project Name:  P1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gray
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_gray;

	// Inputs
	reg Clk;
	reg Reset;
	reg En;

	// Outputs
	wire [2:0] Output;
	wire Overflow;

	// Instantiate the Unit Under Test (UUT)
	gray uut (
		.Clk(Clk), 
		.Reset(Reset), 
		.En(En), 
		.Output(Output), 
		.Overflow(Overflow)
	);
	
	initial
	begin
		Clk = 0;
	end
	
	initial
	begin
		Reset = 1;
		#7
		Reset = 0;
		#93
		Reset = 1;
		#21
		Reset = 0;
	end
	
	initial
	begin
		En = 0;
		#7
		En = 1;
		#180
		En = 0;
		#20
		En = 1;
	end
	
	always #5 Clk = ~Clk;
      
endmodule

