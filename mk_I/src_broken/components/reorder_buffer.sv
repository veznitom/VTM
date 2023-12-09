module reorder_buffer #(
    parameter int SIZE = 16,
    parameter int ARB_ADDRESS = 4'h2
) (
    global_signals_if gs,
    instr_issue_if issue[2],
    common_data_bus_if cdb[2],
    pc_cntrl_if pc
);

  logic [1:0] get_bus, bus_enable;
  logic [1:0] bus_granted;

  rob_record_t records[$:SIZE];

  Arbiter #(ARB_ADDRESS) arbiter_1 (
      get_bus[0],
      cdb[0].select,
      bus_granted[0]
  );
  Arbiter #(ARB_ADDRESS) arbiter_2 (
      get_bus[1],
      cdb[1].select,
      bus_granted[1]
  );

  always @(bus_granted) begin
    casez (bus_granted)
      2'b?1:   bus_enable = 2'b01;
      2'b10:   bus_enable = 2'b10;
      default: bus_enable = 2'b00;
    endcase
  end

  always_comb begin
    if (gs.reset) records.delete();
  end

  always @(posedge gs.clk) begin
    if (records[0].jump && records[0].completed) begin
      if (records[0].address + 4 == records[0].jump_address) begin
        pc_control.jump_address <= 32'hzzzzzzzz;
        pc_control.wr <= 1'b0;

        global_signals.clear_tags = 1'b1;
        global_signals.delete_tagged = 1'b0;
      end else begin
        pc_control.jump_address <= records[0].jump_address;
        pc_control.wr <= 1'b1;

        global_signals.clear_tags = 1'b0;
        global_signals.delete_tagged = 1'b1;
      end
    end else begin
      pc_control.jump_address <= 32'hzzzzzzzz;
      pc_control.wr <= 1'b0;

      global_signals.clear_tags = 1'b0;
      global_signals.delete_tagged = 1'b0;
    end
  end

  always @(posedge gs.clk) begin
    if (!bus_granted && records[0].completed && (records.size() > 0) && !records[0].ignore) begin
      get_bus <= 2'b11;
    end else begin
      get_bus <= 2'b00;
    end
  end

  always @(posedge gs.clk) begin
    if (records[0].ignore || bus_granted) records.pop_front();
  end

  always @(posedge gs.clk) begin
    if (issue[0].st_type != XX && !global_signals.delete_tagged)
      records.push_back('{32'h00000000, issue[0].address, 32'h00000000, issue[0].arn, issue[0].rrn, 1'b0,
                        issue[0].jump, issue[0].tag, 1'b0});

    if (issue[1].st_type != XX && !global_signals.delete_tagged)
      records.push_back('{32'h00000000, issue[1].address, 32'h00000000, issue[1].arn, issue[1].rrn, 1'b0,
                        issue[1].jump, issue[1].tag, 1'b0});
  end

  always @(posedge gs.clk) begin
    foreach (records[i]) begin
      if (records[i].address == cdb[0].address) begin
        records[i].data = cdb[0].data;
        records[i].jump_address = records[i].jump ? cdb[0].jump_address : 32'h00000000;
        records[i].finished = 1'b1;
      end

      if (records[i].address == cdb[1].address) begin
        records[i].data = cdb[1].data;
        records[i].jump_address = records[i].jump ? cdb[1].jump_address : 32'h00000000;
        records[i].finished = 1'b1;
      end
    end
  end

  always @(posedge gs.delete_tagged) begin
    for (int i = 0; i < rob_size; i++) if (records[i].tag) records[i].ignore = 1'b1;
  end

  always @(posedge gs.clear_tags) begin
    for (int i = 0; i < rob_size; i++) if (records[i].tag) records[i].tag = 1'b0;
  end

  assign cdb[0].result = bus_enable[0] ? records[0].data : 32'hzzzzzzzz;
  assign cdb[0].address = bus_enable[0] ? records[0].address : 32'hzzzzzzzz;
  assign cdb[0].jump_address = bus_enable[0] ? records[0].jump_address : 32'hzzzzzzzz;
  assign cdb[0].arn = bus_enable[0] ? records[0].arn : 6'hzz;
  assign cdb[0].rrn = bus_enable[0] ? records[0].rrn : 6'hzz;
  assign cdb[0].we = bus_enable[0] ? 1'b1 : 1'bz;

  assign cdb[1].result = bus_enable[1] ? records[0].data : 32'hzzzzzzzz;
  assign cdb[1].address = bus_enable[1] ? records[0].address : 32'hzzzzzzzz;
  assign cdb[1].jump_address = bus_enable[1] ? records[0].jump_address : 32'hzzzzzzzz;
  assign cdb[1].arn = bus_enable[1] ? records[0].arn : 6'hzz;
  assign cdb[1].rrn = bus_enable[1] && !bus_granted[0] ? records[0].rrn : 6'hzz;
  assign cdb[1].we = bus_enable[1] && !bus_granted[0] ? 1'b1 : 1'bz;

endmodule
