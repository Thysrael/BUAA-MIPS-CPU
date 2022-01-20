`timescale 1ns / 1ps
`include "CONST.v"

module CU(
	input [31:0] D_instr,
	input [31:0] E_instr,
	input [31:0] M_instr,
	input [31:0] W_instr,
	input D_CMPOut,
	input [31:0] DMAdd,
	input E_flag1,
	input M_flag1,
	input W_flag1,
	input M_flag2,
	input W_flag2,
	input W_flag3,
	output reg [3:0] NPCOP,
	output reg [3:0] EXTOP,
	output reg [4:0] ALUOP,
	output reg [3:0] MDUOP,
	output reg [3:0] CMPOP,
	output reg [3:0] LOADOP,
	output reg [3:0] STOREOP,
	output reg [3:0] ByteEn,
	output reg CP0En,
	output reg GRFEn,
	output reg [2:0] PCSel,
	output reg [2:0] JumpSel,
	output reg [2:0] GRFInSel,
	output reg [2:0] GRFAdd3Sel,
	output reg [2:0] SrcBSel,
	
	output reg isBD,
	output reg isRI,
	output reg isCalSigned,
	output reg isCalAddLoad,
	output reg isCalAddStore,
	output reg isLoad,
	output reg isStore,
	output reg D_eret,
	output reg EXLClr
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
	ALUOP_SLLV = 3,
	ALUOP_SRLV = 4,
	ALUOP_SRAV = 5,
	ALUOP_SLT = 6,
	ALUOP_SLTU = 7,
	ALUOP_SLL = 8,
	ALUOP_SRL = 9,
	ALUOP_SRA = 10,
	ALUOP_AND = 11,
	ALUOP_XOR = 12,
	ALUOP_NOR = 13;
	
	// MDUOP
    parameter
	MDUOP_MULT 	= 0,
	MDUOP_MULTU = 1,
	MDUOP_DIV 	= 2,
	MDUOP_DIVU 	= 3,
	MDUOP_MFLO 	= 4,
	MDUOP_MFHI	= 5,
	MDUOP_MTLO	= 6,
	MDUOP_MTHI	= 7;
	
	// LOADOP
	parameter 
	LOADOP_LW 	= 0,
	LOADOP_LH 	= 1,
	LOADOP_LHU = 2,
	LOADOP_LB	= 3,
	LOADOP_LBU = 4;
	
	// STOREOP
	parameter
	STOREOP_SW	= 0,
	STOREOP_SH 	= 1,
	STOREOP_SB	= 2;

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
	GRFInSel_DMOut 	= 1,
	GRFInSel_PC8 	= 2,
	GRFInSel_EXTOut = 3,
	GRFInSel_MDUOut = 4,
	GRFInSel_CP0Out = 5;
	
	//RegAdd3Sel signal
	parameter
	GRFAdd3Sel_rt = 0,
	GRFAdd3Sel_rd = 1,
	GRFAdd3Sel_Link = 2;
	
	//SrcBSel signal
	parameter
	SrcBSel_rtOut = 0,
	SrcBSel_EXTOut = 1;
	
	
	/********** Stage F **********/
	wire [6:0] D_order;
	
	always @(*) begin
		//about isBD
		case(D_order)
			`branch1, `branch2, `jump_i, `jump_r : isBD = 1;
			default : isBD = 0;
		endcase
	end
	
	/********** Stage D **********/
	CORE D_core
		(
			.instr(D_instr),
			.order(D_order)
		);
		
	always @(*) begin
		//about CMPOP
		case(D_order)
			`beq : CMPOP = CMPOP_EQ;
			`bne : CMPOP = CMPOP_NE;
			`blez : CMPOP = CMPOP_LEZ;
			`bgtz : CMPOP = CMPOP_GTZ;
			`bltz : CMPOP = CMPOP_LTZ;
			`bgez : CMPOP = CMPOP_GEZ;
			default : CMPOP = CMPOP_EQ;
		endcase

		//about EXTOP
		case(D_order)
			`cal_il : EXTOP = EXTOP_ZE16;
			`lui : EXTOP = EXTOP_LUI;
			`branch1, `branch2, `load, `store, `cal_ia : EXTOP = EXTOP_SE16;
			`jump_i : EXTOP = EXTOP_ZE26;
			default : EXTOP = EXTOP_ZE16;
		endcase

		//about NPCOP
		case(D_order)
			`jump_i : NPCOP = NPCOP_J;
			`jump_r : NPCOP = NPCOP_JR;
			`branch1, `branch2 : 
				if(D_CMPOut) NPCOP = NPCOP_BRANCH;
				else NPCOP = NPCOP_NORMAL;
			default : NPCOP = NPCOP_NORMAL;
		endcase
	
		//about PCSel
		case(D_order)
			`jump_i : PCSel = PCSel_D;
			`branch1, `branch2 : 
				if(D_CMPOut) PCSel = PCSel_D;
				else PCSel = PCSel_F;
			default : PCSel = PCSel_F;
		endcase
		
		//about JumpSel
		case(D_order)
			`jump_i, `branch1, `branch2 : JumpSel = JumpSel_EXTOut;
			`jump_r : JumpSel = JumpSel_rsOut;
			default : JumpSel = JumpSel_EXTOut;
		endcase
		
		//about isRI
		case(D_order)
			`none : isRI = 1;
			default : isRI = 0;
		endcase
		
		//about D_eret
		case(D_order)
			`eret : D_eret = 1;
			default : D_eret = 0;
		endcase
	end
	
	/********** Stage E **********/
	wire [6:0] E_order;
	CORE E_core
		(
			.instr(E_instr),
			.order(E_order)
		);
 	
	always @(*) begin
		//about ALUOP
		case(E_order)
			`addi, `addiu, `addu, `add, `load, `store : ALUOP = ALUOP_ADD;
			`subu, `sub : ALUOP = ALUOP_SUB;
			`ori, `or: ALUOP = ALUOP_OR;
			`sllv : ALUOP = ALUOP_SLLV;
			`srlv : ALUOP = ALUOP_SRLV;
			`srav : ALUOP = ALUOP_SRAV;
			`slt, `slti : ALUOP = ALUOP_SLT;
			`sltu, `sltiu : ALUOP = ALUOP_SLTU;
			`sll : ALUOP = ALUOP_SLL;
			`srl : ALUOP = ALUOP_SRL;
			`sra : ALUOP = ALUOP_SRA;
			`and, `andi : ALUOP = ALUOP_AND;
			`xor, `xori : ALUOP = ALUOP_XOR;
			`nor : ALUOP = ALUOP_NOR;
			default : ALUOP = ALUOP_ADD;
		endcase
	
		//about SrcBSel
		case(E_order)
			`cal_r : SrcBSel = SrcBSel_rtOut;
			`cal_ia, `cal_il, `load, `store : SrcBSel = SrcBSel_EXTOut;
			default : SrcBSel = SrcBSel_EXTOut;
		endcase
		
		//about MDUOP
		case(E_order)
			`mult : MDUOP = MDUOP_MULT; //相当于写寄存器，不能当default
			`multu : MDUOP = MDUOP_MULTU;
			`div : MDUOP = MDUOP_DIV;
			`divu : MDUOP = MDUOP_DIVU;
			`mfhi : MDUOP = MDUOP_MFHI;
			`mflo : MDUOP = MDUOP_MFLO;
			`mthi : MDUOP = MDUOP_MTHI; //相当于写寄存器，不能当default
			`mtlo : MDUOP = MDUOP_MTLO;
			default : MDUOP = MDUOP_MFLO;
		endcase
		
		//about isCalSigned
		case(E_order)
			`addi, `sub, `add : isCalSigned = 1;
			default : isCalSigned = 0;
		endcase
		
		//about isCalAddLoad
		case(E_order)
			`load: isCalAddLoad = 1;
			default : isCalAddLoad = 0;
		endcase
		
		//about isCalAddStore
		case(E_order)
			`store : isCalAddStore = 1;
			default : isCalAddStore = 0;
		endcase
	end
	
	/********** Stage M **********/
	wire [6:0] M_order;
	CORE M_core
		(
			.instr(M_instr),
			.order(M_order)
		);
		
	always @(*) begin
		//about isLoad
		case(M_order)
			`load : isLoad = 1;
			default : isLoad = 0;
		endcase
		
		//about isStore
		case(M_order)
			`store : isStore = 1;
			default : isStore = 0;
		endcase
	
		// about LOADOP
		case(M_order) 
			`lw : LOADOP = LOADOP_LW;
			`lh : LOADOP = LOADOP_LH;
			`lhu : LOADOP = LOADOP_LHU;
			`lb : LOADOP = LOADOP_LB;
			`lbu : LOADOP = LOADOP_LBU;
			default : LOADOP = LOADOP_LW;
		endcase
		
		// about STOREOP
		case(M_order) 
			`sw : STOREOP = STOREOP_SW;
			`sh : STOREOP = STOREOP_SH;
			`sb : STOREOP = STOREOP_SB;
			default : STOREOP = STOREOP_SW;
		endcase
		
		// about ByteEn
		case(M_order)
			`sw : ByteEn = 4'b1111;
			`sh : ByteEn = 4'b0011 << (2 * DMAdd[1]);
			`sb : ByteEn = 4'b0001 << DMAdd[1:0];
			default : ByteEn = 4'b0000;
		endcase
		
		//about CP0En
		case(M_order)
			`mtc0 : CP0En = 1;
			default : CP0En = 0;
		endcase
		
		//about EXLClr
		case(M_order)
			`eret : EXLClr = 1;
			default : EXLClr = 0;
		endcase
	end
	
	/********** Stage W **********/
	wire [6:0] W_order;
	CORE W_core
		(
			.instr(W_instr),
			.order(W_order)
		);
	
	always @(*) begin
		//about GRFEn
		case(W_order)
			`mfc0, `mf, `cal_r, `cal_ia, `cal_il, `load, `lui, `link : GRFEn = 1;
			default : GRFEn = 0;
		endcase
	
		//about GRFInSel
		case(W_order)
			`cal_r, `cal_il, `cal_ia: GRFInSel = GRFInSel_ALUOut;
			`load : GRFInSel = GRFInSel_DMOut;
			`link : GRFInSel = GRFInSel_PC8;
			`lui : GRFInSel = GRFInSel_EXTOut;
			`mf : GRFInSel = GRFInSel_MDUOut;
			`mfc0 : GRFInSel = GRFInSel_CP0Out;
			default : GRFInSel = GRFInSel_ALUOut;
		endcase
	
		//about GRFAdd3Sel
		case(W_order)
			`mf, `cal_r, `jalr : GRFAdd3Sel = GRFAdd3Sel_rd;
			`mfc0, `cal_ia, `cal_il, `load, `lui : GRFAdd3Sel = GRFAdd3Sel_rt;
			`jal : GRFAdd3Sel = GRFAdd3Sel_Link;
			default : GRFAdd3Sel = GRFAdd3Sel_rt;
		endcase
	end
	
endmodule
