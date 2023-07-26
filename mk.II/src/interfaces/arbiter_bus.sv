interface arbiter_bus_if #();
  logic
      rob_request,
      rob_enable,
      alu_request,
      alu_ebable,
      branch_request,
      branch_enable,
      load_store_request,
      load_store_enable,
      mult_div_request,
      mult_div_enbale;

  modport rob(input rob_enable, output rob_request);
  modport alu(input alu_ebable, output alu_request);
  modport branch(input branch_enable, output branch_request);
  modport load_store(input load_store_enable, output load_store_request);
  modport mult_div(input mult_div_enbale, output mult_div_request);
endinterface
