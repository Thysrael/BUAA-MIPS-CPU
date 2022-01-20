`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:13:58 11/13/2021 
// Design Name: 
// Module Name:    mips 
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
module mips(
	input clk,
	input reset
    );
	
	wire
	RegWrite,
	MemWrite,
	CMPOut;
	
	wire [2:0]
	RegInSel,
	RegAdd3Sel,
	SrcBSel,
	BranchSel;
	
	wire [3:0]
	NPCOP,
	GRFOP,
	EXTOP,
	ALUOP,
	CMPOP,
	DMOP;
	
	wire [4:0]
	rs,
	rt,
	rd,
	RegAdd1,
	RegAdd2,
	RegAdd3,
	SHF,
	shamt;
	
	wire [5:0]
	opcode,
	funcode;
	
	wire [25:0]
	imm26;
	
	wire [31:0] 
	PC, 
	nextPC, 
	instr,
	branch,
	RegIn,
	RegOut1,
	RegOut2,
	EXTOut,
	ALUOut,
	DMOut,
	SrcA,
	SrcB,
	num1,
	num2,
	DMAdd,
	DMIn;
	
	//split the instr
	assign rs = instr[25:21];
	assign rt = instr[20:16];
	assign rd = instr[15:11];
	assign shamt = instr[10:6];
	assign opcode = instr[31:26];
	assign funcode = instr[5:0];
	assign imm26 = instr[25:0];
 	
	//about IFU
	IFU ifu(
		.clk(clk), 
		.reset(reset), 
		.nextPC(nextPC), 
		.PC(PC), 
		.instr(instr)
		);
	
	//about NPC	
	NPC npc(
		.PC(PC), 
		.branch(branch), 
		.nextPC(nextPC), 
		.NPCOP(NPCOP)
		);
	MUX8 BranchMux(
		.out(branch),
		.sel(BranchSel),
		.in0(RegOut1),
		.in1(EXTOut)
		);
	
	//about GRF
	GRF grf(
		.PC(PC), 
		.clk(clk), 
		.reset(reset), 
		.RegAdd1(RegAdd1), 
		.RegAdd2(RegAdd2), 
		.RegAdd3(RegAdd3),
		.RegIn(RegIn),
		.RegOut1(RegOut1),
		.RegOut2(RegOut2),
		.RegWrite(RegWrite),
		.GRFOP(GRFOP)
		);
	assign RegAdd1 = rs;
	assign RegAdd2 = rt;
	MUX8 #(5) RegAdd3Mux(
			.out(RegAdd3),
			.sel(RegAdd3Sel),
			.in0(rt),
			.in1(rd)
			);
	MUX8 RegInMux(
			.out(RegIn),
			.sel(RegInSel),
			.in0(ALUOut),
			.in1(DMOut),
			.in2(PC),
			.in3(EXTOut)
			);
	
	//about EXT
	EXT ext(
		.EXTIn(imm26),
		.EXTOut(EXTOut),
		.EXTOP(EXTOP)
		);
		
	//about ALU
	ALU alu(
		.SrcA(SrcA),
		.SrcB(SrcB),
		.SHF(SHF),
		.ALUOut(ALUOut),
		.ALUOP(ALUOP)
		);
	assign SrcA = RegOut1;
	MUX8 SrcBMux(
			.out(SrcB),
			.sel(SrcBSel),
			.in0(RegOut2),
			.in1(EXTOut)
			);
	assign SHF = shamt;
	
	//about CMP
	CMP cmp(
		.num1(num1),
		.num2(num2),
		.CMPOut(CMPOut),
		.CMPOP(CMPOP)
		);
	assign num1 = RegOut1;
	assign num2 = RegOut2;
	
	//about DM
	DM dm(
		.PC(PC),
		.clk(clk),
		.reset(reset),
		.DMAdd(DMAdd),
		.DMIn(DMIn),
		.DMOut(DMOut),
		.MemWrite(MemWrite),
		.DMOP(DMOP)
		);
	assign DMAdd = ALUOut;
	assign DMIn = RegOut2;
	
	CU cu(
		.opcode(opcode),
		.funcode(funcode),
		.CMPOut(CMPOut),
		.NPCOP(NPCOP),
		.RegWrite(RegWrite),
		.GRFOP(GRFOP),
		.EXTOP(EXTOP),
		.ALUOP(ALUOP),
		.CMPOP(CMPOP),
		.DMOP(DMOP),
		.MemWrite(MemWrite),
		.BranchSel(BranchSel),
		.RegInSel(RegInSel),
		.RegAdd3Sel(RegAdd3Sel),
		.SrcBSel(SrcBSel)
		);
	
    DASM dasm(
        .pc(PC),
        .instr(instr),
        .imm_as_dec(1'b1),
        .reg_name(1'b1),
        .asm()
    );
	
endmodule
