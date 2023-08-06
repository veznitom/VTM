interface memory_bus_if #(
    parameter int BUS_WIDTH_BYTE = 4,
    parameter int BIT_WIDTH_BITS = $clog2(BUS_WIDTH_BYTE),
    parameter int XLEN = 32
) ();
  logic [(BUS_WIDTH_BYTE*8)-1:0] data;
  logic [XLEN-1:0] address;
  logic read, write, tag, ready, done, hit;

  modport load_store(input hit, inout data, output address, read, write, tag);
  modport loader(input data, address, hit, output read);
  modport cache_cpu(input address, read, write, tag, inout data, output hit);
  modport cache_mem(input ready, done, inout data, output address, read, write);
  modport mmu(input data, address, read, write, output ready, done);
  modport ram(input address, read, write, inout data, output ready, done);
  modport cpu(input ready, done, inout data, output address, read, write);
endinterface

