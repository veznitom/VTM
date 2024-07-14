import pkg_defines::*;

module reorder_buffer #(
    parameter logic [7:0] ARBITER_ADDRESS = 8'h00,
    parameter int SIZE = 32
) (
    global_bus_if.rob global_bus,
    pc_bus_if.rob pc_bus,
    common_data_bus_if.rob data_bus[2],
    issue_bus_if.rob issue_bus[2],

    output logic full
);
  // ------------------------------- Structs -------------------------------
  typedef enum bit [1:0] {
    WAITING,
    COMPLETED,
    IGNORE
  } record_status_e;

  typedef struct packed {
    bit [31:0] result, address, jmp_address;
    record_status_e status;
    registers_t regs;
    flag_vector_t flags;
  } rob_record_t;

  // ------------------------------- Wires -------------------------------
  rob_record_t records[SIZE];

  logic [3:0] read_index;
  logic [3:0] write_index;
  logic read;
  logic empty;
  logic get_bus;
  logic bus_granted;
  logic bus_selected;

  // ------------------------------- Modules -------------------------------
  arbiter #(
      .ADDRESS(ARBITER_ADDRESS)
  ) mult_div_arbiter (
      .select({data_bus[1].select, data_bus[0].select}),
      .get_bus(get_bus),
      .bus_granted(bus_granted),
      .bus_selected(bus_selected)
  );

  // ------------------------------- Behaviour -------------------------------
  always_ff @(posedge global_bus.clock) begin : jmp_resolve
    if (records[read_index].status == COMPLETED && records[0].flags.jumps) begin
      if (records[read_index].address + 4 == records[read_index].jmp_address) begin
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

  always_comb begin : bus_requesting
    if (records[read_index].status == COMPLETED) get_bus = 1'h1;
    else get_bus = 1'h0;
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_rob
      always_ff @(posedge global_bus.clock) begin : write_to_bus
        if (bus_granted) begin
          if (bus_selected == i) begin
            data_bus[i].result <= records[read_index].result;
            data_bus[i].address <= records[read_index].address;
            data_bus[i].jmp_address <= records[read_index].jmp_address;
            data_bus[i].arn <= records[read_index].regs.rd;
            data_bus[i].rrn <= records[read_index].regs.rn;
            data_bus[i].reg_write <= records[read_index].flags.writes;
            data_bus[i].cache_write <=
            records[read_index].flags.mem & records[read_index].flags.writes;
          end
        end
      end

      always_ff @(posedge global_bus.clock) begin : add_record
        if (issue_bus[i].instr_type != XX && !global_bus.delete_tag) begin
          records[write_index] <= '{
              'z,
              issue_bus[i].address,
              'z,
              WAITING,
              issue_bus[i].regs,
              issue_bus[i].flags
          };
          write_index <= write_index + 1;
        end
      end

      always_ff @(posedge global_bus.clock) begin : data_bus_fetch
        foreach (records[j]) begin
          if (records[j].address == data_bus[i].address) begin
            records[j].result <= data_bus[i].result;
            records[j].jmp_address <= records[j].flags.jumps ? data_bus[i].jmp_address : 'z;
            records[j].status <= COMPLETED;
          end
        end
      end
    end
  endgenerate

  always_comb begin : pop_ignored
    if (records[read_index].status == IGNORE || bus_granted) read = 1'h1;
    else read = 1'h0;
  end

  always_comb begin : ignore_tagged
    if (global_bus.delete_tag)
      foreach (records[i]) if (records[i].flags.tag) records[i].status = IGNORE;
  end

  always_comb begin : clear_tag
    if (global_bus.delete_tag)
      foreach (records[i]) if (records[i].flags.tag) records[i].flags.tag = 1'h0;
  end

  // ------------------------------- Queue -------------------------------
  always_comb begin
    if (global_bus.reset) begin
      foreach (records[i]) begin
        records[i] = '{
            {XLEN{1'hz}},
            {XLEN{1'hz}},
            {XLEN{1'hz}},
            WAITING,
            '{6'h00, 6'h00, 6'h00, 6'h00},
            '{1'h0, 1'h0, 1'h0, 1'h0, 1'h0}
        };
      end
      read_index  = 8'h00;
      write_index = 8'h00;
    end
  end

  always_ff @(posedge global_bus.clock) begin
    if (read && !empty) begin
      read_index <= read_index + 1;
    end
  end

  always_comb begin
    if (read_index == write_index + 1) full = 1'h1;
    else full = 1'h0;

    if (read_index == write_index) empty = 1'h1;
    else empty = 1'h0;
  end
endmodule
