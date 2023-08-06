interface reg_query_bus_if;
  src_dest_t inputs, outputs;
  logic rename, tag;

  modport resolver(input outputs, output inputs, rename, tag);
  modport reg_file(input inputs, rename, tag, output outputs);
endinterface
