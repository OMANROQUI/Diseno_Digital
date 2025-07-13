cat << 'EOF' > rtl/pwm_core.v
//------------------------------------------------------------------------------  
// pwm_core.v — Núcleo PWM con N canales, contador y comparación de duty  
//------------------------------------------------------------------------------
module pwm_core
  #(
    parameter int N_CHANNELS   = 4,   // número de canales PWM
    parameter int WIDTH_PERIOD = 16,  // ancho en bits de registro de período
    parameter int WIDTH_DUTY   = 16   // ancho en bits de registro de duty
  )
  (
    input  logic                                 clk,
    input  logic                                 reset_n,
    input  logic [N_CHANNELS-1:0][WIDTH_PERIOD-1:0] period,  // valores de período
    input  logic [N_CHANNELS-1:0][WIDTH_DUTY-1:0]   duty,    // valores de duty
    output logic [N_CHANNELS-1:0]                  pwm_out // salidas PWM
  );

  genvar i;
  generate
    for (i = 0; i < N_CHANNELS; i++) begin : gen_pwm
      // contador para cada canal
      logic [WIDTH_PERIOD-1:0] counter;

      // Lógica de conteo
      always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
          counter <= '0;
        else if (counter >= period[i] - 1)
          counter <= '0;
        else
          counter <= counter + 1;
      end

      // Comparación para generar PWM
      assign pwm_out[i] = (counter < duty[i]);
    end
  endgenerate

endmodule
EOF
