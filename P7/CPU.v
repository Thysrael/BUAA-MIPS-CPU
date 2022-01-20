`timescale 1ns / 1ps
`include "CONST.v"

module CPU
	(
		input clk,
		input reset,
		
		output [31:0] i_inst_addr,
		input [31:0] i_inst_rdata,
		
		input [31:0] CPUIn,
		output [31:0] VAdd,
		output [31:0] CPUOut,
		output [3:0] CPUByteEn,
		output [31:0] m_inst_addr,
		
		output w_grf_we,
		output [4:0] w_grf_addr,
		output [31:0] w_grf_wdata,
		output [31:0] w_inst_addr ,
		
		input [5:0] HWInt,
		output [31:0] macroscopic_pc,
		output tbReq
	);
	
	/********** Stage F **********/
	wire [31:0] F_instr, F_PC;
	wire [4:0] F_ExcCode;
	wire F_BD;
	
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
	wire [4:0] D_ExcCode, Raw_D_ExcCode;
	wire D_BD;
	
	/********** Stage E **********/
	wire [31:0] E_instr, E_PC, E_EXTOut, E_rsOut, E_rtOut;
	wire [31:0] E_FWSrc;
	wire [31:0] E_FWrsOut, E_FWrtOut;
	wire [31:0] SrcB;
	wire [4:0] SHF;
	wire [31:0] E_ALUOut;
	wire [31:0] E_MDUOut;
	wire MDUBusy;
	wire E_flag1;
	wire [4:0] E_ExcCode, Raw_E_ExcCode;
	wire E_BD;
	
	/********** Stage M **********/
	wire [31:0] M_instr, M_PC, M_ALUOut, M_EXTOut, M_rsOut, M_rtOut, M_MDUOut;
	wire [31:0] M_FWSrc;
	wire [31:0] M_FWrtOut;
	wire [31:0] M_DMOut;
	wire M_flag1, M_flag2;
	wire [4:0] M_rd;
	wire [31:0] M_CP0Out, M_EPCOut;
	wire [4:0] M_ExcCode, Raw_M_ExcCode;
	wire M_BD;
	wire Req;
	
	/********** Stage W **********/
	wire [31:0] W_instr, W_PC, W_ALUOut, W_EXTOut, W_DMOut, W_rsOut, W_rtOut, W_MDUOut;
	wire [31:0] W_FWSrc;
	wire [4:0] W_rt, W_rd;
	wire [4:0] W_GRFAdd3;
	wire [31:0] W_GRFIn;
	wire [31:0] W_CP0Out;
	wire W_flag1, W_flag2, W_flag3;
	
	/************ CP0 ************/
	wire F_AdEL, D_RI, E_Ov, E_AdEL, E_AdES, M_AdEL, M_AdES;
	wire isCalSigned, isCalAddLoad, isCalAddStore, isLoad, isStore;
	
	/************ CU *************/
	
	wire GRFEn, CP0En;
	wire [3:0] NPCOP, EXTOP, CMPOP, SDMOP, MDUOP, LOADOP, STOREOP, ByteEn;
	wire [4:0] ALUOP;
	wire [2:0] PCSel, JumpSel, SrcBSel, GRFInSel, GRFAdd3Sel;
	wire EXLClr, D_eret;
	CU cu
		(
			//input
			.D_instr(D_instr),
			.E_instr(E_instr),
			.M_instr(M_instr),
			.W_instr(W_instr),
			.D_CMPOut(D_CMPOut),
			.DMAdd(VAdd),
			//output
			.isBD(F_BD),
			.isRI(D_RI),
			.isCalSigned(isCalSigned),
			.isCalAddLoad(isCalAddLoad),
			.isCalAddStore(isCalAddStore),
			.isLoad(isLoad),
			.isStore(isStore),
			
			.CP0En(CP0En),
			.GRFEn(GRFEn),
			.NPCOP(NPCOP),
			.EXTOP(EXTOP),
			.CMPOP(CMPOP),
			.ALUOP(ALUOP),
			.MDUOP(MDUOP),
			.LOADOP(LOADOP),
			.STOREOP(STOREOP),
			.ByteEn(ByteEn),
			.PCSel(PCSel),
			.JumpSel(JumpSel),
			.SrcBSel(SrcBSel),
			.GRFInSel(GRFInSel),
			.GRFAdd3Sel(GRFAdd3Sel),
			.EXLClr(EXLClr),
			.D_eret(D_eret)
		);
		

	/************ FSU *************/
	
	wire [2:0] E_FWSrcSel, M_FWSrcSel, W_FWSrcSel;
	wire [2:0] D_FWrsLevelSel, D_FWrtLevelSel, E_FWrsLevelSel, E_FWrtLevelSel, M_FWrtLevelSel;	
	wire stall;
	
	FSU fsu
		(
			.D_instr(D_instr),
			.E_instr(E_instr),
			.M_instr(M_instr),
			.W_instr(W_instr),
			.MDUBusy(MDUBusy),
			.E_FWSrcSel(E_FWSrcSel),
			.M_FWSrcSel(M_FWSrcSel),
			.W_FWSrcSel(W_FWSrcSel),
			.D_FWrsLevelSel(D_FWrsLevelSel),
			.D_FWrtLevelSel(D_FWrtLevelSel),
			.E_FWrsLevelSel(E_FWrsLevelSel),
			.E_FWrtLevelSel(E_FWrtLevelSel),
			.M_FWrtLevelSel(M_FWrtLevelSel),
			.stall(stall)
		);
	
	
	/********** Stage F **********/

	//about the IFU
	assign i_inst_addr = F_PC;
	assign F_instr = (F_AdEL)? 0 : i_inst_rdata;
	
	IFU ifu
		(
			.clk(clk),
			.reset(reset),
			.en(~stall),
			.nextPC(nextPC),
			.PC(F_PC),
			.Req(Req),
			.D_eret(D_eret),
			.EPC(M_EPCOut),
			.AdEL(F_AdEL)
		);
		
	//about ExcCode
	assign F_ExcCode = (F_AdEL)? `EXC_AdEL : 0;
		
	/********** Stage D **********/
	
	//about ExcCode
	assign D_ExcCode = (Raw_D_ExcCode)? Raw_D_ExcCode : 
					   (D_RI)? `EXC_RI :
					   0;
	
	//about the DREG
	DREG D_reg
		(
			.clk(clk),
			.reset(reset),
			.en(~stall),
			.Req(Req),
			.instrIn(F_instr),
			.PCIn(F_PC),
			.instrOut(D_instr),
			.PCOut(D_PC),
			.ExcCodeIn(F_ExcCode),
			.ExcCodeOut(Raw_D_ExcCode),
			.BDIn(F_BD),
			.BDOut(D_BD)
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
	
	//about the ExcCode
	assign E_ExcCode = (Raw_E_ExcCode)? Raw_E_ExcCode :
					   (E_Ov)? `EXC_Ov : 
					   (E_AdEL)? `EXC_AdEL :
					   (E_AdES)? `EXC_AdES :
					   0;
	
	//about the EREG
	EREG E_reg
		(
			.clk(clk),
			.reset(reset),
			.flush(stall),
			.Req(Req),
			.en(1'b1),
			.instrIn(D_instr),
			.instrOut(E_instr),
			.EXTOutIn(D_EXTOut),
			.EXTOutOut(E_EXTOut),
			.rsOutIn(D_FWrsOut),
			.rsOutOut(E_rsOut),
			.rtOutIn(D_FWrtOut),
			.rtOutOut(E_rtOut),
			.PCIn(D_PC),
			.PCOut(E_PC),
			.flag1In(),			//将D阶段产生的flag1信号输入，就可以流水了
			.flag1Out(E_flag1),
			.ExcCodeIn(D_ExcCode),
			.ExcCodeOut(Raw_E_ExcCode),
			.BDIn(D_BD),
			.BDOut(E_BD)
		);
	
	//about the E_FWSrc
	MUX8 E_FWSrcMux
		(
			.out(E_FWSrc),
			.sel(E_FWSrcSel),
			.in0(E_PC + 8),//这里有一个对PC的处理，因为需要它的是jal
			.in1(E_PC + 8), //摆烂
			.in2(E_EXTOut),
			.in3(E_PC + 8), //摆烂，因为会有ALUOut和DMout选择信号生成，我只能让它选错误数据
			.in4(E_PC + 8), //摆烂，因为会有ALUOut和DMout选择信号生成，我只能让它选错误数据
			.in5(E_PC + 8) 	//摆烂，因为会有ALUOut和DMout选择信号生成，我只能让它选错误数据
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
		
	assign SHF = E_instr[10:6];
	
	ALU alu
		(	
			.SrcA(E_FWrsOut),
			.SrcB(SrcB),
			.SHF(SHF),
			.ALUOP(ALUOP),
			.ALUOut(E_ALUOut),
			
			.isCalAddLoad(isCalAddLoad),
			.isCalAddStore(isCalAddStore),
			.isCalSigned(isCalSigned),
			.Ov(E_Ov),
			.AdEL(E_AdEL),
			.AdES(E_AdES)
		);
	
	// about the MDU
	MDU mdu
		(
			.clk(clk),
			.reset(reset),
			.numA(E_FWrsOut),
			.numB(E_FWrtOut),
			.MDUOP(MDUOP),
			.MDUBusy(MDUBusy),
			.MDUOut(E_MDUOut),
			
			.Req(Req)
		);
	
	/********** Stage M **********/	
	//about ExcCode
	assign M_ExcCode = (Raw_M_ExcCode)? Raw_M_ExcCode :
					   (M_AdEL)? `EXC_AdEL :
					   (M_AdES)? `EXC_AdES :
					   0;
	
	//about the MREG
	MREG M_reg
		(
			.clk(clk),
			.reset(reset),
			.en(1'b1),
			.Req(Req),
			.instrIn(E_instr),
			.instrOut(M_instr),
			.PCIn(E_PC),
			.PCOut(M_PC),
			.ALUOutIn(E_ALUOut),
			.ALUOutOut(M_ALUOut),
			.EXTOutIn(E_EXTOut),
			.EXTOutOut(M_EXTOut),
			.rsOutIn(E_FWrsOut),
			.rsOutOut(M_rsOut),
			.rtOutIn(E_FWrtOut),
			.rtOutOut(M_rtOut),
			.MDUOutIn(E_MDUOut),
			.MDUOutOut(M_MDUOut),
			.flag1In(E_flag1),
			.flag1Out(M_flag1),
			.flag2In(), 			//将E阶段产生的flag2信号输入，就可以流水了
			.flag2Out(M_flag2),
			.ExcCodeIn(E_ExcCode),
			.ExcCodeOut(Raw_M_ExcCode),
			.BDIn(E_BD),
			.BDOut(M_BD)
		);
	
	//about the M_FWSrc
	MUX8 M_FWSrcMux
		(
			.out(M_FWSrc),
			.sel(M_FWSrcSel),
			.in0(M_PC + 8),
			.in1(M_ALUOut),
			.in2(M_EXTOut),
			.in3(M_PC + 8),//摆烂
			.in4(M_MDUOut),
			.in5(M_PC + 8) //摆烂
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
		
	//about the DMI
	assign m_inst_addr = M_PC;
	assign VAdd = M_ALUOut;
	assign CPUByteEn = (Req)? 0 : ByteEn;
	
	DMI dmi
		(
			.tmpDMOut(CPUIn),
			.tmpDMIn(M_FWrtOut),
			.DMAdd(VAdd),
			.DMOut(M_DMOut),
			.DMIn(CPUOut),
			.LOADOP(LOADOP),
			.STOREOP(STOREOP),
			
			.isLoad(isLoad),
			.isStore(isStore),
			.AdEL(M_AdEL),
			.AdES(M_AdES)
		);
	
	//宏观PC选择M_PC
	assign macroscopic_pc = M_PC;
	
	//about the CP0
	assign M_rd = M_instr[15:11];
	
	CP0 cp0
		(
			.clk(clk),
			.reset(reset),
			.en(CP0En),
			.CP0Add(M_rd),
			.CP0In(M_FWrtOut),
			.CP0Out(M_CP0Out),
			.VPC(M_PC),
			.BDIn(M_BD),
			.ExcCodeIn(M_ExcCode),
			.HWInt(HWInt),
			.EXLClr(EXLClr),
			.EPCOut(M_EPCOut),
			.Req(Req),
			.tbReq(tbReq)
		);
	
	/********** Stage W **********/
	
	//about the WREG
	WREG W_reg
		(
			.clk(clk),
			.reset(reset),
			.en(1'b1),
			.Req(Req),
			.instrIn(M_instr),
			.instrOut(W_instr),
			.PCIn(M_PC),
			.PCOut(W_PC),
			.ALUOutIn(M_ALUOut),
			.ALUOutOut(W_ALUOut),
			.EXTOutIn(M_EXTOut),
			.EXTOutOut(W_EXTOut),
			.DMOutIn(M_DMOut),
			.DMOutOut(W_DMOut),
			.MDUOutIn(M_MDUOut),
			.MDUOutOut(W_MDUOut),
			.CP0OutIn(M_CP0Out),
			.CP0OutOut(W_CP0Out),
			.rsOutIn(M_rsOut),
			.rsOutOut(W_rsOut),
			.rtOutIn(M_FWrtOut),
			.rtOutOut(W_rtOut),
			.flag1In(M_flag1),
			.flag1Out(W_flag1),
			.flag2In(M_flag2),
			.flag2Out(W_flag2),
			.flag3In(),				//将M阶段产生的flag3信号输入，就可以流水了
			.flag3Out(W_flag3)
		);
	
	//about the W_FWSrc
	MUX8 W_FWSrcMux
		(
			.out(W_FWSrc),
			.sel(W_FWSrcSel),
			.in0(W_PC + 8),
			.in1(W_ALUOut),
			.in2(W_EXTOut),
			.in3(W_DMOut),
			.in4(W_MDUOut),
			.in5(W_CP0Out)
		);
	
	//about the GRF
	assign W_rt = W_instr[20:16];
	assign W_rd = W_instr[15:11];
	assign w_grf_we = GRFEn;
	assign w_grf_addr = W_GRFAdd3;
	assign w_grf_wdata = W_GRFIn;
	assign w_inst_addr = W_PC;
	
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
			.in2(W_PC + 8), 
			.in3(W_EXTOut),
			.in4(W_MDUOut),
			.in5(W_CP0Out)
			);	
	
endmodule 