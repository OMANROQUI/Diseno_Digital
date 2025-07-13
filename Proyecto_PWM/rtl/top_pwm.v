cat << 'EOF' > rtl/top_pwm.v
//------------------------------------------------------------------------------  
// top_pwm.v — Top-level que integra reg_if + pwm_core  
//------------------------------------------------------------------------------
module top_pwm
  #(
    // parameter definitions…
  )
  (
    // puertos del bus de registro + salidas PWM
  );
  // TODO:
  //  - Instanciar reg_if
  //  - Instanciar pwm_core
  //  - Conectar period/duty desde registros
  //  - Detección de errores (duty > period)
endmodule
EOF
