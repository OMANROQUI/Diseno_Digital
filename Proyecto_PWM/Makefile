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
# Makefile (en la carpeta raíz Proyecto_PWM)
IVERILOG = iverilog -g2012
VVP      = vvp

.PHONY: sim-regif sim-core sim-top all clean

sim-regif:
	$(IVERILOG) -o sim/reg_if.vvp tb/reg_if_tb.v rtl/*.v
	$(VVP) sim/reg_if.vvp

sim-core:
	$(IVERILOG) -o sim/core.vvp tb/pwm_core_tb.v rtl/*.v
	$(VVP) sim/core.vvp

sim-top:
	$(IVERILOG) -o sim/top.vvp tb/top_pwm_tb.v rtl/*.v
	$(VVP) sim/top.vvp

all: sim-regif sim-core sim-top

clean:
	rm -rf sim/*.vvp
