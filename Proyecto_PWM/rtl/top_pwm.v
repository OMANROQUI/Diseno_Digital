//------------------------------------------------------------------------------
// top_pwm.v — Top-level en Verilog-2001, integra reg_if y pwm_core de un canal
//------------------------------------------------------------------------------
module top_pwm(
  clk,
  reset_n,
  addr,
  wdata,
  rdata,
  wen,
  ren,
  pwm_out
);
  parameter ADDR_WIDTH   = 8;
  parameter DATA_WIDTH   = 32;
  parameter WIDTH_PERIOD = 16;
  parameter WIDTH_DUTY   = 16;

  input                     clk;
  input                     reset_n;
  input [ADDR_WIDTH-1:0]    addr;
  input [DATA_WIDTH-1:0]    wdata;
  output [DATA_WIDTH-1:0]   rdata;
  input                     wen;
  input                     ren;
  output                    pwm_out;

  // Señales internas
  wire [DATA_WIDTH-1:0] ctrl_reg;
  wire [DATA_WIDTH-1:0] status_in;
  wire [DATA_WIDTH-1:0] status_reg;

  // Extraer periodo y duty para canal 0
  wire [WIDTH_PERIOD-1:0] period0;
  wire [WIDTH_DUTY-1:0]   duty0;

  assign period0 = ctrl_reg[DATA_WIDTH-1:WIDTH_DUTY];
  assign duty0   = ctrl_reg[WIDTH_DUTY-1:0];

  // Detección de error
  wire error_flag;
  assign error_flag = (duty0 > period0);
  assign status_in  = { {DATA_WIDTH-1{1'b0}}, error_flag };

  // Instanciación de reg_if
  reg_if u_reg_if (
    .clk(clk),
    .reset_n(reset_n),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .wen(wen),
    .ren(ren),
    .ctrl(ctrl_reg),
    .status_in(status_in),
    .status(status_reg)
  );

  // Instanciación de núcleo PWM de un canal
  pwm_core u_pwm_core (
    .clk(clk),
    .reset_n(reset_n),
    .period(period0),
    .duty(duty0),
    .pwm_out(pwm_out)
  );

endmodule
