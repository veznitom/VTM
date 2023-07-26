import CustomTypes::*;

module BranchCombo #(
  parameter int station_size = 1,
  parameter int arbiter_address = 4'h4
)(
  GlobalSignals.rest global_signals,
  InstrIssue.combo issue1, issue2,
  CommonDataBus.combo data_bus1, data_bus2,
  // Dispatch
  output logic [15:0] free_space
);

// Connections
  logic [31:0] pc, rd;
  logic [1:0] get_bus, bus_granted, bus_enable;

  ExecFeed exec_feed();

// Modules
  ResStation #(station_size, BRANCH) station(
    .global_signals(global_signals), 
    .issue1(issue1), .issue2(issue2), 
    .data_bus1(data_bus1), .data_bus2(data_bus2),
    .exec_feed(exec_feed),
    .free_space(free_space)
    );

  Branch branch(
    .data1(exec_feed.data1), .data2(exec_feed.data2), .address(exec_feed.address), .offset(exec_feed.imm), .pid(exec_feed.pid),
    .pc(pc), .rd(rd)
  );

  Arbiter #(arbiter_address) arbiter1(get_bus[0], data_bus1.select, bus_granted[0]);
  Arbiter #(arbiter_address) arbiter2(get_bus[1], data_bus2.select, bus_granted[1]);
  
// Logic
  assign get_bus = (exec_feed.pid != UNKNOWN) ? 2'b11 : 2'b00;

  always @( bus_granted or get_bus ) begin
    casez (bus_granted)
      2'b01: bus_enable = 2'b01;
      2'b1?: bus_enable = 2'b10;
      default: bus_enable = 2'b00;
    endcase
  end

  assign data_bus1.data = bus_enable[0] ? rd : 32'hzzzzzzzz;
  assign data_bus1.address = bus_enable[0] ? exec_feed.address : 32'hzzzzzzzz;
  assign data_bus1.jump_address = bus_enable[0] ? pc : 32'hzzzzzzzz;
  assign data_bus1.arn = 6'hzz;
  assign data_bus1.rrn = bus_enable[0] ? exec_feed.rrn : 6'hzz;
  assign data_bus1.we = bus_enable[0] ? 1'b1 : 1'bz;

  assign data_bus2.data = bus_enable[1] ? rd : 32'hzzzzzzzz;
  assign data_bus2.address = bus_enable[1] ? exec_feed.address : 32'hzzzzzzzz;
  assign data_bus2.jump_address = bus_enable[1] ? pc : 32'hzzzzzzzz;
  assign data_bus2.arn = 6'hzz;
  assign data_bus2.rrn = bus_enable[1] ? exec_feed.rrn : 6'hzz;
  assign data_bus2.we = bus_enable[1] ? 1'b1 : 1'bz;

endmodule