module processing_element (
    input logic clk,
    input logic rst_n,
    input logic load_weight,                                    //tín hiệu cho phép nạp trọng số
    input logic signed [15:0] weight_in,                        //dữ liệu trọng số

    //cổng giao tiếp ngang
    input logic signed [15:0] act_in,                           //giá trị kích hoạt nhận từ phía tây
    output logic signed [15:0] act_out,                         //giá trị kích hoạt xuất ra phía đông

    //cổng giao tiếp dọc
    input logic signed [31:0] psum_in,                          //kết quả tích lũy nhận từ phía bắc
    output logic signed [31:0] psum_out,                        //kết quả tích lũy xuống phía nam
    
    //tín hiệu cho phép
    input logic valid_in,
    output logic valid_out
);
    logic signed [15:0] weight_reg;                             //thanh ghi trọng số
    logic signed [31:0] prod;
    assign prod = act_in * weight_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_reg <= '0;
            act_out <= '0;
            psum_out <= '0;
            valid_out <= 1'b0;
        end else begin
            if (load_weight) begin                              //chỉ cập nhật trọng số khi có cờ nạp
                weight_reg <= weight_in;
            end
            valid_out <= valid_in;
            if (valid_in) begin
            //luồng dữ liệu và tích lũy theo từng nhịp clock
                act_out <= act_in;
                psum_out <= psum_in + prod;
            end
        end
    end

endmodule