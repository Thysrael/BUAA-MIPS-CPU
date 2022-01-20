`timescale 1ns / 1ps

module mips
	(
		input clk,                       // ʱ���ź�
		input reset,                     // ͬ����λ�ź�
		input interrupt,                 // �ⲿ�ж��ź�
		output [31:0] macroscopic_pc,    // ��� PC

		output [31:0] i_inst_addr,       // ȡָ PC
		input  [31:0] i_inst_rdata,      // i_inst_addr ��Ӧ�� 32 λָ��

		output [31:0] m_data_addr,       // ���ݴ洢����д���ַ
		input  [31:0] m_data_rdata,      // m_data_addr ��Ӧ�� 32 λ����
		output [31:0] m_data_wdata,      // ���ݴ洢����д������
		output [3 :0] m_data_byteen,     // �ֽ�ʹ���ź�

		output [31:0] m_inst_addr,       // M ��PC

		output w_grf_we,                 // grf дʹ���ź�
		output [4 :0] w_grf_addr,        // grf ��д��Ĵ������
		output [31:0] w_grf_wdata,       // grf ��д������

		output [31:0] w_inst_addr        // W �� PC		
	);
	
	wire [31:0] BEOut, CPUOut, VAdd;
	wire [3:0] CPUByteEn;
	wire tbReq;
	reg tmpTbReq;
	
	wire [31:0] TC0Out, TC1Out;
	wire [29:0] TC0Add, TC1Add;
	wire [31:0] DMAdd;
	wire [3:0] DMByteEn;
	wire TC0WE, TC1WE;
	
	wire TC0IRQ, TC1IRQ;
	wire [5:0] HWInt;
	
	CPU cpu
	(
		.clk(clk),
		.reset(reset),
		.HWInt(HWInt),
		
		.i_inst_addr(i_inst_addr),
		.i_inst_rdata(i_inst_rdata),
		
		.CPUIn(BEOut),
		.VAdd(VAdd),
		.CPUOut(CPUOut),
		.CPUByteEn(CPUByteEn),
		
		//�����������Լ��
		.tbReq(tbReq),
		
		//���������õ��ź�
		.m_inst_addr(m_inst_addr),
		.w_grf_we(w_grf_we),
		.w_grf_addr(w_grf_addr),
		.w_grf_wdata(w_grf_wdata),
		.w_inst_addr(w_inst_addr),
		.macroscopic_pc(macroscopic_pc)
	);
	
	BE be
	(
		.VAdd(VAdd),
		.CPUByteEn(CPUByteEn),
		.DMOut(m_data_rdata),
		.TC0Out(TC0Out),
		.TC1Out(TC1Out),
		.DMAdd(DMAdd),
		.TC0Add(TC0Add),
		.TC1Add(TC1Add),
		.DMByteEn(DMByteEn),
		.TC0WE(TC0WE),
		.TC1WE(TC1WE),
		.BEOut(BEOut)
	);
	
	TC TC0
	(
		.clk(clk),
		.reset(reset),
		.Addr(TC0Add),
		.WE(TC0WE),
		.Din(CPUOut),
		.Dout(TC0Out),
		.IRQ(TC0IRQ)
	);
	
	TC TC1
	(
		.clk(clk),
		.reset(reset),
		.Addr(TC1Add),
		.WE(TC1WE),
		.Din(CPUOut),
		.Dout(TC1Out),
		.IRQ(TC1IRQ)
	);

	assign HWInt = {3'd0, interrupt, TC1IRQ, TC0IRQ};
	
	assign m_data_wdata = CPUOut;
	
	//Ϊ�˴������Լ��
	initial begin
		tmpTbReq <= 0;
	end
	
	always @(posedge clk) begin
		tmpTbReq <= tbReq;
	end
	
	assign m_data_addr = (tmpTbReq)? 32'h7f20 : DMAdd;
	assign m_data_byteen = (tmpTbReq)? 4'b1111 : DMByteEn;
	
endmodule 