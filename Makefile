IVERILOG = iverilog

IVFLAGS = -y .

VVP = vvp

%.vvp: %.v
	$(IVERILOG) $(IVFLAGS) $< -o $@

%.vcd: %.vvp
	$(VVP) $(VVPFLAGS) -n $<

sim: alu_tb.vcd

alu_tb.vvp: alu_tb.v alu.vvp

alu.vvp: alu.v multiplier.vvp divider.vvp
