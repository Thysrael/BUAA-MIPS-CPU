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
	
	//����VAdd��ȡֵ����һ����Χȥ��Ҫ������һ��IO
	wire DMHit = (VAdd >= `DMLL && VAdd <= `DMUL);
	wire TC0Hit = (VAdd >= `TC0LL && VAdd <= `TC0UL);
	wire TC1Hit = (VAdd >= `TC1LL && VAdd <= `TC1UL);
	
	//����VAdd��ַ���ӹ���IO��ַ
	assign DMAdd = (DMHit)? VAdd : 0;
	assign TC0Add = (TC0Hit)? VAdd[31:2] : 0;
	assign TC1Add = (TC1Hit)? VAdd[31:2] : 0;
	
	//дʹ���źŵ�ѡ��
	assign DMByteEn = (DMHit)? CPUByteEn : 0;
	assign TC0WE = (TC0Hit && (CPUByteEn == 4'b1111));
	assign TC1WE = (TC1Hit && (CPUByteEn == 4'b1111));
	
	//��IO�豸�ж�����
	assign BEOut = (DMHit)? DMOut :
				   (TC0Hit)? TC0Out :
				   (TC1Hit)? TC1Out :
				   32'h0;
	
endmodule 