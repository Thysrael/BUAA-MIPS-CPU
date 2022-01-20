`timescale 1ns / 1ps

module EREG
	(
		input clk,
		input reset,
		input en,
		input [31:0] instrIn,
		input [31:0] PCIn,
		input [31:0] EXTOutIn,
		input [31:0] rsOutIn,
		input [31:0] rtOutIn,
		input CMPOutIn,
		output reg [31:0] instrOut,
		output reg [31:0] PCOut,
		output reg [31:0] EXTOutOut,
		output reg [31:0] rsOutOut,
		output reg [31:0] rtOutOut,
		output reg CMPOutOut
	);
	
	initial begin
		instrOut <= 0;
		PCOut <= 0;
		EXTOutOut <= 0;
		rsOutOut <= 0;
		rtOutOut <= 0;
		CMPOutOut <= 0;	
	end
	
    always @(posedge clk) begin
        if (reset) begin
            instrOut <= 0;
            PCOut <= 0;
            EXTOutOut <= 0;
            rsOutOut <= 0;
            rtOutOut <= 0;
			CMPOutOut <= 0;
        end 
		else if(en) begin
            instrOut <= instrIn;
            PCOut <= PCIn;
            EXTOutOut <= EXTOutIn;
            rsOutOut <= rsOutIn;
            rtOutOut <= rtOutIn;
			CMPOutOut <= CMPOutIn;
        end
    end	
	
endmodule 