module DECODE (
    input [31:0] inst,          // 32位指令输入
    
    // ALU控制信号
    output reg [4:0] alu_op,     // ALU操作码
    output reg alu_src0_sel,     // ALU源操作数0选择 (0:寄存器 1:PC)
    output reg alu_src1_sel,     // ALU源操作数1选择 (0:寄存器 1:立即数)
    
    // 寄存器文件控制信号
    output reg [4:0] rf_ra0,     // 寄存器读地址0
    output reg [4:0] rf_ra1,     // 寄存器读地址1
    output reg [4:0] rf_wa,      // 寄存器写地址
    output reg rf_we,            // 寄存器写使能
    
    // 立即数输出
    output reg [31:0] imm        // 符号扩展后的立即数
);

    // 指令字段
    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];

    always @(*) begin
        // 默认值
        alu_op = 5'b0;
        alu_src0_sel = 1'b0;  // 默认选择寄存器
        alu_src1_sel = 1'b0;   // 默认选择寄存器
        rf_ra0 = 5'b0;
        rf_ra1 = 5'b0;
        rf_wa = 5'b0;
        rf_we = 1'b0;
        imm = 32'b0;
        
        case (opcode)
            // R-type指令 (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
            7'b0110011: begin
                rf_ra0 = rs1;
                rf_ra1 = rs2;
                rf_wa = rd;
                rf_we = 1'b1;
                alu_src1_sel = 1'b0;  // 使用寄存器值
                
                case (funct3)
                    3'b000: alu_op = (funct7 == 7'b0100000) ? 5'b00001 : 5'b00000; // SUB : ADD
                    3'b001: alu_op = 5'b00101; // SLL
                    3'b010: alu_op = 5'b01000; // SLT
                    3'b011: alu_op = 5'b01001; // SLTU
                    3'b100: alu_op = 5'b00100; // XOR
                    3'b101: alu_op = (funct7 == 7'b0100000) ? 5'b00111 : 5'b00110; // SRA : SRL
                    3'b110: alu_op = 5'b00011; // OR
                    3'b111: alu_op = 5'b00010; // AND
                endcase
            end
            
            // I-type指令 (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
            7'b0010011: begin
                rf_ra0 = rs1;
                rf_wa = rd;
                rf_we = 1'b1;
                alu_src1_sel = 1'b1;  // 使用立即数
                imm = {{20{inst[31]}}, inst[31:20]};  // 符号扩展
                
                case (funct3)
                    3'b000: alu_op = 5'b00000; // ADDI
                    3'b010: alu_op = 5'b01000; // SLTI
                    3'b011: alu_op = 5'b01001; // SLTIU
                    3'b100: alu_op = 5'b00100; // XORI
                    3'b110: alu_op = 5'b00011; // ORI
                    3'b111: alu_op = 5'b00010; // ANDI
                    3'b001: alu_op = 5'b00101; // SLLI
                    3'b101: alu_op = (funct7 == 7'b0100000) ? 5'b00111 : 5'b00110; // SRAI : SRLI
                endcase
            end
            
            // LUI
            7'b0110111: begin
                rf_wa = rd;
                rf_we = 1'b1;
                alu_src1_sel = 1'b1;  // 使用立即数
                alu_op = 5'b01010;    // LUI
                imm = {inst[31:12], 12'b0};  // U-type立即数
            end
            
            // AUIPC
            7'b0010111: begin
                rf_wa = rd;
                rf_we = 1'b1;
                alu_src0_sel = 1'b1;  // 使用PC
                alu_src1_sel = 1'b1;  // 使用立即数
                alu_op = 5'b01011;    // AUIPC
                imm = {inst[31:12], 12'b0};  // U-type立即数
            end
            default: begin
                rf_ra0 = 5'b0;
                rf_ra1 = 5'b0;
                rf_wa = 5'b0;
                rf_we = 1'b0;
                alu_op = 5'b0;
                alu_src0_sel = 1'b0;
                alu_src1_sel = 1'b0;
                imm = 32'b0;
            end
        endcase
    end
endmodule