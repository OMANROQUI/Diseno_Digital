// tb/top_pwm_tb.v
`timescale 1ns/1ps

module top_pwm_tb;

  // Dump para GTKWave
  initial begin
    $dumpfile("sim/top_pwm_tb.vcd");
    $dumpvars(0, top_pwm_tb);
  end

  // --------------------------------------------------
  // Parámetros del bus
  // --------------------------------------------------
  localparam ADDR_CTRL   = 8'h00;
  localparam ADDR_STATUS = 8'h04;

  // --------------------------------------------------
  // Señales de Interfaz
  // --------------------------------------------------
  reg         clk;
  reg         reset_n;
  reg  [7:0]  addr;
  reg [31:0]  wdata;
  wire [31:0] rdata;
  reg         wen;
  reg         ren;
  wire        pwm_out;

  // Variables de test
  reg [31:0] read_val;
  reg [31:0] expected_ctrl;
  integer    high_count, low_count, i;

  // --------------------------------------------------
  // Instancia del DUT
  // --------------------------------------------------
  top_pwm dut (
    .clk     (clk),
    .reset_n (reset_n),
    .addr    (addr),
    .wdata   (wdata),
    .rdata   (rdata),
    .wen     (wen),
    .ren     (ren),
    .pwm_out (pwm_out)
  );

  // --------------------------------------------------
  // Generador de reloj (10 ns período)
  // --------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // --------------------------------------------------
  // Reset activo bajo por 2 ciclos
  // --------------------------------------------------
  initial begin
    reset_n = 0;
    #20;
    reset_n = 1;
  end

  // --------------------------------------------------
  // Tarea de escritura por bus
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
  // Tarea de lectura por bus
  // --------------------------------------------------
  task bus_read(input [7:0] a, output [31:0] d);
    begin
      @(negedge clk);
      addr = a;
      ren  = 1;
      wen  = 0;
      @(negedge clk);
      d    = rdata;
      ren  = 0;
      addr = 8'h00;
    end
  endtask

  // --------------------------------------------------
  // Bloque principal de test
  // --------------------------------------------------
  initial begin
    // Inicialización
    addr  = 8'h00;
    wdata = 32'h0;
    wen   = 0;
    ren   = 0;

    @(posedge reset_n);
    $display("** Top-level Testbench Started @ %0t **", $time);

    // ------------------------------------------------
    // 1) Test escritura/lectura de CTRL
    // ------------------------------------------------
    expected_ctrl = {16'd100, 16'd30};
    $display("WRITE CTRL = 0x%0h", expected_ctrl);
    bus_write(ADDR_CTRL, expected_ctrl);

    bus_read(ADDR_CTRL, read_val);
    $display("READ  CTRL via rdata = 0x%0h", read_val);

    if (read_val !== expected_ctrl)
      $error("FAIL: CTRL mismatch (0x%0h vs expected 0x%0h)", read_val, expected_ctrl);
    else
      $display("PASS: CTRL read/write OK");

    // ------------------------------------------------
    // 2) Simula PWM para duty=30 sobre periodo=100
    // ------------------------------------------------
    high_count = 0;
    low_count  = 0;

    // Mide 100 ciclos de reloj
    for (i = 0; i < 100; i = i + 1) begin
      @(posedge clk);
      if (pwm_out)
        high_count = high_count + 1;
      else
        low_count  = low_count + 1;
    end
    $display("Duty=30%% => high_count=%0d, low_count=%0d", high_count, low_count);

    if (high_count !== 30)
      $error("FAIL: high_count (%0d) != 30", high_count);
    else
      $display("PASS: high_count OK");

    if (low_count !== 70)
      $error("FAIL: low_count (%0d) != 70", low_count);
    else
      $display("PASS: low_count OK");

    // ------------------------------------------------
    // 3) Test de error_flag: duty > periodo
    // ------------------------------------------------
    wdata = {16'd50, 16'd60};  // duty=60 > periodo=50
    bus_write(ADDR_CTRL, wdata);
    bus_read(ADDR_STATUS, read_val);
    $display("READ STATUS = 0x%0h", read_val);

    if (read_val[0] !== 1'b1)
      $error("FAIL: error_flag should be 1 when duty>period");
    else
      $display("PASS: error_flag OK (duty>period)");

    // ------------------------------------------------
    // Finalización
    // ------------------------------------------------
    #20;
    $display("** Top-level Testbench Completed **");
    $finish;
  end

endmodule
