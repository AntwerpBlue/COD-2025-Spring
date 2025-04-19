module SegCtrl(
    input           rf_we_ex,
    input    [1:0]  rf_wd_sel_ex,
    input    [1:0]  npc_sel_ex,
    input    [4:0]  rf_wa_ex,
    input    [4:0]  rf_ra0_id,
    input    [4:0]  rf_ra1_id,

    output   reg    stall_pc,
    output   reg    stall_if_id,
    output   reg    flush_if_id,
    output   reg    flush_id_ex
);

    // Load-use hazard detection
    wire load_use_hazard = rf_we_ex && (rf_wd_sel_ex == 2'b10) &&  // EX stage is a load instruction
                         ((rf_ra0_id == rf_wa_ex) ||              // ID stage uses EX's result
                          (rf_ra1_id == rf_wa_ex));

    // Control hazard detection (branch/jump)
    wire ctrl_hazard = (npc_sel_ex != 2'b00);  // EX stage is a branch/jump

    // Stall PC and IF/ID when load-use hazard occurs
    always @(*) begin
        stall_pc    = load_use_hazard;
        stall_if_id = load_use_hazard;
    end

    // Flush IF/ID when control hazard occurs
    always @(*) begin
        flush_if_id = ctrl_hazard;
    end

    // Flush ID/EX when control hazard occurs
    always @(*) begin
        flush_id_ex = ctrl_hazard;
    end

endmodule