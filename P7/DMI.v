`timescale 1ns / 1ps
`include "CONST.v"

module DMI(
	input [31:0] tmpDMOut,
	input [31:0] tmpDMIn,
	input [31:0] DMAdd,
	input [3:0] LOADOP,
	input [3:0] STOREOP,
	output reg [31:0] DMOut,
	output reg [31:0] DMIn,
	
	input isLoad,
	input isStore,
	output AdEL,
	output AdES
    );

	parameter 
	LW 	= 0,
	LH 	= 1,
	LHU = 2,
	LB	= 3,
	LBU = 4;
	
	parameter
	SW	= 0,
	SH 	= 1,
	SB	= 2;
	
	wire [15:0] HalfIn = tmpDMIn[15:0];
	wire [7:0] ByteIn = tmpDMIn[7:0];
	
	wire [15:0] HalfOut = tmpDMOut[16 * DMAdd[1] +: 16];
	wire [7:0] ByteOut = tmpDMOut[8 * DMAdd[1:0] +: 8];
	
	always @(*) begin
		case(LOADOP)
			LW : DMOut = tmpDMOut;
			LH : DMOut = {{16{HalfOut[15]}}, HalfOut};
			LHU : DMOut = {16'd0, HalfOut};
			LB : DMOut = {{24{ByteOut[7]}}, ByteOut};
			LBU : DMOut = {24'd0, ByteOut};
			default : DMOut = tmpDMOut;
		endcase
	end
	
	always @(*) begin
		case(STOREOP)
			SW : DMIn = tmpDMIn;
			SH : DMIn = tmpDMIn << (16 * DMAdd[1]);
			SB : DMIn = tmpDMIn <<(8 * DMAdd[1:0]);
			default : DMIn = tmpDMIn;
		endcase
	end
	
	//about exception
	wire ErrOutOfRange = !((DMAdd >= `DMLL && DMAdd <= `DMUL) || (DMAdd >= `TC0LL && DMAdd <= `TC0UL) || (DMAdd >= `TC1LL && DMAdd <= `TC1UL));
	
	wire ErrLoadAlign = ((LOADOP == LW) && (|DMAdd[1:0])) ||
						(((LOADOP == LH) || (LOADOP == LHU)) && (DMAdd[0]));
						
	wire ErrLoadTimer = (LOADOP != LW) && (DMAdd >= `TC0LL);
	
	wire ErrStoreAlign = ((STOREOP == SW) && (|DMAdd[1:0])) ||
						 ((STOREOP == SH) && (DMAdd[0]));
						 
	wire ErrStoreTimer = (STOREOP != SW) && (DMAdd >= `TC0LL);
	
	wire ErrStoreCounter = (DMAdd == 32'h7f08 || DMAdd == 32'h7f18);
	
	assign AdEL = isLoad && (ErrOutOfRange || ErrLoadAlign || ErrLoadTimer);
	assign AdES = isStore && (ErrOutOfRange || ErrStoreAlign || ErrStoreTimer || ErrStoreCounter);
endmodule
