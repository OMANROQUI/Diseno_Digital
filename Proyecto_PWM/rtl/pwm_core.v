//------------------------------------------------------------------------------
// pwm_core.v — Núcleo PWM sencillo Verilog-2001 para un canal
//------------------------------------------------------------------------------
module pwm_core #(
  parameter WIDTH_PERIOD = 16,
  parameter WIDTH_DUTY   = 16
)(
  input                    clk,
  input                    reset_n,
  input  [WIDTH_PERIOD-1:0] period,
  input  [WIDTH_DUTY-1:0]   duty,
  output                   pwm_out
);

  reg [WIDTH_PERIOD-1:0] counter;

  // Lógica de conteo
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      counter <= 0;
    else if (counter >= period - 1)
      counter <= 0;
    else
      counter <= counter + 1;
  end

  // Generación de PWM
  assign pwm_out = (counter < duty);

endmodule
