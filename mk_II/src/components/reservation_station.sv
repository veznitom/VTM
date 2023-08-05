module reservation_station #(
    parameter int XLEN = 32,
    parameter int SIZE = 16,
    parameter st_type_e ST_TYPE = XX
) (
    global_signals_if gsi,
    instr_issue_if issue[2],
    common_data_bus_if cdb[2],
    station_unit_if exec_feed,
    input logic next,
    output logic full
);


  function automatic bit match_cdb(input logic [5:0] src, input logic valid, input logic [5:0] arn,
                                   input logic [5:0] rrn);
    return (arn == src || rrn == src) && !valid;
  endfunction

  typedef struct packed {
    logic [31:0] data_1, data_2, address, immediate;
    logic [5:0] src_1, src_2, rrn;
    logic valid_1, valid_2, tag, skip;
    instr_name_e instr_name;
  } station_record_t;

  station_record_t records[$:SIZE];

  assign full = SIZE - records.size();

  always_comb begin : reset
    if (gsi.reset) begin
      exec_feed[0].instr_name = UNKNOWN;
      exec_feed[1].instr_name = UNKNOWN;
      records.delete();
    end
  end

  always_ff @(posedge gsi.clk) begin : receive_instruction
    for (int i = 0; i < 2; i++) begin
      if (issue[i].st_type == ST_TYPE && !gsi.delete_tagged) begin
        records.push_back('{issue[i].data_1, issue[i].data_2, issue[i].address, issue[i].immediate,
                          issue[i].regs.rs_1, issue[i].regs.rs_2, issue[i].regs.rn,
                          issue[i].valid_1, issue[i].valid_2, issue[i].flags.tag, 1'h0,
                          issue[i].instr_name});
      end
    end
  end

  always_ff @(posedge gsi.clk) begin : update_records
    foreach (records[i]) begin
      for (int j = 0; j < 2; j++) begin
        if (match_cdb(records[i].src_1, records[i].valid_1, cdb[j].arn, cdb[j].rrn));
        begin
          records[i].data_1  <= cdb[j].result;
          records[i].valid_1 <= 1'h1;
        end
        if (match_cdb(records[i].src_2, records[i].valid_2, cdb[j].arn, cdb[j].rrn));
        begin
          records[i].data_2  <= cdb[j].result;
          records[i].valid_2 <= 1'h1;
        end
      end
    end
  end

  always_ff @(posedge gsi.clk) begin : feed_ex_unit
    for (int i = 0; i < SIZE; i++) begin
      if (records[i].valid_1 && records[i].valid_2 && !records[i].skip) begin
        exec_feed.data_1 <= records[i].data_1;
        exec_feed.data_2 <= records[i].data_2;
        exec_feed.address <= records[i].address;
        exec_feed.immediate <= records[i].immediate;
        exec_feed.rrn <= records[i].rrn;
        exec_feed.instr_name <= records[i].instr_name;
        break;
      end else begin
        exec_feed.instr_name <= UNKNOWN;
      end
    end
  end

  always_comb begin : pop_record
    if (next) records.pop_front();
  end

  always_comb begin : skip
    if (gsi.delete_tagged) foreach (records[i]) records[i].skip = records[i].tag;
  end
endmodule
