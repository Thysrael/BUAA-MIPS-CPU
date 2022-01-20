`timescale 1ns / 1ps
`include "CONST.v"

module FSU
	(
		input [31:0] D_instr,
		input [31:0] E_instr,
		input [31:0] M_instr,
		input [31:0] W_instr,
		input E_flag1,
		input M_flag1,
		input W_flag1,
		input M_flag2,
		input W_flag2,
		input W_flag3,
		input MDUBusy,
		output reg [2:0] E_FWSrcSel,
		output reg [2:0] M_FWSrcSel,
		output reg [2:0] W_FWSrcSel,
		output [2:0] D_FWrsLevelSel,
		output [2:0] D_FWrtLevelSel,
		output [2:0] E_FWrsLevelSel,
		output [2:0] E_FWrtLevelSel,
		output [2:0] M_FWrtLevelSel,
		output stall
	);
	/*
		这个处理成流水最为漂亮，但是我现在时间不够了，所以但愿后来人能够补齐吧
	*/
	
	parameter
	D = 1,
	E = 2,
	M = 3,
	W = 4,
	ZERO = 0;

	parameter
	PC8 = 0,
	ALUOut = 1,
	EXTOut = 2,
	DMOut = 3,
	MDUOut = 4;

	//加指令的时候，当flag信号没有出现的时候，也要让其保持正常
	
	/********** Stage D **********/
	wire [6:0] D_order;
	reg [2:0] rsTuse, rtTuse;
	reg [4:0] D_A1, D_A2;
	wire [4:0] D_rs, D_rt;
	assign D_rs = D_instr[25:21];
	assign D_rt = D_instr[20:16];
	
	CORE D_core
		(
			.instr(D_instr),
			.order(D_order)
		);
		
	always @(*) begin
		//about rsTuse
		case(D_order)
			`mt, `md, `cal_r, `cal_ia, `cal_il, `load, `store : rsTuse = 1;
			`jump_r, `branch2, `branch1 : rsTuse = 0;
			default : rsTuse = 0;
		endcase
		
		//about rtTuse
		case(D_order)
			`store : rtTuse = 2;
			`md, `cal_r : rtTuse = 1;
			`branch2 : rtTuse = 0;
			default : rtTuse = 0;
		endcase
		
		//about D_A1
		case(D_order)
			`md, `mt, `cal_r, `cal_ia, `cal_il, `load, `store, `branch2, `branch1, `jump_r : D_A1 = D_rs;
			default : D_A1 = 0;
		endcase
		
		//about D_A2
		case(D_order)
			`md, `store, `cal_r, `branch2 : D_A2 = D_rt;
			default : D_A2 = 0;
		endcase
	end
	
	/********** Stage E **********/
	wire [6:0] E_order;
	reg [4:0] E_A1, E_A2, E_A3;
	reg [2:0] E_Tnew;
	
	wire [4:0] E_rs, E_rt, E_rd;
	assign E_rs = E_instr[25:21];
	assign E_rt = E_instr[20:16];
	assign E_rd = E_instr[15:11];
	
	CORE E_core
		(
			.instr(E_instr),
			.order(E_order)
		);
	
	always @(*) begin
		//about E_A1
		case(E_order)
			`md, `mt, `cal_r, `cal_ia, `cal_il, `load, `store, `branch2, `branch1, `jump_r : E_A1 = E_rs;
			default : E_A1 = 0;		
		endcase
		
		//about E_A2
		case(E_order)
			`md, `store, `cal_r, `branch2 : E_A2 = E_rt;
			default : E_A2 = 0;			
		endcase
		
		//about E_A3
		case(E_order)
			`mf, `cal_r, `jalr : E_A3 = E_rd;
			`jal : E_A3 = 5'd31;
			`cal_ia, `cal_il, `load, `lui : E_A3 = E_rt;
			default : E_A3 = 0;		
		endcase
		
		// about E_Tnew
		case(E_order)
			`load : E_Tnew = 2;
			`mf, `cal_r, `cal_ia, `cal_il : E_Tnew = 1;
			`lui, `link : E_Tnew = 0;
			default : E_Tnew = 0;			
		endcase
		
		// about E_FWSrcSel
		case(E_order)
			`link : E_FWSrcSel = PC8;
			`cal_r, `cal_ia, `cal_il : E_FWSrcSel = ALUOut;
			`lui : E_FWSrcSel = EXTOut;
			`load : E_FWSrcSel = DMOut;
			`mf : E_FWSrcSel = MDUOut;
			default : E_FWSrcSel = PC8;			
		endcase
		
	end
	
	/********** Stage M **********/
	wire [6:0] M_order;
	reg [4:0] M_A2, M_A3;
	reg [2:0] M_Tnew;
	
	wire [4:0] M_rt, M_rd;
	assign M_rt = M_instr[20:16];
	assign M_rd = M_instr[15:11];
	
	CORE M_core
		(
			.instr(M_instr),
			.order(M_order)
		);
		
	
	always @(*) begin
		// about M_A2
		// 这里如果是md和cal_r，已经没有转发的必要了，已经用完了，这里是无脑了一部分，因为反正转发的数据用不到
		case(M_order)
			`md, `store, `cal_r, `branch2 : M_A2 = M_rt;
			default : M_A2 = 0;				
		endcase
		
		// about M_A3
		case(M_order)
			`mf, `cal_r, `jalr : M_A3 = M_rd;
			`jal : M_A3 = 5'd31;
			`cal_ia, `cal_il, `load, `lui : M_A3 = M_rt;
			default : M_A3 = 0;			
		endcase
		
		// about M_Tnew
		case(M_order)
			`load : M_Tnew = 1;
			`mf, `cal_r, `cal_ia, `cal_il, `lui, `link : M_Tnew = 0;
			default : M_Tnew = 0;
		endcase
		
		// about M_FWSrcSel
		case(M_order)
			`link : M_FWSrcSel = PC8;
			`cal_r, `cal_ia, `cal_il : M_FWSrcSel = ALUOut;
			`lui : M_FWSrcSel = EXTOut;
			`load : M_FWSrcSel = DMOut;
			`mf : M_FWSrcSel = MDUOut;
			default : M_FWSrcSel = PC8;		
		endcase
	end
	
	/********** Stage W **********/
	wire [6:0] W_order;
	reg [4:0] W_A3;
	wire [4:0] W_rd, W_rt;
	assign W_rt = W_instr[20:16];
	assign W_rd = W_instr[15:11];
	
	CORE W_core
		(
			.instr(W_instr),
			.order(W_order)
		);

	always @(*) begin
		// about W_A3
		case(W_order)
			`mf, `cal_r, `jalr : W_A3 = W_rd;
			`jal : W_A3 = 5'd31;
			`cal_ia, `cal_il, `load, `lui : W_A3 = W_rt;
			default : W_A3 = 0;				
		endcase
		
		// about W_FWSrcSel
		case(W_order)
			`link : W_FWSrcSel = PC8;
			`cal_r, `cal_ia, `cal_il : W_FWSrcSel = ALUOut;
			`lui : W_FWSrcSel = EXTOut;
			`load : W_FWSrcSel = DMOut;
			`mf : W_FWSrcSel = MDUOut;
			default : W_FWSrcSel = PC8;				
		endcase
	end
	
	/********** Stage SU **********/
	
	reg E_StallRs, E_StallRt, M_StallRs, M_StallRt;
	
	reg MDUStall;
	
	// about MDUStall
	always @(*) begin
		case(D_order)
			`md, `mt, `mf : 
				if(MDUBusy) MDUStall = 1;
				else MDUStall = 0;
			default : MDUStall = 0;
		endcase
	end
	
	// about E_stall
	// 如果需要加条件，本质是因为写指令的特殊性导致的
	always @(*) begin
		case(E_order)
			default : begin
				E_StallRs = (rsTuse < E_Tnew) && (E_A3 && E_A3 == D_A1);
				E_StallRt = (rtTuse < E_Tnew) && (E_A3 && E_A3 == D_A2);
			end
		endcase
	end
	
	// about M_stall
	always @(*) begin
		case(M_order)
			default : begin
				M_StallRs = (rsTuse < M_Tnew) && (M_A3 && M_A3 == D_A1);
				M_StallRt = (rtTuse < M_Tnew) && (M_A3 && M_A3 == D_A2);
			end
		endcase
	end
	
	wire E_Stall = E_StallRs || E_StallRt;		
	wire M_Stall = M_StallRs || M_StallRt;

	assign stall = E_Stall || M_Stall || MDUStall;
	

	/********** Stage FU **********/
	
	assign D_FWrsLevelSel = (E_A3 && (D_A1 == E_A3) && (E_Tnew == 0))? E :
							(M_A3 && (D_A1 == M_A3) && (M_Tnew == 0))? M :
																	   D ;
										
	assign D_FWrtLevelSel =	(E_A3 && (D_A2 == E_A3) && (E_Tnew == 0))? E :
							(M_A3 && (D_A2 == M_A3) && (M_Tnew == 0))? M :
																	   D ;
													  
	assign E_FWrsLevelSel = (M_A3 && (E_A1 == M_A3) && (M_Tnew == 0))? M :
							(W_A3 && (E_A1 == W_A3))? W :
													  E ;
										
	assign E_FWrtLevelSel = (M_A3 && (E_A2 == M_A3) && (M_Tnew == 0))? M :
							(W_A3 && (E_A2 == W_A3))? W :
													  E ;
										
	assign M_FWrtLevelSel = (W_A3 && (M_A2 == W_A3))? W :
													  M ;	
		
endmodule 