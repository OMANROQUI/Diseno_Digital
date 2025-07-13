# --------------------------------------------------------------------------
# Makefile para síntesis y simulación RTL de top_pwm
# --------------------------------------------------------------------------

YOSYS    := yosys
IVERILOG := iverilog
VVP      := vvp

RTL_SRCS := $(wildcard rtl/*.v)
TB_SRCS  := $(wildcard tb/*.v)

# Target síntesis: activa SystemVerilog y genera top.json
.PHONY: rtl
rtl:
	yosys -p "read_verilog rtl/*.v; prep -top top_pwm; synth_ice40 -json top.json"


# Target simulación: compila y ejecuta testbench
.PHONY: sim
sim:
	$(IVERILOG) -g2012 -o sim.out $(RTL_SRCS) $(TB_SRCS)
	$(VVP) sim.out

# Limpieza de artefactos
.PHONY: clean
clean:
	rm -f sim.out top.json *.blif *.asc
