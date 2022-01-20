`timescale 1ns / 1ps

module mips
	(
		input clk,
		input reset
	);
	
	/********** Stage F **********/
	wire [31:0] F_instr, F_PC;
	/********** Stage D **********/	
	wire [31:0] D_instr, D_PC;
	wire [4:0] D_rs, D_rt;
	wire [31:0] D_rsOut, D_rtOut;
	wire [31:0] D_FWrsOut, D_FWrtOut;
	wire D_CMPOut;
	wire [31:0] D_EXTOut;
	wire [31:0] NPCPC;
	wire [31:0] Jump;
	wire [31:0] nextPC;
	/********** Stage E **********/
	wire [31:0] E_instr, E_PC, E_EXTOut, E_rsOut, E_rtOut;
	wire E_CMPOut;
	wire [31:0] E_FWSrc;
	wire [31:0] E_FWrsOut;
	wire [31:0] E_FWrtOut;
	wire [31:0] SrcB;
	wire [31:0] E_ALUOut;
	/********** Stage M **********/
	wire [31:0] M_instr, M_PC, M_ALUOut, M_EXTOut, M_rtOut;
	wire M_CMPOut;
	wire [31:0] M_FWSrc;
	wire [31:0] M_FWrtOut;
	wire [31:0] M_DMOut;
	/********** Stage W **********/
	wire [31:0] W_instr, W_PC, W_ALUOut, W_EXTOut, W_DMOut;
	wire W_CMPOut;	
	wire [31:0] W_FWSrc;
	wire [4:0] W_rt, W_rd;
	wire [4:0] W_GRFAdd3;
	wire [31:0] W_GRFIn;
	
	
	/************ CU *************/
	
	wire DMEn, GRFEn;
	wire [3:0] NPCOP, EXTOP, CMPOP, ALUOP, DMOP;
	wire [2:0] PCSel, JumpSel, SrcBSel, GRFInSel, GRFAdd3Sel;
	CU cu
		(
			.D_instr(D_instr),
			.E_instr(E_instr),
			.M_instr(M_instr),
			.W_instr(W_instr),
			.D_CMPOut(D_CMPOut),
			.E_CMPOut(E_CMPOut),
			.M_CMPOut(M_CMPOut),
			.W_CMPOut(W_CMPOut),
			.DMEn(DMEn),
			.GRFEn(GRFEn),
			.NPCOP(NPCOP),
			.EXTOP(EXTOP),
			.CMPOP(CMPOP),
			.ALUOP(ALUOP),
			.DMOP(DMOP),
			.PCSel(PCSel),
			.JumpSel(JumpSel),
			.SrcBSel(SrcBSel),
			.GRFInSel(GRFInSel),
			.GRFAdd3Sel(GRFAdd3Sel)
		);
		
	/************ FU *************/
	
	wire [2:0] E_FWSrcSel, M_FWSrcSel, W_FWSrcSel;
	wire [2:0] D_FWrsLevelSel, D_FWrtLevelSel, E_FWrsLevelSel, E_FWrtLevelSel, M_FWrtLevelSel;
	FU fu
		(
			.D_instr(D_instr),
			.E_instr(E_instr),
			.M_instr(M_instr),
			.W_instr(W_instr),
			.E_FWSrcSel(E_FWSrcSel),
			.M_FWSrcSel(M_FWSrcSel),
			.W_FWSrcSel(W_FWSrcSel),
			.D_FWrsLevelSel(D_FWrsLevelSel),
			.D_FWrtLevelSel(D_FWrtLevelSel),
			.E_FWrsLevelSel(E_FWrsLevelSel),
			.E_FWrtLevelSel(E_FWrtLevelSel),
			.M_FWrtLevelSel(M_FWrtLevelSel)
		);
		
	/************ SU *************/
	
	wire stall;
	SU su
		(
			.D_instr(D_instr),
			.E_instr(E_instr),
			.M_instr(M_instr),
			.stall(stall)
		);
	
	/********** Stage F **********/

	//about the IFU
	IFU ifu
		(
			.clk(clk),
			.reset(reset),
			.en(~stall),
			.nextPC(nextPC),
			.instr(F_instr),
			.PC(F_PC)
		);
	/*	
	DASM dasm
		(
			.pc(F_PC),
			.instr(F_instr),
			.imm_as_dec(1'b1),
			.reg_name(1'b0),
			.asm()
		);
		*/
	/********** Stage D **********/
	
	//about the DREG
	DREG dreg
		(
			.clk(clk),
			.reset(reset),
			.en(~stall),
			.instrIn(F_instr),
			.PCIn(F_PC),
			.instrOut(D_instr),
			.PCOut(D_PC)
		);
		
	//about the GRF	
	assign D_rs = D_instr[25:21];
	assign D_rt = D_instr[20:16];
	GRF grf
		(
			.clk(clk),
			.reset(reset),
			.en(GRFEn),
			.GRFAdd1(D_rs),
			.GRFAdd2(D_rt),
			.GRFOut1(D_rsOut),
			.GRFOut2(D_rtOut),
			.PC(W_PC),
			.GRFAdd3(W_GRFAdd3),
			.GRFIn(W_GRFIn)
		);
	
	//about forwarding the D_rsOut
	MUX8 D_FWrsLevelMux
		(
			.out(D_FWrsOut),
			.sel(D_FWrsLevelSel),
			.in0(32'd0),
			.in1(D_rsOut),
			.in2(E_FWSrc),
			.in3(M_FWSrc)
		);
	
	//about forwarding the D_rtOut
	MUX8 D_FWrtLevelMux
		(
			.out(D_FWrtOut),
			.sel(D_FWrtLevelSel),
			.in0(32'd0),
			.in1(D_rtOut),
			.in2(E_FWSrc),
			.in3(M_FWSrc)
		);
		
	//about the CMP
	CMP cmp
		(
			.num1(D_FWrsOut),
			.num2(D_FWrtOut),
			.CMPOut(D_CMPOut),
			.CMPOP(CMPOP)
		);
		
	//about the EXT
	EXT ext
		(
			.EXTIn(D_instr[25:0]),
			.EXTOut(D_EXTOut),
			.EXTOP(EXTOP)
		);
	
	//about the NPC
	MUX8 PCMux
		(
			.out(NPCPC),
			.sel(PCSel),
			.in0(F_PC),
			.in1(D_PC)
		);
		
	MUX8 JumpMux
		(
			.out(Jump),
			.sel(JumpSel),
			.in0(D_FWrsOut),
			.in1(D_EXTOut)
		);
	
	NPC npc
		(
			.PC(NPCPC),
			.Jump(Jump),
			.NPCOP(NPCOP),
			.nextPC(nextPC)
		);
		
	/********** Stage E **********/
	
	//about the EREG
	EREG ereg
		(
			.clk(clk),
			.reset(reset | stall),
			.en(1'b1),
			.CMPOutIn(D_CMPOut),
			.CMPOutOut(E_CMPOut),
			.instrIn(D_instr),
			.instrOut(E_instr),
			.EXTOutIn(D_EXTOut),
			.EXTOutOut(E_EXTOut),
			.rsOutIn(D_FWrsOut),
			.rsOutOut(E_rsOut),
			.rtOutIn(D_FWrtOut),
			.rtOutOut(E_rtOut),
			.PCIn(D_PC),
			.PCOut(E_PC)
		);
	
	//about the E_FWSrc
	MUX8 E_FWSrcMux
		(
			.out(E_FWSrc),
			.sel(E_FWSrcSel),
			.in0(E_PC + 8),//这里有一个对PC的处理，因为需要它的是jal
			.in1(E_PC + 8), //摆烂
			.in2(E_EXTOut),
			.in3(E_PC + 8) //摆烂，因为会有ALUOut和DMout选择信号生成，我只能让它选错误数据
		);
		
	//about forwarding the E_rsOut
	MUX8 E_FWrsLevelMux
		(
			.out(E_FWrsOut),
			.sel(E_FWrsLevelSel),
			.in0(32'd0),
			.in2(E_rsOut),
			.in3(M_FWSrc),
			.in4(W_FWSrc)
		);
		
	//about forwarding the E_rtOut
	MUX8 E_FWrtLevelMux
		(
			.out(E_FWrtOut),
			.sel(E_FWrtLevelSel),
			.in0(32'd0),
			.in2(E_rtOut),
			.in3(M_FWSrc),
			.in4(W_FWSrc)
		);
		
	//about the ALU
	MUX8 SrcBMux
		(
			.out(SrcB),
			.sel(SrcBSel),
			.in0(E_FWrtOut),
			.in1(E_EXTOut)
		);
	
	ALU alu
		(	
			.SrcA(E_FWrsOut),
			.SrcB(SrcB),
			.ALUOP(ALUOP),
			.ALUOut(E_ALUOut)
		);
	
	/********** Stage M **********/	
	
	//about the MREG
	MREG mreg
		(
			.clk(clk),
			.reset(reset),
			.en(1'b1),
			.instrIn(E_instr),
			.instrOut(M_instr),
			.PCIn(E_PC),
			.PCOut(M_PC),
			.ALUOutIn(E_ALUOut),
			.ALUOutOut(M_ALUOut),
			.EXTOutIn(E_EXTOut),
			.EXTOutOut(M_EXTOut),
			.rtOutIn(E_FWrtOut),
			.rtOutOut(M_rtOut),
			.CMPOutIn(E_CMPOut),
			.CMPOutOut(M_CMPOut)
		);
	
	//about the M_FWSrc
	MUX8 M_FWSrcMux
		(
			.out(M_FWSrc),
			.sel(M_FWSrcSel),
			.in0(M_PC + 8),
			.in1(M_ALUOut),
			.in2(M_EXTOut),
			.in3(M_PC + 8)//摆烂
		);
		
	//about forwarding the rtOut
	MUX8 M_FWrtLevelMux
		(
			.out(M_FWrtOut),
			.sel(M_FWrtLevelSel),
			.in0(32'd0),
			.in3(M_rtOut),
			.in4(W_FWSrc)
		);
		
	//about the DM
	DM dm
		(
			.clk(clk),
			.reset(reset),
			.PC(M_PC),
			.en(DMEn),
			.DMOP(DMOP),
			.DMAdd(M_ALUOut),
			.DMIn(M_FWrtOut),
			.DMOut(M_DMOut)
		);
	
	
	/********** Stage W **********/
	
	//about the WREG
	WREG wreg
		(
			.clk(clk),
			.reset(reset),
			.en(1'b1),
			.instrIn(M_instr),
			.instrOut(W_instr),
			.PCIn(M_PC),
			.PCOut(W_PC),
			.CMPOutIn(M_CMPOut),
			.CMPOutOut(W_CMPOut),
			.ALUOutIn(M_ALUOut),
			.ALUOutOut(W_ALUOut),
			.EXTOutIn(M_EXTOut),
			.EXTOutOut(W_EXTOut),
			.DMOutIn(M_DMOut),
			.DMOutOut(W_DMOut)
		);
	
	//about the W_FWSrc
	MUX8 W_FWSrcMux
		(
			.out(W_FWSrc),
			.sel(W_FWSrcSel),
			.in0(W_PC + 8),
			.in1(W_ALUOut),
			.in2(W_EXTOut),
			.in3(W_DMOut)
		);
	
	//about the GRF
	assign W_rt = W_instr[20:16];
	assign W_rd = W_instr[15:11];
	
	MUX8 #(5) GRFAdd3Mux(
		.out(W_GRFAdd3),
		.sel(GRFAdd3Sel),
		.in0(W_rt),
		.in1(W_rd),
		.in2(5'd31)
		);
	
	MUX8 GRFInMux(
			.out(W_GRFIn),
			.sel(GRFInSel),
			.in0(W_ALUOut),
			.in1(W_DMOut),
			.in2(W_PC + 8), //服务jal，这里一定要注意，输进去的是PC + 8，这是去掉GRFOP的代价
			.in3(W_EXTOut)
			);	
	
endmodule 