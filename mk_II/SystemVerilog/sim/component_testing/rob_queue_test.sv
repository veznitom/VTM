import structures::*;

module rob_queue_test ();
  bit clock;
  bit reset;

  global_bus_if global_bus (
      .clock(clock),
      .reset(reset)
  );
  pc_bus_if pc_bus ();
  common_data_bus_if data_bus[2] ();
  issue_bus_if issue[2] ();

  reorder_buffer #(
      .SIZE(4)
  ) rob (
      global_bus,
      pc_bus,
      data_bus,
      issue
  );

  initial begin
    clock = 0;
    reset = 1;
    #20 reset = 0;
    #10 issue[0].instr_type = AL;
    issue[0].address = 32'hdeadbeef;
    issue[0].regs = '{1, 2, 3, 4};
    issue[0].flags = '{1, 0, 1, 0, 1};
    #10 issue[0].instr_type = XX;
    #10 issue[0].instr_type = BR;
    issue[0].address = 32'hffffbeef;
    issue[0].regs = '{0, 4, 5, 6};
    issue[0].flags = '{1, 0, 1, 0, 1};
    #10 issue[0].instr_type = XX;
    #10 data_bus[0].address = 32'hdeadbeef;
    data_bus[0].result = 32'hffffffff;
    #10 data_bus[0].address = 32'h00000000;
    data_bus[0].result = 32'h00000000;
    #10 data_bus[0].address = 32'hffffbeef;
    data_bus[0].result = 32'h00000000;
    #200 $finish;
  end

  assign #5 clock = ~clock;
endmodule
