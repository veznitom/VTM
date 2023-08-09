interface rob_queue_if;
  logic [31:0] result, address, jmp_address;
  record_status_e status;
  registers_t regs;
  flag_vector_t flags;
endinterface
