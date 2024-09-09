// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ReorderBuffer #(
  parameter bit [7:0] ARBITER_ADDRESS = 8'h00,
  parameter int       SIZE            = 32
) (
  IntfCSB.ReorderBuffer   cs,
  IntfCDB.ReorderBuffer   data [2],
  IntfIssue.ReorderBuffer issue[2],

  output reg [31:0] o_jmp_address,
  output reg        o_jmp_write,

  output reg o_full
);
  // ------------------------------- Structs -------------------------------
  typedef enum bit [1:0] {
    WAITING,
    COMPLETED,
    IGNORE
  } record_status_e;

  typedef struct packed {
    bit [31:0]      result, address, jmp_address;
    record_status_e status;
    registers_t     regs;
    flag_vector_t   flags;
  } rob_record_t;

  // ------------------------------- Wires -------------------------------
  rob_record_t       records      [SIZE];

  logic        [3:0] read_index;
  logic        [3:0] write_index;
  logic              read;
  logic              empty;
  logic              get_bus;
  logic              bus_granted;
  logic              bus_selected;

  // ------------------------------- Modules -------------------------------
  /*CDBArbiter #(
    .ADDRESS(ARBITER_ADDRESS)
  ) u_arbiter (
    .select      (),
    .get_bus     (),
    .bus_granted (),
    .bus_selected()
  );*/

  // ------------------------------- Behaviour -------------------------------
  /*
  always_ff @(posedge cs.clock) begin : jmp_resolve
    if (records[read_index].status == COMPLETED && records[0].flags.jumps) begin
      if
      (records[read_index].address + 4 == records[read_index].jmp_address) begin
        o_jmp_address <= 'z;
        o_jmp_write   <= 1'h0;
        cs.clear_tag  <= 1'h1;
        cs.delete_tag <= 1'h0;
      end else begin
        o_jmp_address <= records[0].jmp_address;
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

  always_comb begin : bus_requesting
    if (records[read_index].status == COMPLETED) get_bus = 1'h1;
    else get_bus = 1'h0;
  end

  generate
    for (genvar i = 0; i < 2; i++) begin : gen_rob
      always_ff @(posedge cs.clock) begin : write_to_bus
        if (bus_granted) begin
          if (bus_selected == i) begin
            data[i].result <= records[read_index].result;
            data[i].address <= records[read_index].address;
            data[i].jmp_address <= records[read_index].jmp_address;
            data[i].arn <= records[read_index].regs.rd;
            data[i].rrn <= records[read_index].regs.rn;
            data[i].reg_write <= records[read_index].flags.writes;
            data[i].cache_write <=
            records[read_index].flags.mem & records[read_index].flags.writes;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge cs.clock) begin
    if (cs.reset) begin
      foreach (records[i]) begin
        records[i] <= '{
            'z,
            'z,
            'z,
            WAITING,
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
      end

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
      end

    end
  end

  always_comb begin : pop_ignored
    if (records[read_index].status == IGNORE || bus_granted) read = 1'h1;
    else read = 1'h0;
  end

  always_ff @(posedge cs.clock) begin
    if (cs.reset) begin
      read_index <= 8'h00;
    end else if (read && !empty) begin
      read_index <= read_index + 1;
    end
  end

  always_comb begin
    if (read_index == write_index + 1) o_full = 1'h1;
    else o_full = 1'h0;

    if (read_index == write_index) empty = 1'h1;
    else empty = 1'h0;
  end
  */
endmodule
