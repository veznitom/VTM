module Station #(
  parameter int SIZE = 16,
  parameter logic [7:0] ADDRESS = 8'h00,
  parameter int ISSUE_BUS_CNT = 2,
  parameter int CDB_CNT = 2
)(
  global_signals_if gl_signals,
  instr_issue_if instr_issue [ISSUE_BUS_CNT],
  common_data_bus_if cdb,
  station_unit_if to_unit,
  // Dispatch
  output logic [15:0] free_space
);

  function bit match_iib (input [5:0] src, arn, rrn);
    return (((src == arn) || (src == rrn)) && src != 0);
  endfunction

  function bit match_cdb(input [5:0] src, valid, arn, rrn);
    return ((arn == src) && !valid) || ((rrn == src) && !valid);
  endfunction

  StationRecord temp_rec1, temp_rec2;
  StationRecord records [$:station_size];

  always @(*) begin
    if (global_signals.reset) begin
      temp_rec1 = 'z;
      temp_rec2 = 'z;
      records.delete();
      exec_feed.clear();
    end
  end

  always @( global_signals.clk ) begin
    free_space <= station_size - records.size();
  end

  always @( posedge global_signals.clk ) begin
    if (records[0].address == data_bus1.address || records[0].address == data_bus2.address || records[0].ignore) begin
      records.pop_front();
      if (!records.size()) begin
        exec_feed.clear();
      end
    end
  end

  always @( posedge global_signals.clk) begin
    if ((records.size() > 0) && (records[0].valid1 & records[0].valid2) && !records[0].ignore) begin
      exec_feed.write(records[0].data1,records[0].data2,records[0].address,records[0].imm,records[0].pid,records[0].rrn,records[0].tag);
    end else begin
      exec_feed.clear();
    end
  end

// Loading instruction and operands from Instruction Issue Bus with CDB match to ensure updated data

  always @( posedge global_signals.clk ) begin
    if (issue1.stat_select == station && !global_signals.delete_tagged) begin
      if (issue1.valid1) begin
        temp_rec1.data1 = issue1.data1;
        temp_rec1.valid1 = 1'b1;
      end else if (match_iib(issue1.src1, data_bus1.arn, data_bus1.rrn)) begin
        temp_rec1.data1 = data_bus1.data;
        temp_rec1.valid1 = 1'b1;
      end else if (match_iib(issue1.src1, data_bus2.arn, data_bus2.rrn)) begin
        temp_rec1.data1 = data_bus2.data;
        temp_rec1.valid1 = 1'b1;
      end else begin
        temp_rec1.data1 = 32'h00000000;
        temp_rec1.valid1 = 1'b0;
      end

      if (issue1.valid2) begin
        temp_rec1.data2 = issue1.data2;
        temp_rec1.valid2 = 1'b1;
      end else if (match_iib(issue1.src2, data_bus1.arn, data_bus1.rrn)) begin
        temp_rec1.data2 = data_bus1.data;
        temp_rec1.valid2 = 1'b1;
      end else if (match_iib(issue1.src2, data_bus2.arn, data_bus2.rrn)) begin
        temp_rec1.data2 = data_bus2.data;
        temp_rec1.valid2 = 1'b1;
      end else begin
        temp_rec1.data2 = 32'h00000000;
        temp_rec1.valid2 = 1'b0;
      end
      
      temp_rec1.address = issue1.address;
      temp_rec1.imm = issue1.imm;
      temp_rec1.pid = issue1.pid;
      temp_rec1.src1 = issue1.src1; 
      temp_rec1.src2 = issue1.src2; 
      temp_rec1.rrn = issue1.rrn;
      temp_rec1.tag = issue1.tag;
      temp_rec1.ignore = 1'b0;
      records.push_back(temp_rec1);
    end

    if (issue2.stat_select == station && !global_signals.delete_tagged) begin
      if (issue2.valid1) begin
        temp_rec2.data1 = issue2.data1;
        temp_rec2.valid1 = 1'b1;
      end else if (match_iib(issue2.src1, data_bus1.arn, data_bus1.rrn)) begin
        temp_rec2.data1 = data_bus1.data;
        temp_rec2.valid1 = 1'b1;
      end else if (match_iib(issue2.src1, data_bus2.arn, data_bus2.rrn)) begin
        temp_rec2.data1 = data_bus2.data;
        temp_rec2.valid1 = 1'b1;
      end else begin
        temp_rec2.data1 = 32'h00000000;
        temp_rec2.valid1 = 1'b0;
      end

      if (issue2.valid2) begin
        temp_rec2.data2 = issue2.data2;
        temp_rec2.valid2 = 1'b1;
      end else if (match_iib(issue2.src2, data_bus1.arn, data_bus1.rrn)) begin
        temp_rec2.data2 = data_bus1.data;
        temp_rec2.valid2 = 1'b1;
      end else if (match_iib(issue2.src2, data_bus2.arn, data_bus2.rrn)) begin
        temp_rec2.data2 = data_bus2.data;
        temp_rec2.valid2 = 1'b1;
      end else begin
        temp_rec2.data2 = 32'h00000000;
        temp_rec2.valid2 = 1'b0;
      end
      
      temp_rec2.address = issue2.address;
      temp_rec2.imm = issue2.imm;
      temp_rec2.pid = issue2.pid;
      temp_rec2.src1 = issue2.src1; 
      temp_rec2.src2 = issue2.src2; 
      temp_rec2.rrn = issue2.rrn;
      temp_rec2.tag = issue2.tag;
      temp_rec2.ignore = 1'b0;
      records.push_back(temp_rec2);
    end
  end

// Getting missing data from CDB

  always @( posedge global_signals.clk ) begin 
    foreach (records[i]) begin
        if (match_cdb(records[i].src1, records[i].valid1, data_bus1.arn, data_bus1.rrn)) begin
          records[i].data1 = data_bus1.data;
          records[i].valid1 = 1'b1;
        end

        if (match_cdb(records[i].src2, records[i].valid2, data_bus1.arn, data_bus1.rrn)) begin
          records[i].data2 = data_bus1.data;
          records[i].valid2 = 1'b1;
        end

        if (match_cdb(records[i].src1, records[i].valid1, data_bus2.arn, data_bus2.rrn)) begin
          records[i].data1 = data_bus2.data;
          records[i].valid1 = 1'b1;
        end

        if (match_cdb(records[i].src2, records[i].valid2, data_bus2.arn, data_bus2.rrn)) begin
          records[i].data2 = data_bus2.data;
          records[i].valid2 = 1'b1;
        end
      end
    end

  always @( posedge global_signals.delete_tagged ) begin
    foreach(records[i]) begin
      if (records[i].tag)
        records[i].ignore = 1'b1;
    end
  end

endmodule
