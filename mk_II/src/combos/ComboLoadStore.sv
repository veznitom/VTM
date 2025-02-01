// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ComboLoadStore #(
  parameter bit [7:0] ARBITER_ADDRESS = 8'h00,
  parameter int       SIZE_BITS       = 3
) (
  IntfCSB.tag     cs,
  IntfIssue.Combo issue[2],
  IntfCDB.Combo   data [2],
  IntfDataCache   cache,

  output wire o_full
);
  // ------------------------------- Wires -------------------------------
  IntfDataCache u_cache_sw ();
  IntfExtFeed u_load_store_feed ();

  wire [31:0] load_store_result;
  wire [15:0] select;
  wire get_bus, ready;
  wire bus_granted;
  wire bus_index;
  // ------------------------------- Modules -------------------------------
  ReservationStation #(
    .SIZE_BITS (SIZE_BITS),
    .INSTR_TYPE(LS)
  ) u_station (
    .cs    (cs),
    .issue (issue),
    .data  (data),
    .feed  (u_load_store_feed),
    .i_next(bus_granted),
    .o_rrn (),
    .o_full(o_full)
  );

  LoadStore u_load_store (
    .i_clock        (cs.clock),
    .i_reset        (cs.reset),
    .i_data_1       (u_load_store_feed.data_1),
    .i_data_2       (u_load_store_feed.data_2),
    .i_address      (u_load_store_feed.address),
    .i_immediate    (u_load_store_feed.immediate),
    .i_instr_name   (u_load_store_feed.instr_name),
    .cache          (u_cache_sw),
    .i_tag          (0),
    .o_result       (u_load_store_feed.result),
    .o_store_address(load_store_result),
    .o_ready        (ready)
  );

  CDBArbiter #(
    .ADDRESS(ARBITER_ADDRESS)
  ) u_arbiter (
    .io_select    ({data[1].select, data[0].select}),
    .i_get_bus    (get_bus),
    .o_bus_granted(bus_granted),
    .o_bus_index  (bus_index)
  );
  // ------------------------------- Behaviour -------------------------------
  assign select  = {data[1].select, data[0].select};
  assign get_bus = ready & (u_load_store_feed.instr_name != UNKNOWN);

  always_comb begin : switchboard
    u_cache_sw.din   = cache.dout;
    u_cache_sw.hit   = cache.hit;
    u_cache_sw.ready = cache.ready;

    cache.address    = u_cache_sw.address;
    cache.din        = u_cache_sw.dout;
    cache.store_type = u_cache_sw.store_type;
    cache.read       = u_cache_sw.read;
    cache.write      = u_cache_sw.write;
    cache.tag        = u_cache_sw.tag;
  end

  generate
    for (genvar i = 0; i < 2; i++) begin : gen_rob
      assign data[i].result = (bus_granted & bus_index == i) ? u_load_store_feed.result: 'z;
      assign data[i].address = (bus_granted & bus_index == i) ? u_load_store_feed.address: 'z;
      assign data[i].result_address = (bus_granted & bus_index == i) ? load_store_result : 'z;
      assign data[i].arn = (bus_granted & bus_index == i) ? 0 : 'z;
      assign data[i].rrn = (bus_granted & bus_index == i) ? 0 : 'z;
      assign data[i].reg_write = (bus_granted & bus_index == i) ? '1 : 'z;
    end
  endgenerate
endmodule
