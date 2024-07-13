import pkg_structures::*;

module reservation_station #(
    parameter int SIZE = 16,
    parameter instr_type_e INSTR_TYPE = XX
) (
    input clock,
    input reset,
    input delete_tag,
    input clear_tag,

    issue_bus_if.combo issue_bus[2],
    common_data_bus_if.combo data_bus[2],

    output logic [31:0] data_1,
    output logic [31:0] data_2,
    output logic [31:0] address,
    output logic [31:0] immediate,
    output instr_name_e instr_name,
    output logic[5:0] rrn,

    input  logic next,
    output logic full
);
  // ------------------------------- Functions -------------------------------
  function automatic bit match_data_bus(input logic [5:0] src, input logic valid,
                                        input logic [5:0] arn, input logic [5:0] rrn);
    return (arn == src || rrn == src) && !valid;
  endfunction

  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    bit [31:0] data_1, data_2;
    bit [31:0] address, immediate;
    bit [5:0] src_1, src_2, rrn;
    instr_name_e instr_name;
    bit valid_1, valid_2, tag, skip;
  } station_record_t;

  // ------------------------------- Wires -------------------------------
  localparam int IndexSize = $clog2(SIZE);

  station_record_t records[SIZE];

  logic [IndexSize-1:0] read_index, write_index;
  logic empty;

  // ------------------------------- Behaviour -------------------------------
  always_comb begin : reset
    if (global_bus.reset) begin
      instr_name = UNKNOWN;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_issue_bus
      always_ff @(posedge global_bus.clock) begin : receive_instruction
        if (issue_bus[i].instr_type == INSTR_TYPE && !global_bus.delete_tag && !full) begin
          records[write_index+i] <= '{
              issue_bus[i].data_1,
              issue_bus[i].data_2,
              issue_bus[i].address,
              issue_bus[i].immediate,
              issue_bus[i].regs.rs_1,
              issue_bus[i].regs.rs_2,
              issue_bus[i].regs.rn,
              issue_bus[i].instr_name,
              issue_bus[i].valid_1,
              issue_bus[i].valid_2,
              issue_bus[i].flags.tag,
              1'h0
          };
          write_index <= write_index +
          (issue_bus[0].instr_type == INSTR_TYPE  ? 1 : 0) +
          (issue_bus[1].instr_type == INSTR_TYPE  ? 1 : 0);
        end
      end

      always_ff @(posedge global_bus.clock) begin : update_records
        foreach (records[j]) begin
          if (match_data_bus(
                  records[j].src_1, records[j].valid_1, data_bus[i].arn, data_bus[i].rrn
              ));
          begin
            records[j].data_1  <= data_bus[i].result;
            records[j].valid_1 <= 1'h1;
          end
          if (match_data_bus(
                  records[j].src_2, records[j].valid_2, data_bus[i].arn, data_bus[i].rrn
              ));
          begin
            records[j].data_2  <= data_bus[i].result;
            records[j].valid_2 <= 1'h1;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge global_bus.clock) begin : feed_ex_unit
    if (records[read_index].valid_1 && records[read_index].valid_2 && !records[read_index].skip) begin
      data_1 <= records[read_index].data_1;
      data_2 <= records[read_index].data_2;
      address <= records[read_index].address;
      immediate <= records[read_index].immediate;
      rrn <= records[read_index].rrn;
      instr_name <= records[read_index].instr_name;
    end else begin
      instr_name <= UNKNOWN;
    end
  end

  always_comb begin : skip
    if (global_bus.delete_tag) foreach (records[i]) records[i].skip = records[i].tag;
  end

  // ------------------------------- Queue -------------------------------

  always_comb begin
    if (global_bus.reset) begin
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
      full = 1'h0;
      read_index = '0;
      write_index = '0;
    end
  end

  always_ff @(posedge global_bus.clock) begin
    if (next && !empty) begin
      read_index <= read_index + 1;
    end
  end

  always_ff @(posedge global_bus.clock) begin
    if (!full && (
      ((write_index + 2) % SIZE == read_index) ||
      ((write_index + 1) % SIZE == read_index)))
      full <= 1'h1;
    else if (full && next) full <= 1'h0;

    if (next && (read_index == write_index)) empty <= 1'h1;
    else empty <= 1'h0;
  end
endmodule
