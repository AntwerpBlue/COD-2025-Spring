//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/31 14:46:17
// Design Name: 
// Module Name: MUX
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


module MUX(
    input                   [31 : 0]           src0, src1,
    input                   [ 0 : 0]           sel,

    output                  [31 : 0]           res
);

    assign res = sel ? src1 : src0;

endmodule