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

module ALU (
    input [31:0]  alu_src0,    // 操作数1 (寄存器值或PC)
    input [31:0]  alu_src1,    // 操作数2 (寄存器值或立即数)
    input [4:0]   alu_op,      // 操作码
    output reg [31:0] alu_result
);

    always @(*) begin
        case (alu_op)
            5'b00000: alu_result = alu_src0 + alu_src1;        // ADD
            5'b00001: alu_result = alu_src0 - alu_src1;        // SUB
            5'b00010: alu_result = alu_src0 & alu_src1;        // AND
            5'b00011: alu_result = alu_src0 | alu_src1;        // OR
            5'b00100: alu_result = alu_src0 ^ alu_src1;        // XOR
            5'b00101: alu_result = alu_src0 << alu_src1[4:0];  // SLL
            5'b00110: alu_result = alu_src0 >> alu_src1[4:0];   // SRL
            5'b00111: alu_result = $signed(alu_src0) >>> alu_src1[4:0]; // SRA
            5'b01000: alu_result = ($signed(alu_src0) < $signed(alu_src1)) ? 32'd1 : 32'd0; // SLT
            5'b01001: alu_result = (alu_src0 < alu_src1) ? 32'd1 : 32'd0; // SLTU
            5'b01010: alu_result = alu_src1;                    // LUI (直接使用立即数)
            5'b01011: alu_result = alu_src0 + alu_src1;        // AUIPC (PC + imm)
            default: alu_result = 32'd0;
        endcase
    end
endmodule