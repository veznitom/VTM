// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ReorderBuffer #(
  parameter bit [7:0] ARBITER_ADDRESS = 8'h00,
  parameter int       SIZE_BITS       = 5
) (
  IntfCSB.ReorderBuffer   cs,
  IntfCDB.ReorderBuffer   data [2],
  IntfIssue.ReorderBuffer issue[2],

  output reg [31:0] o_jmp_address,
  output reg        o_jmp_write,

  output reg o_full
);
  // ------------------------------- Structs -------------------------------
  typedef enum bit [2:0] {
    WAITING,
    COMPLETED,
    IGNORE,
    DONE
  } record_status_e;

  typedef struct packed {
    bit [31:0]      result, address, jmp_address;
    record_status_e status;
    registers_t     regs;
    flag_vector_t   flags;
  } rob_record_t;

  // ------------------------------- Wires -------------------------------
  rob_record_t                 records     [2**SIZE_BITS];

  logic        [SIZE_BITS-1:0] read_index;
  logic        [SIZE_BITS-1:0] write_index;
  logic                        read;
  logic                        empty;

  wire         [         15:0] select;
  logic                        get_bus;
  logic                        bus_granted;
  logic                        bus_index;

  // ------------------------------- Modules -------------------------------
  CDBArbiter #(
    .ADDRESS(ARBITER_ADDRESS)
  ) u_arbiter (
    .io_select    ({data[1].select, data[0].select}),
    .i_get_bus    (get_bus),
    .o_bus_granted(bus_granted),
    .o_bus_index  (bus_index)
  );

  // ------------------------------- Behaviour -------------------------------
  always_ff @(posedge cs.clock) begin : jmp_resolve
    if (records[read_index].status == COMPLETED && records[read_index].flags.jumps) begin
      if
      (records[read_index].address + 4 == records[read_index].jmp_address) begin
        o_jmp_address <= 'z;
        o_jmp_write   <= 1'h0;
        cs.clear_tag  <= 1'h1;
        cs.delete_tag <= 1'h0;
      end else begin
        o_jmp_address <= records[read_index].jmp_address;
        o_jmp_write   <= 1'h1;
        cs.clear_tag  <= 1'h0;
        cs.delete_tag <= 1'h1;
      end
    end else begin
      o_jmp_address <= 'z;
      o_jmp_write   <= 1'h0;
      cs.clear_tag  <= 1'h0;
      cs.delete_tag <= 1'h0;
    end
  end

  generate
    for (genvar i = 0; i < 2; i++) begin : gen_rob
      assign data[i].result = (bus_granted & bus_index == i) ? records[read_index].result: 'z;
      assign data[i].address = (bus_granted & bus_index == i) ? records[read_index].address: 'z;
      assign data[i].jmp_address = (bus_granted & bus_index == i) ? records[read_index].jmp_address: 'z;
      assign data[i].arn = (bus_granted & bus_index == i) ? records[read_index].regs.rd: 'z;
      assign data[i].rrn = (bus_granted & bus_index == i) ? records[read_index].regs.rn: 'z;
      assign data[i].reg_write = (bus_granted & bus_index == i) ? records[read_index].flags.writes: 'z;
      assign data[i].cache_write = (bus_granted & bus_index == i) ?
            records[read_index].flags.mem & records[read_index].flags.writes: 'z;
    end
  endgenerate

  always_ff @(posedge cs.clock) begin : main_loop
    if (cs.reset) begin
      foreach (records[i]) begin
        records[i] <= '{
            'z,
            'z,
            'z,
            IGNORE,
            '{6'h00, 6'h00, 6'h00, 6'h00},
            '{1'h0, 1'h0, 1'h0, 1'h0, 1'h0}
        };
      end
      write_index <= 8'h00;
    end else begin

      //add_record
      if (cs.delete_tag) begin
        foreach (records[i])
        if (records[i].flags.tag) begin
          records[i].status    <= IGNORE;
          records[i].flags.tag <= 1'h0;
        end
      end else if (issue[0].instr_type != XX && issue[1].instr_type != XX) begin
        // XX & Valid cannot happen as I use two instr dipatch both valid or
        // one valid which has to be on the fisrt issue bus
        records[write_index] <= '{
            'z,
            issue[0].address,
            'z,
            WAITING,
            issue[0].regs,
            issue[0].flags
        };
        records[write_index+1] <= '{
            'z,
            issue[1].address,
            'z,
            WAITING,
            issue[1].regs,
            issue[1].flags
        };
        write_index <= write_index + 2;
      end else if (issue[0].instr_type != XX) begin
        records[write_index] <= '{
            'z,
            issue[0].address,
            'z,
            WAITING,
            issue[0].regs,
            issue[0].flags
        };
        write_index <= write_index + 1;
      end  // Non XX XX

      //data_bus_fetch
      foreach (records[j]) begin
        if (records[j].address == data[0].address) begin
          records[j].result <= data[0].result;
          records[j].jmp_address <=
              records[j].flags.jumps ? data[0].jmp_address : 'z;
          records[j].status <= COMPLETED;
        end
        if (records[j].address == data[1].address) begin
          records[j].result <= data[1].result;
          records[j].jmp_address <=
              records[j].flags.jumps ? data[1].jmp_address : 'z;
          records[j].status <= COMPLETED;
        end
      end  // Completion

      if (records[read_index].status == COMPLETED) begin
        records[read_index].status <= DONE;
      end

    end  // reset
  end  // main_loop

  always_comb begin : bus_req_and_head_en
    if (records[read_index].status == IGNORE || bus_granted) read = 1'h1;
    else read = 1'h0;
    if (records[read_index].status == COMPLETED) get_bus = 1'h1;
    else get_bus = 1'h0;
  end

  always_ff @(posedge cs.clock) begin
    if (cs.reset) begin
      read_index <= 8'h00;
    end else if (read && !empty) begin
      read_index <= read_index + 1;
    end
  end

  always_comb begin
    if (
      (read_index == write_index + 1 ||
      read_index == write_index) &&
      records[read_index].status == WAITING) begin
      o_full = 1'h1;
    end else o_full = 1'h0;

    if (read_index == write_index &&
        (records[read_index].status == COMPLETED ||
        records[read_index].status == IGNORE)) begin
      empty = 1'h1;
    end else empty = 1'h0;
  end
endmodule
