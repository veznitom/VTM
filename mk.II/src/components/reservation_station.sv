module reservation_station #(
    parameter int XLEN = 32,
    parameter int SIZE = 16
) (
    global_signals_if gsi,
    instr_issue_if issue[2],
    common_data_bus_if cdb[2],
    station_unit_if exec_feed
);
    TODO();
endmodule
