// tb/reg_if_tb.v
`timescale 1ns/1ps

module reg_if_tb;

  // Dump para GTKWave
  initial begin
    $dumpfile("sim/reg_if_tb.vcd");
    $dumpvars(0, reg_if_tb);
  end

  // --------------------------------------------------
  // Señales de interfaz
  // --------------------------------------------------
  reg         clk;
  reg         reset_n;
  reg  [7:0]  addr;
  reg  [31:0] wdata;
  wire [31:0] rdata;
  reg         wen;
  reg         ren;
  wire [31:0] ctrl;
  reg  [31:0] status_in;
  wire [31:0] status;

  // Variable para almacenar lectura de rdata
  reg  [31:0] read_val;

  // --------------------------------------------------
  // Instancia del DUT
  // --------------------------------------------------
  reg_if dut (
    .clk       (clk),
    .reset_n   (reset_n),
    .addr      (addr),
    .wdata     (wdata),
    .rdata     (rdata),
    .wen       (wen),
    .ren       (ren),
    .ctrl      (ctrl),
    .status_in (status_in),
    .status    (status)
  );

  // --------------------------------------------------
  // 1) Generación de reloj (10 ns de período)
  // --------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // --------------------------------------------------
  // 2) Reset activo bajo por 2 ciclos de reloj
  // --------------------------------------------------
  initial begin
    reset_n = 0;
    #20;        // 2 ciclos de 10 ns
    reset_n = 1;
  end

  // --------------------------------------------------
  // 3) Tarea de escritura por bus
  // --------------------------------------------------
  task bus_write(input [7:0] a, input [31:0] d);
    begin
      @(negedge clk);
      addr  = a;
      wdata = d;
      wen   = 1;
      ren   = 0;
      @(negedge clk);
      wen   = 0;
      addr  = 8'h00;
      wdata = 32'h0;
    end
  endtask

  // --------------------------------------------------
  // 4) Tarea de lectura por bus
  // --------------------------------------------------
  task bus_read(input [7:0] a, output [31:0] d);
    begin
      @(negedge clk);
      addr  = a;
      ren   = 1;
      wen   = 0;
      @(negedge clk);
      d     = rdata;
      ren   = 0;
      addr  = 8'h00;
    end
  endtask

  // --------------------------------------------------
  // 5) Bloque principal de test
  // --------------------------------------------------
  initial begin
    // Inicialización de señales
    addr      = 8'h00;
    wdata     = 32'h0;
    wen       = 0;
    ren       = 0;
    status_in = 32'hDEADBEEF;  // valor de prueba para status

    // Esperar a que salga de reset
    @(posedge reset_n);
    $display("** Reset completo @ %0t **", $time);

    // Escribe 0x12345678 en CTRL (addr = 0x00)
    bus_write(8'h00, 32'h12345678);
    $display("WRITE CTRL = 0x12345678 @ %0t", $time);

    // Lee la misma dirección para verificar via rdata
    bus_read(8'h00, read_val);
    $display("READ  CTRL via rdata = 0x%0h @ %0t", read_val, $time);
    if (read_val !== 32'h12345678)
      $error("FAIL: rdata (0x%0h) != 0x12345678", read_val);

    // Verifica la salida directa 'ctrl'
    if (ctrl !== 32'h12345678)
      $error("FAIL: ctrl port (0x%0h) != 0x12345678", ctrl);
    else
      $display("PASS: ctrl port OK");

    // Verifica el registro de status
    if (status !== status_in)
      $error("FAIL: status port (0x%0h) != 0x%0h", status, status_in);
    else
      $display("PASS: status port OK");

    // Finalizar simulación
    #20;
    $display("** Testbench completo **");
    $finish;
  end

endmodule
