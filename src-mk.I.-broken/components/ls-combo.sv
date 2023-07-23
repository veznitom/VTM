import CustomTypes::*;

module LoadStoreCombo #(
  parameter int station_size = 4,
  parameter int arbiter_address = 4'h3
)(
  GlobalSignals.rest global_signals,
  InstrIssue.combo issue1, issue2,
  CommonDataBus.combo data_bus1, data_bus2,
  // Dispatch
  output logic [15:0] free_space,
  // Mem
  DataCacheBus.combo data_cache
);

// Connections
  logic [31:0] result;
  logic [1:0] get_bus, bus_granted, bus_enable;
  logic finished, done;

  ExecFeed exec_feed();

// Modules
    ResStation #(station_size, LS) station(
    .global_signals(global_signals), 
    .issue1(issue1), .issue2(issue2), 
    .data_bus1(data_bus1), .data_bus2(data_bus2),
    .exec_feed(exec_feed),
    .free_space(free_space)
    );

  LoadStore load_store(
    .global_signals(global_signals),
    .base(exec_feed.data1), .data(exec_feed.data2), .offset(exec_feed.imm), .instr(exec_feed.address), .pid(exec_feed.pid), .tag(exec_feed.tag),
    .result(result),
    .finished(finished), .done(done),
    .data_cache(data_cache)
  );

  Arbiter #(arbiter_address) arbiter1(get_bus[0], data_bus1.select, bus_granted[0]);
  Arbiter #(arbiter_address) arbiter2(get_bus[1], data_bus1.select, bus_granted[1]);

// Logic
  assign get_bus = finished ? 2'b11 : 2'b00;
  assign done = bus_granted[0] | bus_granted[1];

  always @( bus_granted or get_bus ) begin
    casez (bus_granted)
      2'b01: bus_enable = 2'b01;
      2'b1?: bus_enable = 2'b10;
      default: bus_enable = 2'b00;
    endcase
  end

  assign data_bus1.data = bus_enable[0] ? result : 32'hzzzzzzzz;
  assign data_bus1.address = bus_enable[0] ? exec_feed.address : 32'hzzzzzzzz;
  assign data_bus1.jump_address = 32'hzzzzzzzz;
  assign data_bus1.arn = 6'hzz;
  assign data_bus1.rrn = bus_enable[0] ? exec_feed.rrn : 6'hzz;
  assign data_bus1.we = bus_enable[0] ? 1'b1 : 1'bz;

  assign data_bus2.data = bus_enable[1] ? result : 32'hzzzzzzzz;
  assign data_bus2.address = bus_enable[1] ? exec_feed.address : 32'hzzzzzzzz;
  assign data_bus2.jump_address = 32'hzzzzzzzz;
  assign data_bus2.arn = 6'hzz;
  assign data_bus2.rrn = bus_enable[1] ? exec_feed.rrn : 6'hzz;
  assign data_bus2.we = bus_enable[1] ? 1'b1 : 1'bz;

endmodule