import structures::*;

module ram #(
    parameter int MEM_SIZE_BYTES = 1024,
    parameter string MEM_FILE_PATH = ""
) (
    memory_bus_if memory_bus,

    input logic clock,
    input logic reset
);
  // ------------------------------- Structures -------------------------------
  typedef logic [memory_bus.BUS_WIDTH_BITS-1:0] memory_bus_data_t;

  // ------------------------------- Wires --------------------------------
  logic [7:0] data[MEM_SIZE_BYTES];
  logic [31:0] start_address, end_address;

  int file, instr_load, index;
  reg [memory_bus.BUS_WIDTH_BITS-1:0] tmp_data;

  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    if (reset) begin
      // $readmemh(MEM_FILE_PATH, data);
      file = $fopen(MEM_FILE_PATH, "r");
      index = 0;
      tmp_data = 0;
      foreach (data[i]) data[i] = 0;
      while ($fscanf(
          file, "%h", instr_load
      ) == 1) begin
        data[index+3] = instr_load[7:0];
        data[index+2] = instr_load[15:8];
        data[index+1] = instr_load[23:16];
        data[index+0] = instr_load[31:24];
        index += 4;
      end

      memory_bus.done  = 1'h0;
      memory_bus.ready = 1'h0;
    end
  end

  assign start_address = {
    memory_bus.address[31:memory_bus.BUS_BIT_LOG], {memory_bus.BUS_BIT_LOG{1'h0}}
  };
  assign end_address = {
    memory_bus.address[31:memory_bus.BUS_BIT_LOG], {memory_bus.BUS_BIT_LOG{1'h1}}
  };

  always_ff @(posedge clock) begin
    if (memory_bus.read) begin
      for (int i = 0; i < memory_bus.BUS_WIDTH_BYTES; i++) begin
        memory_bus.data <= memory_bus_data_t'(data[start_address+:memory_bus.BUS_WIDTH_BYTES]);
      end
      memory_bus.ready <= 1'h1;
    end else if (memory_bus.write) begin
      for (int i = 0; i < memory_bus.BUS_WIDTH_BYTES; i++) begin
        data[start_address+i] <= memory_bus.data[i];
      end
      memory_bus.done <= 1'h1;
    end else begin
      memory_bus.ready <= 1'h0;
      memory_bus.done  <= 1'h0;
    end
  end

endmodule
