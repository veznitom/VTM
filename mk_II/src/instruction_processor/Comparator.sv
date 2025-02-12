// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Comparator (
  IntfInstrInfo.In         instr_info,
  IntfIssue.Comparator     issue,
  IntfRegValBus.Comparator reg_val,
  IntfCDB.Comparator       data      [2]
);
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    reg_val.src_1    = instr_info.regs.rs_1;
    reg_val.src_2    = instr_info.regs.rs_2;
    issue.address    = instr_info.address;
    issue.immediate  = instr_info.immediate;
    issue.instr_name = instr_info.instr_name;
    issue.instr_type = instr_info.instr_type;
    issue.regs       = instr_info.regs;
    issue.flags      = instr_info.flags;

    if (instr_info.regs.rs_1 != 0 &&
        (instr_info.regs.rs_1 == data[0].arn ||
        instr_info.regs.rs_1 == data[0].rrn)) begin
      issue.data_1  = data[0].result;
      issue.valid_1 = 1'h1;
    end else if (instr_info.regs.rs_1 != 0 &&
      (instr_info.regs.rs_1 == data[1].arn ||
      instr_info.regs.rs_1 == data[1].rrn)) begin
      issue.data_1  = data[1].result;
      issue.valid_1 = 1'h1;
    end else begin
      issue.data_1  = reg_val.data_1;
      issue.valid_1 = reg_val.valid_1;
    end

    if (instr_info.regs.rs_2 != 0 && (instr_info.regs.rs_2 == data[0].arn ||
        instr_info.regs.rs_2 == data[0].rrn)) begin
      issue.data_2  = data[0].result;
      issue.valid_2 = 1'h1;
    end else if (instr_info.regs.rs_2 != 0 && (
      instr_info.regs.rs_2 == data[1].arn ||
      instr_info.regs.rs_2 == data[1].rrn)) begin
      issue.data_2  = data[1].result;
      issue.valid_2 = 1'h1;
    end else begin
      issue.data_2  = reg_val.data_2;
      issue.valid_2 = reg_val.valid_2;
    end
  end

endmodule
