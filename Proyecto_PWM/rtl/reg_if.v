cat << 'EOF' > rtl/reg_if.v
//------------------------------------------------------------------------------
// reg_if.v — Interfaz de registro (APB/AHB-lite)
//   – Registros:
//       • CTRL   (offset 0x00): lectura/escritura por software
//       • STATUS (offset 0x04): lect. solo, flags de hardware
//------------------------------------------------------------------------------
module reg_if
  #(
    parameter ADDR_WIDTH = 8,    // anchura de bus de direcciones
    parameter DATA_WIDTH = 32    // anchura de datos
  )
  (
    input  logic                     clk,
    input  logic                     reset_n,
    input  logic [ADDR_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    wdata,
    output logic [DATA_WIDTH-1:0]    rdata,
    input  logic                     wen,    // write enable
    input  logic                     ren,    // read  enable
    output logic [DATA_WIDTH-1:0]    ctrl,   // valor del registro CTRL
    input  logic [DATA_WIDTH-1:0]    status_in, // flags desde PWM
    output logic [DATA_WIDTH-1:0]    status  // lectura de flags
  );

  // Offsets de registro
  localparam logic [ADDR_WIDTH-1:0] ADDR_CTRL   = 'h00;
  localparam logic [ADDR_WIDTH-1:0] ADDR_STATUS = 'h04;

  // Escritura de registros y captura de status
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      ctrl   <= '0;
      status <= '0;
    end else begin
      // Actualiza siempre status con flags de hardware
      status <= status_in;

      if (wen) begin
        case (addr)
          ADDR_CTRL: ctrl <= wdata;
          default:    /* nada */ ;
        endcase
      end
    end
  end

  // Lógica de lectura
  always_comb begin
    if (ren) begin
      case (addr)
        ADDR_CTRL:   rdata = ctrl;
        ADDR_STATUS: rdata = status;
        default:     rdata = '0;
      endcase
    end else begin
      rdata = '0;
    end
  end

endmodule
EOF
