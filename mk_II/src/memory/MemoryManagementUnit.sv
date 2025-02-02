// Copyright (c) 2024 veznitom

`default_nettype none
module MemoryManagementUnit (
  IntfMemory memory,
  IntfMemory instr_cache,
  IntfMemory data_cache
);
  // ------------------------------- Strucutres -------------------------------
  typedef enum bit [1:0] {
    FREE,
    INSTR,
    DATA
  } mmu_state_e;

  // ------------------------------- Wires -------------------------------
  mmu_state_e lock;

  assign data_cache.data  = data_cache.read ? memory.data : 'z;
  assign instr_cache.data = instr_cache.read ? memory.data : 'z;
  assign memory.data      = data_cache.write ? data_cache.data : 'z;

  // ------------------------------- Behaviour -------------------------------
  always_comb begin : access_management
    if (instr_cache.read && lock != DATA) begin : instructions_read
      lock = INSTR;
      if (memory.ready) begin
        instr_cache.ready = 1'h1;
        lock              = FREE;
      end else begin
        memory.address    = instr_cache.address;
        memory.read       = 1'h1;
        instr_cache.ready = 1'h0;
      end
    end else if (data_cache.read && lock != INSTR) begin : data_read
      lock = DATA;
      if (memory.ready) begin
        data_cache.ready = 1'h1;
        lock             = FREE;
      end else begin
        memory.address   = data_cache.address;
        memory.read      = 1'h1;
        data_cache.ready = 1'h0;
      end
    end else if (data_cache.write && lock != INSTR) begin
      lock = DATA;
      if (memory.done) begin
        memory.write    = 1'b0;
        data_cache.done = 1'b1;
        lock            = FREE;
      end else begin
        memory.address  = data_cache.address;
        memory.write    = 1'b1;
        data_cache.done = 1'b0;
      end
    end else begin
      lock              = FREE;
      memory.address    = '0;
      memory.read       = '0;
      memory.write      = '0;
      instr_cache.ready = '0;
      data_cache.ready  = '0;
      data_cache.done   = '0;
    end
  end

endmodule
