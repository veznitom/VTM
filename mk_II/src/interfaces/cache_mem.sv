// From internal compoinents to caches
interface cache_bus_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] data;
  logic [XLEN-1:0] address;
  logic read, write, tag, hit;
  modport comp(input hit, inout data, output address, read, write, tag);
  modport cache(input address, read, write, tag, inout data, output hit);
endinterface

// From caches to memory management unit
interface cache_memory_bus_if #(
    parameter int BUS_WIDTH_BYTE = 16,
    parameter int BIT_WIDTH_BITS = $clog2(BUS_WIDTH_BYTE),
    parameter int XLEN = 32
) ();
  logic [(BUS_WIDTH_BYTE*8)-1:0] data;
  logic [XLEN-1:0] address;
  logic read, write, ready, done;
  modport mmu(input data, address, read, write, output ready, done);
  modport cache(input ready, done, inout data, output address, read, write);
endinterface

// From memory management unit to main memory
interface memory_bus_if #(
    parameter int BUS_WIDTH_BYTE = 256,
    parameter int BIT_WIDTH_BITS = $clog2(BUS_WIDTH_BYTE),
    parameter int XLEN = 32
) ();
  logic [7:0] data[BUS_WIDTH_BYTE];
  logic [XLEN-1:0] address;
  logic read, write, ready, done;
  modport ram(input address, read, write, inout data, output ready, done);
  modport cpu(input ready, done, inout data, output address, read, write);
endinterface

