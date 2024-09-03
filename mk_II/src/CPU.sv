// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module CPU #(
  parameter int BUS_WIDTH_BYTES   = 256,
  parameter int INSTR_CACHE_WORDS = 4,
  parameter int INSTR_CACHE_SETS  = 8,
  parameter int DATA_CACHE_WORDS  = 4,
  parameter int DATA_CACHE_SETS   = 10
) (
  input wire i_clock,
  input wire i_reset,

  IntfMemory.CPU memory
);
  IntfCSB u_common_signal_bus ();
  IntfMemory #(.BUS_WIDTH_BYTES(INSTR_CACHE_WORDS * 4)) u_instr_mem ();
  IntfMemory #(.BUS_WIDTH_BYTES(DATA_CACHE_WORDS * 4)) u_data_mem ();
  IntfInstrCache u_intr_cache_bus[2] ();
  IntfDataCache u_data_cache_bus ();
  IntfCDB u_common_data_bus[2] ();
  IntfIssue u_issue[2] ();
  IntfRegQuery u_query[2] ();
  IntfRegValBus u_reg_val[2] ();
  IntfFull u_full ();

  wire [31:0] jmp_address;
  wire        jmp_write;

  MemoryManagementUnit u_mmu (
    .cs    (u_common_signal_bus),
    .memory(memory),
    .instr (u_instr_mem),
    .data  (u_data_mem)
  );

  InstructionCache #(
    .SETS (INSTR_CACHE_SETS),
    .WORDS(INSTR_CACHE_WORDS)
  ) u_instr_cache (
    .cs    (u_common_signal_bus),
    .memory(u_instr_mem),
    .cache (u_intr_cache_bus)
  );

  DataCache #(
    .SETS (DATA_CACHE_SETS),
    .WORDS(DATA_CACHE_WORDS)
  ) u_data_cache (
    .cs      (u_common_signal_bus),
    .memory  (u_data_mem),
    .cache   (u_data_cache_bus),
    .data_bus(u_common_data_bus)
  );

  IPWrapper u_wrapper (
    .cs           (u_common_signal_bus),
    .cache        (u_intr_cache_bus),
    .issue        (u_issue),
    .data         (u_common_data_bus),
    .query        (u_query),
    .reg_val      (u_reg_val),
    .full         (u_full),
    .i_jmp_address(jmp_address),
    .i_jmp_write  (jmp_write)
  );

  RegisterFile u_reg_file (
    .cs     (u_common_signal_bus),
    .query  (u_query),
    .reg_val(u_reg_val),
    .data   (u_common_data_bus)
  );

  ReorderBuffer u_rob (
    .cs           (u_common_signal_bus),
    .data         (u_common_data_bus),
    .issue        (u_issue),
    .o_jmp_address(jmp_address),
    .o_jmp_write  (jmp_write),
    .o_full       (u_full.rob)
  );

  ComboALU u_combo_alu (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .o_full(u_full.alu)
  );

  ComboBranch u_combo_branch (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .o_full(full.branch)
  );

  ComboLoadStore u_combo_load_store (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .cache (u_data_cache_bus),
    .o_full(full.load_store)
  );

  ComboMulDiv u_combo_mul_div (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .o_full(full.mul_div)
  );

  // ------------------------------- Behaviour -------------------------------
  assign u_common_signal_bus.clock = i_clock;
  assign u_common_signal_bus.reset = i_reset;

endmodule
