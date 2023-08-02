interface register_query_if;
  src_dest_t inputs, outputs;
  logic rename, tag;
  modport resolv(input outputs, output inputs, rename, tag);
  modport regs(input inputs, rename, tag, output outputs);
endinterface
