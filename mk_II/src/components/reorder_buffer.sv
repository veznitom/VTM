module reorder_buffer #(
    parameter int XLEN = 32,
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00,
    parameter int SIZE = 32
) (
    global_bus_if.rob global_bus,
    pc_bus_if.rob pc_bus,
    common_data_bus_if.rob data_bus[2],
    issue_bus_if.rob issue[2],

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
      .select({data_bus[1].select, data_bus[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

  rob_record_t records[$:SIZE];

  assign full = (SIZE - 2 == records.size()) ? 1'h1 : 1'h0;

  always_comb begin : reset
    if (global_bus.reset) records.delete();
  end

  always_ff @(posedge global_bus.clock) begin : jmp_resolve
    if (records[0].status == COMPLETED && records[0].flags.jumps) begin
      if (records[0].address + 4 == records[0].jmp_address) begin
        pc_bus.jmp_address <= 'z;
        pc_bus.write <= 1'h0;
        global_bus.clear_tag <= 1'h1;
        global_bus.delete_tag <= 1'h0;
      end else begin
        pc_bus.jmp_address <= records[0].jmp_address;
        pc_bus.write <= 1'h1;
        global_bus.clear_tag <= 1'h0;
        global_bus.delete_tag <= 1'h1;
      end
    end else begin
      pc_bus.jmp_address <= 'z;
      pc_bus.write <= 1'h0;
      global_bus.clear_tag <= 1'h0;
      global_bus.delete_tag <= 1'h0;
    end
  end

  always_ff @(posedge global_bus.clock) begin : bus_requesting
    if (records[0].status == COMPLETED) get_bus <= 1'h1;
    else get_bus <= 1'h0;
  end

  always_ff @(posedge global_bus.clock) begin : write_to_bus
    if (bus_granted) begin
      if (bus_selected) begin
        data_bus[1].result <= records[0].result;
        data_bus[1].address <= records[0].address;
        data_bus[1].jmp_address <= records[0].jmp_address;
        data_bus[1].arn <= records[0].regs.rd;
        data_bus[1].rrn <= records[0].regs.rn;
        data_bus[1].reg_write <= records[0].flags.writes;
        data_bus[1].cache_write <= records[0].flags.mem & records[0].flags.writes;
      end else begin
        data_bus[0].result <= records[0].result;
        data_bus[0].address <= records[0].address;
        data_bus[0].jmp_address <= records[0].jmp_address;
        data_bus[0].arn <= records[0].regs.rd;
        data_bus[0].rrn <= records[0].regs.rn;
        data_bus[0].reg_write <= records[0].flags.writes;
        data_bus[0].cache_write <= records[0].flags.mem & records[0].flags.writes;
      end
    end else begin
      data_bus[0].result <= 'z;
      data_bus[0].address <= 'z;
      data_bus[0].jmp_address <= 'z;
      data_bus[0].arn <= 'z;
      data_bus[0].rrn <= 'z;
      data_bus[0].reg_write <= 'z;
      data_bus[0].cache_write <= 'z;
      data_bus[1].result <= 'z;
      data_bus[1].address <= 'z;
      data_bus[1].jmp_address <= 'z;
      data_bus[1].arn <= 'z;
      data_bus[1].rrn <= 'z;
      data_bus[1].reg_write <= 'z;
      data_bus[1].cache_write <= 'z;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_issue
      always_ff @(posedge global_bus.clock) begin : add_record
        if (issue[i].st_type != XX && !global_bus.delete_tag)
          records.push_back('{'z, issue[i].address, 'z, WAITING, issue[i].regs, issue[i].flags});
      end
    end
  endgenerate

  generate
    for (i = 2; i < 2; i++) begin : gen_data_bus
      always_ff @(posedge global_bus.clock) begin : data_bus_fetch
        foreach (records[j]) begin
          if (records[j].address == data_bus[i].address) begin
            records[j].result <= data_bus[i].result;
            records[j].jump_address <= records[j].flags.jumps ? data_bus[i].jmp_address : 'z;
            records[j].status <= COMPLETED;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge global_bus.clock) begin : pop_ignored
    if (records[0].status == IGNORE) records.pop_front();
  end

  always_ff @(posedge global_bus.delete_tag) begin : ignore_tagged
    for (int i = 0; i < SIZE; i++) if (records[i].flags.tag) records[i].status <= IGNORE;
  end

  always_ff @(posedge global_bus.clear_tag) begin : clear_tag
    for (int i = 0; i < SIZE; i++) if (records[i].flags.tag) records[i].flags.tag <= 1'b0;
  end

endmodule
