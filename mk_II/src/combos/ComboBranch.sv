// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ComboBranch #(
    parameter bit [7:0] ARBITER_ADDRESS = 8'h00,
    parameter int       SIZE_BITS       = 3
) (
    IntfCSB.tag     cs,
    IntfIssue.Combo issue[2],
    IntfCDB.Combo   data [2],

    output wire o_full
);
    // ------------------------------- Wires -------------------------------
    IntfExtFeed u_branch_feed ();

    wire get_bus;
    wire bus_granted;
    wire bus_index;

    // ------------------------------- Modules -------------------------------
    ReservationStation #(
        .SIZE_BITS (SIZE_BITS),
        .INSTR_TYPE(BR)
    ) u_station (
        .cs    (cs),
        .issue (issue),
        .data  (data),
        .feed  (u_branch_feed),
        .i_next(bus_granted),
        .o_rrn (),
        .o_full(o_full)
    );

    Branch u_branch (.feed(u_branch_feed));

    CDBArbiter #(
        .ADDRESS(ARBITER_ADDRESS)
    ) u_arbiter (
        .io_select    ({data[1].select, data[0].select}),
        .i_get_bus    (get_bus),
        .o_bus_granted(bus_granted),
        .o_bus_index  (bus_index)
    );
    // ------------------------------- Behaviour -------------------------------
    assign get_bus = u_branch_feed.instr_name != UNKNOWN;

    generate
        for (genvar i = 0; i < 2; i++) begin : gen_rob
            assign data[i].result = (bus_granted & bus_index == i) ?
                u_branch_feed.result : 'z;
            assign data[i].address = (bus_granted & bus_index == i) ?
                u_branch_feed.address : 'z;
            assign data[i].result_address = (bus_granted & bus_index == i) ?
                u_branch_feed.result_address : 'z;
            assign data[i].arn = (bus_granted & bus_index == i) ? 0 : 'z;
            assign data[i].rrn = (bus_granted & bus_index == i) ? 0 : 'z;
            assign data[i].reg_write = (bus_granted & bus_index == i) ? '1 : 'z;
        end
    endgenerate
endmodule
