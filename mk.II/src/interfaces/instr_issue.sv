import structures::*;

interface instr_issue_if #(
    parameter int XLEN = 32
) ();
  logic [XLEN-1:0] address, immediate;
  logic [5:0] src_1, src_2, arn, rrn;
  logic jump, tag;

  instr_name_e instr_name;
  st_type_e st_type;

  modport dispatch(
      output address, immediate, src_1, src_2, arn, rrn, jump, tag, st_type, instr_name,
      import clear, write
  );

  modport combo(
      input address, immediate, src_1, src_2, arn, rrn, jump, tag, st_type, instr_name
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
      src_1 <= task_src_1;
      src_2 <= task_src_2;
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
      src_1 <= 6'hzz;
      src_2 <= 6'hzz;
      arn <= 6'hzz;
      rrn <= 6'hzz;
      st_type <= XX;
      jump <= 1'hz;
      tag <= 1'hz;
    end
  endtask
endinterface
