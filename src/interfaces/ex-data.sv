import CustomTypes::*;

interface DataMemoryBus #(parameter width = 32)();
  wire [width-1:0] data;
  logic [31:0] address;
  logic read, write, ready, done;
  WordSelect ws;

  modport mmu (
    input data, address, read, write, ws,
    output ready, done
  );

  modport cache (
    input ready, done,
    inout data,
    output address, read, write, ws
  );
endinterface


interface DataCacheBus;
  wire [31:0] data;
  logic [31:0] address, instr;
  logic read, write, tag, hit;
  WordSelect ws;

  modport combo (
    input hit,
    inout data,
    output address, instr, read, write, tag, ws
  );

  modport cache (
    input address, instr, read, write, tag, ws,
    inout data,
    output hit
  );
endinterface

interface InstrMemoryBus #(parameter width = 64)();
  logic [width-1:0] data;
  logic [31:0] address;
  logic read, ready;

  modport cache (
    input ready, data,
    output address, read
  );

  modport mmu (
    input address, read,
    output ready, data
  );
endinterface

interface InstrCacheBus;
  logic [31:0] instr1, instr2, address;
  logic read, hit;

  modport dispatch (
    input instr1, instr2, hit,
    output read
  );

  modport cache (
    input address, read,
    output instr1, instr2, hit
  );
endinterface

interface MemoryBus#(parameter width = 64)();
  wire [width-1:0] data;
  logic [31:0] address;
  logic read, write, ready, done, source;
  WordSelect ws;

  modport ram (
    input address, read, write, source, ws,
    inout data,
    output ready, done
  );

  modport cpu (
    input ready, done,
    inout data,
    output address, read, write, source, ws
  );
endinterface