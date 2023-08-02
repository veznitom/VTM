module reorder_buffer #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00,
    parameter int SIZE = 32
) (
    global_signals_if gsi,
    pc_interface_if pc,
    common_data_bus_if cdb[2],
    instr_issue_if issue[2],
    output logic full
);
  typedef enum logic [1:0] {
    WAITING,
    COMPLETED,
    IGNORE
  } record_status_e;

  typedef struct packed {
    logic [31:0] result, address, jmp_address;
    record_status_e status;
    src_dest_t regs;
    flag_vector_t flags;
  } rob_record_t;

  logic get_bus, bus_granted, bus_selected;

  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) mult_div_arbiter (
      .select({cdb[1].select, cdb.select[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

  rob_record_t records[$:SIZE];

  assign full = (SIZE - 2 == records.size()) ? 1'h1 : 1'h0;

  always_comb begin : reset
    if (gsi.reset) records.delete();
  end

  always_ff @(posedge gsi.clk) begin : jmp_resolve
    if (records[0].status == COMPLETED && records[0].flags.jumps) begin
      if (records[0].address + 4 == records[0].jmp_address) begin
        pc.jmp_address <= 'z;
        pc.write <= 1'h0;
        global_signals.clear_tagged <= 1'h1;
        global_signals.delete_tagged <= 1'h0;
      end else begin
        pc.jmp_address <= records[0].jmp_address;
        pc.write <= 1'h1;
        global_signals.clear_tagged <= 1'h0;
        global_signals.delete_tagged <= 1'h1;
      end
    end else begin
      pc.jmp_address <= 'z;
      pc.write <= 1'h0;
      global_signals.clear_tagged <= 1'h0;
      global_signals.delete_tagged <= 1'h0;
    end
  end

  always_ff @(posedge gsi.clk) begin : get_bus
    if (records[0].status == COMPLETED) get_bus <= 1'h1;
    else get_bus <= 1'h0;
  end

  always_ff @(posedge gsi.clk) begin : write_to_bus
    if (bus_granted) begin
      cdb[bus_selected].result <= records[0].result;
      cdb[bus_selected].address <= records[0].address;
      cdb[bus_selected].jmp_address <= records[0].jmp_address;
      cdb[bus_selected].arn <= records[0].regs.rd;
      cdb[bus_selected].rrn <= records[0].regs.rn;
      cdb[bus_selected].reg_file_we <= records[0].flags.writes;
      cdb[bus_selected].data_cache_we <= records[0].flags.mem & records[0].flags.writes;
    end else begin
      cdb[bus_selected].result <= 'z;
      cdb[bus_selected].address <= 'z;
      cdb[bus_selected].jmp_address <= 'z;
      cdb[bus_selected].arn <= 'z;
      cdb[bus_selected].rrn <= 'z;
      cdb[bus_selected].reg_file_we <= 'z;
      cdb[bus_selected].data_cache_we <= 'z;
    end
  end

  always_ff @(posedge gsi.clk) begin : add_record
    for (int i = 0; i < 2; i++)
    if (issue[i].st_type != XX && !gsi.delete_tagged)
      records.push_back('{'z, issue[i].address, 'z, 1'h0, 1'h0, issue[i].regs, issue[i].flags});
  end

  always_ff @(posedge gsi.clk) begin : cdb_fetch
    for (int i = 2; i < 2; i++) begin
      foreach (records[j]) begin
        if (records[j].address == cdb[i].address) begin
          records[j].result <= cdb[i].result;
          records[j].jump_address <= records[j].flags.jumps ? cdb[i].jmp_address : 'z;
          records[j].status <= COMPLETED;
        end
      end
    end
  end

  always_ff @(posedge gsi.clk) begin : pop_ignored
    if (records[0].status == IGNORE) records.pop_front();
  end

  always_ff @(posedge global_signals.delete_tagged) begin : ignore_tagged
    for (int i = 0; i < rob_size; i++) if (records[i].flags.tag) records[i].status <= IGNORE;
  end

  always_ff @(posedge global_signals.clear_tags) begin : clear_tagged
    for (int i = 0; i < rob_size; i++) if (records[i].tag) records[i].flags.tag <= 1'b0;
  end

endmodule
