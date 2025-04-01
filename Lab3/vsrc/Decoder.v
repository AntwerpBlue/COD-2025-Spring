//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/31 12:59:14
// Design Name: 
// Module Name: Decoder
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

module DECODE (
    input [31:0] inst,
    output reg [4:0] alu_op,
    output reg [31:0] imm,
    output reg [4:0] rf_ra0,
    output reg [4:0] rf_ra1,
    output reg [4:0] rf_wa,
    output reg rf_we,
    output reg alu_src0_sel,
    output reg alu_src1_sel
);

    // 指令字段分解
    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];
    wire [6:0] funct7 = inst[31:25];
    wire [4:0] shamt = inst[24:20];

    // 立即数生成
    always @(*) begin
        case (opcode)
            // I-type (addi, slli, srli, srai, slti, sltiu, andi, ori, xori)
            7'b0010011: begin
                case (funct3)
                    3'b001, 3'b101: imm = {27'b0, shamt}; // 移位指令
                    default: imm = {{20{inst[31]}}, inst[31:20]}; // 其他I-type
                endcase
            end
            // S-type
            7'b0100011: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            // U-type (lui, auipc)
            7'b0110111, 7'b0010111: imm = {inst[31:12], 12'b0};
            // J-type
            7'b1101111: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            // R-type
            default: imm = 32'b0;
        endcase
    end

    // ALU操作码生成（直接使用数值）
    always @(*) begin
        case (opcode)
            // R-type
            7'b0110011: begin
                case (funct3)
                    3'b000: alu_op = (funct7[5] ? 5'b00001 : 5'b00000); // ADD/SUB
                    3'b001: alu_op = 5'b00010; // SLL
                    3'b010: alu_op = 5'b00011; // SLT
                    3'b011: alu_op = 5'b00100; // SLTU
                    3'b100: alu_op = 5'b00101; // XOR
                    3'b110: alu_op = 5'b01000; // OR
                    3'b111: alu_op = 5'b01001; // AND
                    3'b101: alu_op = (funct7[5] ? 5'b00111 : 5'b00110); // SRA/SRL
                    default: alu_op = 5'b00000;
                endcase
            end
            // I-type
            7'b0010011: begin
                case (funct3)
                    3'b000: alu_op = 5'b00000; // ADDI
                    3'b010: alu_op = 5'b00011; // SLTI
                    3'b011: alu_op = 5'b00100; // SLTIU
                    3'b100: alu_op = 5'b00101; // XORI
                    3'b110: alu_op = 5'b01000; // ORI
                    3'b111: alu_op = 5'b01001; // ANDI
                    3'b001: alu_op = 5'b00010; // SLLI
                    3'b101: alu_op = (inst[30] ? 5'b00111 : 5'b00110); // SRAI/SRLI
                    default: alu_op = 5'b00000;
                endcase
            end
            // U-type
            7'b0110111: alu_op = 5'b01010; // LUI
            7'b0010111: alu_op = 5'b01011; // AUIPC
            // J-type
            7'b1101111: alu_op = 5'b01100; // JAL
            7'b1100111: alu_op = 5'b01101; // JALR
            default: alu_op = 5'b00000;
        endcase
    end

    // 寄存器文件控制
    always @(*) begin
        rf_ra0 = rs1;
        rf_ra1 = (opcode == 7'b0110011) ? rs2 : 5'b0; // 仅R-type需要rs2
        rf_wa = rd;
        
        // 写回使能
        case (opcode)
            7'b0110011,  // R-type
            7'b0010011,  // I-type
            7'b0110111,  // LUI
            7'b0010111,  // AUIPC
            7'b1101111,  // JAL
            7'b1100111:  // JALR
                rf_we = 1'b1;
            default: 
                rf_we = 1'b0;
        endcase
    end

    // ALU操作数选择
    always @(*) begin
        case (opcode)
            // R-type
            7'b0110011: begin
                alu_src0_sel = 1'b0; // 选择寄存器rs1
                alu_src1_sel = 1'b0; // 选择寄存器rs2
            end
            // I-type
            7'b0010011: begin
                alu_src0_sel = 1'b0; // 选择寄存器rs1
                alu_src1_sel = 1'b1; // 选择立即数
            end
            // U-type
            7'b0110111: begin  // LUI
                alu_src0_sel = 1'b1; // 选择0（通过ALU输入控制）
                alu_src1_sel = 1'b1; // 选择立即数
            end
            7'b0010111: begin  // AUIPC
                alu_src0_sel = 1'b1; // 选择PC
                alu_src1_sel = 1'b1; // 选择立即数
            end
            // J-type
            7'b1101111: begin  // JAL
                alu_src0_sel = 1'b1; // 选择PC
                alu_src1_sel = 1'b1; // 选择立即数
            end
            7'b1100111: begin  // JALR
                alu_src0_sel = 1'b0; // 选择寄存器rs1
                alu_src1_sel = 1'b1; // 选择立即数
            end
            default: begin
                alu_src0_sel = 1'b0;
                alu_src1_sel = 1'b0;
            end
        endcase
    end
endmodule