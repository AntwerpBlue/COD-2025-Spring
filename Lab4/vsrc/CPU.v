module CPU (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            global_en,

/* ------------------------------ Memory (inst) ----------------------------- */
    output                  [31 : 0]            imem_raddr,
    input                   [31 : 0]            imem_rdata,

/* ------------------------------ Memory (data) ----------------------------- */
    input                   [31 : 0]            dmem_rdata,
    output                  [ 0 : 0]            dmem_we,
    output                  [31 : 0]            dmem_addr,
    output                  [31 : 0]            dmem_wdata,

/* ---------------------------------- Debug --------------------------------- */
    output                  [ 0 : 0]            commit,
    output                  [31 : 0]            commit_pc,
    output                  [31 : 0]            commit_instr,
    output                  [ 0 : 0]            commit_halt,
    output                  [ 0 : 0]            commit_reg_we,
    output                  [ 4 : 0]            commit_reg_wa,
    output                  [31 : 0]            commit_reg_wd,
    output                  [ 0 : 0]            commit_dmem_we,
    output                  [31 : 0]            commit_dmem_wa,
    output                  [31 : 0]            commit_dmem_wd,

    input                   [ 4 : 0]            debug_reg_ra,   // TODO
    output                  [31 : 0]            debug_reg_rd    // TODO
);

    // -----------------------------------------
    // 1. Program Counter (PC) Logic
    // -----------------------------------------
    wire [31:0] pc_current;
    wire [31:0] pc_add4=pc_current+4;
    wire [31:0] pc_next,pc_offset,pc_j;
    wire [1:0] npc_sel;

    MUX2 #(.WIDTH(32)) pc_mux(
        .src0(pc_add4),
        .src1(pc_offset),
        .src2(pc_j),
        .src3(pc_j),
        .sel(npc_sel),
        .res(pc_next)
    );
    
    PC pc_reg(
        .clk(clk),
        .rst(rst),
        .en(global_en),
        .pc(pc_current),
        .npc(pc_next)
    );

    assign imem_raddr = pc_current;
    wire [31:0] inst = imem_rdata;

    // -----------------------------------------
    // 2. Decode Stage
    // -----------------------------------------
    wire [4:0]  alu_op;
    wire [31:0] imm;
    wire [4:0]  rf_ra0, rf_ra1, rf_wa;
    wire        rf_we, datamem_we;
    wire        alu_src0_sel, alu_src1_sel;
    wire [1:0] rf_wd_sel;
    wire [3:0] br_type,dmem_access;


    DECODE decoder(
        .inst(inst),
        .alu_op(alu_op),
        .imm(imm),
        .rf_ra0(rf_ra0),
        .rf_ra1(rf_ra1),
        .rf_wa(rf_wa),
        .rf_we(rf_we),
        .alu_src0_sel(alu_src0_sel),
        .alu_src1_sel(alu_src1_sel),
        .rf_wd_sel(rf_wd_sel),
        .br_type(br_type),
        .dmem_access(dmem_access),
        .dmem_we(datamem_we)
    );

    assign dmem_we = datamem_we&global_en;
    // -----------------------------------------
    // 3. Register File
    // -----------------------------------------

    wire [31:0] rf_rd0, rf_rd1;
    wire [31:0] rf_wd;
    wire [31:0] dmem_rd_out;

    REG_FILE global_regfile(
        .clk(clk),
        .rf_ra0(rf_ra0),
        .rf_ra1(rf_ra1),
        .rf_wa(rf_wa),
        .rf_we(rf_we&global_en),
        .rf_wd(rf_wd),
        .rf_rd0(rf_rd0),
        .rf_rd1(rf_rd1),
        .debug_reg_ra(debug_reg_ra),
        .debug_reg_rd(debug_reg_rd)
    );

    BRANCH branch(
        .br_type(br_type),
        .br_src0(rf_rd0),
        .br_src1(rf_rd1),
        .npc_sel(npc_sel)
    );

    // -----------------------------------------
    // 4. ALU Data Path
    // -----------------------------------------
    wire [31:0] alu_src0, alu_src1;
    wire [31:0] alu_result;
    
    MUX mux0(
        .src0(rf_rd0),
        .src1(pc_current),
        .sel(alu_src0_sel),
        .res(alu_src0)
    );

    MUX mux1(
        .src0(rf_rd1),
        .src1(imm),
        .sel(alu_src1_sel),
        .res(alu_src1)
    );


    ALU alu(
        .alu_src0(alu_src0),
        .alu_src1(alu_src1),
        .alu_op(alu_op),
        .alu_result(alu_result)
    );

    SL_UNIT sl_unit(
        .addr(alu_result),
        .dmem_access(dmem_access),
        .rd_in(dmem_rdata),
        .wd_in(rf_rd1),
        .rd_out(dmem_rd_out),
        .wd_out(dmem_wdata)
    );

    assign dmem_addr=alu_result;
    assign pc_offset=alu_result;
    assign pc_j=alu_result;

    // -----------------------------------------
    // 5. Write Back
    // -----------------------------------------

    MUX2 #(.WIDTH(32)) RF_WD_MUX(
        .src0(pc_add4),
        .src1(alu_result),
        .src2(dmem_rd_out),
        .src3(0),
        .sel(rf_wd_sel),
        .res(rf_wd)
    );

    // Commit
    reg  [ 0 : 0]   commit_reg          ;
    reg  [31 : 0]   commit_pc_reg       ;
    reg  [31 : 0]   commit_inst_reg     ;
    reg  [ 0 : 0]   commit_halt_reg     ;
    reg  [ 0 : 0]   commit_reg_we_reg   ;
    reg  [ 4 : 0]   commit_reg_wa_reg   ;
    reg  [31 : 0]   commit_reg_wd_reg   ;
    reg  [ 0 : 0]   commit_dmem_we_reg  ;
    reg  [31 : 0]   commit_dmem_wa_reg  ;
    reg  [31 : 0]   commit_dmem_wd_reg  ;

    // Commit
    always @(posedge clk) begin
        if (rst) begin
            commit_reg          <= 1'B0;
            commit_pc_reg       <= 32'H00400000;
            commit_inst_reg     <= 32'H0;
            commit_halt_reg     <= 1'B0;
            commit_reg_we_reg   <= 1'B0;
            commit_reg_wa_reg   <= 5'H0;
            commit_reg_wd_reg   <= 32'H0;
            commit_dmem_we_reg  <= 1'B0;
            commit_dmem_wa_reg  <= 32'H0;
            commit_dmem_wd_reg  <= 32'H0;
        end
        else if (global_en) begin
            commit_reg          <= 1'B1;
            commit_pc_reg       <= pc_current;   // TODO
            commit_inst_reg     <= inst;   // TODO
            commit_halt_reg     <= (inst == 32'H00100073);   // TODO
            commit_reg_we_reg   <= rf_we;   // TODO
            commit_reg_wa_reg   <= rf_wa;   // TODO
            commit_reg_wd_reg   <= rf_wd;   // TODO
            commit_dmem_we_reg  <= dmem_we;   // TODO
            commit_dmem_wa_reg  <= dmem_addr;   // TODO
            commit_dmem_wd_reg  <= dmem_wdata;   // TODO
        end
    end

    assign commit           = commit_reg;
    assign commit_pc        = commit_pc_reg;
    assign commit_instr      = commit_inst_reg;
    assign commit_halt      = commit_halt_reg;
    assign commit_reg_we    = commit_reg_we_reg;
    assign commit_reg_wa    = commit_reg_wa_reg;
    assign commit_reg_wd    = commit_reg_wd_reg;
    assign commit_dmem_we   = commit_dmem_we_reg;
    assign commit_dmem_wa   = commit_dmem_wa_reg;
    assign commit_dmem_wd   = commit_dmem_wd_reg;

endmodule