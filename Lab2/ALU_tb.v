`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 16:30:49
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb;
    // 输入信号
    reg  [31:0] alu_src0;
    reg  [31:0] alu_src1;
    reg  [4:0]  alu_op;
    
    // 输出信号
    wire [31:0] alu_res;
    
    // 实例化 ALU
    ALU uut (
        .alu_src0(alu_src0),
        .alu_src1(alu_src1),
        .alu_op(alu_op),
        .alu_res(alu_res)
    );
    
    // 测试主流程
    initial begin
        
        // 测试加法 (ADD)
        alu_op = `ADD;
        alu_src0 = 32'h0000_0003; alu_src1 = 32'h0000_0002;
        #10 $display("ADD: %h + %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试减法 (SUB)
        alu_op = `SUB;
        alu_src0 = 32'h0000_0005; alu_src1 = 32'h0000_0003;
        #10 $display("SUB: %h - %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试有符号比较 (SLT)
        alu_op = `SLT;
        alu_src0 = 32'hFFFF_FFFF; alu_src1 = 32'h0000_0000; // -1 < 0
        #10 $display("SLT: %h < %h (signed)? %h", alu_src0, alu_src1, alu_res);
        
        // 测试无符号比较 (SLTU)
        alu_op = `SLTU;
        alu_src0 = 32'hFFFF_FFFF; alu_src1 = 32'h0000_0001; // 0xFFFFFFFF > 0x1
        #10 $display("SLTU: %h < %h (unsigned)? %h", alu_src0, alu_src1, alu_res);
        
        // 测试按位与 (AND)
        alu_op = `AND;
        alu_src0 = 32'hF0F0_F0F0; alu_src1 = 32'h0F0F_0F0F;
        #10 $display("AND: %h & %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试按位或 (OR)
        alu_op = `OR;
        alu_src0 = 32'hF0F0_F0F0; alu_src1 = 32'h0F0F_0F0F;
        #10 $display("OR: %h | %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试按位异或 (XOR)
        alu_op = `XOR;
        alu_src0 = 32'hF0F0_F0F0; alu_src1 = 32'h0F0F_0F0F;
        #10 $display("XOR: %h ^ %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试逻辑左移 (SLL)
        alu_op = `SLL;
        alu_src0 = 32'h0000_000F; alu_src1 = 32'h0000_0004; // 左移 4 位
        #10 $display("SLL: %h << %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试逻辑右移 (SRL)
        alu_op = `SRL;
        alu_src0 = 32'hF000_0000; alu_src1 = 32'h0000_0004; // 右移 4 位
        #10 $display("SRL: %h >> %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试算术右移 (SRA)
        alu_op = `SRA;
        alu_src0 = 32'hF000_0000; alu_src1 = 32'h0000_0004; // 算术右移 4 位（符号扩展）
        #10 $display("SRA: %h >>> %h = %h", alu_src0, alu_src1, alu_res);
        
        // 测试直通 SRC0
        alu_op = `SRC0;
        alu_src0 = 32'h1234_5678; alu_src1 = 32'h0000_0000;
        #10 $display("SRC0: %h (src1 ignored) = %h", alu_src0, alu_res);
        
        // 测试直通 SRC1
        alu_op = `SRC1;
        alu_src0 = 32'h0000_0000; alu_src1 = 32'h8765_4321;
        #10 $display("SRC1: %h (src0 ignored) = %h", alu_src1, alu_res);
        
        // 测试边界情况（加法溢出）
        alu_op = `ADD;
        alu_src0 = 32'h7FFF_FFFF; alu_src1 = 32'h0000_0001; // 最大正数 +1
        #10 $display("ADD Overflow: %h + %h = %h", alu_src0, alu_src1, alu_res);
        
        // 结束仿真
        $display("\nALU Testbench Finished.");
        $finish;
    end
endmodule

