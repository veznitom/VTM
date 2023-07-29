interface register_query_if;
  logic [5:0] ret_renamed_num, reg_1_ren_num, reg_2_ren_num;
  logic [4:0] reg_1_num, reg_2_num, reg_3_num;
  logic get_renamed_num, tag;
  modport dispatch(
      input ret_renamed_num, reg_1_ren_num, reg_2_ren_num,
      output reg_1_num, reg_2_num, reg_3_num, get_renamed_num, tag
  );
  modport regs(
      input reg_1_num, reg_2_num, reg_3_num, get_renamed_num, tag,
      output ret_renamed_num, reg_1_ren_num, reg_2_ren_num
  );
endinterface
