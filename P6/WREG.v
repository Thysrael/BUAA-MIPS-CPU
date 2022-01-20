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
	input [31:0] rsOutIn,
	input [31:0] rtOutIn,
	input [31:0] MDUOutIn,
	input flag1In,
	input flag2In,
	input flag3In,
    output reg [31:0] instrOut,
    output reg [31:0] PCOut,
    output reg [31:0] ALUOutOut,
    output reg [31:0] DMOutOut,
	output reg [31:0] EXTOutOut,
	output reg [31:0] rsOutOut,
	output reg [31:0] rtOutOut,
	output reg [31:0] MDUOutOut,
	output reg flag1Out,
	output reg flag2Out,
	output reg flag3Out
);

	initial begin
		instrOut <= 0;
		PCOut <= 0;
		ALUOutOut <= 0;
		DMOutOut <= 0;
		EXTOutOut <= 0;
		rsOutOut <= 0;
		rtOutOut <= 0;
		MDUOutOut <= 0;
		flag1Out <= 0;
		flag2Out <= 0;
		flag3Out <= 0;
	end

    always @(posedge clk) begin
        if (reset) begin
            instrOut <= 0;
            PCOut <= 0;
            ALUOutOut <= 0;
            DMOutOut <= 0;
			EXTOutOut <= 0;
			rsOutOut <= 0;
			rtOutOut <= 0;
			MDUOutOut <= 0;
			flag1Out <= 0;
			flag2Out <= 0;
			flag3Out <= 0;
        end else if(en) begin
            instrOut <= instrIn;
            PCOut <= PCIn;
            ALUOutOut <= ALUOutIn;
            DMOutOut <= DMOutIn;
			EXTOutOut <= EXTOutIn;
			rsOutOut <= rsOutIn;
			rtOutOut <= rtOutIn;
			MDUOutOut <= MDUOutIn;
			flag1Out <= flag1In;
			flag2Out <= flag2In;
			flag3Out <= flag3In;
        end
    end

endmodule 