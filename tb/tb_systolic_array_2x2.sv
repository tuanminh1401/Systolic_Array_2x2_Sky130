`timescale 1ns / 1ps
module tb_systolic_array_2x2;
    localparam time CLK_PERIOD = 10ns;

    logic clk;
    logic rst_n;
    logic load_weight;

    // Cờ kích hoạt dữ liệu
    logic valid_row0_in;
    logic valid_row1_in;
    logic valid_row0_out;
    logic valid_row1_out;

    //4 cổng nạp trọng số
    logic signed [15:0] w00;
    logic signed [15:0] w01;
    logic signed [15:0] w10;
    logic signed [15:0] w11;

    //cổng kích hoạt từ phía Tây
    logic signed [15:0] act_row0_in;                                //a00, a01
    logic signed [15:0] act_row1_in;                                //a10, a11

    //cổng tích lũy từ phía Bắc
    logic signed [31:0] psum_col0_in;
    logic signed [31:0] psum_col1_in;

    //cổng kết quả ra ở phía Nam
    logic signed [31:0] psum_col0_out;
    logic signed [31:0] psum_col1_out; 

    int test_count = 0;
    int error_count = 0;

    //ma trận weight và activate và ma trận Y mong muốn
    logic signed [15:0] matrix_A[2][2];
    logic signed [15:0] matrix_W[2][2];
    logic signed [31:0] matrix_Y_golden[2][2];

    function automatic void calc_golden();
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 2; j++) begin
                matrix_Y_golden[i][j] = '0;
                for (int k = 0; k < 2; k++) begin
                    matrix_Y_golden[i][j] = matrix_Y_golden[i][j] + (matrix_A[i][k] * matrix_W[k][j]);
                end
            end
        end
    endfunction

    task automatic score_board(input string tag, input logic signed [31:0] actual, input logic signed [31:0] expected);
        test_count++;
        if (actual === expected) begin
            $display("[PASS] %s | Output = %0d | Golden = %0d", tag, actual, expected);
        end else begin
            $error("[FAIL] %s | Output = %0d | Golden = %0d", tag, actual, expected);
            error_count++;
        end
    endtask

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    systolic_array_2x2 dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .load_weight     (load_weight),
        .valid_row0_in   (valid_row0_in),
        .valid_row1_in   (valid_row1_in),
        .w00             (w00),
        .w01             (w01),
        .w10             (w10),
        .w11             (w11),
        .act_row0_in     (act_row0_in),                  
        .act_row1_in     (act_row1_in),                     
        .psum_col0_in    (psum_col0_in),
        .psum_col1_in    (psum_col1_in),
        .psum_col0_out   (psum_col0_out),
        .psum_col1_out   (psum_col1_out),
        .valid_row0_out  (valid_row0_out),
        .valid_row1_out  (valid_row1_out)
    );

    initial begin
        rst_n         = '0;
        load_weight   = '0;
        valid_row0_in = '0;
        valid_row1_in = '0;
        act_row0_in   = '0;
        act_row1_in   = '0;
        psum_col0_in  = '0;
        psum_col1_in  = '0;

        //ma trận A
        matrix_A[0][0] = 'd5; 
        matrix_A[0][1] = 'd6; 
        matrix_A[1][0] = 'd7; 
        matrix_A[1][1] = 'd8;

        //ma trận W
        matrix_W[0][0] = 'd2; 
        matrix_W[0][1] = 'd3; 
        matrix_W[1][0] = 'd1; 
        matrix_W[1][1] = 'd4;

        calc_golden();

        w00 = matrix_W[0][0];
        w01 = matrix_W[0][1];
        w10 = matrix_W[1][0];
        w11 = matrix_W[1][1];

        repeat(2) @(negedge clk);
        rst_n = 1'b1;
        load_weight = 1'b1;
        @(negedge clk);
        load_weight = 1'b0;

        //nhịp 1: bơm phần tử đầu tiên
        act_row0_in = matrix_A[0][0];
        valid_row0_in = 1'b1;
        act_row1_in   = '0;
        valid_row1_in = 1'b0;

        //nhịp 2: bơm lệch pha
        @(negedge clk);
        act_row0_in = matrix_A[1][0];
        valid_row0_in = 1'b1;
        act_row1_in   = matrix_A[0][1];
        valid_row1_in = 1'b1;

        //thu hoạch Y00;
        @(posedge clk); #1ps;
        score_board("Y[0][0]", psum_col0_out, matrix_Y_golden[0][0]);

        //nhịp 3: bơm nốt hàng 1 
        @(negedge clk);
        act_row0_in = '0;
        valid_row0_in = 1'b0;
        act_row1_in   = matrix_A[1][1];
        valid_row1_in = 1'b1;

        //thu hoạch Y01 và Y10
        @(posedge clk); #1ps;
        score_board("Y[1][0]", psum_col0_out, matrix_Y_golden[1][0]);
        score_board("Y[0][1]", psum_col1_out, matrix_Y_golden[0][1]);

        //nhịp 4: dừng cấp
        @(negedge clk);
        act_row0_in = '0;
        valid_row0_in = 1'b0;
        act_row1_in   = '0;
        valid_row1_in = 1'b0;

        //thu hoạch Y11
        @(posedge clk); #1ps;
        score_board("Y[1][1]", psum_col1_out, matrix_Y_golden[1][1]);

        #(CLK_PERIOD);
        $display("---------------------------------------------------------");
        if (error_count == 0) begin
            $display(">> TEST RESULT: ALL %0d CHECKS PASSED!", test_count);
        end else begin
            $display(">> TEST RESULT: FAILED WITH %0d / %0d ERRORS!", error_count, test_count);
        end
        $display("---------------------------------------------------------");
        $finish;

        $stop;
    end

endmodule