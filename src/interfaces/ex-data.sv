interface data_memory_bus_if #(
    parameter int WIDTH = 256
) ();
  wire [WIDTH-1:0] data;
  logic [31:0] address;
  logic read, write, ready, done;
  data_width_e data_width;

  modport mmu(input data, address, read, write, data_width, output ready, done);

  modport cache(input ready, done, inout data, output address, read, write, data_width);
endinterface


interface data_cache_bus_if;
  wire [31:0] data;
  logic [31:0] address, instr;
  logic read, write, tag, hit;
  data_width_e data_width;

  modport combo(input hit, inout data, output address, instr, read, write, tag, data_width);

  modport cache(input address, instr, read, write, tag, data_width, inout data, output hit);
endinterface

interface instr_memory_bus_if #(
    parameter int WIDTH = 256
) ();
  logic [WIDTH-1:0] data;
  logic [31:0] address;
  logic read, ready;

  modport cache(input ready, data, output address, read);

  modport mmu(input address, read, output ready, data);
endinterface

interface instr_cache_bus_if;
  logic [31:0] instr_1, instr_2, address;
  logic read, hit;

  modport dispatch(input instr_1, instr_2, hit, output read);

  modport cache(input address, read, output instr_1, instr_2, hit);
endinterface

interface memory_bus_if #(
    parameter int WIDTH = 256
) ();
  wire [WIDTH-1:0] data;
  logic [31:0] address;
  logic read, write, ready, done;

  modport ram(input address, read, write, source, inout data, output ready, done);

  modport cpu(input ready, done, inout data, output address, read, write, source);
endinterface

