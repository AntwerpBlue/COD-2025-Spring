module Forwarding(
    input         rf_we_mem,
    input         rf_we_wb,
    input [4:0]   rf_wa_mem,
    input [4:0]   rf_wa_wb,
    input [31:0]  rf_wd_mem,
    input [31:0]  rf_wd_wb,
    input [4:0]   rf_ra0_ex,
    input [4:0]   rf_ra1_ex,

    output reg        rf_rd0_fe,
    output reg       rf_rd1_fe,
    output reg [31:0] rf_rd0_fd,
    output reg [31:0] rf_rd1_fd
);

always @(*) begin
    // Default values (no forwarding)
    rf_rd0_fe = 1'b0;
    rf_rd1_fe = 1'b0;
    rf_rd0_fd = 32'b0;
    rf_rd1_fd = 32'b0;
    
    // Forwarding logic for read port 0 (rf_ra0_ex)
    if (rf_we_mem && (rf_wa_mem != 5'b0) && (rf_wa_mem == rf_ra0_ex)) begin
        // Forward from MEM stage (highest priority)
        rf_rd0_fe = 1'b1;
        rf_rd0_fd = rf_wd_mem;
    end
    else if (rf_we_wb && (rf_wa_wb != 5'b0) && (rf_wa_wb == rf_ra0_ex)) begin
        // Forward from WB stage
        rf_rd0_fe = 1'b1;
        rf_rd0_fd = rf_wd_wb;
    end
    
    // Forwarding logic for read port 1 (rf_ra1_ex)
    if (rf_we_mem && (rf_wa_mem != 5'b0) && (rf_wa_mem == rf_ra1_ex)) begin
        // Forward from MEM stage (highest priority)
        rf_rd1_fe = 1'b1;
        rf_rd1_fd = rf_wd_mem;
    end
    else if (rf_we_wb && (rf_wa_wb != 5'b0) && (rf_wa_wb == rf_ra1_ex)) begin
        // Forward from WB stage
        rf_rd1_fe = 1'b1;
        rf_rd1_fd = rf_wd_wb;
    end
end



endmodule