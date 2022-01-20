`timescale 1ns / 1ps

module SU
	(
		input [31:0] D_instr,
		input [31:0] E_instr,
		input [31:0] M_instr,
		output stall
	);
	
	wire [4:0] A1, A2;
	wire [2:0] rsTuse, rtTuse;//三位可以用到的是两位，绝对不会出乱子
	SUCORE D_sucore
		(
			.instr(D_instr),
			.A1(A1),
			.A2(A2),
			.rsTuse(rsTuse),
			.rtTuse(rtTuse)
		);
		
	wire [4:0] E_A3;
	wire [2:0] E_Tnew;
	SUCORE E_sucore
		(
			.instr(E_instr),
			.A3(E_A3),
			.E_Tnew(E_Tnew)
		);
		
	wire [4:0] M_A3;
	wire [2:0] M_Tnew;
	SUCORE M_sucore
		(
			.instr(M_instr),
			.A3(M_A3),
			.M_Tnew(M_Tnew)
		);
		
	wire E_StallRs = (rsTuse < E_Tnew) && (E_A3 && E_A3 == A1);
	wire E_StallRt = (rtTuse < E_Tnew) && (E_A3 && E_A3 == A2);
	wire E_Stall = E_StallRs || E_StallRt;
	
	wire M_StallRs = (rsTuse < M_Tnew) && (M_A3 && M_A3 == A1);
	wire M_StallRt = (rtTuse < M_Tnew) && (M_A3 && M_A3 == A2);
	wire M_Stall = M_StallRs || M_StallRt;
	
	assign stall = E_Stall || M_Stall;
	
endmodule 