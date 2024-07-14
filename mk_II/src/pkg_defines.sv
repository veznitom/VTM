package pkg_defines;
  typedef enum bit [7:0] {
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

  typedef enum bit [2:0] {
    NN,
    NJ,
    JN,
    JJ,
    ERROR
  } jmp_relation_e;

  typedef enum bit [1:0] {
    VALID,
    INVALID,
    MODIFIED
  } cache_state_e;

  typedef enum bit [2:0] {
    BR,
    AL,
    LS,
    MD,
    RB,
    XX
  } instr_type_e;

  typedef struct packed {bit writes, jumps, uses_imm, tag, mem;} flag_vector_t;

  typedef struct packed {bit [5:0] rd, rs_1, rs_2, rn;} registers_t;
endpackage
