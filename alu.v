`include "macros/aluops.vh"

module alu #(
	parameter [0:0]SUPPORT_MUL = 0,
	parameter [0:0]SUPPORT_DIV = 0,
	parameter [7:0]WIDTH = 32
)(
	input clk,
	input rst_n,
	input [WIDTH-1:0]a,
	input [WIDTH-1:0]b,
	input [7:0] op,
	input valid,
	output ready,
	output [WIDTH-1:0]result,
	output [WIDTH-1:0]extra_result
);

localparam [3:0]BIT_WIDTH = (WIDTH == 4) ? 2 :
			    ((WIDTH == 8) ? 3 :
			     ((WIDTH == 16) ? 4 :
			      ((WIDTH == 32) ? 5 :
			       ((WIDTH == 64) ? 6 :
			        ((WIDTH == 128) ? 7 : 0)))));

generate if (BIT_WIDTH == 0) begin
	invalid_alu invalud_alu();
end endgenerate

localparam SUPPORT_MULTI_CYCLE_OP = SUPPORT_MUL || SUPPORT_DIV;

wire mul = (SUPPORT_MUL && op == `ALU_OP_MUL);
wire div = (SUPPORT_DIV && op == `ALU_OP_DIV);

wire multi_cycle = mul || div;

wire single_cycle_valid = valid && (!multi_cycle);
wire multi_cycle_valid = valid && multi_cycle;

wire mul_valid = valid && mul;
wire div_valid = valid && div;

reg [WIDTH-1:0]single_cycle_result;
reg [WIDTH-1:0]single_cycle_extra_result;
wire [WIDTH-1:0]multi_cycle_result;
wire [WIDTH-1:0]multi_cycle_extra_result;

reg single_cycle_ready;
wire multi_cycle_ready;

wire mul_ready;
wire div_ready;

wire [WIDTH-1:0]mul_hi;
wire [WIDTH-1:0]mul_lo;

wire [WIDTH-1:0]div_quotient;
wire [WIDTH-1:0]div_remainder;

assign ready = single_cycle_valid ? single_cycle_ready :
	       (multi_cycle_valid ? multi_cycle_ready : 1'b0);

assign result = (single_cycle_valid && single_cycle_ready) ?
		single_cycle_result :
	        ((multi_cycle_valid && multi_cycle_ready) ?
		 multi_cycle_result : 'bx);

assign extra_result = (single_cycle_valid && single_cycle_ready) ?
		      single_cycle_extra_result :
		      ((multi_cycle_valid && multi_cycle_ready) ?
		       multi_cycle_extra_result : 'bx);

assign multi_cycle_ready = mul_valid ? mul_ready :
			   (div_valid ? div_ready : 1'b0);

assign multi_cycle_result = mul_ready ? mul_lo :
			    (div_ready ? div_quotient : 'bx);

assign multi_cycle_extra_result = mul_ready ? mul_hi :
				  (div_ready ? div_remainder : 'bx);

generate if (SUPPORT_MUL) begin
	multiplier #(
		.WIDTH(WIDTH)
	)main_multiplier(
		.clk(clk),
		.rst_n(rst_n),
		.a(a),
		.b(b),
		.valid(mul_valid),
		.ready(mul_ready),
		.hi(mul_hi),
		.lo(mul_lo)
	);
end endgenerate

generate if (SUPPORT_DIV) begin
	divider #(
		.WIDTH(WIDTH)
	)main_divider(
		.clk(clk),
		.rst_n(rst_n),
		.a(a),
		.b(b),
		.valid(div_valid),
		.ready(div_ready),
		.quotient(div_quotient),
		.remainder(div_remainder)
	);
end endgenerate

always @* begin
	if (single_cycle_valid) begin
		single_cycle_ready = 1;
		case (op)
		`ALU_OP_ADD: begin
			single_cycle_result = a + b;
			single_cycle_extra_result = 0;
		end
		`ALU_OP_SLTU: begin
			single_cycle_result = a < b;
			single_cycle_extra_result = 0;
		end
		`ALU_OP_SLT: begin
			single_cycle_extra_result = 0;
			if (a[WIDTH-1] && b[WIDTH-1])
				single_cycle_result = a > b;
			else if (a[WIDTH-1])
				single_cycle_result = 1;
			else if (b[WIDTH-1])
				single_cycle_result = 0;
			else
				single_cycle_result = a < b;
		end
		`ALU_OP_AND: begin
			single_cycle_result = a & b;
			single_cycle_extra_result = 0;
		end
		`ALU_OP_OR: begin
			single_cycle_result = a | b;
			single_cycle_extra_result = 0;
		end
		`ALU_OP_XOR: begin
			single_cycle_result = a ^ b;
			single_cycle_extra_result = 0;
		end
		`ALU_OP_SLL: begin
			single_cycle_result = a << b[BIT_WIDTH-1:0];
			single_cycle_extra_result = 0;
		end
		`ALU_OP_SRL: begin
			single_cycle_result = a >> b[BIT_WIDTH-1:0];
			single_cycle_extra_result = 0;
		end
		`ALU_OP_SRA: begin
			single_cycle_result = a >>> b[BIT_WIDTH-1:0];
			single_cycle_extra_result = 0;
		end
		`ALU_OP_SUB: begin
			single_cycle_result = a - b;
			single_cycle_extra_result = 0;
		end
		`ALU_OP_EQ: begin
			single_cycle_result = a == b;
			single_cycle_extra_result = 0;
		end
		default: begin
			single_cycle_result = 0;
			single_cycle_extra_result = 0;
		end
		endcase
	end else begin
		single_cycle_ready = 0;
		single_cycle_result = 0;
		single_cycle_extra_result = 0;
	end
end

endmodule
