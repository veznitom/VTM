import global_variables::XLEN;
import structures::*;

interface memory_bus_if #(
    parameter int BUS_WIDTH_BYTES = 256,
    parameter int BUS_WIDTH_BITS = BUS_WIDTH_BYTES * 8,
    parameter int BUS_BIT_LOG = $clog2(BUS_WIDTH_BYTES)
) ();
  logic [(BUS_WIDTH_BYTES*8)-1:0] data;
  logic [XLEN-1:0] address;
  logic read, write, ready, done;

  modport cache(input ready, done, inout data, output address, read, write);
  modport mmu(input read, write, inout data, address, output ready, done);
  modport ram(input address, read, write, inout data, output ready, done);
  modport cpu(input ready, done, inout data, output address, read, write);

  task automatic clear();
    data <= {XLEN{1'h0}};
    address <= {XLEN{1'h0}};
    {read, write, ready, done} <= {1'h0, 1'h0, 1'h0, 1'h0};
  endtask
endinterface
