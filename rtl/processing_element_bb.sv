(* blackbox *)
module processing_element (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        load_weight,
    input  wire [15:0] weight_in,
    input  wire [15:0] act_in,
    output wire [15:0] act_out,
    input  wire [31:0] psum_in,
    output wire [31:0] psum_out,
    input  wire        valid_in,
    output wire        valid_out
);
endmodule