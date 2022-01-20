`timescale 1ns / 1ps

module ALU(
	input [4:0] ALUOP,
	input [31:0] SrcA,
	input [31:0] SrcB,
	input [4:0] SHF,
	output reg [31:0] ALUOut,
	
	input isCalSigned,
	input isCalAddLoad,
	input isCalAddStore,
	output Ov,
	output AdEL,
	output AdES
    );
	
	parameter
	ADD = 0,
	SUB = 1,
	OR = 2, 
	SLLV = 3,
	SRLV = 4,
	SRAV = 5,
	SLT = 6,
	SLTU = 7,
	SLL = 8,
	SRL = 9,
	SRA = 10,
	AND = 11,
	XOR = 12,
	NOR = 13;
	
	//when make shift, need to know the $sign and <<<
	
	wire [31:0] res_slt = $signed(SrcA) < $signed(SrcB) ? 32'b1 : 32'b0;
	
	always @(*) begin
		case(ALUOP)
			ADD :	ALUOut = SrcA + SrcB;
			SUB :	ALUOut = SrcA - SrcB;
			OR 	:	ALUOut = SrcA | SrcB;
			SLLV :	ALUOut = SrcB << SrcA[4:0];
			SRLV :	ALUOut = SrcB >> SrcA[4:0];
			SRAV :  ALUOut = $signed($signed(SrcB) >>> SrcA[4:0]);
			SLT :	ALUOut = res_slt;
			SLTU : 	ALUOut = (SrcA < SrcB);
			SLL :   ALUOut = SrcB << SHF;
			SRL : 	ALUOut = SrcB >> SHF;
			SRA : 	ALUOut = $signed($signed(SrcB) >>> SHF);
			AND : 	ALUOut = SrcA & SrcB;
			XOR	:	ALUOut = SrcA ^ SrcB;
			NOR	:	ALUOut = ~(SrcA | SrcB);
			default :	ALUOut = SrcA + SrcB;
		endcase
	end
	
	//about exception
	wire [32:0] exA = {SrcA[31], SrcA};
	wire [32:0] exB = {SrcB[31], SrcB};
	wire [32:0] exAdd = exA + exB;
	wire [32:0] exSub = exA - exB;
	
	assign Ov = isCalSigned && (((ALUOP == ADD) && (exAdd[32] != exAdd[31])) || ((ALUOP == SUB) && (exSub[32] != exSub[31]))); 
	assign AdEL = isCalAddLoad && (exAdd[32] != exAdd[31]);
	assign AdES = isCalAddStore && (exAdd[32] != exAdd[31]);
	
endmodule