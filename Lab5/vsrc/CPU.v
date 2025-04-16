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
    output                  [31 : 0]            commit_inst,
    output                  [ 0 : 0]            commit_halt,
    output                  [ 0 : 0]            commit_reg_we,
    output                  [ 4 : 0]            commit_reg_wa,
    output                  [31 : 0]            commit_reg_wd,
    output                  [ 0 : 0]            commit_dmem_we,
    output                  [31 : 0]            commit_dmem_wa,
    output                  [31 : 0]            commit_dmem_wd,

    input                   [ 4 : 0]            debug_reg_ra,   
    output                  [31 : 0]            debug_reg_rd    
);

    // -----------------------------------------
    // 1. IF Stage
    // -----------------------------------------
    wire [31:0] pc_if;
    wire [31:0] pcadd4_if=pc_if+4;
    wire [31:0] npc_ex,pcadd4_id,pc_id,pcadd4_ex,pc_ex,pcadd4_mem,pc_mem,pcadd4_wb,pc_wb;
    wire [1:0] npc_sel;
    wire branch_taken = (npc_sel != 2'b00); //分支跳转
    
    wire commit_id, commit_ex, commit_mem, commit_wb;

    PC pc_reg(
        .clk(clk),
        .rst(rst),
        .en(global_en),
        .pc(pc_if),
        .npc(npc_ex)
    );

    assign imem_raddr = pc_if;
    wire [31:0] inst_if = imem_rdata;
    wire [31:0] inst_id, inst_ex, inst_mem, inst_wb;

    Pipeline IF_ID_REG (
        // 时钟和控制信号
        .clk(clk),
        .rst(rst),
        .flush(branch_taken),
        .stall(1'b0),
        .en(global_en),
        
        // 必要输入信号
        .commit_in(1'b1),
        .pc_in(pc_if),
        .pc_add4_in(pcadd4_if),
        .inst_in(inst_if),
        
        // 仅连接需要的输出信号
        .commit_out(commit_id),
        .pc_out(pc_id),
        .pc_add4_out(pcadd4_id),
        .inst_out(inst_id),
        
        // 未使用的输入信号设为默认值
        .rf_rd0_in(32'h0),
        .rf_rd1_in(32'h0),
        .imm_in(32'h0),
        .rf_wa_in(5'h0),
        .alu_res_in(32'h0),
        .alu_op_in(5'h0),
        .dmem_rd_out_in(32'h0),
        .alu_sel0_in(1'b0),
        .alu_sel1_in(1'b0),
        .rf_wd_sel_in(2'b0),
        .br_type_in(4'h0),
        .dmem_access_in(4'h0),
        .dmem_wdata_in(32'h0),
        .rf_we_in(1'b0),
        .datamem_we_in(1'b0),
        .dmem_addr_in(32'h0),
        
        // 未使用的输出信号留空
        .rf_rd0_out(),
        .rf_rd1_out(),
        .imm_out(),
        .rf_wa_out(),
        .alu_res_out(),
        .alu_op_out(),
        .dmem_rd_out_out(),
        .alu_sel0_out(),
        .alu_sel1_out(),
        .rf_wd_sel_out(),
        .br_type_out(),
        .dmem_access_out(),
        .dmem_wdata_out(),
        .rf_we_out(),
        .datamem_we_out(),
        .dmem_addr_out()
    );


    // -----------------------------------------
    // 2. ID Stage
    // -----------------------------------------
    wire [4:0]  alu_op_id,alu_op_ex;
    wire [31:0] imm_id,imm_ex;
    wire [4:0]  rf_ra0_id, rf_ra1_id, rf_wa_id, rf_wa_ex, rf_wa_mem, rf_wa_wb;
    wire        rf_we_id, rf_we_ex, rf_we_mem, rf_we_wb;
    wire        datamem_we_id, datamem_we_wb, datamem_we_ex, datamem_we_mem;
    wire        alu_src0_sel_id, alu_src1_sel_id, alu_src0_sel_ex, alu_src1_sel_ex;
    wire [1:0] rf_wd_sel_id, rf_wd_sel_ex, rf_wd_sel_mem, rf_wd_sel_wb;
    wire [3:0] br_type_id,dmem_access_id, br_type_ex, dmem_access_ex, dmem_access_mem;


    DECODE decoder(
        .inst(inst_id),
        .alu_op(alu_op_id),
        .imm(imm_id),
        .rf_ra0(rf_ra0_id),
        .rf_ra1(rf_ra1_id),
        .rf_wa(rf_wa_id),
        .rf_we(rf_we_id),
        .alu_src0_sel(alu_src0_sel_id),
        .alu_src1_sel(alu_src1_sel_id),
        .rf_wd_sel(rf_wd_sel_id),
        .br_type(br_type_id),
        .dmem_access(dmem_access_id),
        .dmem_we(datamem_we_id)
    );

    wire [31:0] rf_rd0_id, rf_rd1_id, rf_rd0_ex, rf_rd1_ex, rf_rd1_mem;
    wire [31:0] rf_wd_wb;
    wire [31:0] dmem_rd_out_mem,dmem_rd_out_wb;

    REG_FILE global_regfile(
        .clk(clk),
        .rf_ra0(rf_ra0_id),
        .rf_ra1(rf_ra1_id),
        .rf_wa(rf_wa_wb),
        .rf_we(rf_we_wb&global_en),
        .rf_wd(rf_wd_wb),
        .rf_rd0(rf_rd0_id),
        .rf_rd1(rf_rd1_id),
        .debug_reg_ra(debug_reg_ra),
        .debug_reg_rd(debug_reg_rd)
    );

    Pipeline ID_EX_REG (
        // 时钟和控制信号
        .clk(clk),
        .rst(rst),
        .flush(branch_taken),  // 分支发生时冲刷
        .stall(1'b0),         // 暂停信号置无效
        .en(global_en),       // 全局使能
        
        // 来自ID阶段的输入信号
        .commit_in(commit_id),
        .pc_in(pc_id),
        .pc_add4_in(pcadd4_id),
        .inst_in(inst_id),
        .rf_rd0_in(rf_rd0_id),
        .rf_rd1_in(rf_rd1_id),
        .imm_in(imm_id),
        .rf_wa_in(rf_wa_id),
        .alu_op_in(alu_op_id),
        .alu_sel0_in(alu_src0_sel_id),
        .alu_sel1_in(alu_src1_sel_id),
        .rf_wd_sel_in(rf_wd_sel_id),
        .br_type_in(br_type_id),
        .dmem_access_in(dmem_access_id),
        .rf_we_in(rf_we_id),
        .datamem_we_in(datamem_we_id),
        
        // 传递到EX阶段的输出信号
        .commit_out(commit_ex),
        .pc_out(pc_ex),
        .pc_add4_out(pcadd4_ex), 
        .inst_out(inst_ex),
        .rf_rd0_out(rf_rd0_ex),
        .rf_rd1_out(rf_rd1_ex),
        .imm_out(imm_ex),
        .rf_wa_out(rf_wa_ex),
        .alu_op_out(alu_op_ex),
        .alu_sel0_out(alu_src0_sel_ex),
        .alu_sel1_out(alu_src1_sel_ex),
        .rf_wd_sel_out(rf_wd_sel_ex),
        .br_type_out(br_type_ex),
        .dmem_access_out(dmem_access_ex),
        .rf_we_out(rf_we_ex),
        .datamem_we_out(datamem_we_ex),
        
        // 未使用的输入信号（显式置零）
        .alu_res_in(32'h0),
        .dmem_rd_out_in(32'h0),
        .dmem_wdata_in(32'h0),
        .dmem_addr_in(32'h0),
        
        // 未使用的输出信号（显式留空）
        .alu_res_out(),
        .dmem_rd_out_out(),
        .dmem_wdata_out(),
        .dmem_addr_out()
    );

    // -----------------------------------------
    // 3. EX Stage
    // -----------------------------------------

    BRANCH branch(
        .br_type(br_type_ex),
        .br_src0(rf_rd0_ex),
        .br_src1(rf_rd1_ex),
        .npc_sel(npc_sel)
    );

    wire [31:0] alu_src0_ex, alu_src1_ex;
    wire [31:0] alu_result_ex,alu_result_mem, alu_result_wb;
    wire [31:0] pc_j_ex=alu_result_ex&(32'hFFFFFFFE);
    
    MUX mux0(
        .src0(rf_rd0_ex),
        .src1(pc_ex),
        .sel(alu_src0_sel_ex),
        .res(alu_src0_ex)
    );

    MUX mux1(
        .src0(rf_rd1_ex),
        .src1(imm_ex),
        .sel(alu_src1_sel_ex),
        .res(alu_src1_ex)
    );


    ALU alu(
        .alu_src0(alu_src0_ex),
        .alu_src1(alu_src1_ex),
        .alu_op(alu_op_ex),
        .alu_result(alu_result_ex)
    );

    MUX2 #(.WIDTH(32)) pc_mux(
        .src0(pcadd4_if),
        .src1(alu_result_ex),
        .src2(pc_j_ex),
        .src3(pc_j_ex),
        .sel(npc_sel),
        .res(npc_ex)
    );

    Pipeline EX_MEM_REG (
        // 时钟和控制信号
        .clk(clk),
        .rst(rst),
        .flush(1'b0),
        .stall(1'b0),         // 暂停信号常闭
        .en(global_en),       // 全局流水线使能
    
        // 来自EX阶段的输入信号
        .commit_in(commit_ex),
        .pc_in(pc_ex),
        .pc_add4_in(pcadd4_ex),
        .inst_in(inst_ex),
        .rf_rd1_in(rf_rd1_ex),      // EX阶段读出的寄存器数据
        .rf_wa_in(rf_wa_ex),        // 写回地址
        .alu_res_in(alu_result_ex), // ALU计算结果
        .rf_wd_sel_in(rf_wd_sel_ex),// 写回数据选择
        .dmem_access_in(dmem_access_ex), // 存储器访问类型
        .rf_we_in(rf_we_ex),       // 寄存器写使能
        .datamem_we_in(datamem_we_ex), // 数据存储器写使能
    
        // 传递到MEM阶段的输出信号
        .commit_out(commit_mem),
        .pc_out(pc_mem),
        .pc_add4_out(pcadd4_mem),
        .inst_out(inst_mem),
        .rf_rd1_out(rf_rd1_mem),    // 传递给MEM阶段的存储数据
        .rf_wa_out(rf_wa_mem),
        .alu_res_out(alu_result_mem), // MEM阶段地址/计算结果
        .rf_wd_sel_out(rf_wd_sel_mem),
        .dmem_access_out(dmem_access_mem),
        .rf_we_out(rf_we_mem),
        .datamem_we_out(datamem_we_mem),
    
        // 未使用的输入信号（显式置零）
        .rf_rd0_in(32'h0),
        .imm_in(32'h0),
        .alu_op_in(5'h0),
        .dmem_rd_out_in(32'h0),
        .alu_sel0_in(1'b0),
        .alu_sel1_in(1'b0),
        .br_type_in(4'h0),
        .dmem_wdata_in(32'h0),
        .dmem_addr_in(32'h0),
    
        // 未使用的输出信号（显式留空）
        .rf_rd0_out(),
        .imm_out(),
        .alu_op_out(),
        .dmem_rd_out_out(),
        .alu_sel0_out(),
        .alu_sel1_out(),
        .br_type_out(),
        .dmem_wdata_out(),
        .dmem_addr_out()
    );

    // -----------------------------------------
    // 4. MEM Stage
    // -----------------------------------------

    wire [31:0] dmem_wdata_wb, dmem_wdata_mem;

    SL_UNIT sl_unit(
        .addr(alu_result_mem),
        .dmem_access(dmem_access_mem),
        .rd_in(dmem_rdata),
        .wd_in(rf_rd1_mem),
        .rd_out(dmem_rd_out_mem),
        .wd_out(dmem_wdata_mem)
    );

    wire [31:0] dmem_addr_mem,dmem_addr_wb;
    assign dmem_addr=alu_result_mem;
    assign dmem_addr_mem=alu_result_mem;
    assign dmem_wdata=dmem_wdata_mem;
    assign dmem_we=datamem_we_mem&global_en;

    Pipeline MEM_WB_REG (
        // 时钟和控制信号
        .clk(clk),
        .rst(rst),
        .flush(1'b0),                // WB阶段通常不需要冲刷
        .stall(1'b0),                // 暂停信号常闭
        .en(global_en),              // 全局流水线使能

        // 来自MEM阶段的输入信号
        .commit_in(commit_mem),
        .pc_in(pc_mem),
        .pc_add4_in(pcadd4_mem),
        .rf_wa_in(rf_wa_mem),        // 寄存器写地址
        .alu_res_in(alu_result_mem), // ALU计算结果/存储器地址
        .dmem_rd_out_in(dmem_rd_out_mem), // 存储器读取数据
        .rf_wd_sel_in(rf_wd_sel_mem),// 写回数据选择
        .rf_we_in(rf_we_mem),        // 寄存器写使能
        .datamem_we_in(datamem_we_mem&global_en), // 数据存储器写使能（用于调试）
        .dmem_addr_in(dmem_addr_mem), // 存储器地址（用于调试）
        .dmem_wdata_in(dmem_wdata_mem), // 存储器写数据（用于调试）
        .inst_in(inst_mem),

        // 传递到WB阶段的输出信号
        .commit_out(commit_wb),
        .pc_out(pc_wb),
        .pc_add4_out(pcadd4_wb),
        .rf_wa_out(rf_wa_wb),
        .alu_res_out(alu_result_wb),
        .dmem_rd_out_out(dmem_rd_out_wb),
        .rf_wd_sel_out(rf_wd_sel_wb),
        .rf_we_out(rf_we_wb),
        .inst_out(inst_wb),

        // 调试信号输出
        .datamem_we_out(datamem_we_wb),
        .dmem_addr_out(dmem_addr_wb),
        .dmem_wdata_out(dmem_wdata_wb),

        // 未使用的输入信号（显式置零）
        .rf_rd0_in(32'h0),
        .rf_rd1_in(32'h0),
        .imm_in(32'h0),
        .alu_op_in(5'h0),
        .alu_sel0_in(1'b0),
        .alu_sel1_in(1'b0),
        .br_type_in(4'h0),
        .dmem_access_in(4'h0),

        // 未使用的输出信号（显式留空）
        .rf_rd0_out(),
        .rf_rd1_out(),
        .imm_out(),
        .alu_op_out(),
        .alu_sel0_out(),
        .alu_sel1_out(),
        .br_type_out(),
        .dmem_access_out()
    );
    // -----------------------------------------
    // 5. WB Stage
    // -----------------------------------------

    MUX2 #(.WIDTH(32)) RF_WD_MUX(
        .src0(pcadd4_wb),
        .src1(alu_result_wb),
        .src2(dmem_rd_out_wb),
        .src3(0),
        .sel(rf_wd_sel_wb),
        .res(rf_wd_wb)
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
            commit_reg          <= 1'h0;
            commit_pc_reg       <= 32'H00400000;
            commit_inst_reg     <= 32'H0;
            commit_halt_reg     <= 1'h0;
            commit_reg_we_reg   <= 1'h0;
            commit_reg_wa_reg   <= 5'H0;
            commit_reg_wd_reg   <= 32'H0;
            commit_dmem_we_reg  <= 1'h0;
            commit_dmem_wa_reg  <= 32'H0;
            commit_dmem_wd_reg  <= 32'H0;
        end
        else if (global_en) begin
            commit_reg          <= commit_wb;
            commit_pc_reg       <= pc_wb;   
            commit_inst_reg     <= inst_wb;   
            commit_halt_reg     <= (inst_wb == 32'H00100073);   
            commit_reg_we_reg   <= rf_we_wb;   
            commit_reg_wa_reg   <= rf_wa_wb;   
            commit_reg_wd_reg   <= rf_wd_wb;   
            commit_dmem_we_reg  <= datamem_we_wb;   
            commit_dmem_wa_reg  <= dmem_addr_wb;   
            commit_dmem_wd_reg  <= dmem_wdata_wb;   
        end
    end

    assign commit           = commit_reg;
    assign commit_pc        = commit_pc_reg;
    assign commit_inst      = commit_inst_reg;
    assign commit_halt      = commit_halt_reg;
    assign commit_reg_we    = commit_reg_we_reg;
    assign commit_reg_wa    = commit_reg_wa_reg;
    assign commit_reg_wd    = commit_reg_wd_reg;
    assign commit_dmem_we   = commit_dmem_we_reg;
    assign commit_dmem_wa   = commit_dmem_wa_reg;
    assign commit_dmem_wd   = commit_dmem_wd_reg;

endmodule