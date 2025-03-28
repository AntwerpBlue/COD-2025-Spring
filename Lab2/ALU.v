`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 16:16:17
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define ADD                 5'B00000    
`define SUB                 5'B00010   
`define SLT                 5'B00100
`define SLTU                5'B00101
`define AND                 5'B01001
`define OR                  5'B01010
`define XOR                 5'B01011
`define SLL                 5'B01110   
`define SRL                 5'B01111    
`define SRA                 5'B10000  
`define SRC0                5'B10001
`define SRC1                5'B10010

module ALU (
    input       [31:0] alu_src0,    // 操作数 A
    input       [31:0] alu_src1,    // 操作数 B
    input       [4:0]  alu_op,

    output reg  [31:0] alu_res      // 运算结果
);

    // ALU 核心逻辑（组合逻辑）
    always @(*) begin
        case (alu_op)
            `ADD:   alu_res = alu_src0 + alu_src1;                // 加法
            `SUB:   alu_res = alu_src0 - alu_src1;                // 减法
            `SLT:   alu_res = ($signed(alu_src0) < $signed(alu_src1)) ? 32'd1 : 32'd0; // 有符号比较
            `SLTU:  alu_res = (alu_src0 < alu_src1) ? 32'd1 : 32'd0;                  // 无符号比较
            `AND:   alu_res = alu_src0 & alu_src1;                // 按位与
            `OR:    alu_res = alu_src0 | alu_src1;                // 按位或
            `XOR:   alu_res = alu_src0 ^ alu_src1;                // 按位异或
            `SLL:   alu_res = alu_src0 << alu_src1[4:0];          // 逻辑左移（低5位有效）
            `SRL:   alu_res = alu_src0 >> alu_src1[4:0];          // 逻辑右移
            `SRA:   alu_res = $signed(alu_src0) >>> alu_src1[4:0]; // 算术右移（符号扩展）
            `SRC0:  alu_res = alu_src0;                           // 直通操作数A
            `SRC1:  alu_res = alu_src1;                           // 直通操作数B
            default:alu_res = 32'H0;                              // 默认输出0（防锁存器）
        endcase
    end

endmodule