`timescale 1ns / 1ps

module FU
	(
		input [31:0] D_instr,
		input [31:0] E_instr,
		input [31:0] M_instr,
		input [31:0] W_instr,
		output [2:0] E_FWSrcSel,
		output [2:0] M_FWSrcSel,
		output [2:0] W_FWSrcSel,
		output [2:0] D_FWrsLevelSel,
		output [2:0] D_FWrtLevelSel,
		output [2:0] E_FWrsLevelSel,
		output [2:0] E_FWrtLevelSel,
		output [2:0] M_FWrtLevelSel
	);
	
	parameter
	D = 1,
	E = 2,
	M = 3,
	W = 4,
	ZERO = 0;
	
	wire [4:0] D_A1, D_A2;
	FUCORE D_fucore
		(
			.instr(D_instr),
			.A1(D_A1),
			.A2(D_A2)
		);
	
	wire [4:0] E_A1, E_A2, E_A3;
	FUCORE E_fucore
		(
			.instr(E_instr),
			.A1(E_A1),
			.A2(E_A2),
			.A3(E_A3),
			.FWSrcSel(E_FWSrcSel)
		);
	
	wire [4:0] M_A2, M_A3;
	FUCORE M_fucore
		(
			.instr(M_instr),
			.A2(M_A2),
			.A3(M_A3),
			.FWSrcSel(M_FWSrcSel)
		);
		
	wire [4:0] W_A3;
	FUCORE W_fucore
		(
			.instr(W_instr),
			.A3(W_A3),
			.FWSrcSel(W_FWSrcSel)
		);
		
	assign D_FWrsLevelSel = (E_A3 && (D_A1 == E_A3))? E :
							(M_A3 && (D_A1 == M_A3))? M :
													  D ;
										
	assign D_FWrtLevelSel =	(E_A3 && (D_A2 == E_A3))? E :
							(M_A3 && (D_A2 == M_A3))? M :
													  D ;
													  
	assign E_FWrsLevelSel = (M_A3 && (E_A1 == M_A3))? M :
							(W_A3 && (E_A1 == W_A3))? W :
													  E ;
										
	assign E_FWrtLevelSel = (M_A3 && (E_A2 == M_A3))? M :
							(W_A3 && (E_A2 == W_A3))? W :
													  E ;
										
	assign M_FWrtLevelSel = (W_A3 && (M_A2 == W_A3))? W :
													  M ;
										
endmodule 