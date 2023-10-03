import global_variables::XLEN;

interface common_data_bus_if;
  logic [XLEN-1:0] result, address, jmp_address;
  logic [5:0] arn, rrn;
  logic [7:0] select;
  logic reg_write, cache_write;

  modport combo(input arn, inout result, address, jmp_address, select, output rrn, reg_write);
  modport rob(inout result, address, jmp_address, arn, rrn, select, output reg_write, cache_write);
  modport reg_file(input result, address, arn, rrn, reg_write);
  modport cache(input result, address, cache_write);
  modport cmp(input result, arn, rrn);

  task automatic clear();
    result <= {XLEN{1'h0}};
    address <= {XLEN{1'h0}};
    jmp_address <= {XLEN{1'h0}};
    arn <= 6'h0;
    rrn <= 6'h0;
    reg_write <= 1'h0;
    cache_write <= 1'h0;
  endtask  //automatic
endinterface
