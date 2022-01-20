`timescale 1ns / 1ps

module GRF(
	input clk,
	input reset,
	input en,
	input [4:0] GRFAdd1,
	input [4:0] GRFAdd2,
	input [4:0] GRFAdd3,
	input [31:0] PC, //for debugging
	input [31:0] GRFIn,
	output [31:0] GRFOut1,
	output [31:0] GRFOut2
    );
	
	integer i;
	reg [31:0] GRF [0:31];
	
	assign GRFOut1 = (GRFAdd1 == GRFAdd3 && GRFAdd3 && en)? GRFIn : GRF[GRFAdd1];
	assign GRFOut2 = (GRFAdd2 == GRFAdd3 && GRFAdd3 && en)? GRFIn : GRF[GRFAdd2];
	

	initial begin
		for(i = 0; i < 32; i = i + 1)
			GRF[i] <= 0;
	end
	
	always @(posedge clk) begin
		if(reset)
			for(i = 0; i < 32; i = i + 1)
				GRF[i] <= 0;
		else if(en)
			if(GRFAdd3) begin 
				GRF[GRFAdd3] <= GRFIn;
				$display("%d@%h: $%d <= %h", $time, PC, GRFAdd3, GRFIn);
			end	
	end

endmodule
