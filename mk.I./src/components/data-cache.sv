import CustomTypes::*;

module DataCache #(
  parameter cache_size = 16
)(
  GlobalSignals.rest global_signals,
  CommonDataBus.cache data_bus1, data_bus2,
  DataCacheBus.cache data_ls,
  DataMemoryBus.cache data_mem
);

  int index, i;

  logic [31:0] data_data_ls, data_data_mem;
  logic [7:0] state;
  logic miss, write_back;

  DataCacheRecord records [cache_size-1:0];
  DataCacheRecord write_queue [$:cache_size];

  assign data_ls.data = data_ls.hit ? data_data_ls : 32'hzzzzzzzz;
  assign data_mem.data = data_mem.write ? data_data_mem : 32'hzzzzzzzz;

  always @(*) begin
    if (global_signals.reset) begin
      foreach (records[i])
        records[i] = '{0,0,0,0,INVALID,EMPTY};
      data_data_ls <= 32'hzzzzzzzz;
      data_data_mem <= 32'hzzzzzzzz;
      data_mem.address <= 32'hzzzzzzzz;
      data_mem.read = 1'b0;
      data_mem.write = 1'b0;
      state <= 7'h00;
      miss <= 1'b0;
      data_ls.hit <= 1'b0;
    end
  end

  always @( posedge global_signals.clk ) begin
    if (data_ls.read && !data_ls.hit && !write_back) begin
      miss = 1'b1;
      foreach (records[i])
        if (records[i].address == data_ls.address && (records[i].state == VALID || records[i].state == MODIFIED)) begin
          data_data_ls = records[i].data;
          data_ls.hit = 1'b1;
          miss = 1'b0;
        end
    end

    if (!data_ls.read)
      data_ls.hit = 1'b0;
  end

  always @( posedge global_signals.clk) begin
    if (miss && !write_back) begin
      if (!data_mem.ready) begin
        data_mem.address <= data_ls.address;
        data_mem.read <= 1'b1;
      
      end else if (data_mem.read) begin
        data_mem.address <= 32'hzzzzzzzz;
        data_mem.read <= 1'b0;

        index = -1;
        // INVALID SEARCH
        for (i = 0; i < cache_size; i++) begin
            if (records[i].state == INVALID)
              index = i;
        end

        // MODIFIED SEARCH
        if (index == -1)
          for (i = 0; i < cache_size; i++) begin
            if (records[i].state == MODIFIED) begin
              index = i;
              write_queue.push_back(records[i]);
            end
          end
        
        // VALID EJECTION
        if (index == -1)
          for (i = 0; i < cache_size; i++) begin
            if (records[i].state == VALID)
              index = i;
          end

        if (index > -1) begin
          records[index] <= '{data_mem.data, data_ls.address, 0, 0, VALID, EMPTY};
          miss <= 1'b0; 
        end
      end 

    end else begin
      data_mem.address <= 32'hzzzzzzzz;
      data_mem.read <= 1'b0;
    end

  end

  always @( posedge global_signals.clk) begin
    if (data_ls.write) begin

      index = -1;
      for (i = 0; i < cache_size; i++) begin
            if (records[i].address == data_ls.address && records[i].state == MODIFIED) begin
              index = i;
              write_queue.push_back(records[i]);
            end
        end

      // INVALID SEARCH
      if (index == -1)
        for (i = 0; i < cache_size; i++) begin
            if (records[i].state == INVALID)
              index = i;
        end

      // VALID EJECTION
      if (index == -1)
        for (i = 0; i < cache_size; i++) begin
          if (records[i].state == VALID)
            index = i;
        end

      // MODIFIED SEARCH
      if (index == -1)
        for (i = 0; i < cache_size; i++) begin
          if (records[i].state == MODIFIED) begin
            index = i;
            write_queue.push_back(records[i]);
          end
        end

      if (index > -1) begin
        records[index] = '{data_ls.data, data_ls.address ,data_ls.instr, data_ls.tag, WAITING, data_ls.ws};
      end
    end
  end

  always @( posedge global_signals.clk ) begin
    foreach (records[i]) begin
      if (records[i].instr == data_bus1.address && records[i].state == WAITING)
        records[i].state = MODIFIED;
      
      if (records[i].instr == data_bus2.address && records[i].state == WAITING)
        records[i].state = MODIFIED;
    end
  end

  always @( posedge global_signals.clk ) begin
    if ((write_queue.size() > 0 && !data_mem.read && !data_mem.write) || write_back) begin
      write_back <= 1'b1;
      if (!data_mem.done) begin
        data_mem.write <= 1'b1;
        data_mem.address <= write_queue[0].address;
        data_mem.ws <= write_queue[0].ws;
        data_data_mem <= write_queue[0].data;
      end else begin
        write_queue.pop_front();
        data_mem.write <= 1'b0;
        data_mem.address <= 32'hzzzzzzzz;
        data_data_mem <= 32'hzzzzzzzz;
        write_back <= 1'b0;
      end
    end else
      write_back <= 1'b0;
  end

endmodule