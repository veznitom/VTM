interface common_data_bus_if #(
    parameterint XLEN = 32
) ();
  logic [XLEN-1:0] result, address, jmp_address;
  logic [5:0] arn, rrn;
  logic [3:0] select;
  logic free, reg_file_we, data_cache_we;

  modport combo(input arn, inout result, address, jmp_address, select, output rrn, reg_file_we);

  modport rob(
      inout result, address, jmp_address, arn, rrn, select,
      output reg_file_we, data_cache_we
  );

  modport reg_file(input result, address, arn, rrn, reg_file_we);

  modport cache(input result, address, data_cache_we);

endinterface
