interface cpu_debug_if;
  logic [31:0] reg_11_value;
  logic [ 6:0] ren_queue_size;
endinterface

interface memory_debug_if #(
    parameter int SIZE_BYTES = 128
);
  logic [7:0] bytes[SIZE_BYTES];
  logic en_debug;
endinterface
