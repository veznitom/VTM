interface register_query_if;
  logic [31:0] reg1_data, reg2_data;
  logic [5:0] ret_renamed, reg1_ren, reg2_ren;
  logic [4:0] reg1_num, reg2_num, reg3_num;
  logic reg1_valid, reg2_valid, get_renamed, tag;

  modport dispatch(
      input reg1_data, reg2_data, ret_renamed, reg1_ren, reg2_ren, reg1_valid, reg2_valid,
      output reg1_num, reg2_num, reg3_num, get_renamed, tag,
      import dd_clear, read
  );

  modport regs(
      input reg1_num, reg2_num, reg3_num, get_renamed, tag,
      output reg1_data, reg2_data, ret_renamed, reg1_ren, reg2_ren, reg1_valid, reg2_valid,
      import reg_clear, reg1_write, reg2_write
  );

  task automatic dd_clear();
    reg1_num = 5'hzz;
    reg2_num = 5'hzz;
    reg3_num = 5'hzz;
    get_renamed = 1'h0;
    tag = 1'h0;
  endtask

  task automatic reg_clear();
    ret_renamed = 6'hzz;

    reg1_data = 32'hzzzzzzzz;
    reg1_valid = 1'hz;
    reg1_ren = 6'hzz;

    reg2_data = 32'hzzzzzzzz;
    reg2_valid = 1'hz;
    reg2_ren = 6'hzz;
  endtask

  task automatic reg1_write(input logic [31:0] data, input logic valid, input logic [5:0] rrn);
    reg1_data  = data;
    reg1_valid = valid;
    reg1_ren   = rrn;
  endtask

  task automatic reg2_write(input logic [31:0] data, input logic valid, input logic [5:0] rrn);
    reg2_data  = data;
    reg2_valid = valid;
    reg2_ren   = rrn;
  endtask

  task automatic read(input logic [4:0] reg1, input logic [4:0] reg2, input logic [4:0] reg3,
                      input logic get_ren, input logic _tag);
    reg1_num = reg1;
    reg2_num = reg2;
    reg3_num = reg3;
    get_renamed = get_ren;
    tag = _tag;
  endtask
endinterface

interface instr_issue_if;
  logic [31:0] data1, data2, address, imm;
  logic [5:0] src1, src2, arn, rrn;
  logic valid1, valid2, jump, tag;

  PID pid;
  Station stat_select;

  modport dispatch(
      output data1, data2, address, imm,
      output src1, src2, arn, rrn, valid1, valid2, jump, tag, stat_select, pid,
      import clear, write
  );

  modport combo(
      input data1, data2, address, imm,
      input src1, src2, arn, rrn, valid1, valid2, jump, tag, stat_select, pid
  );

  modport rob(input address, arn, rrn, jump, tag, stat_select);

  task automatic write(input logic [31:0] _data1, input logic [31:0] _data2,
                       input logic [31:0] _address, input logic [31:0] _imm, input PID _pid,
                       input logic [5:0] _src1, input logic [5:0] _src2, input logic [5:0] _arn,
                       input logic [5:0] _rrn, input Station _stat_select, input logic _jump,
                       input logic _tag, input logic _valid1, input logic _valid2);
    data1 <= _data1;
    data2 <= _data2;
    address <= _address;
    imm <= _imm;
    pid <= _pid;
    src1 <= _src1;
    src2 <= _src2;
    arn <= _arn;
    rrn <= _rrn;
    stat_select <= _stat_select;
    jump <= _jump;
    tag <= _tag;
    valid1 <= _valid1;
    valid2 <= _valid2;
  endtask

  task automatic clear();
    begin
      data1 <= 32'hzzzzzzzz;
      data2 <= 32'hzzzzzzzz;
      address <= 32'hzzzzzzzz;
      imm <= 32'hzzzzzzzz;
      pid <= UNKNOWN;
      src1 <= 6'hzz;
      src2 <= 6'hzz;
      arn <= 6'hzz;
      rrn <= 6'hzz;
      stat_select <= NONE;
      jump <= 1'hz;
      tag <= 1'hz;
      valid1 <= 1'hz;
      valid2 <= 1'hz;
    end
  endtask
endinterface

interface common_data_bus_if;
  wire [31:0] res, addr, jres;
  wire [5:0] ard, rrd;
  wire [3:0] sel;
  wire we;

  modport combo(input arn, inout data, address, jump_address, select, output rrn, we);

  modport rob(inout data, address, jump_address, arn, rrn, select, output we);

  modport regs(input data, arn, rrn, we, address);

  modport dispatch(input data, arn, rrn);

  modport cache(input address);

endinterface

interface staation_unit_if;
  logic [31:0] rs1, rs2, addr, imm;
  logic [5:0] rd;
  instr_name_e instr;

  modport station(output data1, data2, address, imm, rrn, tag, pid, import clear);

  modport exec(input data1, data2, address, imm, rrn, tag, pid);

  task automatic clear();
    data1 <= 32'hzzzzzzzz;
    data2 <= 32'hzzzzzzzz;
    address <= 32'hzzzzzzzz;
    imm <= 32'hzzzzzzzz;
    pid <= UNKNOWN;
    rrn <= 6'hzz;
    tag <= 1'hz;
  endtask

  task automatic write(input logic [31:0] _data1, input logic [31:0] _data2,
                       input logic [31:0] _address, input logic [31:0] _imm, PID _pid,
                       logic [5:0] _rrn, logic _tag);
    data1 <= _data1;
    data2 <= _data2;
    address <= _address;
    imm <= _imm;
    pid <= _pid;
    rrn <= _rrn;
    tag <= _tag;
  endtask

endinterface

