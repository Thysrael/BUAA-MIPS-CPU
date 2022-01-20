`timescale 1ns / 1ps
`include "const.v"

module CU(
	input [31:0] D_instr,
	input D_CMPOut,
	input [31:0] E_instr,
	input E_CMPOut,
	input [31:0] M_instr,
	input M_CMPOut,
	input [31:0] W_instr,
	input W_CMPOut,
	output reg [3:0] NPCOP,
	output reg [3:0] EXTOP,
	output reg [3:0] ALUOP,
	output reg [3:0] CMPOP,
	output reg [3:0] DMOP,
	output reg GRFEn,
	output reg DMEn,
	output reg [2:0] PCSel,
	output reg [2:0] JumpSel,
	output reg [2:0] GRFInSel,
	output reg [2:0] GRFAdd3Sel,
	output reg [2:0] SrcBSel
    );
	
	//NPC signal
	parameter
	NPCOP_NORMAL = 0,
	NPCOP_BRANCH = 1,
	NPCOP_J = 2,
	NPCOP_JR = 3;
	
	//EXT signal
	parameter
	EXTOP_ZE16 = 0,
	EXTOP_SE16 = 1,
	EXTOP_ZE26 = 2,
	EXTOP_LUI = 3;

	//ALU signal
	parameter
	ALUOP_ADD = 0,
	ALUOP_SUB = 1,
	ALUOP_OR = 2,
	ALUOP_LLEFT = 3;
	
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
	
	//PCSel signal
	parameter
	PCSel_F = 0,
	PCSel_D = 1;
	
	//JumpSel signal
	parameter
	JumpSel_rsOut = 0,
	JumpSel_EXTOut = 1;
	
	//RegInSel signal
	parameter
	GRFInSel_ALUOut = 0,
	GRFInSel_DMOut = 1,
	GRFInSel_PC8 = 2,
	GRFInSel_EXTOut = 3;
	
	//RegAdd3Sel signal
	parameter
	GRFAdd3Sel_rt = 0,
	GRFAdd3Sel_rd = 1,
	GRFAdd3Sel_Link = 2;
	
	//SrcBSel signal
	parameter
	SrcBSel_rtOut = 0,
	SrcBSel_EXTOut = 1;
	

	/********** Stage D **********/
	wire [6:0] D_order;
	CORE D_core
		(
			.instr(D_instr),
			.order(D_order)
		);
		
	//about CMPOP
	always @(*) begin
		case(D_order)
			`beq: CMPOP = CMPOP_EQ;
			default : CMPOP = CMPOP_EQ;
		endcase

	//about EXTOP
		case(D_order)
			`ori : EXTOP = EXTOP_ZE16;
			`lui : EXTOP = EXTOP_LUI;
			`beq, `lw, `sw : EXTOP = EXTOP_SE16;
			`j, `jal : EXTOP = EXTOP_ZE26;
			default : EXTOP = EXTOP_ZE16;
		endcase

	//about NPCOP
		case(D_order)
			`j, `jal : NPCOP = NPCOP_J;
			`jr : NPCOP = NPCOP_JR;
			`beq : 
				if(D_CMPOut) NPCOP = NPCOP_BRANCH;
				else NPCOP = NPCOP_NORMAL;
			default : NPCOP = NPCOP_NORMAL;
		endcase
	
	//about PCSel
		case(D_order)
			`j, `jal, `jr : PCSel = PCSel_D;
			`beq : 
				if(D_CMPOut) PCSel = PCSel_D;
				else PCSel = PCSel_F;
			default : PCSel = PCSel_F;
		endcase
		
	//about JumpSel
		case(D_order)
			`j, `jal, `beq : JumpSel = JumpSel_EXTOut;
			`jr : JumpSel = JumpSel_rsOut;
			default : JumpSel = JumpSel_EXTOut;
		endcase
	end
	
	/********** Stage E **********/
	wire [6:0] E_order;
	CORE E_core
		(
			.instr(E_instr),
			.order(E_order)
		);
 	
	//about ALUOP
	always @(*) begin
		case(E_order)
			`addu, `lw, `sw : ALUOP = ALUOP_ADD;
			`subu : ALUOP = ALUOP_SUB;
			`ori : ALUOP = ALUOP_OR;
			default : ALUOP = ALUOP_ADD;
		endcase
	
	//about SrcBSel
		case(E_order)
			`addu, `subu : SrcBSel = SrcBSel_rtOut;
			`ori, `lw, `sw : SrcBSel = SrcBSel_EXTOut;
			default : SrcBSel = SrcBSel_EXTOut;
		endcase
	end
	
	/********** Stage M **********/
	wire [6:0] M_order;
	CORE M_core
		(
			.instr(M_instr),
			.order(M_order)
		);
	//about DMEn
	always @(*) begin
		case(M_order)
			`sw : DMEn = 1;
			default : DMEn = 0;
		endcase
	
	//about DMOP
		case(M_order)
			`sw, `lw : DMOP = DMOP_W;
			default : DMOP = DMOP_W;
		endcase
	end
	
	/********** Stage W **********/
	wire [6:0] W_order;
	CORE W_core
		(
			.instr(W_instr),
			.order(W_order)
		);
	
	//about GRFEn
	always @(*) begin
		case(W_order)
			`addu, `subu, `ori, `lw, `lui, `jal : GRFEn = 1;
			default : GRFEn = 0;
		endcase
	
	//about GRFInSel
		case(W_order)
			`addu, `subu, `ori: GRFInSel = GRFInSel_ALUOut;
			`lw : GRFInSel = GRFInSel_DMOut;
			`jal : GRFInSel = GRFInSel_PC8;
			`lui : GRFInSel = GRFInSel_EXTOut;
			default : GRFInSel = GRFInSel_ALUOut;
		endcase
	
	//about GRFAdd3Sel
		case(W_order)
			`addu, `subu : GRFAdd3Sel = GRFAdd3Sel_rd;
			`ori, `lw, `lui : GRFAdd3Sel = GRFAdd3Sel_rt;
			`jal : GRFAdd3Sel = GRFAdd3Sel_Link;
			default : GRFAdd3Sel = GRFAdd3Sel_rt;
		endcase
	end
	
endmodule
