import CustomTypes::*;

module InstrCache #(
  parameter cache_size = 16
)(
  GlobalSignals.rest global_signals,
  InstrCacheBus instr_dd,
  InstrMemoryBus instr_mem
);

  logic [31:0] pc;
  logic miss, hit1, hit2, side;

  int index, i,j;

  InstrCacheRecord records [1:0][cache_size-1:0];

  always @(*) begin
    if (global_signals.reset) begin
      for (j = 0; j < 2; j++)
        for (i = 0; i < cache_size; i++)
          records[j][i] = '{32'hzzzzzzz,32'hzzzzzzz};
      instr_mem.address <= 32'hzzzzzzzz;
      instr_mem.read = 1'b0;
      miss <= 1'b0;
      instr_dd.hit <= 1'b0;
      side <= 1'b0;
      pc <= instr_dd.address;
    end
  end

// Look up the instructions if not present set miss otherwise hit an return them

  always @( posedge global_signals.clk ) begin
    if (instr_dd.read && !instr_dd.hit) begin
      miss = 1'b1;
      hit1 = 1'b0;
      hit2 = 1'b0;
      for (j = 0; j < 2; j++)
        for (i = 0; i < cache_size; i++) begin
          if (records[j][i].address == instr_dd.address) begin
            instr_dd.instr1 = records[j][i].instr;
            hit1 = 1'b1;
          end
            
          if (records[j][i].address == instr_dd.address+4) begin
            instr_dd.instr2 = records[j][i].instr;
            hit2 = 1'b1;
          end
        end

      if (hit1 && hit2) begin
        instr_dd.hit = 1'b1;
        miss = 1'b0;
      end

    end
    if (!instr_dd.read)
      instr_dd.hit <= 1'b0;
  end

// Fetch missed instructions from the Memory

  always @( posedge global_signals.clk) begin
    if (miss) begin
      if (!instr_mem.ready) begin
        if (!global_signals.delete_tagged) begin
          instr_mem.address <= instr_dd.address;
          instr_mem.read <= 1'b1;
        end else begin
          instr_mem.address <= 32'hzzzzzzzz;
          instr_mem.read <= 1'b0;
        end
      end else if (instr_mem.read) begin
        instr_mem.address <= 32'hzzzzzzzz;
        instr_mem.read <= 1'b0;
        for(i = 1; i <= cache_size; i++) begin
          records[side][i-1] = '{instr_mem.address + ((i-1)*4) ,instr_mem.data[((i*32)-1)-:32]};
        end
        side = ~side;
      end

    end else begin
      instr_mem.address <= 32'hzzzzzzzz;
      instr_mem.read <= 1'b0;
    end
  end
endmodule