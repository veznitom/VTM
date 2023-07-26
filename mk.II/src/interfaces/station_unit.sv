interface station_unit_if #(
    parameterint XLEN = 32
) ();
  logic [XLEN-1:0] data_1, data_2, addrres, immediate;
  logic [5:0] rrn;
  instr_name_e instr_name;

  modport station(output data_1, data_2, address, immediate, rrn, tag, instr_name, import clear);

  modport exec(input data_1, data_2, address, immediate, rrn, tag, instr_name);

  task automatic clear();
    data_1 <= {XLEN{1'hz}};
    data_2 <= {XLEN{1'hz}};
    address <= {XLEN{1'hz}};
    immediate <= {XLEN{1'hz}};
    instr_name <= UNKNOWN;
    rrn <= 6'hzz;
  endtask

  task automatic write;
    input logic [31:0] task_data_1, task_data_2, task_address, task_imm;
    input instr_name_e task_instr_name;
    input logic [5:0] task_rrn;
    begin
      data_1 <= task_data_1;
      data_2 <= taks_data_2;
      address <= task_address;
      immediate <= task_imm;
      instr_name <= task_instr_name;
      rrn <= task_rrn;
    end
  endtask

endinterface
