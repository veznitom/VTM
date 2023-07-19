interface data_memory_bus_if #(
    parameter int WIDTH = 256,
    parameterint XLEN = 32
) ();
  wire  [WIDTH-1:0] data;
  logic [ XLEN-1:0] address;
  logic read, write, ready, done;
  data_width_e data_width;

  modport mmu(input data, address, read, write, data_width, output ready, done);

  modport cache(input ready, done, inout data, output address, read, write, data_width);
endinterface

interface cache_bus_if #(
    parameter int WIDTH = 256,
    parameterint XLEN = 32
) ();
  wire  [WIDTH-1:0] data;
  logic [ XLEN-1:0] address;
  logic read, write, tag, hit;
  data_width_e data_width;

  modport load_store(input hit, inout data, output address, read, write, tag, data_width);

  modport cache(input address, read, write, tag, data_width, inout data, output hit);
endinterface

interface instr_memory_bus_if #(
    parameter int WIDTH = 256,
    parameterint XLEN = 32
) ();
  logic [WIDTH-1:0] data;
  logic [ XLEN-1:0] address;
  logic read, ready;

  modport cache(input ready, data, output address, read);

  modport mmu(input address, read, output ready, data);
endinterface

interface memory_bus_if #(
    parameter int WIDTH = 256,
    parameterint XLEN = 32
) ();
  wire  [WIDTH-1:0] data;
  logic [ XLEN-1:0] address;
  logic read, write, ready, done;

  modport ram(input address, read, write, source, inout data, output ready, done);

  modport cpu(input ready, done, inout data, output address, read, write, source);
endinterface

