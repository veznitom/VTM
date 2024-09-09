// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ReservationStation #(
  parameter int          SIZE       = 16,
  parameter instr_type_e INSTR_TYPE = XX
) (
  IntfCSB.tag         cs,
  IntfIssue.Combo     issue[2],
  IntfCDB.Combo       data [2],
  IntfExtFeed.Station feed,

  input  wire       i_next,
  output wire [5:0] o_rrn,
  output wire       o_full
);
  // ------------------------------- Functions -------------------------------
  function automatic bit match_data(input logic [5:0] src, input logic valid,
                                    input logic [5:0] arn,
                                    input logic [5:0] rrn);
    return (arn == src || rrn == src) && !valid;
  endfunction

  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    bit [31:0]   data_1,     data_2;
    bit [31:0]   address,    immediate;
    bit [5:0]    src_1,      src_2,     rrn;
    instr_name_e instr_name;
    bit          valid_1,    valid_2,   tag, skip;
  } station_record_t;

  // ------------------------------- Wires -------------------------------
  localparam int IndexSize = $clog2(SIZE);

  station_record_t records[SIZE];

  logic [IndexSize-1:0] read_index, write_index;
  logic empty;

  // ------------------------------- Behaviour -------------------------------
  /*
  always_comb begin : reset
    if (cs.reset) begin
      instr_name = UNKNOWN;
    end
  end

  generate
    for (genvar i = 0; i < 2; i++) begin : gen_issue
      always_ff @(posedge cs.clock) begin : receive_instruction
        if (issue[i].instr_type == INSTR_TYPE && !cs.delete_tag && !full) begin
          records[write_index+i] <= '{
              issue[i].data_1,
              issue[i].data_2,
              issue[i].address,
              issue[i].immediate,
              issue[i].regs.rs_1,
              issue[i].regs.rs_2,
              issue[i].regs.rn,
              issue[i].instr_name,
              issue[i].valid_1,
              issue[i].valid_2,
              issue[i].flags.tag,
              1'h0
          };
          write_index <= write_index +
          (issue[0].instr_type == INSTR_TYPE  ? 1 : 0) +
          (issue[1].instr_type == INSTR_TYPE  ? 1 : 0);
        end
      end

      always_ff @(posedge cs.clock) begin : update_records
        foreach (records[j]) begin
          if (match_data(
                  records[j].src_1, records[j].valid_1, data[i].arn, data[i].rrn
              ));
          begin
            records[j].data_1  <= data[i].result;
            records[j].valid_1 <= 1'h1;
          end
          if (match_data(
                  records[j].src_2, records[j].valid_2, data[i].arn, data[i].rrn
              ));
          begin
            records[j].data_2  <= data[i].result;
            records[j].valid_2 <= 1'h1;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge cs.clock) begin : feed_ex_unit
    if (records[read_index].valid_1 && records[read_index].valid_2 &&
        !records[read_index].skip) begin
      data_1     <= records[read_index].data_1;
      data_2     <= records[read_index].data_2;
      address    <= records[read_index].address;
      immediate  <= records[read_index].immediate;
      rrn        <= records[read_index].rrn;
      instr_name <= records[read_index].instr_name;
    end else begin
      instr_name <= UNKNOWN;
    end
  end

  always_comb begin : skip
    if (cs.delete_tag) begin
      foreach (records[i]) records[i].skip = records[i].tag;
    end
  end

  // ------------------------------- Queue -------------------------------

  always_comb begin
    if (cs.reset) begin
      foreach (records[i]) begin
        records[i] = '{
            {32{1'h0}},
            {32{1'h0}},
            {32{1'h0}},
            {32{1'h0}},
            6'h00,
            6'h00,
            6'h00,
            UNKNOWN,
            1'h0,
            1'h0,
            1'h0,
            1'h0
        };
      end
      full        = 1'h0;
      read_index  = '0;
      write_index = '0;
    end
  end

  always_ff @(posedge cs.clock) begin
    if (next && !empty) begin
      read_index <= read_index + 1;
    end
  end

  always_ff @(posedge cs.clock) begin
    if (!full && (
      ((write_index + 2) % SIZE == read_index) ||
      ((write_index + 1) % SIZE == read_index))) begin
      full <= 1'h1;
    end else if (full && next) full <= 1'h0;

    if (next && (read_index == write_index)) empty <= 1'h1;
    else empty <= 1'h0;
  end
  */
endmodule
