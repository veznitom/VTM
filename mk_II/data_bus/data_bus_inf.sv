interface data_bus_if;
  logic [31:0] data, address, jmp_address;
  logic [5:0] rd, rn;
  logic [7:0] select;
  logic reg_write, cache_write;

  modport arbiter(output data, address, jmp_address, rd, rn, reg_write, cache_write, inout select);
  modport combo(input data, address, rd, rn);
  modport rob(input data, address, jmp_address, rd, rn);
  modport reg_file(input data, rd, rn, reg_write);
  modport cache(input data, address, cache_write);
  modport cmp(input data, rd, rn);
endinterface  //data_bus
