// instruction memory size: 2 ^ INSTR_MEM_DEPTH * 4B
`define INSTR_MEM_START         32'H00400000
`define INSTR_MEM_DEPTH         16
`define INSTR_MEM_INI           "mem/instr.ini"

// data memory size: 2 ^ DATA_MEM_DEPTH * 4B
`define DATA_MEM_START          32'H10010000
`define DATA_MEM_DEPTH          16
`define DATA_MEM_INI            "mem/data.ini"

// core type
`define SINGLE_CYCLE            8'H0
`define PIPELINE                8'H1
`define CORE_TYPE               `SINGLE_CYCLE
