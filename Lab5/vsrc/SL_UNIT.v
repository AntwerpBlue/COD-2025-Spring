module SL_UNIT (
    input [31:0] addr,           // 访问地址
    input [3:0] dmem_access,     // 访存控制信号 [3]:1=存储 [2]:符号扩展 [1:0]:大小(00=1B 01=2B 10=4B)
    input [31:0] rd_in,          // 从内存读取的原始数据（32位）
    input [31:0] wd_in,          // 要写入内存的数据（32位）
    output reg [31:0] rd_out,    // 处理后的读取数据（符号扩展后）
    output reg [31:0] wd_out     // 处理后的写入数据（对齐后）
);

    // 字节偏移量（小端序）
    wire [1:0] byte_offset = addr[1:0];

    // 读取数据处理（符号扩展）
    always @(*) begin
        case (dmem_access[1:0])
            2'b00: begin // 字节加载
                case (byte_offset)
                    2'b00: rd_out = {{24{rd_in[7] & dmem_access[2]}}, rd_in[7:0]};
                    2'b01: rd_out = {{24{rd_in[15] & dmem_access[2]}}, rd_in[15:8]};
                    2'b10: rd_out = {{24{rd_in[23] & dmem_access[2]}}, rd_in[23:16]};
                    2'b11: rd_out = {{24{rd_in[31] & dmem_access[2]}}, rd_in[31:24]};
                endcase
            end
            2'b01: begin // 半字加载
                case (byte_offset)
                    2'b00: rd_out = {{16{rd_in[15] & dmem_access[2]}}, rd_in[15:0]};
                    2'b10: rd_out = {{16{rd_in[31] & dmem_access[2]}}, rd_in[31:16]};
                    default: rd_out = 32'b0; // 非对齐访问（可添加错误信号）
                endcase
            end
            2'b10: begin // 字加载
                rd_out = rd_in; // 直接传递32位数据
            end
            default: rd_out = 32'b0;
        endcase
    end

    // 写入数据处理（对齐）
    always @(*) begin
        if (dmem_access[3]) begin // 存储操作
            case (dmem_access[1:0])
                2'b00: begin // 字节存储
                    case (byte_offset)
                        2'b00: wd_out = {rd_in[31:8], wd_in[7:0]};
                        2'b01: wd_out = {rd_in[31:16], wd_in[7:0], rd_in[7:0]};
                        2'b10: wd_out = {rd_in[31:24], wd_in[7:0], rd_in[15:0]};
                        2'b11: wd_out = {wd_in[7:0], rd_in[23:0]};
                    endcase
                end
                2'b01: begin // 半字存储
                    case (byte_offset)
                        2'b00: wd_out = {rd_in[31:16], wd_in[15:0]};
                        2'b10: wd_out = {wd_in[15:0], rd_in[15:0]};
                        default: wd_out = rd_in; // 非对齐访问（可添加错误信号）
                    endcase
                end
                2'b10: begin // 字存储
                    wd_out = wd_in; // 直接存储32位数据
                end
                default: wd_out = rd_in;
            endcase
        end else begin
            wd_out = rd_in; // 非存储操作，保持原数据不变
        end
    end

endmodule