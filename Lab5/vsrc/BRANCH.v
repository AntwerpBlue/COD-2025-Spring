
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/08 13:23:20
// Design Name: 
// Module Name: Branch
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


module BRANCH(
    input                   [ 3 : 0]            br_type,

    input                   [31 : 0]            br_src0,
    input                   [31 : 0]            br_src1,

    output      reg         [ 1 : 0]            npc_sel
);

always @(*) begin
    npc_sel = 2'b00;
    case (br_type)
        4'b0000:begin
            if(br_src0 == br_src1)npc_sel = 2'b01;
        end
        4'b0001:begin
            if(br_src0 != br_src1)npc_sel = 2'b01;
        end
        4'b0110:begin
            if(br_src0 < br_src1)npc_sel = 2'b01;
        end
        4'b0111:begin
            if(br_src0 >= br_src1)npc_sel = 2'b01;
        end
        4'b0100:begin
            if($signed(br_src0) < $signed(br_src1))npc_sel = 2'b01;
        end
        4'b0101:begin
            if($signed(br_src0) >= $signed(br_src1))npc_sel = 2'b01;
        end
        4'b1100:begin
            npc_sel = 2'b01;
        end
        4'b1000:begin
            npc_sel = 2'b10;
        end
        default:begin
            npc_sel = 2'b00;
        end
    endcase
end


endmodule
