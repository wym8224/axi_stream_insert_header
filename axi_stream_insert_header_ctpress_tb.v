`timescale 1ns/1ps

module axi_stream_insert_header_ctpress_tb;

parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

reg clk;
reg rst_n;
reg valid_in;
reg [DATA_WD-1 : 0] data_in;
reg [DATA_BYTE_WD-1 : 0] keep_in;
reg last_in;
wire ready_in;
wire valid_out;
wire [DATA_WD-1 : 0] data_out;
wire [DATA_BYTE_WD-1 : 0] keep_out;
wire last_out;
reg ready_out;
reg valid_insert;
reg [DATA_WD-1 : 0] data_insert;
reg [DATA_BYTE_WD-1 : 0] keep_insert;
reg [BYTE_CNT_WD-1 : 0] byte_insert_cnt;
wire ready_insert;

axi_stream_insert_header #(
    .DATA_WD(DATA_WD),
    .DATA_BYTE_WD(DATA_BYTE_WD),
    .BYTE_CNT_WD(BYTE_CNT_WD)
) dut_3 (
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

integer cycle_count;
integer ready_out_wait_time;

initial begin
    // initialize inputs
    clk = 0;
    rst_n = 0;
    valid_in = 0;
    data_in = '0;
    keep_in = '0;
    last_in = 0;
    ready_out = 1;
    valid_insert = 0;
    data_insert = '0;
    keep_insert = '0;
    byte_insert_cnt = 0;
    // reset for several cycles
    #10 rst_n = 1;
    repeat (5) @(posedge clk);
    rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;
    // generate test vectors
    data_in = 'h12345678;
    keep_in = 'hff;
    valid_in = 1;
    byte_insert_cnt = 3;
    data_insert = 'hdeadbeef;
    keep_insert = 'hf;
    // run simulation
    cycle_count = 0;
    while (cycle_count < 100) begin
        $display("cycle %d: valid_in=%b, data_in=%h, keep_in=%h, last_in=%b, ready_out=%b, valid_out=%b, data_out=%h, keep_out=%h, last_out=%b, ready_in=%b, valid_insert=%b, data_insert=%h, keep_insert=%h, byte_insert_cnt=%d, ready_insert=%b", cycle_count, valid_in, data_in, keep_in, last_in, ready_out, valid_out, data_out, keep_out, last_out, ready_in, valid_insert, data_insert, keep_insert, byte_insert_cnt, ready_insert);
        // consume output
        if (valid_out && ready_out) begin
            cycle_count = cycle_count + 1;
            ready_out_wait_time = $random() % 10;
            repeat (ready_out_wait_time) @(posedge clk);
            valid_in = 0;
            ready_out = 0;
        end
        // insert header if input is ready
        if (ready_in) begin
            valid_in = 1;
            ready_out = 1;
        end
        // generate random input data and keep
        data_in = $random();
        keep_in = $random();
        last_in = cycle_count == 99;
        // generate random insert header
        valid_insert = $random() % 2;
        data_insert = $random();
        keep_insert = $random();
        byte_insert_cnt = $random() % (DATA_BYTE_WD-1);
        // wait for a few cycles
        repeat (10) @(posedge clk);
        // end of test
        $finish;
    end
end
always #5 clk =~ clk;
endmodule
