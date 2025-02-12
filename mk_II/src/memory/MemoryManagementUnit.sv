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

  assign data_cache.data = data_cache.read && lock != INSTR ? memory.data : 'z;
  assign instr_cache.data = instr_cache.read && lock != DATA ? memory.data : 'z;
  assign memory.data = data_cache.write && lock != INSTR ? data_cache.data : 'z;

  // ------------------------------- Behaviour -------------------------------
  always_comb begin : access_management
    if (instr_cache.read && lock != DATA) begin : instructions_read
      lock              = INSTR;
      memory.write      = '0;
      data_cache.ready  = '0;
      data_cache.done   = '0;
      memory.address    = instr_cache.address;
      memory.read       = instr_cache.read;
      instr_cache.ready = memory.ready;
    end else if ((data_cache.read || data_cache.write) && lock != INSTR) begin : data_read
      lock              = DATA;
      memory.read       = '0;
      instr_cache.ready = '0;
      memory.address    = data_cache.address;
      memory.read       = data_cache.read;
      memory.write      = data_cache.write;
      data_cache.ready  = memory.ready;
      data_cache.done   = memory.done;
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
