// Copyright (c) 2024 veznitom

`default_nettype none
package pkg_defines;
    typedef enum logic [7:0] {
        // Custom value
        UNKNOWN,
        // Memory instructions
        LB,
        LH,
        LW,
        LBU,
        LHU,
        SB,
        SH,
        SW,
        // Bracnh and jump insructions
        BEQ,
        BNE,
        BLT,
        BGE,
        BLTU,
        BGEU,
        JAL,
        JALR,
        // Arithmetic and logic instructions
        ADDI,
        SLTI,
        SLTIU,
        XORI,
        ORI,
        ANDI,
        SLLI,
        SRLI,
        SRAI,
        ADD,
        SUB,
        SLL,
        SLT,
        SLTU,
        XOR,
        SRL,
        SRA,
        OR,
        AND,
        LUI,
        AUIPC,
        // Multiplication and division instructions
        MUL,
        MULH,
        MULHSU,
        MULHU,
        DIV,
        DIVU,
        REM,
        REMU,
        // Zircsr instructions
        CSRRW,
        CSRRS,
        CSRRC,
        CSRRWI,
        CSRRSI,
        CSRRCI,
        // System instructions
        ECALL,
        EBREAK,
        FENCE
    } instr_name_e;

    typedef enum logic [2:0] {
        NN,
        NJ,
        JN,
        JJ,
        ERROR
    } jmp_relation_e;

    typedef enum logic [2:0] {
        BR,
        AL,
        LS,
        MD,
        RB,
        XX
    } instr_type_e;

    typedef struct packed {logic writes, jumps, uses_imm, tag, mem;} flag_vector_t;

    typedef struct packed {logic [5:0] rd, rs_1, rs_2, rn;} registers_t;

    localparam bit [31:0] NOP_INSTR = 32'h00000013;
endpackage
