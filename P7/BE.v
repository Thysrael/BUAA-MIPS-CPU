`timescale 1ns / 1ps
`include "CONST.v"

module BE
	(
		input [31:0] VAdd,
		input [3:0] CPUByteEn,
		input [31:0] DMOut,
		input [31:0] TC0Out,
		input [31:0] TC1Out,
		output [31:0] DMAdd,
		output [29:0] TC0Add,
		output [29:0] TC1Add,
		output [3:0] DMByteEn,
		output TC0WE,
		output TC1WE,
		output [31:0] BEOut
	);
	
	//利用VAdd的取值在哪一个范围去看要访问哪一个IO
	wire DMHit = (VAdd >= `DMLL && VAdd <= `DMUL);
	wire TC0Hit = (VAdd >= `TC0LL && VAdd <= `TC0UL);
	wire TC1Hit = (VAdd >= `TC1LL && VAdd <= `TC1UL);
	
	//处理VAdd地址，加工成IO地址
	assign DMAdd = (DMHit)? VAdd : 0;
	assign TC0Add = (TC0Hit)? VAdd[31:2] : 0;
	assign TC1Add = (TC1Hit)? VAdd[31:2] : 0;
	
	//写使能信号的选择
	assign DMByteEn = (DMHit)? CPUByteEn : 0;
	assign TC0WE = (TC0Hit && (CPUByteEn == 4'b1111));
	assign TC1WE = (TC1Hit && (CPUByteEn == 4'b1111));
	
	//从IO设备中读数据
	assign BEOut = (DMHit)? DMOut :
				   (TC0Hit)? TC0Out :
				   (TC1Hit)? TC1Out :
				   32'h0;
	
endmodule 