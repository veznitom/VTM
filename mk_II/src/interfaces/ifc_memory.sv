// Copyright (c) 2024 veznitom

interface ifc_memory #(
    parameter int BUS_WIDTH_BYTES = 256
) ();
  logic [(BUS_WIDTH_BYTES * 8) - 1:0] data;
  logic [31:0] address;
  logic read, write, ready, done;

  modport cache(input ready, done, inout data, output address, read, write);
  modport mmu(input read, write, inout data, address, output ready, done);
  modport ram(input address, read, write, inout data, output ready, done);
  modport cpu(input ready, done, inout data, output address, read, write);
endinterface  //ifc_memory
