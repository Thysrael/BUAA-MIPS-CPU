`timescale 1ns/1ps

module mips_txt;

	reg clk;
	reg reset;
	reg interrupt;

	wire [31:0] macroscopic_pc;

	wire [31:0] i_inst_addr;
	wire [31:0] i_inst_rdata;

	wire [31:0] m_data_addr;
	wire [31:0] m_data_rdata;
	wire [31:0] m_data_wdata;
	wire [3 :0] m_data_byteen;

	wire [31:0] m_inst_addr;

	wire		w_grf_we;
	wire [4 :0] w_grf_addr;
	wire [31:0] w_grf_wdata;

	wire [31:0] w_inst_addr;

	mips uut(
		.clk(clk),
		.reset(reset),
		.interrupt(interrupt),
		.macroscopic_pc(macroscopic_pc),

		.i_inst_addr(i_inst_addr),
		.i_inst_rdata(i_inst_rdata),

		.m_data_addr(m_data_addr),
		.m_data_rdata(m_data_rdata),
		.m_data_wdata(m_data_wdata),
		.m_data_byteen(m_data_byteen),

		.m_inst_addr(m_inst_addr),

		.w_grf_we(w_grf_we),
		.w_grf_addr(w_grf_addr),
		.w_grf_wdata(w_grf_wdata),

		.w_inst_addr(w_inst_addr)
	);

	initial begin
		clk <= 0;
		reset <= 1;
		interrupt <= 0;
		#20 reset <= 0;
	end

	integer i;
	reg [31:0] fixed_addr;
	reg [31:0] fixed_wdata;
	reg [31:0] data[0:4095];
	reg [31:0] inst[0:5119];

	// ----------- For Instructions -----------

	assign m_data_rdata = data[(m_data_addr >> 2) % 5120];
	assign i_inst_rdata = inst[((i_inst_addr - 32'h3000) >> 2) % 5120];

	initial begin
		$readmemh("code.txt", inst);
		for (i = 0; i < 5120; i = i + 1) data[i] <= 0;
	end

	// ----------- For Data Memory -----------

	always @(*) begin
		fixed_wdata = data[(m_data_addr >> 2) & 4095];
		fixed_addr = m_data_addr & 32'hfffffffc;
		if (m_data_byteen[3]) fixed_wdata[31:24] = m_data_wdata[31:24];
		if (m_data_byteen[2]) fixed_wdata[23:16] = m_data_wdata[23:16];
		if (m_data_byteen[1]) fixed_wdata[15: 8] = m_data_wdata[15: 8];
		if (m_data_byteen[0]) fixed_wdata[7 : 0] = m_data_wdata[7 : 0];
	end

	always @(posedge clk) begin
		if (reset) for (i = 0; i < 4096; i = i + 1) data[i] <= 0;
		else if (|m_data_byteen && fixed_addr >> 2 < 4096) begin
			data[fixed_addr >> 2] <= fixed_wdata;
			$display("@%h: *%h <= %h",  m_inst_addr, fixed_addr, fixed_wdata);
		end
	end

	// ----------- For Registers -----------

	always @(posedge clk) begin
		if (~reset) begin
			if (w_grf_we && (w_grf_addr != 0)) begin
				$display("@%h: $%d <= %h",  w_inst_addr, w_grf_addr, w_grf_wdata);
			end
		end
	end

	// ----------- For Interrupt -----------

	wire [31:0] fixed_macroscopic_pc;

	assign fixed_macroscopic_pc = macroscopic_pc & 32'hfffffffc;

	always @(posedge clk) begin
		if (reset) interrupt <= 0;
	end

	always @(negedge clk) begin
		if (~reset && interrupt && |m_data_byteen) begin
			if (fixed_addr == 32'h7F20) begin
				interrupt <= 0;
			end
		end
	end

	reg [31:0]need_interrupt = 37;

	always @(negedge clk) begin
		if (~reset) begin
			if (need_interrupt==32'd37 && fixed_macroscopic_pc == 32'h3008) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd36 && fixed_macroscopic_pc == 32'h301c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd35 && fixed_macroscopic_pc == 32'h3030) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd34 && fixed_macroscopic_pc == 32'h3034) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd33 && fixed_macroscopic_pc == 32'h3038) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd32 && fixed_macroscopic_pc == 32'h3048) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd31 && fixed_macroscopic_pc == 32'h3058) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd30 && fixed_macroscopic_pc == 32'h3064) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd29 && fixed_macroscopic_pc == 32'h3074) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd28 && fixed_macroscopic_pc == 32'h3078) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd27 && fixed_macroscopic_pc == 32'h3084) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd26 && fixed_macroscopic_pc == 32'h308c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd25 && fixed_macroscopic_pc == 32'h309c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd24 && fixed_macroscopic_pc == 32'h30a4) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd23 && fixed_macroscopic_pc == 32'h30b4) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd22 && fixed_macroscopic_pc == 32'h30d0) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd21 && fixed_macroscopic_pc == 32'h30f8) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd20 && fixed_macroscopic_pc == 32'h3104) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd19 && fixed_macroscopic_pc == 32'h310c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd18 && fixed_macroscopic_pc == 32'h3114) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd17 && fixed_macroscopic_pc == 32'h311c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd16 && fixed_macroscopic_pc == 32'h3134) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd15 && fixed_macroscopic_pc == 32'h313c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd14 && fixed_macroscopic_pc == 32'h3150) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd13 && fixed_macroscopic_pc == 32'h316c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd12 && fixed_macroscopic_pc == 32'h3174) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd11 && fixed_macroscopic_pc == 32'h318c) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd10 && fixed_macroscopic_pc == 32'h31a0) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd9 && fixed_macroscopic_pc == 32'h31b8) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd8 && fixed_macroscopic_pc == 32'h31d4) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd7 && fixed_macroscopic_pc == 32'h31f8) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd6 && fixed_macroscopic_pc == 32'h3214) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd5 && fixed_macroscopic_pc == 32'h32c8) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd4 && fixed_macroscopic_pc == 32'h32d0) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd3 && fixed_macroscopic_pc == 32'h32e4) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd2 && fixed_macroscopic_pc == 32'h32f4) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else if (need_interrupt==32'd1 && fixed_macroscopic_pc == 32'h3300) begin
				interrupt <= 1;
				need_interrupt <= need_interrupt - 1;
			end
			else need_interrupt <= need_interrupt;
			
		end
	end

	always #2 clk <= ~clk;

endmodule
