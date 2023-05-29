interface GlobalSignals(input logic clk, reset);
  logic delete_tagged, clear_tags;

  modport rob(
    input clk, reset,
    output delete_tagged, clear_tags
  );

  modport rest (
    input clk, reset, delete_tagged, clear_tags
  );
endinterface

interface DebugInterface;
  logic [31:0] reg11_value;
  logic [6:0] ren_queue_size;
endinterface

interface PCInterface;
  logic [31:0] jump_address, address;
  logic inc, inc2, wr;

  modport pc (
    input jump_address, inc, inc2, wr,
    output address
  );

  modport dispatch(
    input address,
    output inc, inc2
  );

  modport rob (
    output jump_address, wr
  );
endinterface