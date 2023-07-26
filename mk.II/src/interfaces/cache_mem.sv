// From internal compoinents to caches
interface cache_bus_if #(
    parameterint XLEN = 32
) ();
  logic [XLEN-1:0] data;
  logic [XLEN-1:0] address;
  logic read, write, tag, hit;

  modport comp(input hit, inout data, output address, read, write, tag);

  modport cache(input address, read, write, tag, inout data, output hit);
endinterface

// From caches to memory management unit
interface cache_memory_bus_if #(
    parameter int WIDTH = 256,
    parameterint XLEN = 32
) ();
  logic [WIDTH-1:0] data;
  logic [ XLEN-1:0] address;
  logic read, write, ready, done;

  modport mmu(input data, address, read, write, output ready, done);

  modport cache(input ready, done, inout data, output address, read, write);
endinterface

// From memory management unit to main memory
interface memory_bus_if #(
    parameter int WIDTH = 256,
    parameterint XLEN = 32
) ();
  logic [WIDTH-1:0] data;
  logic [ XLEN-1:0] address;
  logic read, write, ready, done;

  modport ram(input address, read, write, source, inout data, output ready, done);

  modport cpu(input ready, done, inout data, output address, read, write, source);
endinterface

