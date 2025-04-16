//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 15:46:19
// Design Name: 
// Module Name: RegFile
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



module REG_FILE (
    input                   [ 0 : 0]        clk,

    input                   [ 4 : 0]        rf_ra0,
    input                   [ 4 : 0]        rf_ra1,   
    input                   [ 4 : 0]        rf_wa,
    input                   [ 0 : 0]        rf_we,
    input                   [31 : 0]        rf_wd,

    output                  [31 : 0]        rf_rd0,
    output                  [31 : 0]        rf_rd1,
    input                   [4  : 0]        debug_reg_ra,
    output                  [31 : 0]        debug_reg_rd  
);

    reg [31 : 0] reg_file [0 : 31];

    // 用于初始化寄存器
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            reg_file[i] = 0;
    end

    wire [31 : 0] rf_rd0_tmp, rf_rd1_tmp, debug_reg_rd_tmp;

    // 读操作0：如果正在写入该寄存器，则直接返回写入值，否则返回存储值
    assign rf_rd0_tmp = (rf_we && (rf_wa == rf_ra0) && (rf_wa != 0)) ? rf_wd : reg_file[rf_ra0];
    assign rf_rd0 = (rf_ra0 == 0) ? 32'b0 : rf_rd0_tmp;

    // 读操作1：如果正在写入该寄存器，则直接返回写入值，否则返回存储值
    assign rf_rd1_tmp = (rf_we && (rf_wa == rf_ra1) && (rf_wa != 0)) ? rf_wd : reg_file[rf_ra1];
    assign rf_rd1 = (rf_ra1 == 0) ? 32'b0 : rf_rd1_tmp;

    //assign debug_reg_rd_tmp = (rf_we && (rf_wa == debug_reg_ra) && (rf_wa != 0)) ? rf_wd : reg_file[debug_reg_ra];
    assign debug_reg_rd = reg_file[debug_reg_ra];

    // 写操作（同步）
    always @(posedge clk) begin
        if (rf_we && (rf_wa != 0)) begin
            reg_file[rf_wa] <= rf_wd;
        end
    end
endmodule