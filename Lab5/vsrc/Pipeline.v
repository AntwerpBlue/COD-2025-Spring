module Pipeline(
    // 时钟和控制信号
    input               clk,        // 时钟
    input               rst,        // 异步复位（高有效）
    input               flush,      // 冲刷流水级（高有效）
    input               stall,      // 暂停流水级（高有效）
    input               en,         // 使能更新（高有效）
    input               commit_in,  // 提交信号输入
    
    // 指令相关信号
    input       [31:0]  pc_add4_in, // PC+4值输入
    input       [31:0]  pc_in,      // PC值输入
    input       [31:0]  inst_in,    // 指令输入
    
    // 寄存器文件相关信号
    input       [31:0]  rf_rd0_in,  // 寄存器读端口0数据
    input       [31:0]  rf_rd1_in,  // 寄存器读端口1数据
    input       [4:0]   rf_wa_in,   // 寄存器写地址
    input               rf_we_in,   // 寄存器写使能
    
    // 立即数和ALU相关信号
    input       [31:0]  imm_in,     // 立即数
    input       [31:0]  alu_res_in, // ALU结果
    input       [4:0]   alu_op_in,  // ALU操作码
    input               alu_sel0_in,// ALU源0选择
    input               alu_sel1_in,// ALU源1选择
    
    // 数据存储器相关信号
    input       [31:0]  dmem_rd_out_in, // 存储器读数据
    input       [3:0]   dmem_access_in, // 存储器访问类型
    input       [31:0]  dmem_wdata_in,  // 存储器写数据
    input               datamem_we_in,  // 存储器写使能
    input       [31:0]  dmem_addr_in,   // 存储器地址
    
    // 其他控制信号
    input       [1:0]   rf_wd_sel_in,   // 寄存器写数据选择
    input       [3:0]   br_type_in,     // 分支类型
    
    // 输出信号（与输入一一对应）
    output reg          commit_out,
    output reg  [31:0]  pc_add4_out,
    output reg  [31:0]  pc_out,
    output reg  [31:0]  inst_out,
    output reg  [31:0]  rf_rd0_out,
    output reg  [31:0]  rf_rd1_out,
    output reg  [31:0]  imm_out,
    output reg  [4:0]   rf_wa_out,
    output reg  [31:0]  alu_res_out,
    output reg  [4:0]   alu_op_out,
    output reg  [31:0]  dmem_rd_out_out,
    output reg          alu_sel0_out,
    output reg          alu_sel1_out,
    output reg  [1:0]   rf_wd_sel_out,
    output reg  [3:0]   br_type_out,
    output reg  [3:0]   dmem_access_out,
    output reg  [31:0]  dmem_wdata_out,
    output reg          rf_we_out,
    output reg          datamem_we_out,
    output reg  [31:0]  dmem_addr_out
);

always @(posedge clk) begin
    if (rst) begin
        // 异步复位
        commit_out       <= 1'b0;
        pc_add4_out      <= 32'h0;
        pc_out          <= 32'h00400000;  // PC复位值
        inst_out        <= 32'h00000013;  // NOP指令
        rf_rd0_out      <= 32'h0;
        rf_rd1_out      <= 32'h0;
        imm_out         <= 32'h0;
        rf_wa_out       <= 5'h0;
        alu_res_out     <= 32'h0;
        alu_op_out      <= 5'h0;
        dmem_rd_out_out <= 32'h0;
        alu_sel0_out    <= 1'b0;
        alu_sel1_out    <= 1'b1;
        rf_wd_sel_out   <= 2'b01;
        br_type_out     <= 4'b1111;
        dmem_access_out <= 4'b0;
        dmem_wdata_out  <= 32'h0;
        rf_we_out       <= 1'b0;
        datamem_we_out  <= 1'b0;
        dmem_addr_out   <= 32'h0;
    end
    else if (en) begin
        if (flush) begin
            // 冲刷流水级，插入NOP
            commit_out       <= 1'b0;
            pc_add4_out      <= pc_add4_in;
            pc_out          <= pc_in;
            inst_out        <= 32'h00000013;  // NOP指令
            rf_rd0_out      <= 32'h0;
            rf_rd1_out      <= 32'h0;
            imm_out         <= 32'h0;
            rf_wa_out       <= 5'h0;
            alu_res_out     <= 32'h0;
            alu_op_out      <= 5'h0;
            dmem_rd_out_out <= 32'h0;
            alu_sel0_out    <= 1'b0;
            alu_sel1_out    <= 1'b1;
            rf_wd_sel_out   <= 2'b01;
            br_type_out     <= 4'b1111;
            dmem_access_out <= 4'b0;
            dmem_wdata_out  <= 32'h0;
            rf_we_out       <= 1'b0;
            datamem_we_out  <= 1'b0;
            dmem_addr_out   <= 32'h0;
        end
        else if (stall) begin
        // 暂停流水级，保持所有值不变
        // 不需要任何操作
        end
        else begin
            // 正常流水线更新
            commit_out       <= commit_in;
            pc_add4_out      <= pc_add4_in;
            pc_out          <= pc_in;
            inst_out        <= inst_in;
            rf_rd0_out      <= rf_rd0_in;
            rf_rd1_out      <= rf_rd1_in;
            imm_out         <= imm_in;
            rf_wa_out       <= rf_wa_in;
            alu_res_out     <= alu_res_in;
            alu_op_out      <= alu_op_in;
            dmem_rd_out_out <= dmem_rd_out_in;
            alu_sel0_out    <= alu_sel0_in;
            alu_sel1_out    <= alu_sel1_in;
            rf_wd_sel_out   <= rf_wd_sel_in;
            br_type_out     <= br_type_in;
            dmem_access_out <= dmem_access_in;
            dmem_wdata_out  <= dmem_wdata_in;
            rf_we_out       <= rf_we_in;
            datamem_we_out  <= datamem_we_in;
            dmem_addr_out   <= dmem_addr_in;
        end
    end
end

endmodule