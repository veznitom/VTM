import CustomTypes::*;

module ROB#(
  parameter int rob_size = 16,
  parameter int arbiter_address = 4'h2
)(
  GlobalSignals.rob global_signals,
  InstrIssue.rob issue1, issue2,
  CommonDataBus.rob data_bus1, data_bus2,
  PCInterface.rob pc_control
);

  logic [1:0] get_bus, bus_enable;
  logic [1:0] bus_granted;

  ROBRecord records[$:rob_size];
  
  Arbiter #(arbiter_address) arbiter1(get_bus[0], data_bus1.select, bus_granted[0]);
  Arbiter #(arbiter_address) arbiter2(get_bus[1], data_bus2.select, bus_granted[1]);

  always @( bus_granted ) begin
    casez(bus_granted)
      2'b?1: bus_enable = 2'b01;
      2'b10: bus_enable = 2'b10;
      default: bus_enable = 2'b00;
    endcase
  end

  always @(*) begin : records_reset
    if ( global_signals.reset )
      records.delete();
  end
  
  always @( posedge global_signals.clk ) begin
    if (records[0].jump && records[0].finished) begin
      if(records[0].address + 4 == records[0].jump_address) begin
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

  always @( posedge global_signals.clk ) begin
    if (!bus_granted && records[0].finished && (records.size() > 0) && !records[0].ignore) begin
      get_bus <= 2'b11;
    end else begin
      get_bus <= 2'b00;
    end
  end

  always @( posedge global_signals.clk ) begin
    if (records[0].ignore || bus_granted)
      records.pop_front();
  end

  always @( posedge global_signals.clk ) begin
    if (issue1.stat_select != NONE && !global_signals.delete_tagged)
      records.push_back('{
        32'h00000000,
        issue1.address, 
        32'h00000000, 
        issue1.arn, issue1.rrn, 
        1'b0, issue1.jump, issue1.tag, 1'b0});

    if (issue2.stat_select != NONE && !global_signals.delete_tagged)
      records.push_back('{
        32'h00000000,
        issue2.address,
        32'h00000000,
        issue2.arn, issue2.rrn,
        1'b0, issue2.jump, issue2.tag, 1'b0});
  end

  always @( posedge global_signals.clk ) begin
    foreach (records[i]) begin
      if (records[i].address == data_bus1.address) begin
        records[i].data = data_bus1.data;
        records[i].jump_address = records[i].jump ? data_bus1.jump_address : 32'h00000000;
        records[i].finished = 1'b1;
      end

      if (records[i].address == data_bus2.address) begin
        records[i].data = data_bus2.data;
        records[i].jump_address = records[i].jump ? data_bus2.jump_address : 32'h00000000;
        records[i].finished = 1'b1;
      end
    end
  end

  always @( posedge global_signals.delete_tagged) begin
    for(int i = 0; i < rob_size; i++)
      if (records[i].tag)
        records[i].ignore = 1'b1;
  end

  always @( posedge global_signals.clear_tags) begin
    for(int i = 0; i < rob_size; i++)
      if (records[i].tag)
        records[i].tag = 1'b0;
  end

  assign data_bus1.data = bus_enable[0] ? records[0].data : 32'hzzzzzzzz;
  assign data_bus1.address = bus_enable[0] ? records[0].address : 32'hzzzzzzzz;
  assign data_bus1.jump_address = bus_enable[0] ? records[0].jump_address : 32'hzzzzzzzz;
  assign data_bus1.arn = bus_enable[0] ? records[0].arn : 6'hzz;
  assign data_bus1.rrn = bus_enable[0] ? records[0].rrn : 6'hzz;
  assign data_bus1.we = bus_enable[0] ? 1'b1 : 1'bz;

  assign data_bus2.data = bus_enable[1] ? records[0].data : 32'hzzzzzzzz;
  assign data_bus2.address = bus_enable[1] ? records[0].address : 32'hzzzzzzzz;
  assign data_bus2.jump_address = bus_enable[1] ? records[0].jump_address : 32'hzzzzzzzz;
  assign data_bus2.arn = bus_enable[1] ? records[0].arn : 6'hzz;
  assign data_bus2.rrn = bus_enable[1] && !bus_granted[0] ? records[0].rrn : 6'hzz;
  assign data_bus2.we = bus_enable[1] && !bus_granted[0] ? 1'b1 : 1'bz;

endmodule