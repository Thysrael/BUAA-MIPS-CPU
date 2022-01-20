`timescale 1ns / 1ps

//{temp_hi, temp_lo} <= {hi, lo} + $signed({{32{rs[31]}}, rs[31:0]} * $signed({{32{rt[31]}}, rt[31:0]}));
//{temp_hi, temp_lo} <= {hi, lo} + $signed($signed(64'd0) + $signed(rs) * $signed(rt));

module MDU (
    input clk,
    input reset,
    input [31:0] numA,
    input [31:0] numB,
    input [3:0] MDUOP,
    output MDUBusy,
    output reg [31:0] MDUOut,
	
	input Req
);
	
    parameter
	MULT 	= 0,
	MULTU 	= 1,
	DIV 	= 2,
	DIVU 	= 3,
	MFLO 	= 4,
	MFHI	= 5,
	MTLO	= 6,
	MTHI	= 7;
	
	reg start;
	reg busy, nextBusy;
	reg[3:0] cnt, nextCnt;
	reg [31:0] hi, lo, nextHi, nextLo;
	
	// read logic
	always @(*) begin
		case(MDUOP)
			MFLO : MDUOut = lo;
			MFHI : MDUOut = hi;
			default : MDUOut = lo;
		endcase
	end
	
	// start is only a combination logic
	always @(*) begin
		case(MDUOP)
			MULT, MULTU, DIV, DIVU : start = 1; //不需要处理
			default : start = 0;
		endcase
	end
	
	assign MDUBusy = busy | start;
	
	// about busy
	always @(*) begin
		if(nextCnt == 0)
			nextBusy = 0;
		else 
			nextBusy = 1;
	end
	
	// about cnt
	always @(*) begin
		if(cnt > 0)
			nextCnt = cnt - 1;
		else
			case(MDUOP)
				MULT, MULTU : nextCnt = 5;
				DIV, DIVU : nextCnt = 10;
				default : nextCnt = 0;
			endcase
	end
	
	// about hi, lo
	always @(*) begin
		case(MDUOP)
			MTLO :  begin //即使只有一个被赋值，两种情况也要讨论，不然造成bug
				nextLo = numA;
				nextHi = hi;
			end
			MTHI : begin
				nextHi = numA;
				nextLo = lo;
			end
			MULT : {nextHi, nextLo} = $signed(numA) * $signed(numB);
			MULTU : {nextHi, nextLo} = numA * numB;
			DIV : begin
				nextLo = $signed(numA) / $signed(numB);
				nextHi = $signed(numA) % $signed(numB);
			end
			DIVU : begin
				nextLo = numA / numB;
				nextHi = numA % numB;
			end
			default : begin
				nextLo = lo;
				nextHi = hi;
			end
		endcase
	end
	
	initial begin
		cnt 	<= 0;
		busy 	<= 0;
		hi 		<= 0;
		lo 		<= 0;
	end
	
	always @(posedge clk) begin
		if(reset) begin
			cnt 	<= 0;
			busy 	<= 0;
			hi 		<= 0;
			lo 		<= 0;
		end
		else if(~Req) begin //这是为了当MDU相关指令到达E级，此时产生中断，那么这条指令就需要作废
			cnt 	<= nextCnt;
			busy 	<= nextBusy;
			hi 		<= nextHi;
			lo 		<= nextLo;
		end
	end
	
endmodule


/*
`timescale 1ns / 1ps

//{temp_hi, temp_lo} <= {hi, lo} + $signed({{32{rs[31]}}, rs[31]} * $signed({{32{rt[31]}}, rt[31]}));

module MDU (
    input clk,
    input reset,
    input [31:0] numA,
    input [31:0] numB,
    input [3:0] MDUOP,
    output MDUBusy,
    output reg [31:0] MDUOut
);
	
    parameter
	MULT 	= 0,
	MULTU 	= 1,
	DIV 	= 2,
	DIVU 	= 3,
	MFLO 	= 4,
	MFHI	= 5,
	MTLO	= 6,
	MTHI	= 7;
	
	reg [31:0] hi, lo;
	
	// read logic
	always @(*) begin
		case(MDUOP)
			MFLO : MDUOut = lo;
			MFHI : MDUOut = hi;
			default : MDUOut = lo;
		endcase
	end
	
	reg start;
	
	always @(*) begin
		case(MDUOP)
			MULT, MULTU, DIV, DIVU : start = 1; //不需要处理
			default : start = 0;
		endcase
	end
	
	reg [31:0] tmpHi, tmpLo;
	reg [3:0] state;
	reg busy;
	
	assign MDUBusy = busy | start;
	
	initial begin
		state <= 0;
		busy <= 0;
		hi <= 0;
		lo <= 0;
	end
	
	always @(posedge clk) begin
		if(reset) begin
			state <= 0;
			busy <= 0;
			hi <= 0;
			lo <= 0;
		end
		else begin
			if(state == 0) 
				case(MDUOP)
					MTLO : lo <= numA;
					MTHI : hi <= numA;
					MULT : begin
						busy <= 1;
						state <= 5;
						{tmpHi, tmpLo} <= $signed(numA) * $signed(numB);
					end
					MULTU : begin
						busy <= 1;
						state <= 5;
						{tmpHi, tmpLo} <= numA * numB;
					end
					DIV : begin
						busy <= 1;
						state <= 10;
						tmpLo <= $signed(numA) / $signed(numB);
						tmpHi <= $signed(numA) % $signed(numB);						
					end
					DIVU : begin
						busy <= 1;
						state <= 10;
						tmpLo <= numA / numB;
						tmpHi <= numA % numB;
					end
				endcase

			else if(state == 1) begin
				busy <= 0;
				state <= 0;
				hi <= tmpHi;
				lo <= tmpLo;
			end
			else
				state <= state - 1;
		end
	end
	
endmodule


*/
