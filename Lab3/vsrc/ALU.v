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

`define ADD     5'b00000     // 加法
`define SUB     5'b00001     // 减法
`define SLL     5'b00010     // 逻辑左移
`define SLT     5'b00011     // 有符号比较
`define SLTU    5'b00100     // 无符号比较
`define XOR     5'b00101     // 异或
`define SRL     5'b00110     // 逻辑右移
`define SRA     5'b00111     // 算术右移
`define OR      5'b01000     // 或
`define AND     5'b01001     // 与
`define LUI     5'b01010     // 高位立即数加载
`define AUIPC   5'b01011     // PC加立即数
`define JAL     5'b01100     // 跳转并链接（仅计算返回地址）
`define JALR    5'b01101     // 寄存器跳转并链接（仅计算返回地址）

module ALU (
    input       [31:0] alu_src0,    // 操作数A
    input       [31:0] alu_src1,    // 操作数B
    input       [4:0]  alu_op,      // 操作码
    
    output reg  [31:0] alu_res      // 运算结果
);

    // ALU核心逻辑（组合逻辑）
    always @(*) begin
        case (alu_op)
            // 算术运算
            `ADD:    alu_res = alu_src0 + alu_src1;
            `SUB:    alu_res = alu_src0 - alu_src1;
            
            // 移位运算
            `SLL:    alu_res = alu_src0 << alu_src1[4:0];
            `SRL:    alu_res = alu_src0 >> alu_src1[4:0];
            `SRA:    alu_res = $signed(alu_src0) >>> alu_src1[4:0];
            
            // 比较运算
            `SLT:    alu_res = ($signed(alu_src0) < $signed(alu_src1)) ? 32'd1 : 32'd0;
            `SLTU:   alu_res = (alu_src0 < alu_src1) ? 32'd1 : 32'd0;
            
            // 逻辑运算
            `AND:    alu_res = alu_src0 & alu_src1;
            `OR:     alu_res = alu_src0 | alu_src1;
            `XOR:    alu_res = alu_src0 ^ alu_src1;
            
            // 特殊指令
            `LUI:    alu_res = alu_src1;            // 直接使用立即数
            `AUIPC:  alu_res = alu_src0 + alu_src1; // PC + 立即数
            `JAL:    alu_res = alu_src0 + 32'd4;    // 返回地址(PC+4)
            `JALR:   alu_res = alu_src0 + 32'd4;    // 返回地址(PC+4)
            
            // 默认情况
            default: alu_res = 32'h0;
        endcase
    end
endmodule