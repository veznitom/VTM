import CustomTypes::*;

module Registers (
    GlobalSignals.rest global_signals,
    RegisterQuery.regs query1,
    query2,
    CommonDataBus.regs data_bus1,
    data_bus2,
    DebugInterface debug
);

  RegisterData registers[63:0];
  reg [5:0] ren_queue[$:32];

  task automatic append_ren(input [5:0] ren);
    automatic bit present = 1'b0;
    foreach (ren_queue[i]) if (ren_queue[i] == ren) present = 1'b1;
    if (!present) ren_queue.push_back(ren);
  endtask

  always @(*) begin
    if (global_signals.reset) query1.reg_clear();
    query2.reg_clear();
    for (int i = 0; i < 64; i = i + 1) registers[i] = '{32'h00000000, 6'h00, 1'b0, 1'b0};
    registers[0] = '{32'h00000000, 6'h00, 1'b1, 1'b0};
    ren_queue.delete();
    for (int i = 32; i < 64; i = i + 1) begin
      ren_queue.insert(i - 32, i);
    end
  end

  task automatic q1_rename();
    query1.ret_renamed = query1.get_renamed && (ren_queue.size() > 0) ? ren_queue.pop_front() : 6'hzz;
    registers[query1.reg3_num].rrn = query1.ret_renamed;
    registers[query1.ret_renamed] = '{32'h00000000, 6'h00, 1'b0, query1.tag};
    if (!query1.tag) registers[query1.reg3_num].valid = 1'b0;
    registers[query1.reg3_num].tag = query1.tag;
  endtask

  task automatic q2_rename();
    query2.ret_renamed = query2.get_renamed && (ren_queue.size() > 0) ? ren_queue.pop_front() : 6'hzz;
    registers[query2.reg3_num].rrn = query2.ret_renamed;
    registers[query2.ret_renamed] = '{32'h00000000, 6'h00, 1'b0, query2.tag};
    if (!query2.tag) registers[query2.reg3_num].valid = 1'b0;
    registers[query2.reg3_num].tag = query2.tag;
  endtask

  // The read_qxry tasks do the same, return the value, validity, and register number base on the query register number input
  // These task are separated as generate block was problematic with tasks

  task automatic read_q1r1(input [5:0] tmp_rrn, input tmp_valid);
    if (query1.reg1_num == 0) query1.reg1_write(32'h00000000, 1'b1, 6'h00);
    else if (query1.reg1_num < 32) begin
      automatic int arn = query1.reg1_num;
      automatic int rrn = registers[query1.reg1_num].rrn;
      if (tmp_rrn != 1 && arn == query1.reg3_num)
        if (tmp_rrn == 0) query1.reg1_write(registers[arn].value, tmp_valid, arn);
        else query1.reg1_write(registers[tmp_rrn].value, registers[tmp_rrn].valid, tmp_rrn);
      else if (rrn > 31) query1.reg1_write(registers[rrn].value, registers[rrn].valid, rrn);
      else query1.reg1_write(registers[arn].value, registers[arn].valid, 1'b0);
    end else query1.reg1_write(32'hzzzzzzzz, 1'hz, 6'hzz);
  endtask

  task automatic read_q1r2(input [5:0] tmp_rrn, input tmp_valid);
    if (query1.reg2_num == 0) query1.reg2_write(32'h00000000, 1'b1, 6'h00);
    else if (query1.reg2_num < 32) begin
      automatic int arn = query1.reg2_num;
      automatic int rrn = registers[query1.reg2_num].rrn;
      if (tmp_rrn != 1 && arn == query1.reg3_num)
        if (tmp_rrn == 0) query1.reg2_write(registers[arn].value, tmp_valid, arn);
        else query1.reg2_write(registers[tmp_rrn].value, registers[tmp_rrn].valid, tmp_rrn);
      else if (rrn > 31) query1.reg2_write(registers[rrn].value, registers[rrn].valid, rrn);
      else query1.reg2_write(registers[arn].value, registers[arn].valid, 0);
    end else query1.reg2_write(32'hzzzzzzzz, 1'hz, 6'hzz);
  endtask

  task automatic read_q2r1(input [5:0] tmp_rrn, input tmp_valid);
    if (query2.reg1_num == 0) query2.reg1_write(32'h00000000, 1'b1, 6'h00);
    else if (query2.reg1_num < 32) begin
      automatic int arn = query2.reg1_num;
      automatic int rrn = registers[query2.reg1_num].rrn;
      if (tmp_rrn != 1 && arn == query2.reg3_num)
        if (tmp_rrn == 0) query2.reg1_write(registers[arn].value, tmp_valid, arn);
        else query2.reg1_write(registers[tmp_rrn].value, registers[tmp_rrn].valid, tmp_rrn);
      else if (rrn > 31) query2.reg1_write(registers[rrn].value, registers[rrn].valid, rrn);
      else query2.reg1_write(registers[arn].value, registers[arn].valid, 0);
    end else query2.reg1_write(32'hzzzzzzzz, 1'hz, 6'hzz);
  endtask

  task automatic read_q2r2(input [5:0] tmp_rrn, input tmp_valid);
    if (query2.reg2_num == 0) begin
      query2.reg2_write(32'h00000000, 1'b1, 6'h00);
    end else if (query2.reg2_num < 32) begin
      automatic int arn = query2.reg2_num;
      automatic int rrn = registers[query2.reg2_num].rrn;
      if (tmp_rrn != 1 && arn == query2.reg3_num)
        if (tmp_rrn == 0) query2.reg2_write(registers[arn].value, tmp_valid, arn);
        else query2.reg2_write(registers[tmp_rrn].value, registers[tmp_rrn].valid, tmp_rrn);
      else if (rrn > 31) query2.reg2_write(registers[rrn].value, registers[rrn].valid, rrn);
      else query2.reg2_write(registers[arn].value, registers[arn].valid, 0);
    end else query2.reg2_write(32'hzzzzzzzz, 1'hz, 6'hzz);
  endtask

  // If the CDB write enable is 1. Write the data either to renamed register, if from execution unit, or to architectural register, if from ROB.

  task automatic write_back();
    if (data_bus1.we)
      if ((data_bus1.rrn < 64) && (data_bus1.rrn > 31) && (data_bus1.arn < 32) && (data_bus1.arn > 0)) begin // Write from ROB
        if ((data_bus1.rrn == registers[data_bus1.arn].rrn) || (registers[data_bus1.arn].rrn == 6'h00)) begin
          registers[data_bus1.arn] = '{data_bus1.data, 6'h00, 1'b1, 1'b0};
        end else begin
          registers[data_bus1.arn].value = data_bus1.data;
          registers[data_bus1.arn].valid = 1'b1;
        end
        registers[data_bus1.rrn] = '{32'h00000000, 6'h00, 1'b0, 1'b0};
        append_ren(data_bus1.rrn);
      end else if ((data_bus1.rrn < 64) && (data_bus1.rrn >= 32)) begin  // Write from exec
        registers[data_bus1.rrn] = '{data_bus1.data, 6'h00, 1'b1, registers[data_bus1.rrn].tag};
      end

    if (data_bus2.we)
      if ((data_bus2.rrn < 64) && (data_bus2.rrn > 31) && (data_bus2.arn < 32) && (data_bus2.arn > 0)) begin // Write from ROB
        if ((data_bus2.rrn == registers[data_bus2.arn].rrn) || (registers[data_bus2.arn].rrn == 6'h00))
          registers[data_bus2.arn] = '{data_bus2.data, 6'h00, 1'b1, 1'b0};
        else begin
          registers[data_bus2.arn].value = data_bus2.data;
          registers[data_bus2.arn].valid = 1'b1;
        end
        registers[data_bus2.rrn] = '{32'h00000000, 6'h00, 1'b0, 1'b0};
        append_ren(data_bus2.rrn);
      end else if ((data_bus2.rrn < 64) && (data_bus2.rrn >= 32)) begin  // Write from exec
        registers[data_bus2.rrn] = '{data_bus2.data, 6'h00, 1'b1, registers[data_bus2.rrn].tag};
      end
  endtask

  always @(global_signals.clk) begin
    debug.ren_queue_size <= ren_queue.size();
  end

  always @(posedge global_signals.clk) begin
    debug.reg11_value <= registers[11].value;

    write_back();

    if ((query1.reg1_num == query1.reg3_num || query1.reg1_num == query1.reg3_num) && query1.reg3_num != 0) begin
      automatic int tmp_rrn = registers[query1.reg3_num].rrn;
      automatic bit tmp_valid = registers[query1.reg3_num].valid;
      q1_rename();
      read_q1r1(tmp_rrn, tmp_valid);
      read_q1r2(tmp_rrn, tmp_valid);
    end else begin
      read_q1r1(6'h01, 1'b0);
      read_q1r2(6'h01, 1'b0);
      if (query1.get_renamed) q1_rename();
      else query1.ret_renamed = 6'hzz;
    end

    if ((query2.reg1_num == query2.reg3_num || query2.reg1_num == query2.reg3_num) && query2.reg3_num != 6'h00) begin
      automatic int tmp_rrn = registers[query2.reg3_num].rrn;
      automatic bit tmp_valid = registers[query2.reg3_num].valid;
      q2_rename();
      read_q2r1(tmp_rrn, tmp_valid);
      read_q2r2(tmp_rrn, tmp_valid);
    end else begin
      read_q2r1(6'h01, 1'b0);
      read_q2r2(6'h01, 1'b0);
      if (query2.get_renamed) q2_rename();
      else query2.ret_renamed = 6'hzz;
    end
  end

  always @(posedge global_signals.delete_tagged) begin
    for (int i = 0; i < 32; i++) begin
      if (registers[i].tag) begin
        registers[i].tag = 0;
        registers[i].rrn = 0;
      end
    end

    for (int i = 32; i < 64; i++) begin
      if (registers[i].tag) begin
        registers[i] = '{0, 0, 0, 0};
        append_ren(i[5:0]);
      end
    end
  end

  always @(posedge global_signals.clear_tags) begin
    foreach (registers[i]) if (registers[i].tag) registers[i].tag = 0;
  end

endmodule


