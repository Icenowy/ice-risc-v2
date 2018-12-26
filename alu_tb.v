`include "config/tb_timescale.vh"
`include "macros/aluops.vh"

module alu_tb();

reg clk;
reg rst_n;

reg [31:0]a_32;
reg [31:0]b_32;
reg [7:0]op_32;
reg valid_32;
wire ready_32;
wire [31:0]result_32;
wire [31:0]extra_result_32;

alu #(
	.SUPPORT_MUL(1),
	.SUPPORT_DIV(1),
	.WIDTH(32)
)alu_32(
	.clk(clk),
	.rst_n(rst_n),
	.a(a_32),
	.b(b_32),
	.op(op_32),
	.valid(valid_32),
	.ready(ready_32),
	.result(result_32),
	.extra_result(extra_result_32)
);

initial begin
	$dumpfile("alu_tb.vcd");
        $dumpvars(0,alu_tb);
	clk = 0;
	rst_n = 0;
end

initial #50 rst_n = 1;

initial #100 begin
	a_32 = 7;
	b_32 = 13;
	op_32 = `ALU_OP_ADD;
	valid_32 = 1;
end

initial #150 valid_32 = 0;

initial #1000 begin
	a_32 = 30000000;
	b_32 = 40000000;
	op_32 = `ALU_OP_MUL;
	valid_32 = 1;
end

initial #1950 valid_32 = 0;

initial #2000 begin
	a_32 = 8;
	b_32 = 3;
	op_32 = `ALU_OP_DIV;
	valid_32 = 1;
end

initial #2950 valid_32 = 0;

initial #10000 $finish;

always #10 clk = ~clk;

endmodule
