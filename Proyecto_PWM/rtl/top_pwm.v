cat << 'EOF' > rtl/top_pwm.v
//------------------------------------------------------------------------------  
// top_pwm.v — Top-level que integra reg_if + pwm_core  
//------------------------------------------------------------------------------
module top_pwm
  #(
    parameter ADDR_WIDTH   = 8,
    parameter DATA_WIDTH   = 32,
    parameter N_CHANNELS   = 4,
    parameter WIDTH_PERIOD = 16,
    parameter WIDTH_DUTY   = 16
  )
  (
    input  logic                     clk,
    input  logic                     reset_n,
    input  logic [ADDR_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    wdata,
    output logic [DATA_WIDTH-1:0]    rdata,
    input  logic                     wen,
    input  logic                     ren,
    output logic [N_CHANNELS-1:0]    pwm_out
  );

  // Registro de control y flags de estado
  logic [DATA_WIDTH-1:0] ctrl_reg;
  logic [DATA_WIDTH-1:0] status_reg;
  logic [DATA_WIDTH-1:0] status_in;

  // Buses de período y duty por canal
  logic [WIDTH_PERIOD-1:0] period_bus [N_CHANNELS-1:0];
  logic [WIDTH_DUTY-1:0]   duty_bus   [N_CHANNELS-1:0];

  // Mapeo: ctrl_reg[31:16]=periodo, ctrl_reg[15:0]=duty para canal 0
  assign period_bus[0] = ctrl_reg[DATA_WIDTH-1:WIDTH_DUTY];
  assign duty_bus[0]   = ctrl_reg[WIDTH_DUTY-1:0];

  // Canales extra a cero
  genvar i;
  generate
    for (i = 1; i < N_CHANNELS; i++) begin : gen_zero
      assign period_bus[i] = '0;
      assign duty_bus[i]   = '0;
    end
  endgenerate

  // Detección de error: duty > period en canal 0
  logic error_flag;
  assign error_flag = (duty_bus[0] > period_bus[0]);
  assign status_in  = { {DATA_WIDTH-1{1'b0}}, error_flag };

  // Instancia de interfaz de registro
  reg_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) u_reg_if (
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

  // Instancia del núcleo PWM
  pwm_core #(
    .N_CHANNELS(N_CHANNELS),
    .WIDTH_PERIOD(WIDTH_PERIOD),
    .WIDTH_DUTY(WIDTH_DUTY)
  ) u_pwm_core (
    .clk(clk),
    .reset_n(reset_n),
    .period(period_bus),
    .duty(duty_bus),
    .pwm_out(pwm_out)
  );

endmodule
EOF
