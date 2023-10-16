interface instr_proc_if;
  logic issuer_stop, resolver_stop, stop;

  assign stop = issuer_stop | resolver_stop | 1'h0;

  modport loader(input stop);
  modport decoder(input stop);
  modport renamer(input stop);
  modport resolver(input issuer_stop, output resolver_stop);
  modport issuer(output issuer_stop);
endinterface
