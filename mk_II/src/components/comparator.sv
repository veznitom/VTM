/*  Checks if common data bus and issue_busd values clash if so then choose the data_bus data as they are always newer than register data.
    Should contain only combinational logic (it's basicvaly a switch).*/
module comparator (
    instr_info_bus_if.in instr_info,
    issue_bus_if.cmp issue_bus,
    reg_val_bus_if.cmp reg_val_bus,
    common_data_bus_if.cmp data_bus[2]
);
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    if (instr_info.regs.rs_1 == data_bus[0].arn || instr_info.regs.rs_1 == data_bus[0].rrn) begin
      issue_bus.data_1  = data_bus[0].result;
      issue_bus.valid_1 = 1'h1;
    end else if (
      instr_info.regs.rs_1 == data_bus[1].arn ||
      instr_info.regs.rs_1 == data_bus[1].rrn) begin
      issue_bus.data_1  = data_bus[1].result;
      issue_bus.valid_1 = 1'h1;
    end else begin
      issue_bus.data_1  = reg_val_bus.data_1;
      issue_bus.valid_1 = reg_val_bus.valid_1;
    end

    if (instr_info.regs.rs_2 == data_bus[0].arn || instr_info.regs.rs_2 == data_bus[0].rrn) begin
      issue_bus.data_2  = data_bus[0].result;
      issue_bus.valid_2 = 1'h1;
    end else if (
      instr_info.regs.rs_2 == data_bus[1].arn ||
      instr_info.regs.rs_2 == data_bus[1].rrn) begin
      issue_bus.data_2  = data_bus[1].result;
      issue_bus.valid_2 = 1'h1;
    end else begin
      issue_bus.data_2  = reg_val_bus.data_2;
      issue_bus.valid_2 = reg_val_bus.valid_2;
    end
  end
endmodule
