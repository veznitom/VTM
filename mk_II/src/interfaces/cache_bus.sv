import global_variables::XLEN;

interface instr_cache_bus_if;
  logic [XLEN-1:0] address_in, address_out;
  logic [31:0] instr;
  logic hit, read;

  modport loader(input instr, address_out, hit, output read);
  modport cache(input address_in, read, output instr, address_out, hit);
endinterface

interface data_cache_bus_if;
  logic [XLEN-1:0] address;
  logic [XLEN-1:0] data;
  logic read, write, hit, tag;

  modport load_store(input hit, inout data, output address, read, write, tag);
  modport cache(input address, read, write, tag, inout data, output hit);
endinterface

