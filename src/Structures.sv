package Structures;

  typedef enum reg [7:0] {
    LB,
    LH,
    LW,
    LBU,
    LHU,
    SB,
    SH,
    SW,
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU,
    JAL,
    JALR,
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
    ECALL,
    EBREAK,
    FENCE,
    UNKNOWN
  } instr_name_e;

  typedef enum reg [2:0] {
    LOAD,
    PREPARE,
    RENAME,
    FETCH,
    ISSUE,
    STALL,
    BREAK
  } dispatch_state_e;

  typedef enum reg [2:0] {
    NJ1NJ2,
    NJ1J2,
    J1NJ2,
    J1J2,
    ERROR
  } instr_types_e;

  typedef enum reg [1:0] {
    BYTE,
    HALFWORD,
    WORD,
    DOUBLEWORD,
    EMPTY
  } data_width_e;

  typedef enum reg [1:0] {
    VALID,
    INVALID,
    MODIFIED
  } cache_state_e;

  typedef enum reg [1:0] {
    IDLE,
    READ,
    WRITE
  } mmu_state_e;

  typedef enum {
    BR,
    AL,
    LS,
    MD,
    XX
  } instr_type_e;

  typedef struct packed {
    reg [31:0] data1, data2, address, imm;
    reg [5:0] src1, src2, rrn;
    reg valid1, valid2, tag, skip;
    instr_name_e instr_name;
  } station_record_t;

  typedef struct packed {
    reg [31:0] value;
    reg [5:0] rrn;
    reg valid, tag;
  } register_t;

  typedef struct packed {
    reg [31:0] data, address, instr;
    cache_state_e state;
    word_select_e ws;
  } data_cache_record_t;

  typedef struct packed {reg [31:0] address, instr;} instr_cache_record_t;

  typedef struct packed {
    reg [31:0] data, address, jump_address;
    reg [5:0] arn, rrn;
    reg finished, jumps, tag, ignore;
  } rob_record_t;
endpackage



