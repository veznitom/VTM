import structures::registers_t;

interface reg_query_bus_if;
  registers_t inputs, outputs;
  logic rename, tag;

  modport resolver(input outputs, output inputs, rename, tag, import clear);
  modport reg_file(input inputs, rename, tag, output outputs);

  task automatic clear();
    inputs <= '{0, 0, 0, 0};
    outputs <= '{0, 0, 0, 0};
    rename <= 0;
    tag <= 0;
  endtask
endinterface
