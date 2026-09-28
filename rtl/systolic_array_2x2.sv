module systolic_array_2x2 (
    input logic clk,
    input logic rst_n,
    input logic load_weight,

    // Cổng cờ kích hoạt từ phía Tây
    input  logic valid_row0_in,
    input  logic valid_row1_in,

    //4 cổng nạp trọng số
    input logic signed [15:0] w00,
    input logic signed [15:0] w01,
    input logic signed [15:0] w10,
    input logic signed [15:0] w11,

    //cổng kích hoạt từ phía Tây
    input logic signed [15:0] act_row0_in,                      //a00, a01
    input logic signed [15:0] act_row1_in,                      //a10, a11

    //cổng tích lũy từ phía Bắc
    input logic signed [31:0] psum_col0_in,
    input logic signed [31:0] psum_col1_in,

    //cổng kết quả ra ở phía Nam
    output logic signed [31:0] psum_col0_out,
    output logic signed [31:0] psum_col1_out,

    // Cổng cờ kích hoạt xuất ra ở phía Đông
    output logic valid_row0_out,
    output logic valid_row1_out
);
    //dây truyền ngang (Tây sang Đông)
    logic signed [15:0] act_00_out_01_in;
    logic signed [15:0] act_10_out_11_in;
    logic signed [15:0] act_01_out;
    logic signed [15:0] act_11_out;

    // Dây truyền cờ valid ngang (Tây sang Đông)
    logic valid_00_out_01_in;
    logic valid_10_out_11_in;

    //dây truyền dọc (Bắc xuống Nam)
    logic signed [31:0] psum_00_out_10_in; 
    logic signed [31:0] psum_01_out_11_in; 

    //khởi tạo PE
    // --- Hàng 0 ---
    processing_element u_pe00 (
        .clk         (clk),
        .rst_n       (rst_n),
        .load_weight (load_weight),
        .weight_in   (w00),
        .act_in      (act_row0_in),
        .act_out     (act_00_out_01_in),
        .psum_in     (psum_col0_in),
        .psum_out    (psum_00_out_10_in),
        .valid_in    (valid_row0_in),
        .valid_out   (valid_00_out_01_in)
    );

    processing_element u_pe01 (
        .clk         (clk),
        .rst_n       (rst_n),
        .load_weight (load_weight),
        .weight_in   (w01),
        .act_in      (act_00_out_01_in),
        .act_out     (act_01_out),
        .psum_in     (psum_col1_in),
        .psum_out    (psum_01_out_11_in),
        .valid_in    (valid_00_out_01_in),
        .valid_out   (valid_row0_out)
    );

    // --- Hàng 1 ---
    processing_element u_pe10 (
        .clk         (clk),
        .rst_n       (rst_n),
        .load_weight (load_weight),
        .weight_in   (w10),
        .act_in      (act_row1_in),
        .act_out     (act_10_out_11_in),
        .psum_in     (psum_00_out_10_in),
        .psum_out    (psum_col0_out),
        .valid_in    (valid_row1_in),
        .valid_out   (valid_10_out_11_in)
    );

    processing_element u_pe11 (
        .clk         (clk),
        .rst_n       (rst_n),
        .load_weight (load_weight),
        .weight_in   (w11),
        .act_in      (act_10_out_11_in),
        .act_out     (act_11_out),
        .psum_in     (psum_01_out_11_in),
        .psum_out    (psum_col1_out),
        .valid_in    (valid_10_out_11_in),
        .valid_out   (valid_row1_out)
    );
endmodule