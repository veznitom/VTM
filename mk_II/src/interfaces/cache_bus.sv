import global_variables::XLEN;

interface instr_cache_bus_if;
  logic [XLEN-1:0] address;
  logic [31:0] instr;
  logic hit;
  logic read;

  modport loader(input instr, address, hit, output read);
  modport cache(input address, read, output instr, hit);
endinterface

interface data_cache_bus_if;
  logic [XLEN-1:0] address;
  logic [XLEN-1:0] data;
  logic read;
  logic write;
  logic hit;
  logic tag;

  modport load_store(input hit, inout data, output address, read, write, tag);
  modport cache(input address, read, write, tag, inout data, output hit);
endinterface
