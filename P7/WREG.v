`timescale 1ns / 1ps

module WREG (
    input clk,
    input reset,
    input en,
	input Req,
	
    input [31:0] instrIn,
    input [31:0] PCIn,
    input [31:0] ALUOutIn,
    input [31:0] DMOutIn,
	input [31:0] EXTOutIn,
	input [31:0] rsOutIn,
	input [31:0] rtOutIn,
	input [31:0] MDUOutIn,
	input [31:0] CP0OutIn,
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
	output reg [31:0] CP0OutOut,
	output reg flag1Out,
	output reg flag2Out,
	output reg flag3Out
);

	reg [31:0] nextPC;
	
	always @(*) begin
		if(reset) nextPC = 32'h3000;
		else if(Req) nextPC = 32'h4180;
		else if(en) nextPC = PCIn;
		else nextPC = PCOut; //stay at value
	end
	
	initial begin
		instrOut <= 0;
		PCOut <= 32'h3000;
		ALUOutOut <= 0;
		DMOutOut <= 0;
		EXTOutOut <= 0;
		rsOutOut <= 0;
		rtOutOut <= 0;
		MDUOutOut <= 0;
		CP0OutOut <= 0;
		flag1Out <= 0;
		flag2Out <= 0;
		flag3Out <= 0;
	end

    always @(posedge clk) begin
        if (reset | Req) begin
            instrOut <= 0;
            ALUOutOut <= 0;
            DMOutOut <= 0;
			EXTOutOut <= 0;
			rsOutOut <= 0;
			rtOutOut <= 0;
			MDUOutOut <= 0;
			CP0OutOut <= 0;
			flag1Out <= 0;
			flag2Out <= 0;
			flag3Out <= 0;
        end 
		else if(en) begin
            instrOut <= instrIn;
            ALUOutOut <= ALUOutIn;
            DMOutOut <= DMOutIn;
			EXTOutOut <= EXTOutIn;
			rsOutOut <= rsOutIn;
			rtOutOut <= rtOutIn;
			MDUOutOut <= MDUOutIn;
			CP0OutOut <= CP0OutIn;
			flag1Out <= flag1In;
			flag2Out <= flag2In;
			flag3Out <= flag3In;
        end
		
		PCOut <= nextPC;
    end

endmodule 