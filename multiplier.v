module multiplier #(
	parameter [7:0]WIDTH = 32
)(
	input clk,
	input rst_n,
	input [WIDTH-1:0]a,
	input [WIDTH-1:0]b,
	input valid,
	output ready,
	output [WIDTH-1:0]hi,
	output [WIDTH-1:0]lo
);

reg ready;
reg [WIDTH-1:0]hi;
reg [WIDTH-1:0]lo;

reg [2*WIDTH-1:0]result;

reg [8:0] current_bit;

always @(posedge clk) begin
	if (!rst_n || !valid) begin
		ready <= 0;
		result <= 0;
		current_bit <= 0;
		hi <= 'bx;
		lo <= 'bx;
	end else begin
		if (current_bit == WIDTH) begin
			ready <= 1;
			hi <= result[2*WIDTH-1:WIDTH];
			lo <= result[WIDTH-1:0];
		end else begin
			if (b[current_bit])
				result <= result + (a << current_bit);
			current_bit <= current_bit + 1;
		end
	end
end

endmodule
