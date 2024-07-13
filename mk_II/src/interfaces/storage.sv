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

interface reg_val_bus_if;
  logic [31:0] data_1, data_2;
  logic [5:0] src_1, src_2;
  logic valid_1, valid_2;

  modport cmp(input data_1, data_2, valid_1, valid_2, output src_1, src_2);
  modport reg_file(input src_1, src_2, output data_1, data_2, valid_1, valid_2);
endinterface