`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//template
//
/*

LoadFromDM
RegWrite = 1;
RegAdd3Sel = RegAdd3Sel_rt/rd;
RegInSel = RegInSel_DMOut;
GRFOP = GRFOP_FULL;

LoadFromALU
RegWrite = 1;
RegAdd3Sel = RegAdd3Sel_rd/rt;
RegInSel = RegInSel_ALUOut;
GRFOP = GRFOP_FULL;

caculate1
EXTOP = EXTOP_ZE16/SE16;
SrcBSel = SrcBSel_EXTOut;
ALUOP = ALUOP_;

caculate2
SrcBSel = SrcBSel_RegOut2;
ALUOP = ALUOP_;

Store
MemWrite = 1;
DMOP = DMOP_W/H/B;

*/
//////////////////////////////////////////////////////////////////////////////////
module CU(
	input [5:0] opcode,
	input [5:0] funcode,
	input CMPOut,
	output reg [3:0] NPCOP,
	output reg [3:0] GRFOP,
	output reg [3:0] EXTOP,
	output reg [3:0] ALUOP,
	output reg [3:0] CMPOP,
	output reg [3:0] DMOP,
	output reg RegWrite,
	output reg MemWrite,
	output reg [2:0] BranchSel,
	output reg [2:0] RegInSel,
	output reg [2:0] RegAdd3Sel,
	output reg [2:0] SrcBSel
    );
	
	//NPC signal
	parameter
	NPCOP_NORMAL = 0,
	NPCOP_BRANCH = 1,
	NPCOP_J = 2,
	NPCOP_JR = 3;
	
	//GRF signal
	parameter
	GRFOP_FULL = 0,
	GRFOP_LUI = 1,
	GRFOP_LINK = 2,
	GRFOP_SET = 3;
	
	//EXT signal
	parameter
	EXTOP_ZE16 = 0,
	EXTOP_SE16 = 1,
	EXTOP_ZE26 = 2;

	//ALU signal
	parameter
	ALUOP_ADD = 0,
	ALUOP_SUB = 1,
	ALUOP_OR = 2;
	
	//CMP signal
	parameter
	CMPOP_EQ = 0,
	CMPOP_G = 1,
	CMPOP_LT = 2,
	CMPOP_NE = 3,
	CMPOP_GE = 4,
	CMPOP_LE = 5,
	CMPOP_EQZ = 6,
	CMPOP_GTZ = 7,
	CMPOP_LTZ = 8,
	CMPOP_NEZ = 9,
	CMPOP_GEZ = 10,
	CMPOP_LEZ = 11;

	//DM siganl
	parameter
	DMOP_W = 0,
	DMOP_B = 1,
	DMOP_H = 2;

	//RegInSel signal
	parameter
	RegInSel_ALUOut = 0,
	RegInSel_DMOut = 1,
	RegInSel_PC = 2,
	RegInSel_EXTOut = 3;
	
	//RegAdd3Sel signal
	parameter
	RegAdd3Sel_rt = 0,
	RegAdd3Sel_rd = 1;
	
	//SrcBSel signal
	parameter
	SrcBSel_RegOut2 = 0,
	SrcBSel_EXTOut = 1;
	
	//BranchSel signal
	parameter
	BranchSel_RegOut1 = 0,
	BranchSel_EXTOut = 1;
	
	//instructions
	parameter
	nop = 0,
	subu = 1,
	ori = 2,
	lw = 3,
	sw = 4,
	beq = 5,
	lui = 6,
	jal = 7,
	jr = 8,
	lb = 9,
	lh = 10,
	sb = 11,
	sh = 12,
	slt = 13,
	sll = 14,
	bgtz = 15,
	addu = 16;
	
	reg [4:0] order;
	//get the order
	always @(*) begin
		case(opcode)
			0:
				case(funcode)
					8:
						order = jr;
					33:
						order = addu;
					35:
						order = subu;
					default:
						order = nop;
				endcase
				
			3:
				order = jal;
				
			4:
				order = beq;
			
			13:
				order = ori;
				
			15:
				order = lui;
				
			32:
				order = lb;
				
			35:
				order = lw;
				
			43:
				order = sw;
			
			default:
				order = nop;
		endcase
	end
	
	//excute the order
	always @(*) begin
		//default
		NPCOP = NPCOP_NORMAL;
		RegWrite = 0;
		GRFOP = GRFOP_FULL;
		EXTOP = EXTOP_ZE16;
		ALUOP = ALUOP_ADD;
		CMPOP = CMPOP_EQ;
		MemWrite = 0;
		DMOP = DMOP_W;
		RegInSel = 0;
		RegAdd3Sel = 0;
		SrcBSel = 0;
		BranchSel = 0;
		
		case(order)
			nop: begin
				NPCOP = NPCOP_NORMAL;
				RegWrite = 0;
				GRFOP = GRFOP_FULL;
				EXTOP = EXTOP_ZE16;
				ALUOP = ALUOP_ADD;
				CMPOP = CMPOP_EQ;
				MemWrite = 0;
				DMOP = DMOP_W;
				RegInSel = 0;
				RegAdd3Sel = 0;
				SrcBSel = 0;
				BranchSel = 0;
			end
			
			addu: begin
				//caculate2
				SrcBSel = SrcBSel_RegOut2;
				ALUOP = ALUOP_ADD;
				//LoadFromALU
				RegWrite = 1;
				RegAdd3Sel = RegAdd3Sel_rd;
				RegInSel = RegInSel_ALUOut;
				GRFOP = GRFOP_FULL;
			end
			
			subu: begin
				//caculate2
				SrcBSel = SrcBSel_RegOut2;
				ALUOP = ALUOP_SUB;
				//LoadFromALU
				RegWrite = 1;
				RegAdd3Sel = RegAdd3Sel_rd;
				RegInSel = RegInSel_ALUOut;
				GRFOP = GRFOP_FULL;				
			end
			
			ori: begin
				//caculate1
				EXTOP = EXTOP_ZE16;
				SrcBSel = SrcBSel_EXTOut;
				ALUOP = ALUOP_OR;
				//LoadFromALU
				RegWrite = 1;
				RegAdd3Sel = RegAdd3Sel_rt;
				RegInSel = RegInSel_ALUOut;
				GRFOP = GRFOP_FULL;
			end
			
			lw: begin
				//caculate1
				EXTOP = EXTOP_SE16;
				SrcBSel = SrcBSel_EXTOut;
				ALUOP = ALUOP_ADD;
				//LoadFromDM
				RegWrite = 1;
				RegAdd3Sel = RegAdd3Sel_rt;
				RegInSel = RegInSel_DMOut;
				GRFOP = GRFOP_FULL;
			end
			
			sw: begin
				//caculate1
				EXTOP = EXTOP_SE16;
				SrcBSel = SrcBSel_EXTOut;
				ALUOP = ALUOP_ADD;
				//Store
				MemWrite = 1;
				DMOP = DMOP_W;
			end
			
			beq:begin
				//Compare
				CMPOP = CMPOP_EQ;
				BranchSel = BranchSel_EXTOut;
				EXTOP = EXTOP_SE16;
				if(CMPOut)
					//Branch
					NPCOP = NPCOP_BRANCH;
				else
					NPCOP = NPCOP_NORMAL;
			end
			
			lui: begin
				//Extend
				EXTOP = EXTOP_ZE16;
				//LoadNeedOP
				RegWrite = 1;
				RegAdd3Sel = RegAdd3Sel_rt;
				RegInSel = RegInSel_EXTOut;
				GRFOP = GRFOP_LUI;
			end
			
			jal:begin
				//Extend
				EXTOP = EXTOP_ZE26;
				//Branch
				NPCOP = NPCOP_J;
				BranchSel = BranchSel_EXTOut;
				//LoadAsLink
				RegWrite = 1;
				RegAdd3Sel = RegAdd3Sel_rt;
				RegInSel = RegInSel_PC;
				GRFOP = GRFOP_LINK;
			end
			
			jr: begin
				//Branch
				NPCOP = NPCOP_JR;
				BranchSel = BranchSel_RegOut1;
			end
			
			lb: begin
				//Extend
				EXTOP = EXTOP_SE16;
				//Calculate1
				SrcBSel = SrcBSel_EXTOut;
				ALUOP = ALUOP_ADD;				
				//LoadFromDM
				RegWrite = 1;
				RegAdd3Sel = RegAdd3Sel_rt;
				RegInSel = RegInSel_DMOut;
				GRFOP = GRFOP_FULL;
				MemWrite = 0;
				DMOP = DMOP_B;
			end
			
			default: begin
				NPCOP = NPCOP_NORMAL;
				RegWrite = 0;
				GRFOP = GRFOP_FULL;
				EXTOP = EXTOP_ZE16;
				ALUOP = ALUOP_ADD;
				CMPOP = CMPOP_EQ;
				MemWrite = 0;
				DMOP = DMOP_W;
				RegInSel = 0;
				RegAdd3Sel = 0;
				SrcBSel = 0;
				BranchSel = 0;
			end
		endcase	
	end
	
	
endmodule
