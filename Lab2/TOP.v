`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 17:04:57
// Design Name: 
// Module Name: TOP
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


module TOP (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            enable,
    input                   [ 4 : 0]            in,
    input                   [ 1 : 0]            ctrl,

    output                  [ 3 : 0]            seg_data,
    output                  [ 2 : 0]            seg_an
);

    wire        res_en;     // 结果寄存器使能
    wire        src0_en;    // src0 寄存器使能
    wire        src1_en;    // src1 寄存器使能
    wire        op_en;      // 操作码寄存器使能

    reg  [31:0] alu_src0;   // 操作数0（符号扩展后）
    reg  [31:0] alu_src1;   // 操作数1（符号扩展后）
    reg  [4:0]  alu_op;     // ALU 操作码
    wire [31:0] alu_res;    // ALU 计算结果
    reg  [31:0] alu_res_reg;// 结果寄存器

    // 符号扩展：5-bit 有符号数 -> 32-bit
    wire [31:0] sign_ext_in = {{27{in[4]}}, in};

    //------------------------------------------
    // 控制信号译码（ctrl -> 寄存器使能）
    //------------------------------------------
    assign res_en  = (ctrl == 2'b11) & enable;  // 更新显示数据
    assign src0_en = (ctrl == 2'b01) & enable;  // 更新 src0
    assign src1_en = (ctrl == 2'b10) & enable;  // 更新 src1
    assign op_en   = (ctrl == 2'b00) & enable;  // 更新操作码

    //------------------------------------------
    // 寄存器写入逻辑（同步复位，上升沿触发）
    //------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_src0   <= 32'b0;
            alu_src1   <= 32'b0;
            alu_op     <= 5'b0;
            alu_res_reg <= 32'b0;
        end else begin
            if (src0_en) alu_src0 <= sign_ext_in;  // 写入 src0
            if (src1_en) alu_src1 <= sign_ext_in;  // 写入 src1
            if (op_en)   alu_op   <= in;           // 写入操作码
            if (res_en)  alu_res_reg <= alu_res;   // 锁存 ALU 结果
        end
    end

    //------------------------------------------
    // 模块实例化
    //------------------------------------------
    // ALU 实例化
    ALU alu (
        .alu_src0(alu_src0),
        .alu_src1(alu_src1),
        .alu_op(alu_op),
        .alu_res(alu_res)
    );

    // 数码管显示模块实例化（显示 alu_res_reg）
    Segment seg (
        .clk(clk),
        .rst(rst),
        .output_data(alu_res_reg),
        .seg_data(seg_data),
        .seg_an(seg_an)
    );



endmodule