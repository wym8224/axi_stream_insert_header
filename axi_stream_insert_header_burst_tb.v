module axi_stream_insert_header_burst_tb;

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
) dut_2 (
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

initial begin
  // Reset simulation
  clk = 0;
  rst_n = 0;
  valid_in = 0;
  data_in = 0;
  keep_in = 0;
  last_in = 0;
  ready_out = 1;
  valid_insert = 0;
  data_insert = 0;
  keep_insert = 0;
  byte_insert_cnt = 0;
  #10;

  // Reset
  rst_n = 1'b0;
  #20;
  rst_n = 1'b1;
  #20;

  // 非 burst 模式测试，**头后输出数据为输入数据加头部
  valid_insert = 1;
  data_insert = 32'h12345678;
  keep_insert = 4'hf;
  byte_insert_cnt = 1;
  #10;

  valid_in = 1;
  data_in = 32'habcdef12;
  keep_in = 4'hf;
  #10;

  // waiting for output
  repeat (10) @(posedge clk);
  assert (valid_out && data_out == 64'h12345678_abcdef12 && keep_out == 8'hff && !last_out);

  // burst 模式测试，每个 burst 有3个数据，**头后输出数据为输入数据中的第2和第3个数据加头部
  valid_insert = 1;
  data_insert = 32'h12345678;
  keep_insert = 4'hf;
  byte_insert_cnt = 1;
  #10;

  // The first burst
  valid_in = 1;
  data_in = 32'habcdef12;
  keep_in = 4'h7;
  #10;

  valid_in = 1;
  data_in = 32'h34567890;
  keep_in = 4'h3;
  last_in = 1;
  #10;

  // waiting for output
  repeat (10) @(posedge clk);
  assert (valid_out && data_out == 64'h56789012_34567890 && keep_out == 8'h0f && !last_out);

  // The second burst
  valid_insert = 1;
  data_insert = 32'habcdef12;
  keep_insert = 4'h3;
  byte_insert_cnt = 2;
  #10;

  valid_in = 1;
  data_in = 32'h12345678;
  keep_in = 4'h3;
  #10;

  valid_in = 1;
  data_in = 32'h34567890;
  keep_in = 4'h7;
  last_in = 1;
  #10;

  // waiting for the output
  repeat (10) @(posedge clk);
  assert (valid_out && data_out == 64'h34567890_12345678 && keep_out == 8'h0f && !last_out);

  // end simulation
  $finish;
end

always #5 clk <= ~clk;

endmodule