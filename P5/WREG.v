`timescale 1ns / 1ps

module WREG (
    input clk,
    input reset,
    input en,
    input [31:0] instrIn,
    input [31:0] PCIn,
    input [31:0] ALUOutIn,
    input [31:0] DMOutIn,
	input [31:0] EXTOutIn,
	input CMPOutIn,
    output reg [31:0] instrOut,
    output reg [31:0] PCOut,
    output reg [31:0] ALUOutOut,
    output reg [31:0] DMOutOut,
	output reg [31:0] EXTOutOut,
	output reg CMPOutOut
);

	initial begin
		instrOut <= 0;
		PCOut <= 0;
		ALUOutOut <= 0;
		DMOutOut <= 0;
		EXTOutOut <= 0;
		CMPOutOut <= 0;	
	end

    always @(posedge clk) begin
        if (reset) begin
            instrOut <= 0;
            PCOut <= 0;
            ALUOutOut <= 0;
            DMOutOut <= 0;
			EXTOutOut <= 0;
			CMPOutOut <= 0;
        end else if(en) begin
            instrOut <= instrIn;
            PCOut <= PCIn;
            ALUOutOut <= ALUOutIn;
            DMOutOut <= DMOutIn;
			EXTOutOut <= EXTOutIn;
			CMPOutOut <= CMPOutIn;
        end
    end

endmodule 