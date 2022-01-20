`timescale 1ns / 1ps

module ALU(
	input [3:0] ALUOP,
	input [31:0] SrcA,
	input [31:0] SrcB,
	input [4:0] SHF,
	output reg [31:0] ALUOut
    );
	
	parameter
	ADD = 0,
	SUB = 1,
	OR = 2, 
	LLEFT = 3;
	
	//when make shift, need to know the $sign and <<<
	always @(*) begin
		case(ALUOP)
			ADD:
				ALUOut = SrcA + SrcB;
			SUB:
				ALUOut = SrcA - SrcB;
			OR:
				ALUOut = SrcA | SrcB;
			LLEFT:
				ALUOut = SrcB << SHF;
			default:
				ALUOut = 32'dx;
		endcase
	end

endmodule