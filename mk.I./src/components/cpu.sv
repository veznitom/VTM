import CustomTypes::*;

module CPU #(
  parameter int instr_cache_size = 16,
  parameter int data_cache_size = 16
)(
  input wire clk, reset,
  MemoryBus.cpu mem_bus,
  DebugInterface debug
);

// Conetions
  GlobalSignals global_signals(.clk(clk),.reset(reset));
  CommonDataBus data_buses[2]();
  InstrIssue instr_issues[2]();
  RegisterQuery queries[2]();
  DataCacheBus data_cache_bus();
  InstrCacheBus instr_cache_bus();
  PCInterface pc_control();
  InstrMemoryBus #(instr_cache_size*32) instr_bus();
  DataMemoryBus data_bus();

  // Station capacities
  wire [15:0] aluc_free_space, branchc_free_space, lsc_free_space;
  
// Modules
  MemoryManagementUnit mmu(
    .global_signals(global_signals),
    .mem_bus(mem_bus),
    .instr_bus(instr_bus),
    .data_bus(data_bus)
  );

  InstrCache #(instr_cache_size) instr_cache(
    .global_signals(global_signals), 
    .instr_dd(instr_cache_bus),
    .instr_mem(instr_bus)
  );

  PC pc(
    .global_signals(global_signals), 
    .pc_control(pc_control)
  );

  ROB #(32) rob(
    .global_signals(global_signals), 
    .issue1(instr_issues[0]), .issue2(instr_issues[1]),
    .data_bus1(data_buses[0]), .data_bus2(data_buses[1]),
    .pc_control(pc_control)
    );
  
  Dispatch dispatch(
    .global_signals(global_signals), 
    .pc_control(pc_control),
    .instr_cache(instr_cache_bus),
    .data_bus1(data_buses[0]), .data_bus2(data_buses[1]),
    .query1(queries[0]), .query2(queries[1]),
    .issue1(instr_issues[0]), .issue2(instr_issues[1]),
    .stations_capacity({branchc_free_space, aluc_free_space, lsc_free_space})
    );

  Registers registers(
    .global_signals(global_signals), 
    .query1(queries[0]), .query2(queries[1]),
    .data_bus1(data_buses[0]), .data_bus2(data_buses[1]),
    .debug(debug)
    );

  ALUCombo #(16) alu_combo(
    .global_signals(global_signals),
    .issue1(instr_issues[0]), .issue2(instr_issues[1]),
    .data_bus1(data_buses[0]), .data_bus2(data_buses[1]),
    .free_space(aluc_free_space)
    );

  BranchCombo #(1) branch_combo(
    .global_signals(global_signals),
    .issue1(instr_issues[0]), .issue2(instr_issues[1]),
    .data_bus1(data_buses[0]), .data_bus2(data_buses[1]),
    .free_space(branchc_free_space)
    );

  LoadStoreCombo #(4) load_store_combo(
    .global_signals(global_signals),
    .issue1(instr_issues[0]), .issue2(instr_issues[1]),
    .data_bus1(data_buses[0]), .data_bus2(data_buses[1]),
    .free_space(lsc_free_space),
    .data_cache(data_cache_bus)
  );

  DataCache #(data_cache_size) data_cache(
    .global_signals(global_signals),
    .data_bus1(data_buses[0]), .data_bus2(data_buses[1]),
    .data_ls(data_cache_bus),
    .data_mem(data_bus)
  );

// Logic
  assign data_buses[0].data = 32'hzzzzzzzz; 
  assign data_buses[0].address = 32'hzzzzzzzz;
  assign data_buses[0].jump_address = 32'hzzzzzzzz;
  assign data_buses[0].arn = 6'hzz;
  assign data_buses[0].rrn = 6'hzz;
  assign data_buses[0].select = 5'hzz;
  assign data_buses[0].we = 1'hz;

  assign data_buses[1].data = 32'hzzzzzzzz; 
  assign data_buses[1].address = 32'hzzzzzzzz;
  assign data_buses[1].jump_address = 32'hzzzzzzzz;
  assign data_buses[1].arn = 6'hzz;
  assign data_buses[1].rrn = 6'hzz;
  assign data_buses[1].select = 5'hzz;
  assign data_buses[1].we = 1'hz;


  assign instr_cache_bus.address = pc_control.address;
endmodule