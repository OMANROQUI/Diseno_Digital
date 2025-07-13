cat << 'EOF' > rtl/reg_if.v
//------------------------------------------------------------------------------  
// reg_if.v — Interfaz de registro (APB/AHB-lite)  
//------------------------------------------------------------------------------
module reg_if
  #(
    // parameter ADDR_WIDTH = …,
    // parameter DATA_WIDTH = …
  )
  (
    // input  logic                clk,
    // input  logic                reset_n,
    // input  logic [ADDR_WIDTH-1:0] addr,
    // input  logic [DATA_WIDTH-1:0] wdata,
    // output logic [DATA_WIDTH-1:0] rdata,
    // input  logic                wen,
    // input  logic                ren
  );
  // TODO: implementar registros CTRL/STATUS, lógica de lectura/escritura
endmodule
EOF
