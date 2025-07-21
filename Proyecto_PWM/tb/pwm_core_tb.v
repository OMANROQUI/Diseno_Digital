// tb/pwm_core_tb.v
`timescale 1ns/1ps

module pwm_core_tb;

  // Dump para GTKWave
  initial begin
    $dumpfile("sim/pwm_core_tb.vcd");
    $dumpvars(0, pwm_core_tb);
  end

  // --------------------------------------
  // Señales
  // --------------------------------------
  reg         clk;
  reg         reset_n;
  reg  [15:0] period;   // ancho según WIDTH_PERIOD (default 16)
  reg  [15:0] duty;     // ancho según WIDTH_DUTY   (default 16)
  wire        pwm_out;

  // --------------------------------------
  // Instancia del DUT
  // --------------------------------------
  pwm_core dut (
    .clk      (clk),
    .reset_n  (reset_n),
    .period   (period),
    .duty     (duty),
    .pwm_out  (pwm_out)
  );

  // --------------------------------------
  // Reloj: 10 ns período
  // --------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // --------------------------------------
  // Reset activo bajo por 2 ciclos
  // --------------------------------------
  initial begin
    reset_n = 0;
    #20;
    reset_n = 1;
  end

  // --------------------------------------
  // Contadores auxiliares
  // --------------------------------------
  integer high_count, low_count, i;

  // --------------------------------------
  // Bloque principal de test
  // --------------------------------------
  initial begin
    @(posedge reset_n);
    $display("** PWM Core Testbench Started **");

    // Fijar el período constante en 100 ciclos
    period = 100;

    // Recorre DUTY = 0%, 50%, 100%
    for (i = 0; i <= 100; i = i + 50) begin
      duty       = i;       // duty en porcentaje de period
      high_count = 0;
      low_count  = 0;

      // Medir sobre un periodo completo
      repeat (period) begin
        @(posedge clk);
        if (pwm_out)
          high_count = high_count + 1;
        else
          low_count  = low_count + 1;
      end

      // Mostrar resultados
      $display("Duty=%0d%% => high_count=%0d, low_count=%0d", duty, high_count, low_count);

      // Verificaciones
      if (high_count !== duty)
        $error("FAIL: high_count (%0d) != duty (%0d)", high_count, duty);
      else
        $display("PASS: high_count OK");

      if (low_count !== (period - duty))
        $error("FAIL: low_count (%0d) != period-duty (%0d)", low_count, period-duty);
      else
        $display("PASS: low_count OK");

      $display("-----------------------------");
    end

    $display("** PWM Core Testbench Completed **");
    #10;
    $finish;
  end

endmodule
