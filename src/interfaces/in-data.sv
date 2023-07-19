`include "../Structures.sv"

interface register_query_if;
  logic [5:0] ret_renamed_num, reg_1_ren_num, reg_2_ren_num;
  logic [4:0] reg_1_num, reg_2_num, reg_3_num;
  logic get_renamed_num, tag;

  modport dispatch(
      input ret_renamed_num, reg_1_ren_num, reg_2_ren_num,
      output reg_1_num, reg_2_num, reg_3_num, get_renamed_num, tag,
      import clear_source, read
  );

  modport regs(
      input reg_1_num, reg_2_num, reg_3_num, get_renamed_num, tag,
      output ret_renamed_num, reg_1_ren_num, reg_2_ren_num,
      import clear_results
  );

  task automatic clear_source();
    begin
      reg_1_num = 5'hzz;
      reg_2_num = 5'hzz;
      reg_3_num = 5'hzz;
      get_renamed_num = 1'h0;
      tag = 1'h0;
    end
  endtask

  task automatic clear_results();
    ret_renamed = 6'hzz;
    reg1_ren = 6'hzz;
    reg2_ren = 6'hzz;
  endtask

  task automatic read(input logic [4:0] reg_1, input logic [4:0] reg_2, input logic [4:0] reg_3,
                      input logic get_ren_num, input logic task_tag);
    reg_1_num = reg_1;
    reg_2_num = reg_2;
    reg_3_num = reg_3;
    get_renamed = get_ren;
    tag = task_tag;
  endtask
endinterface

interface instr_issue_if #(
    parameterint XLEN = 32
) ();
  logic [XLEN-1:0] address, immediate;
  logic [5:0] src_1, src_2, arn, rrn;
  logic jump, tag;

  instr_name_e instr_name;
  st_type_e st_type;

  modport dispatch(
      output address, immediate, src_1, src_2, arn, rrn, jump, tag, instr_type, instr_name,
      import clear, write
  );

  modport combo(
      input address, immediate, src_1, src_2, arn, rrn, jump, tag, instr_type, instr_name
  );

  modport rob(input address, arn, rrn, jump, tag);

  task automatic write;
    input logic [31:0] task_address, task_imm;
    input logic [5:0] task_src_1, task_src_2, task_arn, task_rrn;
    input logic task_jump, task_tag;
    input st_type_e task_st_type;
    input instr_name_e task_instr_name;
    begin
      address <= task_address;
      immediate <= task_imm;
      instr_name <= task_instr_name;
      src1 <= task_src_1;
      src2 <= task_src_2;
      arn <= task_arn;
      rrn <= task_rrn;
      st_type <= task_st_type;
      jump <= task_jump;
      tag <= task_tag;
    end
  endtask

  task automatic clear();
    begin
      address <= 32'hzzzzzzzz;
      immediate <= 32'hzzzzzzzz;
      instr_name <= UNKNOWN;
      src1 <= 6'hzz;
      src2 <= 6'hzz;
      arn <= 6'hzz;
      rrn <= 6'hzz;
      st_type <= XX;
      jump <= 1'hz;
      tag <= 1'hz;
    end
  endtask
endinterface

interface common_data_bus_if #(
    parameterint XLEN = 32
) ();
  wire [XLEN-1:0] result, address, jmp_address;
  wire [5:0] arn, rrn;
  wire [3:0] select;
  wire we;

  modport combo(input arn, inout result, address, jmp_address, select, output rrn, we);

  modport rob(inout result, address, jmp_address, arn, rrn, select, output we);

  modport reg_file(input result, address, arn, rrn, we);

  modport cache(input result, address);

endinterface

interface station_unit_if #(
    parameterint XLEN = 32
) ();
  logic [XLEN-1:0] data_1, data_2, addrres, immediate;
  logic [5:0] rrn;
  instr_name_e instr_name;

  modport station(output data_1, data_2, address, immediate, rrn, tag, instr_name, import clear);

  modport exec(input data_1, data_2, address, immediate, rrn, tag, instr_name);

  task automatic clear();
    data_1 <= 32'hzzzzzzzz;
    data_2 <= 32'hzzzzzzzz;
    address <= 32'hzzzzzzzz;
    immediate <= 32'hzzzzzzzz;
    instr_name <= UNKNOWN;
    rrn <= 6'hzz;
  endtask

  task automatic write;
    input logic [31:0] task_data_1, task_data_2, task_address, task_imm;
    input instr_name_e task_instr_name;
    input logic [5:0] task_rrn;
    begin
      data_1 <= task_data_1;
      data_2 <= taks_data_2;
      address <= task_address;
      immediate <= task_imm;
      instr_name <= task_instr_name;
      rrn <= task_rrn;
    end
  endtask

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
