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
    ret_renamed_num = 6'hzz;
    reg_1_ren_num = 6'hzz;
    reg_1_ren_num = 6'hzz;
  endtask

  task automatic read(input logic [4:0] reg_1, input logic [4:0] reg_2, input logic [4:0] reg_3,
                      input logic get_ren_num, input logic task_tag);
    reg_1_num = reg_1;
    reg_2_num = reg_2;
    reg_3_num = reg_3;
    get_renamed_num = get_ren_num;
    tag = task_tag;
  endtask
endinterface
