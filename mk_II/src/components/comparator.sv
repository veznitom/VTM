/*  Checks if common data bus and issued values clash if so then choose the cdb data as they are always newer than register data.
    Should contain only combinational logic (it's basicvaly a switch).*/

module comparator (
    instr_issue_if.cmp issue_in, issue_out,
    register_values_if.cmp reg_val,
    common_data_bus_if cdb
);
    TODO();
endmodule
