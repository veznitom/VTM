module station #(
    parameter int SIZE = 16,
    parameter st_type_e ST_TYPE = XX,
    parameter int ISSUE_BUS_CNT = 2,
    parameter int CDB_CNT = 2
) (
    global_signals_if global_signals,
    instr_issue_if instr_issue[ISSUE_BUS_CNT],
    common_data_bus_if cdb[CDB_CNT],
    station_unit_if to_unit[UNIT_CNT],

    input  logic done,
    output logic full
);

  station_record_t issued_records[$:SIZE], ready_records[$:SIZE];

  always_comb begin
    if (global_signals.reset) begin
      issued_records.delete();
      ready_records.delete();
    end
  end

  always_ff @(global_signals.clk) begin
    full <= (SIZE - 1 == issued_records.size()) ? 1'b1 : 1'b0;
  end

  always_ff @(posedge global_signals.clk) begin : ouptut_management
    if (done || records[head].ignore) begin
      ready_records.pop_front();
    end else if (!ready_records.size()) begin
      to_unit.clear();
    end else begin
      to_unit.write(ready_records[0]);
    end
  end

  always_ff @(posedge global_signals.clk) begin : input_management
    foreach (instr_issue[i]) begin
      if (instr_issue[i].station_index == ST_INDEX && !global_signals.delete_tagged)
        issued_records.push_back(instr_issue[i].TODO);
    end
  end

  always_ff @(posedge global_signals.clk) begin : CDB_fetch
    foreach (records[i]) begin
      foreach (cdb[i]) begin
        if (!records[i].valid1)
          if (records[i].src1 == cdb[i].arn || cdb[i].rrn) begin
            records[i].src1 <= cdb[i].data;
            records[i].src1 <= 1'b1;
          end

        if (!records[i].valid2)
          if (records[i].src2 == cdb[i].arn || cdb[i].rrn) begin
            records[i].src2 <= cdb[i].data;
            records[i].src2 <= 1'b1;
          end
      end
    end
  end

  always @(posedge global_signals.delete_tagged) begin
    foreach (records[i]) begin
      if (records[i].tag) records[i].ignore = 1'b1;
    end
  end

endmodule
