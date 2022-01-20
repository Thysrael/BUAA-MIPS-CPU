`timescale 1ns / 1ps

module EXT(
	input [25:0] EXTIn,
	output reg [31:0] EXTOut,
	input [3:0] EXTOP
    );
	
	parameter
	ZE16 = 0,
	SE16 = 1,
	ZE26 = 2,
	LUI = 3;
	
	always @(*) begin
		case(EXTOP)
			ZE16: EXTOut = {{16{1'd0}}, EXTIn[15:0]};
			SE16: EXTOut = {{16{EXTIn[15]}}, EXTIn[15:0]};
			ZE26: EXTOut = {{6{1'd0}}, EXTIn};
			LUI : EXTOut = {EXTIn[15:0], 16'd0};
			default: EXTOut = 32'dx;
		endcase
	end

endmodule 