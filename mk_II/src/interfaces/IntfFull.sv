// Copyright (c) 2024 veznitom

`default_nettype none
interface IntfFull;
  wire alu, branch, load_store, mul_div, rob;

  modport Control(input alu, branch, load_store, mul_div, rob);
endinterface  //IntfFull
