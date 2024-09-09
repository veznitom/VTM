// Copyright (c) 2024 veznitom

`default_nettype none
module MemoryManagementUnit (
  IntfCSB.notag  cs,
  IntfMemory.CPU memory_bus,
  IntfMemory.MMU instr_bus,
  IntfMemory.MMU data_bus
);
  // ------------------------------- Strucutres -------------------------------
  typedef enum bit [1:0] {
    FREE,
    INSTR,
    DATA
  } mmu_state_e;

  // ------------------------------- Wires -------------------------------
  mmu_state_e        lock;
  reg         [31:0] tmp_data;

  // ------------------------------- Behaviour -------------------------------
  assign memory_bus.data = data_bus.write ? tmp_data : 'z;
  assign instr_bus.data  =
    (lock == INSTR && instr_bus.read) ? memory_bus.data : 'z;
  assign data_bus.data = (lock == DATA && data_bus.read) ? memory_bus.data : 'z;

  always_ff @(posedge cs.clock) begin
    if (cs.reset) begin
      lock <= FREE;
    end else begin
      case (lock)
        FREE: begin
          if (instr_bus.read) begin
            lock <= INSTR;
          end else if (data_bus.read || data_bus.write) begin
            lock <= DATA;
          end else begin
            lock <= FREE;
          end
        end
        INSTR: begin
          if (instr_bus.read) begin
            memory_bus.address <= instr_bus.address;
            memory_bus.read    <= instr_bus.read;
            memory_bus.write   <= instr_bus.write;
            instr_bus.ready    <= memory_bus.ready;
            instr_bus.done     <= memory_bus.done;
          end else begin
            memory_bus.address <= '0;
            memory_bus.read    <= '0;
            memory_bus.write   <= '0;
            lock               <= FREE;
          end
          data_bus.ready <= '0;
          data_bus.done  <= '0;
        end
        DATA: begin
          if (data_bus.read || data_bus.write) begin
            memory_bus.address <= data_bus.address;
            memory_bus.read    <= data_bus.read;
            memory_bus.write   <= data_bus.write;
            if (data_bus.write) tmp_data <= data_bus.data;
            data_bus.ready <= memory_bus.ready;
            data_bus.done  <= memory_bus.done;
          end else begin
            memory_bus.address <= '0;
            memory_bus.read    <= '0;
            memory_bus.write   <= '0;
            lock               <= FREE;
          end
          instr_bus.ready <= '0;
          instr_bus.done  <= '0;
        end
        default: begin
          memory_bus.address <= '0;
          memory_bus.read    <= '0;
          memory_bus.write   <= '0;
          instr_bus.ready    <= '0;
          instr_bus.done     <= '0;
          data_bus.ready     <= '0;
          data_bus.done      <= '0;
        end
      endcase
    end
  end

  /*
  assign memory.address = tmp_address;
  assign memory.data    = tmp_data;

  always_comb begin : access_management
    if (cs.reset) begin
      lock       = FREE;
      instr.done = 1'h0;
      tmp_data   = '0;
    end else if (instr_cache.read && lock != DATA) begin : instructions_read
      lock = INSTR;
      if (memory.ready) begin
        instr_cache.data  = memory.data[instr.BUS_WIDTH_BITS-1:0];
        instr_cache.ready = 1'h1;
        lock              = FREE;
      end else begin
        tmp_address       = instr_cache.address;
        memory.read       = 1'h1;
        instr_cache.ready = 1'h0;
      end
    end else if (data_cache.read && lock != INSTR) begin : data_read
      lock = DATA;
      if (memory.ready) begin
        data_cache.data  = memory.data[data.BUS_WIDTH_BITS-1:0];
        data_cache.ready = 1'h1;
        lock             = FREE;
      end else begin
        tmp_address      = data_cache.address;
        memory.read      = 1'h1;
        data_cache.ready = 1'h0;
      end
    end else if (data_cache.write && lock != INSTR) begin
      lock = DATA;
      if (memory.done) begin
        data_cache.data = memory.data[data.BUS_WIDTH_BITS-1:0];
        memory.write    = 1'b0;
        data_cache.done = 1'b1;
        lock            = FREE;
      end else begin
        tmp_address     = instr_cache.address;
        memory.write    = 1'b1;
        data_cache.done = 1'b0;
      end
    end else begin
      tmp_address       = '0;
      memory.read       = '0;
      memory.write      = '0;
      instr_cache.ready = '0;
      data_cache.ready  = '0;
      data_cache.done   = '0;
    end
  end
  */
endmodule
