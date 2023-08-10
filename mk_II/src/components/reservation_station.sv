import structures::*;

module reservation_station #(
    parameter int XLEN = 32,
    parameter int SIZE = 16,
    parameter instr_type_e INSTR_TYPE = XX
) (
    global_bus_if.rest global_bus,
    issue_bus_if.combo issue_bus[2],
    common_data_bus_if.combo data_bus[2],
    feed_bus_if.station feed_bus,

    input  logic next,
    output logic full
);
  function automatic bit match_data_bus(input logic [5:0] src, input logic valid,
                                        input logic [5:0] arn, input logic [5:0] rrn);
    return (arn == src || rrn == src) && !valid;
  endfunction

  typedef struct packed {
    logic [31:0] data_1, data_2, address, immediate;
    logic [5:0] src_1, src_2, rrn;
    logic valid_1, valid_2, tag, skip;
    instr_name_e instr_name;
  } station_record_t;

  station_record_t records[SIZE];

  logic [3:0] read_index;
  logic [3:0] write_index;
  logic empty;

  always_comb begin : reset
    if (global_bus.reset) begin
      feed_bus.instr_name = UNKNOWN;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_issue_bus
      always_ff @(posedge global_bus.clock) begin : receive_instruction
        if (issue_bus[i].instr_type == INSTR_TYPE && !global_bus.delete_tag) begin
          records[write_index] <= '{
              issue_bus[i].data_1,
              issue_bus[i].data_2,
              issue_bus[i].address,
              issue_bus[i].immediate,
              issue_bus[i].regs.rs_1,
              issue_bus[i].regs.rs_2,
              issue_bus[i].regs.rn,
              issue_bus[i].valid_1,
              issue_bus[i].valid_2,
              issue_bus[i].flags.tag,
              1'h0,
              issue_bus[i].instr_name
          };
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
    for (int i = 0; i < SIZE; i++) begin
      if (records[i].valid_1 && records[i].valid_2 && !records[i].skip) begin
        feed_bus.data_1 <= records[i].data_1;
        feed_bus.data_2 <= records[i].data_2;
        feed_bus.address <= records[i].address;
        feed_bus.immediate <= records[i].immediate;
        feed_bus.rrn <= records[i].rrn;
        feed_bus.instr_name <= records[i].instr_name;
        break;
      end else begin
        feed_bus.instr_name <= UNKNOWN;
      end
    end
  end

  always_comb begin : skip
    if (global_bus.delete_tag) foreach (records[i]) records[i].skip = records[i].tag;
  end

  // Queue control -------------------------------------------------------------------------------

  always_comb begin
    if (global_bus.reset) begin
      foreach (records[i]) begin
        records[i] = '{
            {XLEN{1'hz}},
            {XLEN{1'hz}},
            {XLEN{1'hz}},
            {XLEN{1'hz}},
            6'h00,
            6'h00,
            6'h00,
            1'h0,
            1'h0,
            1'h0,
            1'h0,
            UNKNOWN
        };
      end
      read_index  = 8'h00;
      write_index = 8'h00;
    end
  end

  always_ff @(posedge global_bus.clock) begin
    if (next && !empty) begin
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
