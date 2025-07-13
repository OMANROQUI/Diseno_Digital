cat << 'EOF' > rtl/pwm_core.v
//------------------------------------------------------------------------------  
// pwm_core.v — Núcleo PWM  
//------------------------------------------------------------------------------
module pwm_core
  #(
    // parameter int N_CHANNELS   = …,
    // parameter int WIDTH_PERIOD = …,
    // parameter int WIDTH_DUTY   = …
  )
  (
    // input  logic                clk,
    // input  logic                reset_n,
    // input  logic [N_CHANNELS-1:0][WIDTH_PERIOD-1:0] period,
    // input  logic [N_CHANNELS-1:0][WIDTH_DUTY-1:0]   duty,
    // output logic [N_CHANNELS-1:0]                  pwm_out
  );
  // TODO: implementar contador y comparación por canal
endmodule
EOF
