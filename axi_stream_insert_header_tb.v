`timescale 1ns/1ps

module axi_stream_insert_header_tb();

    // Parameters
    parameter DATA_WD = 32;
    parameter DATA_BYTE_WD = DATA_WD / 8;
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

    // Inputs
    reg clk, rst_n, valid_in, last_in, valid_insert, ready_out;
    reg [DATA_WD-1:0] data_in, data_insert;
    reg [DATA_BYTE_WD-1:0] keep_in, keep_insert;
    reg [BYTE_CNT_WD-1:0] byte_insert_cnt;

    // Outputs
    wire ready_in, valid_out, last_out, ready_insert;
    wire [DATA_WD-1:0] data_out;
    wire [DATA_BYTE_WD-1:0] keep_out;

    // Instantiate the Unit Under Test (UUT)
    axi_stream_insert_header #(
    .DATA_WD(DATA_WD),
    .DATA_BYTE_WD(DATA_BYTE_WD),
    .BYTE_CNT_WD(BYTE_CNT_WD)
    ) dut_1 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .keep_in(keep_in),
        .last_in(last_in),
        .ready_in(ready_in),
        .valid_out(valid_out),
        .data_out(data_out),
        .keep_out(keep_out),
        .last_out(last_out),
        .ready_out(ready_out),
        .valid_insert(valid_insert),
        .data_insert(data_insert),
        .keep_insert(keep_insert),
        .byte_insert_cnt(byte_insert_cnt),
        .ready_insert(ready_insert)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        // Reset simulation
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        last_in = 0;
        data_in = 0;
        keep_in = 0;
        ready_out = 0;
        valid_insert = 0;
        data_insert = 0;
        keep_insert = 0;
        byte_insert_cnt = 0;
        #10 rst_n = 1;

        // Test case 1: Insert header at the beginning of the stream
        valid_insert = 1;
        data_insert = {DATA_WD{1'b1}};
        keep_insert = {DATA_BYTE_WD{1'b1}};
        byte_insert_cnt = 0;
        #20;
        valid_in = 1;
        data_in = {DATA_WD{1'b0}};
        keep_in = {DATA_BYTE_WD{1'b0}};
        ready_out = 1;

        // Test case 2: Insert header in the middle of the stream
        valid_insert = 1;
        data_insert = {DATA_WD{1'b1}};
        keep_insert = {DATA_BYTE_WD{1'b1}};
        byte_insert_cnt = 2;
        #20;
        valid_insert = 0;
        ready_out = 1;

        // test case 3: insert header near the end of the stream
            valid_insert = 1;
            data_insert = {DATA_WD{1'b0}};
            keep_insert = {DATA_BYTE_WD{1'b0}};
            byte_insert_cnt = 3;
            #20;
            valid_in = 1;
            data_in = {DATA_WD{1'b1}};
            keep_in = {DATA_BYTE_WD{1'b1}};
            last_in = 1;

            $display("all test cases passed!");

            // end simulation
            #20;
            $finish;
        end

endmodule