`timescale 1ns / 1ps
`define IM SR[15:10]
`define EXL SR[1]
`define IE SR[0]
`define BD Cause[31]
`define IP Cause[15:10]
`define ExcCode Cause[6:2]

module CP0
	(
		input clk,
		input reset,
		input en,
		input [4:0] CP0Add,
		input [31:0] CP0In,
		output [31:0] CP0Out,
		input [31:0] VPC,
		input BDIn,
		input [4:0] ExcCodeIn,
		input [5:0] HWInt,
		input EXLClr,
		output [31:0] EPCOut,
		output Req,
		output tbReq
	);
	
	reg [31:0] SR, Cause, EPC, PrID;
	
	//Ϊ�˲���Լ��
	assign tbReq = (HWInt[2] & SR[12] & (~`EXL) & `IE);
	
	wire IntReq = (|(HWInt & `IM)) & (~`EXL) & `IE;
	//������û��ȫ���ж�ʹ�ܣ���Ҫ��Ӧ�쳣
	wire ExcReq = (|ExcCodeIn) & (~`EXL);
	assign Req = IntReq | ExcReq;
	//����������жϣ���Ҫ������EPC�����򱣳�ԭֵ
	wire [31:0] nextEPC = (Req)? ((BDIn)? VPC - 4 : VPC) :
								 EPC;							 
	
	assign EPCOut = EPC;
	
	assign CP0Out = (CP0Add == 5'd12)? SR :
					(CP0Add == 5'd13)? Cause : 
					(CP0Add == 5'd14)? EPC :
					(CP0Add == 5'd15)? PrID :
					0;
	
	initial begin
		SR <= 0;
		Cause <= 0;
		EPC <= 0;
		PrID <= 32'hDEAD_C0DE;
	end
	
	always @(posedge clk) begin
		if(reset) begin
			SR <= 0;
			Cause <= 0;
			EPC <= 0;
			PrID <= 32'hDEAD_C0DE;		
		end
		else begin
			if(EXLClr) `EXL <= 0;
			
			if(Req) begin //�൱��Req���ٵ�ʱ����û�а취��mt��д������
				`ExcCode <= IntReq ? 5'b0 : ExcCodeIn;
				`EXL <= 1;
				EPC <= nextEPC;
				`BD <= BDIn;
			end
			else if(en) begin
				if(CP0Add == 12) SR <= CP0In;
				//if(CP0Add == 13) Cause <= CP0In;
				if(CP0Add == 14) EPC <= CP0In;
				//if(CP0Add == 15) PrID <= CP0In;
			end
			`IP <= HWInt;
		end
	end
	
	
endmodule 