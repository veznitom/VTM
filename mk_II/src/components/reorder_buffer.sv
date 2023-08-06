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

  always_ff @(posedge gsi.clk) begin : bus_requesting
    if (records[0].status == COMPLETED) get_bus <= 1'h1;
    else get_bus <= 1'h0;
  end

  always_ff @(posedge gsi.clk) begin : write_to_bus
    if (bus_granted) begin
      if (bus_selected) begin
        cdb[1].result <= records[0].result;
        cdb[1].address <= records[0].address;
        cdb[1].jmp_address <= records[0].jmp_address;
        cdb[1].arn <= records[0].regs.rd;
        cdb[1].rrn <= records[0].regs.rn;
        cdb[1].reg_file_we <= records[0].flags.writes;
        cdb[1].data_cache_we <= records[0].flags.mem & records[0].flags.writes;
      end else begin
        cdb[0].result <= records[0].result;
        cdb[0].address <= records[0].address;
        cdb[0].jmp_address <= records[0].jmp_address;
        cdb[0].arn <= records[0].regs.rd;
        cdb[0].rrn <= records[0].regs.rn;
        cdb[0].reg_file_we <= records[0].flags.writes;
        cdb[0].data_cache_we <= records[0].flags.mem & records[0].flags.writes;
      end
    end else begin
      cdb[0].result <= 'z;
      cdb[0].address <= 'z;
      cdb[0].jmp_address <= 'z;
      cdb[0].arn <= 'z;
      cdb[0].rrn <= 'z;
      cdb[0].reg_file_we <= 'z;
      cdb[0].data_cache_we <= 'z;
      cdb[1].result <= 'z;
      cdb[1].address <= 'z;
      cdb[1].jmp_address <= 'z;
      cdb[1].arn <= 'z;
      cdb[1].rrn <= 'z;
      cdb[1].reg_file_we <= 'z;
      cdb[1].data_cache_we <= 'z;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_issue
      always_ff @(posedge gsi.clk) begin : add_record
        if (issue[i].st_type != XX && !gsi.delete_tagged)
          records.push_back('{'z, issue[i].address, 'z, WAITING, issue[i].regs, issue[i].flags});
      end
    end
  endgenerate

  generate
    for (i = 2; i < 2; i++) begin : gen_cdb
      always_ff @(posedge gsi.clk) begin : cdb_fetch
        foreach (records[j]) begin
          if (records[j].address == cdb[i].address) begin
            records[j].result <= cdb[i].result;
            records[j].jump_address <= records[j].flags.jumps ? cdb[i].jmp_address : 'z;
            records[j].status <= COMPLETED;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge gsi.clk) begin : pop_ignored
    if (records[0].status == IGNORE) records.pop_front();
  end

  always_ff @(posedge global_signals.delete_tagged) begin : ignore_tagged
    for (int i = 0; i < SIZE; i++) if (records[i].flags.tag) records[i].status <= IGNORE;
  end

  always_ff @(posedge global_signals.clear_tags) begin : clear_tagged
    for (int i = 0; i < SIZE; i++) if (records[i].tag) records[i].flags.tag <= 1'b0;
  end

endmodule
