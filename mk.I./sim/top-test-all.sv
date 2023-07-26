import CustomTypes::*;

module TopTestAll();
  wire [31:0] debug [38:0];
  logic clk, reset;
  
  int passed = 0;
  
  localparam instr_cache_size = 16;
  localparam reg[8*100:0] hex_files[37:0] = '{ 
    "absolute-path/rv32i-tests/rv32ui-p-add.hex",
    "absolute-path/rv32i-tests/rv32ui-p-addi.hex",
    "absolute-path/rv32i-tests/rv32ui-p-and.hex",
    "absolute-path/rv32i-tests/rv32ui-p-andi.hex",
    "absolute-path/rv32i-tests/rv32ui-p-auipc.hex",
    "absolute-path/rv32i-tests/rv32ui-p-beq.hex",
    "absolute-path/rv32i-tests/rv32ui-p-bge.hex",
    "absolute-path/rv32i-tests/rv32ui-p-bgeu.hex",
    "absolute-path/rv32i-tests/rv32ui-p-blt.hex",
    "absolute-path/rv32i-tests/rv32ui-p-bltu.hex",
    "absolute-path/rv32i-tests/rv32ui-p-bne.hex",
    "absolute-path/rv32i-tests/rv32ui-p-jal.hex",
    "absolute-path/rv32i-tests/rv32ui-p-jalr.hex",
    "absolute-path/rv32i-tests/rv32ui-p-lb.hex",
    "absolute-path/rv32i-tests/rv32ui-p-lbu.hex",
    "absolute-path/rv32i-tests/rv32ui-p-lh.hex",
    "absolute-path/rv32i-tests/rv32ui-p-lhu.hex",
    "absolute-path/rv32i-tests/rv32ui-p-lui.hex",
    "absolute-path/rv32i-tests/rv32ui-p-lw.hex",
    "absolute-path/rv32i-tests/rv32ui-p-or.hex",
    "absolute-path/rv32i-tests/rv32ui-p-ori.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sb.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sh.hex",
    "absolute-path/rv32i-tests/rv32ui-p-simple.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sll.hex",
    "absolute-path/rv32i-tests/rv32ui-p-slli.hex",
    "absolute-path/rv32i-tests/rv32ui-p-slt.hex",
    "absolute-path/rv32i-tests/rv32ui-p-slti.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sltiu.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sltu.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sra.hex",
    "absolute-path/rv32i-tests/rv32ui-p-srai.hex",
    "absolute-path/rv32i-tests/rv32ui-p-srl.hex",
    "absolute-path/rv32i-tests/rv32ui-p-srli.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sub.hex",
    "absolute-path/rv32i-tests/rv32ui-p-sw.hex",
    "absolute-path/rv32i-tests/rv32ui-p-xor.hex",
    "absolute-path/rv32i-tests/rv32ui-p-xori.hex"};
  
  genvar i;
  generate
    for (i = 0; i < 38; i++) begin
      MemoryBus #(instr_cache_size*32) mem_bus();
      DebugInterface debug_bus();
      
      assign debug[i] = debug_bus.reg11_value;

      CPU #(
        .instr_cache_size(instr_cache_size), .data_cache_size(32)
      ) cpu(
        .clk(clk), .reset(reset),
        .mem_bus(mem_bus),
        .debug(debug_bus)
      );
      
      FakeRam #(
        .file_path({hex_files[i]}),
        .size_b(8192)
      ) fake_ram(
        .clk(clk), .reset(reset), 
        .mem_bus(mem_bus)
      );
    end
  endgenerate

  always #10 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;
    #20 reset = 0;
    #60000;
    for (int i = 0; i < 38; i++) begin
      assert (debug[i] == 32'h0600d000) begin
        $display("%d run %s: PASS", i, hex_files[i]);
        passed += 1;
      end else
        $display("%d run %s: FAIL", i, hex_files[i]);
    end
    $display("Total passed: %d", passed);
    $finish;
  end

endmodule