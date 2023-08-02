/*  Checks if common data bus and issued values clash if so then choose the cdb data as they are always newer than register data.
    Should contain only combinational logic (it's basicvaly a switch).*/

module comparator (
    instr_info_if instr_info,
    instr_issue_if.cmp issue,
    register_values_if.cmp reg_val,
    common_data_bus_if cdb[2]
);

  assign reg_val.src_1 = instr_info.regs.rs_1;
  assign reg_val.src_2 = instr_info.regs.rs_2;

  assign issue.address = instr_info.address;
  assign issue.immediate = instr_info.immediate;
  assign issue.instr_name = instr_info.instr_name;
  assign issue.regs = instr_info.regs;
  assign issue.flags = instr_info.flags;

  always_comb begin : compare
    if (instr_info.regs.rs_1 == cdb[0].arn || instr_info.regs.rs_1 == cdb[0].rrn) begin
      issue.data_1  = cdb[0].data;
      issue.valid_1 = 1'h1;
    end else if (instr_info.regs.rs_1 == cdb[1].arn || instr_info.regs.rs_1 == cdb[1].rrn) begin
      issue.data_1  = cdb[1].data;
      issue.valid_1 = 1'h1;
    end else begin
      issue.data_1  = reg_val.data_1;
      issue.valid_1 = reg_val.valid_1;
    end

    if (instr_info.regs.rs_2 == cdb[0].arn || instr_info.regs.rs_2 == cdb[0].rrn) begin
      issue.data_2  = cdb[0].data;
      issue.valid_2 = 1'h1;
    end else if (instr_info.regs.rs_2 == cdb[1].arn || instr_info.regs.rs_2 == cdb[1].rrn) begin
      issue.data_2  = cdb[1].data;
      issue.valid_2 = 1'h1;
    end else begin
      issue.data_2  = reg_val.data_2;
      issue.valid_2 = reg_val.valid_2;
    end
  end
endmodule
