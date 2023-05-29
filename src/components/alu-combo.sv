import CustomTypes::*;

module ALUCombo #(
  parameter int station_size = 8,
  parameter int arbiter_address = 4'h5
)(
  GlobalSignals.rest global_signals,
  InstrIssue.combo issue1, issue2,
  CommonDataBus.combo data_bus1, data_bus2,
  // Dispatch
  output logic [15:0] free_space
);

// Connections
  logic [31:0] result1, result2;
  logic [1:0] get_bus, bus_enable, res_select;
  wire [1:0] bus_granted;

  ExecFeed exec_feeds[2]();

// Modules
  MultiResStation #(station_size, ALU) station(
    .global_signals(global_signals), 
    .issue1(issue1), .issue2(issue2), 
    .data_bus1(data_bus1), .data_bus2(data_bus2),
    .exec_feed1(exec_feeds[0]), .exec_feed2(exec_feeds[1]),
    .free_space(free_space)
  );

  ALU alu1(.data1(exec_feeds[0].data1), .data2(exec_feeds[0].data2), .address(exec_feeds[0].address), .imm(exec_feeds[0].imm), .pid(exec_feeds[0].pid), .res(result1));
  ALU alu2(.data1(exec_feeds[1].data1), .data2(exec_feeds[1].data2), .address(exec_feeds[1].address), .imm(exec_feeds[1].imm), .pid(exec_feeds[1].pid), .res(result2));
  
  Arbiter #(arbiter_address) arbiter1(get_bus[0], data_bus1.select, bus_granted[0]);
  Arbiter #(arbiter_address) arbiter2(get_bus[1], data_bus2.select, bus_granted[1]);
  
// Logic
  always @(exec_feeds[0].pid or exec_feeds[1].pid) begin
    get_bus = {exec_feeds[1].pid != UNKNOWN, exec_feeds[0].pid != UNKNOWN};
  end

  always @( bus_granted or get_bus ) begin
    casez({bus_granted, get_bus})
      4'b01?1: begin
        bus_enable = 2'b01;
        res_select = 2'b00;
      end
      4'b0110: begin
        bus_enable = 2'b01;
        res_select = 2'b01;
      end
      4'b10?1: begin
        bus_enable = 2'b10;
        res_select = 2'b00;
      end
      4'b1010: begin
        bus_enable = 2'b10;
        res_select = 2'b01;
      end
      4'b1101: begin
        bus_enable = 2'b01;
        res_select = 2'b00;
      end
      4'b1110: begin
        bus_enable = 2'b10;
        res_select = 2'b01;
      end
      4'b1111: begin
        bus_enable = 2'b11;
        res_select = 2'b01;
      end
      default: begin
        bus_enable = 2'b00;
        res_select = 2'b00;
      end
    endcase
  end

  assign data_bus1.data = bus_enable[0] ? ( res_select[1] ? result2 : result1 ) : 32'hzzzzzzzz;
  assign data_bus1.address = bus_enable[0] ? ( res_select[1] ? exec_feeds[1].address : exec_feeds[0].address ) : 32'hzzzzzzzz;
  assign data_bus1.jump_address = 32'hzzzzzzzz;
  assign data_bus1.arn = 6'hzz;
  assign data_bus1.rrn = bus_enable[0] ? ( res_select[1] ? exec_feeds[1].rrn : exec_feeds[0].rrn ) : 6'hzz;
  assign data_bus1.we = bus_enable[0] ? 1'b1 : 1'bz;

  assign data_bus2.data = bus_enable[1] ? ( res_select[0] ? result2 : result1 ) : 32'hzzzzzzzz;
  assign data_bus2.address = bus_enable[1] ? ( res_select[0] ? exec_feeds[1].address : exec_feeds[0].address ) : 32'hzzzzzzzz;
  assign data_bus2.jump_address = 32'hzzzzzzzz;
  assign data_bus2.arn = 6'hzz;
  assign data_bus2.rrn = bus_enable[1] ? ( res_select[0] ? exec_feeds[1].rrn : exec_feeds[0].rrn ) : 6'hzz;
  assign data_bus2.we = bus_enable[1] ? 1'b1 : 1'bz;

endmodule