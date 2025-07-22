IVERILOG = iverilog -g2012
VVP      = vvp

sim-regif:
	$(IVERILOG) -o sim/reg_if.vvp tb/reg_if_tb.v rtl/*.v && $(VVP) sim/reg_if.vvp
# …y así para sim-core y sim-top
