module reservation_station #(
    parameter int XLEN = 32,
    parameter int SIZE = 16
) (
    global_signals_if gsi,
    instr_issue_if issue[2],
    common_data_bus_if cdb[2],
    station_unit_if exec_feed
);

  typedef struct packed {
    reg [31:0] data_1, data_2, address, imm;
    reg [5:0] src_1, src_2, rrn;
    reg valid_1, valid_2, tag, skip;
    instr_name_e instr_name;
  } station_record_t;

  TODO();
endmodule
