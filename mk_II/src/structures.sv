package structures;

  typedef enum logic [7:0] {
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
    FENCE,
    // Custom value
    UNKNOWN
  } instr_name_e;

  typedef enum logic [2:0] {
    NJ1NJ2,
    NJ1J2,
    J1NJ2,
    J1J2,
    ERROR
  } jmp_relation_e;

  typedef enum logic [1:0] {
    VALID,
    INVALID,
    MODIFIED
  } cache_state_e;

  typedef enum logic [1:0] {
    IDLE,
    READ,
    WRITE
  } mmu_state_e;

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
endpackage



