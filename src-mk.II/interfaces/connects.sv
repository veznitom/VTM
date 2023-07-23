interface global_signals_if (
    input logic clk,
    reset
);
  logic delete_tagged, clear_tags;

  modport rob(input clk, reset, output delete_tagged, clear_tags);

  modport rest(input clk, reset, delete_tagged, clear_tags);
endinterface

interface debug_interface_if;
  logic [31:0] reg_11_value;
  logic [ 6:0] ren_queue_size;
endinterface

interface pc_interface_if#(
    parameterint XLEN = 32
) ();
  logic [31:0] jmp_address, address;
  logic plus_4, plus_8, write;

  modport pc(input jmp_address, plus_4, plus_8, write, output address);

  modport dispatch(input address, output plus_4, plus_8);

  modport rob(output jmp_address, write);
endinterface

interface register_values_if #(
    parameterint XLEN = 32
) ();
  logic [XLEN-1:0] data_1, data_2;
  logic [5:0] src_1, src_2;
  logic valid_1, valid_2;
endinterface

interface instr_info_if #(
    parameter int XLEN = 32
);
  logic [XLEN-1:0] addresses[2];
  logic [XLEN-1:0] immediates[2];
  instr_name_e instr_names[2];
  instr_type_e instr_types[2];
  src_dest_t regs[2];
  flag_vector_t flags[2];
endinterface
