// Copyright (c) 2024 veznitom

interface ifc_memory_bus #(
    parameter int BUS_WIDTH_BYTES = 256
) ();
  wire [(BUS_WIDTH_BYTES * 8) - 1:0] data;
    wire [31:0] address;
  logic read, write, ready, done;

  modport cache(input ready, done, inout data, output address, read, write);
  modport mmu(input read, write, inout data, address, output ready, done);
  modport ram(input address, read, write, inout data, output ready, done);
  modport cpu(input ready, done, inout data, output address, read, write);

  /*task automatic clear();
    data <= {XLEN{1'h0}};
    address <= {XLEN{1'h0}};
    {read, write, ready, done} <= {1'h0, 1'h0, 1'h0, 1'h0};
  endtask*/
endinterface
