`timescale 1ns / 1ps

module EREG
	(
		input clk,
		input reset,
		input en,
		input Req,
		input flush,
		
		input [31:0] instrIn,
		input [31:0] PCIn,
		input [31:0] EXTOutIn,
		input [31:0] rsOutIn,
		input [31:0] rtOutIn,
		input flag1In,
		input BDIn,
		input [4:0] ExcCodeIn,
		output reg [31:0] instrOut,
		output reg [31:0] PCOut,
		output reg [31:0] EXTOutOut,
		output reg [31:0] rsOutOut,
		output reg [31:0] rtOutOut,
		output reg flag1Out,
		output reg BDOut,
		output reg [4:0] ExcCodeOut
	);
	
	reg [31:0] nextPC;
	
	always @(*) begin
		if(reset) nextPC = 32'h3000;
		else if(Req) nextPC = 32'h4180;
		else if(flush) nextPC = PCIn; //这里应该是用前一条指令的PC，这样的nop不会触发延迟槽检查
		else if(en) nextPC = PCIn;
		else nextPC = PCOut;
	end
	
	initial begin
		instrOut <= 0;
		PCOut <= 32'h3000;
		EXTOutOut <= 0;
		rsOutOut <= 0;
		rtOutOut <= 0;
		flag1Out <= 0;	
		BDOut <= 0;
		ExcCodeOut <= 0;
	end
	
    always @(posedge clk) begin
        if (reset | Req | flush) begin
            instrOut <= 0;
            EXTOutOut <= 0;
            rsOutOut <= 0;
            rtOutOut <= 0;
			flag1Out <= 0;
			BDOut <= (reset)? 0 : ((Req)? 0 : ((flush)? BDIn : 0));
			ExcCodeOut <= 0;
			
        end 
		else if(en) begin
            instrOut <= instrIn;
            EXTOutOut <= EXTOutIn;
            rsOutOut <= rsOutIn;
            rtOutOut <= rtOutIn;
			flag1Out <= flag1In;
			BDOut <= BDIn;
			ExcCodeOut <= ExcCodeIn;
        end
		
		PCOut <= nextPC;
    end	
	
endmodule 