module divider #(
	parameter [7:0]WIDTH = 32
)(
	input clk,
	input rst_n,
	input [WIDTH-1:0]a,
	input [WIDTH-1:0]b,
	input valid,
	output ready,
	output [WIDTH-1:0]quotient,
	output [WIDTH-1:0]remainder
);

reg ready;
reg [WIDTH-1:0]quotient;
reg [WIDTH-1:0]remainder;

reg [2*WIDTH-1:0]temp_a;
reg [2*WIDTH-1:0]new_temp_a;
reg [2*WIDTH-1:0]temp_b;

wire [WIDTH-1:0]zero_pad = 0;

reg [8:0] current_bit;

reg running;

always @* begin
	new_temp_a = {temp_a[2*WIDTH-2:0], 1'b0};
	if (new_temp_a[2*WIDTH-1:WIDTH] >= b)
		new_temp_a = new_temp_a - temp_b + 1'b1;
	else
		new_temp_a = new_temp_a;
end

always @(posedge clk) begin
	if (!rst_n || !valid) begin
		ready <= 0;
		temp_a <= 0;
		temp_b <= 0;
		current_bit <= 0;
		quotient <= 'bx;
		remainder <= 'bx;
		running <= 0;
	end else begin
		if (current_bit == 0 && !running) begin
			temp_a <= {zero_pad, a};
			temp_b <= {b, zero_pad};
			running <= 1;
		end else if (running) begin
			if (current_bit == WIDTH) begin
				running <= 0;
				quotient <= temp_a[WIDTH-1:0];
				remainder <= temp_a[2*WIDTH-1:WIDTH];
				ready <= 1;
			end else begin
				temp_a <= new_temp_a;
			end
			current_bit <= current_bit + 1;
		end
	end
end

endmodule
