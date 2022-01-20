`timescale 1ns / 1ps
`include "CONST.v"

module CORE
	(
		input [31:0] instr,
		output reg [6:0] order
	);
	
	wire [5:0] opcode = instr[31:26];
	wire [5:0] funcode = instr[5:0];
	wire [4:0] rt = instr[20:16];
	
	always @(*) begin
		case(opcode)
			0: 
				case(funcode)
					0: 	order = `sll;
					2:	order = `srl;
					3:	order = `sra;
					4:	order = `sllv;
					6:	order = `srlv;
					7: 	order = `srav;
					8: 	order = `jr;
					9:	order = `jalr;
					16: order = `mfhi;
					17:	order = `mthi;
					18: order = `mflo;
					19: order = `mtlo;
					24:	order = `mult;
					25:	order = `multu;
					26: order = `div;
					27:	order = `divu;
					32: order = `add;
					33: order = `addu;
					34: order = `sub;
					35: order = `subu;
					36: order = `and;
					37: order = `or;
					38: order = `xor;
					39: order = `nor;
					42: order = `slt;
					43: order = `sltu;
					default : order = `nop;
				endcase
				
			1:	
				case(rt)
					0:	order = `bltz;
					1:	order = `bgez;
					default : order = `nop;
				endcase
				
			2: 	order = `j;
			3: 	order = `jal;
			4: 	order = `beq;
			5:	order = `bne;
			6:	order = `blez;
			7:	order = `bgtz;
			8:	order = `addi;
			9: 	order = `addiu;
			10:	order = `slti;
			11: order = `sltiu;
			12: order = `andi;
			13: order = `ori;
			14: order = `xori;
			15: order = `lui;
			32: order = `lb;
			36: order = `lbu;
			33: order = `lh;
			35: order = `lw;
			37:	order = `lhu;
			40:	order = `sb;
			41: order = `sh;
			43: order = `sw;
			default : order = `nop;
		endcase
	end

endmodule 