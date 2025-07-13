//------------------------------------------------------------------------------
// reg_if.v — Interfaz de registro en puro Verilog-2001 (sin SystemVerilog)
//------------------------------------------------------------------------------
module reg_if(
  clk,
  reset_n,
  addr,
  wdata,
  rdata,
  wen,
  ren,
  ctrl,
  status_in,
  status
);
  parameter ADDR_WIDTH = 8;
  parameter DATA_WIDTH = 32;

  input                     clk;
  input                     reset_n;
  input [ADDR_WIDTH-1:0]    addr;
  input [DATA_WIDTH-1:0]    wdata;
  output [DATA_WIDTH-1:0]   rdata;
  input                     wen;
  input                     ren;
  output [DATA_WIDTH-1:0]   ctrl;
  input [DATA_WIDTH-1:0]    status_in;
  output [DATA_WIDTH-1:0]   status;

  // Offsets
  localparam [ADDR_WIDTH-1:0] ADDR_CTRL   = 8'h00;
  localparam [ADDR_WIDTH-1:0] ADDR_STATUS = 8'h04;

  reg [DATA_WIDTH-1:0] ctrl_reg;
  reg [DATA_WIDTH-1:0] status_reg;
  reg [DATA_WIDTH-1:0] read_data;

  // Escritura y actualización de status
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      ctrl_reg   <= {DATA_WIDTH{1'b0}};
      status_reg <= {DATA_WIDTH{1'b0}};
    end else begin
      status_reg <= status_in;
      if (wen) begin
        case (addr)
          ADDR_CTRL: ctrl_reg <= wdata;
          default: /* noop */;
        endcase
      end
    end
  end

  // Lectura
  always @(*) begin
    if (ren) begin
      case (addr)
        ADDR_CTRL:   read_data = ctrl_reg;
        ADDR_STATUS: read_data = status_reg;
        default:     read_data = {DATA_WIDTH{1'b0}};
      endcase
    end else begin
      read_data = {DATA_WIDTH{1'b0}};
    end
  end

  assign ctrl   = ctrl_reg;
  assign status = status_reg;
  assign rdata  = read_data;

endmodule
