import CustomTypes::*;

module Top();
  localparam string test_file_path = "absolute-path/rv32i-tests/rv32ui-p-add.hex";
  localparam instr_cache_size = 16;
  
  logic clk, reset;

  MemoryBus #(instr_cache_size*32) mem_bus();
  DebugInterface debug();
  
  CPU #(
    .instr_cache_size(instr_cache_size), .data_cache_size(32)
  ) cpu(
    .clk(clk), .reset(reset),
    .mem_bus(mem_bus),
    .debug(debug)
    );

  FakeRam #(
    .file_path(test_file_path), 
    .size_b(8192)
  ) fake_ram(
    .clk(clk), .reset(reset), 
    .mem_bus(mem_bus)
    );

  always #10 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;
    #20 reset = 0;
    #60000;
    $display("x11 value: %d",debug.reg11_value);
    $finish;
  end

endmodule