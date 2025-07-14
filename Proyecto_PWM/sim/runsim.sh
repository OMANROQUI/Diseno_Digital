#!/bin/bash
case $1 in
  regif)
    iverilog -g2012 -o sim/reg_if.vvp tb/reg_if_tb.v rtl/*.v && vvp sim/reg_if.vvp
    ;;
  core)
    iverilog -g2012 -o sim/core.vvp tb/pwm_core_tb.v rtl/*.v && vvp sim/core.vvp
    ;;
  top)
    iverilog -g2012 -o sim/top.vvp tb/top_pwm_tb.v rtl/*.v && vvp sim/top.vvp
    ;;
  all)
    $0 regif
    $0 core
    $0 top
    ;;
  clean)
    rm -rf sim/*.vvp
    ;;
  *)
    echo "Usage: $0 {regif|core|top|all|clean}"
    ;;
esac
