// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ReservationStation #(
    parameter int          SIZE_BITS  = 4,
    parameter instr_type_e INSTR_TYPE = XX
) (
    IntfCSB.tag         cs,
    IntfIssue.Combo     issue[2],
    IntfCDB.Combo       data [2],
    IntfExtFeed.Station feed,

    input  wire       i_next,
    output reg  [5:0] o_rrn,
    output wire       o_full
);
    // ------------------------------- Structures -------------------------------
    typedef struct packed {
        bit [31:0]   data_1,     data_2;
        bit [31:0]   address,    immediate;
        bit [5:0]    src_1,      src_2,     rrn;
        instr_name_e instr_name;
        bit          valid_1,    valid_2,   tag, skip;
    } station_record_t;

    localparam station_record_t EMPTY_RECORD = {
        {32{1'h0}},
        {32{1'h0}},
        {32{1'h0}},
        {32{1'h0}},
        6'h00,
        6'h00,
        6'h00,
        UNKNOWN,
        1'h1,
        1'h1,
        1'h0,
        1'h0
    };

    // ------------------------------- Functions -------------------------------
    function automatic bit match_data(input logic [5:0] src, input logic valid,
                                      input logic [5:0] arn,
                                      input logic [5:0] rrn);
        return ((arn != 0 && arn == src) || (rrn != 0 && rrn == src)) && !valid;
    endfunction

    function automatic bit issue_to_record();
        return issue[0].address[0];
    endfunction
    // ------------------------------- Wires -------------------------------
    station_record_t records[2**SIZE_BITS];

    logic [SIZE_BITS-1:0] read_index, write_index;
    logic empty, full;

    logic [31:0] data_1[2], data_2[2];
    logic valid_1[2], valid_2[2];

    // ------------------------------- Behaviour -------------------------------
    assign o_full = full;

    always_comb begin : data_select
        // data_1 ------------------------------ issue[0] x (data[0] || data[1])
        if (match_data(
                issue[0].regs.rs_1, issue[0].valid_1, data[0].arn, data[0].rrn
            )) begin
            data_1[0]  = data[0].result;
            valid_1[0] = 1'h1;
        end else if (match_data(
                issue[0].regs.rs_1, issue[0].valid_1, data[1].arn, data[1].rrn
            )) begin
            data_1[0]  = data[1].result;
            valid_1[0] = 1'h1;
        end else begin
            data_1[0]  = issue[0].data_1;
            valid_1[0] = issue[0].valid_1;
        end
        // data_2 ------------------------------ issue[0] x (data[0] || data[1])
        if (match_data(
                issue[0].regs.rs_2, issue[0].valid_2, data[0].arn, data[0].rrn
            )) begin
            data_2[0]  = data[0].result;
            valid_2[0] = 1'h1;
        end else if (match_data(
                issue[0].regs.rs_2, issue[0].valid_2, data[1].arn, data[1].rrn
            )) begin
            data_2[0]  = data[1].result;
            valid_2[0] = 1'h1;
        end else begin
            data_2[0]  = issue[0].data_2;
            valid_2[0] = issue[0].valid_2;
        end

        // data_1 ------------------------------ issue[1] x (data[0] || data[1])
        if (match_data(
                issue[1].regs.rs_1, issue[1].valid_1, data[0].arn, data[0].rrn
            )) begin
            data_1[1]  = data[0].result;
            valid_1[1] = 1'h1;
        end else if (match_data(
                issue[1].regs.rs_1, issue[1].valid_1, data[1].arn, data[1].rrn
            )) begin
            data_1[1]  = data[1].result;
            valid_1[1] = 1'h1;
        end else begin
            data_1[1]  = issue[1].data_1;
            valid_1[1] = issue[1].valid_1;
        end
        // data_2 ------------------------------ issue[1] x (data[0] || data[1])
        if (match_data(
                issue[1].regs.rs_2, issue[1].valid_2, data[0].arn, data[0].rrn
            )) begin
            data_2[1]  = data[0].result;
            valid_2[1] = 1'h1;
        end else if (match_data(
                issue[1].regs.rs_2, issue[1].valid_2, data[1].arn, data[1].rrn
            )) begin
            data_2[1]  = data[1].result;
            valid_2[1] = 1'h1;
        end else begin
            data_2[1]  = issue[1].data_2;
            valid_2[1] = issue[1].valid_2;
        end
    end

    always_ff @(posedge cs.clock) begin : main_loop
        if (cs.reset) begin
            foreach (records[i]) begin
                records[i] <= EMPTY_RECORD;
            end
            read_index  <= '0;
            write_index <= '0;
        end else if (cs.delete_tag) begin
            foreach (records[i])
            if (!records[i].skip) records[i].skip <= records[i].tag;
        end else begin
            if (i_next && !empty) begin
                read_index <= read_index + 1;
            end
            if (i_next && records[read_index].valid_1 &&
                records[read_index].valid_2) begin
                records[read_index].skip <= '1;
            end
            // issue read
            if (issue[0].instr_type == INSTR_TYPE &&
                issue[1].instr_type == INSTR_TYPE) begin
                records[write_index] <= '{
                    data_1[0],
                    data_2[0],
                    issue[0].address,
                    issue[0].immediate,
                    issue[0].regs.rs_1,
                    issue[0].regs.rs_2,
                    issue[0].regs.rn,
                    issue[0].instr_name,
                    valid_1[0],
                    valid_2[0],
                    issue[0].flags.tag,
                    1'h0
                };
                records[write_index+1] <= '{
                    data_1[1],
                    data_2[1],
                    issue[1].address,
                    issue[1].immediate,
                    issue[1].regs.rs_1,
                    issue[1].regs.rs_2,
                    issue[1].regs.rn,
                    issue[1].instr_name,
                    valid_1[1],
                    valid_2[1],
                    issue[1].flags.tag,
                    1'h0
                };
            end else if (issue[0].instr_type == INSTR_TYPE) begin
                records[write_index] <= '{
                    data_1[0],
                    data_2[0],
                    issue[0].address,
                    issue[0].immediate,
                    issue[0].regs.rs_1,
                    issue[0].regs.rs_2,
                    issue[0].regs.rn,
                    issue[0].instr_name,
                    valid_1[0],
                    valid_2[0],
                    issue[0].flags.tag,
                    1'h0
                };
            end else if (issue[1].instr_type == INSTR_TYPE) begin
                records[write_index] <= '{
                    data_1[1],
                    data_2[1],
                    issue[1].address,
                    issue[1].immediate,
                    issue[1].regs.rs_1,
                    issue[1].regs.rs_2,
                    issue[1].regs.rn,
                    issue[1].instr_name,
                    valid_1[1],
                    valid_2[1],
                    issue[1].flags.tag,
                    1'h0
                };
            end
            write_index <= write_index +
                (issue[0].instr_type == INSTR_TYPE ? 1 : 0) +
                (issue[1].instr_type == INSTR_TYPE ? 1 : 0);
            // Records data update
            foreach (records[i]) begin
                // data_1 -------------------------------
                if (match_data(
                        records[i].src_1,
                        records[i].valid_1,
                        data[0].arn,
                        data[0].rrn
                    )) begin
                    records[i].data_1  <= data[0].result;
                    records[i].valid_1 <= 1'h1;
                end else if (match_data(
                        records[i].src_1,
                        records[i].valid_1,
                        data[1].arn,
                        data[1].rrn
                    )) begin
                    records[i].data_1  <= data[1].result;
                    records[i].valid_1 <= 1'h1;
                end
                // data_2 -------------------------------
                if (match_data(
                        records[i].src_2,
                        records[i].valid_2,
                        data[0].arn,
                        data[0].rrn
                    )) begin
                    records[i].data_2  <= data[0].result;
                    records[i].valid_2 <= 1'h1;
                end else if (match_data(
                        records[i].src_2,
                        records[i].valid_2,
                        data[1].arn,
                        data[1].rrn
                    )) begin
                    records[i].data_2  <= data[1].result;
                    records[i].valid_2 <= 1'h1;
                end
            end
        end
    end  // main_loop

    always_comb begin : feed_ex_unit
        if (cs.reset) begin
            feed.data_1     = '0;
            feed.data_2     = '0;
            feed.address    = '0;
            feed.immediate  = '0;
            o_rrn           = '0;
            feed.instr_name = UNKNOWN;
            feed.tag        = '0;
            o_rrn           = '0;
        end else begin
            if (records[read_index].valid_1 && records[read_index].valid_2 &&
                !records[read_index].skip) begin
                feed.data_1     = records[read_index].data_1;
                feed.data_2     = records[read_index].data_2;
                feed.address    = records[read_index].address;
                feed.immediate  = records[read_index].immediate;
                o_rrn           = records[read_index].rrn;
                feed.instr_name = records[read_index].instr_name;
                feed.tag        = records[read_index].tag;
            end else begin
                feed.data_1     = '0;
                feed.data_2     = '0;
                feed.address    = '0;
                feed.immediate  = '0;
                o_rrn           = '0;
                feed.instr_name = UNKNOWN;
                feed.tag        = '0;
                o_rrn           = '0;
                o_rrn           = '0;
            end
        end
    end

    always_comb begin
        if ((read_index == write_index || read_index == write_index + 1) &&
            records[read_index].instr_name != UNKNOWN &&
            !records[read_index].skip) begin
            full = 1'h1;
        end else full = 1'h0;

        if (read_index == write_index &&
            (records[read_index].instr_name == UNKNOWN ||
             records[read_index].valid_1 && records[read_index].valid_2 &&
             records[read_index].skip || !(records[read_index].valid_1 &&
                                           records[read_index].valid_2))) begin
            empty = 1'h1;
        end else empty = 1'h0;
    end
endmodule
