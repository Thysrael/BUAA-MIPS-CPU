`define nop 	7'd0
`define addu 	7'd1
`define subu 	7'd2
`define ori 	7'd3
`define lw 		7'd4
`define sw 		7'd5
`define beq 	7'd6
`define lui 	7'd7
`define j 		7'd8
`define jal 	7'd9
`define jr 		7'd10
`define lhu 	7'd11
`define lh 		7'd12
`define lbu 	7'd13
`define lb 		7'd14
`define sb		7'd15
`define sh		7'd16
`define add		7'd18
`define sub 	7'd19
`define sllv 	7'd20
`define srlv	7'd21
`define srav	7'd22
`define slt		7'd23
`define sltu	7'd24
`define sll		7'd25
`define srl		7'd26
`define sra		7'd27
`define and		7'd28
`define or 		7'd29
`define xor		7'd30
`define nor 	7'd31
`define mult	7'd32
`define multu	7'd33
`define div		7'd34
`define divu	7'd35
`define mfhi	7'd36
`define mflo	7'd37
`define mthi 	7'd38
`define mtlo	7'd39
`define addi 	7'd40
`define addiu 	7'd41
`define slti	7'd42
`define sltiu	7'd43
`define andi	7'd44
`define xori	7'd45
`define bne		7'd46
`define blez	7'd47
`define bgtz	7'd48
`define bltz	7'd49
`define bgez 	7'd50
`define jalr	7'd51
`define none 	7'd52 //none 代表指令未知
`define mfc0	7'd53
`define mtc0	7'd54
`define eret	7'd55

`define load	`lw, `lh, `lhu, `lb, `lbu
`define store	`sw, `sh, `sb
`define cal_r	`add, `addu, `sub, `subu, `sllv, `srlv, `srav, `slt, `sltu, `sll, `srl, `sra, `and, `or, `xor, `nor
`define cal_ia	`addi, `addiu, `slti, `sltiu
`define cal_il	`andi, `ori, `xori
`define branch2	`beq, `bne
`define branch1 `blez, `bgtz, `bltz, `bgez
`define jump_i	`j, `jal
`define jump_r	`jr, `jalr
`define link  	`jal, `jalr
`define md		`mult, `multu, `div, `divu
`define mf		`mfhi, `mflo
`define mt		`mthi, `mtlo

`define DMLL 	32'h0000
`define DMUL 	32'h2fff
`define IMLL 	32'h3000
`define IMUL 	32'h6ffc
`define TC0LL 	32'h7f00
`define TC0UL 	32'h7f08
`define TC1LL 	32'h7f10
`define TC1UL 	32'h7f18

`define EXC_Int 	0
`define EXC_AdEL 	4
`define EXC_AdES 	5
`define EXC_RI 		10
`define EXC_Ov 		12