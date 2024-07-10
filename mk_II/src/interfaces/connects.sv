import global_variables::XLEN;

interface global_bus_if (
    input logic clock,
    input logic reset
);
  logic delete_tag, clear_tag;

  modport rob(input clock, reset, output delete_tag, clear_tag);
  modport rest(input clock, reset, delete_tag, clear_tag);
endinterface

interface pc_bus_if;
  logic [31:0] jmp_address, address;
  logic plus_4, plus_8, write;

  //modport pc(input jmp_address, plus_4, plus_8, write, output address);
  modport loader(input jmp_address, write);
  modport rob(output jmp_address, write);
endinterface

interface reg_val_bus_if;
  logic [XLEN-1:0] data_1, data_2;
  logic [5:0] src_1, src_2;
  logic valid_1, valid_2;

  modport cmp(input data_1, data_2, valid_1, valid_2, output src_1, src_2);
  modport reg_file(input src_1, src_2, output data_1, data_2, valid_1, valid_2);
endinterface

interface fullness_bus_if;
  logic alu, branch, load_store, rob, mult_div;

  modport issuer(input alu, branch, load_store, rob, mult_div);
endinterface
