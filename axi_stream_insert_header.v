module axi_stream_insert_header #(
parameter DATA_WD = 32,
parameter DATA_BYTE_WD = DATA_WD / 8,
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
input clk,
input rst_n,
// AXI Stream input original data
input valid_in,
input [DATA_WD-1 : 0] data_in,
input [DATA_BYTE_WD-1 : 0] keep_in,
input last_in,
output ready_in,
// AXI Stream output with header inserted
output valid_out,
output [DATA_WD-1 : 0] data_out,
output [DATA_BYTE_WD-1 : 0] keep_out,
output last_out,
input ready_out,
// The header to be inserted to AXI Stream input
input valid_insert,
input [DATA_WD-1 : 0] data_insert,
input [DATA_BYTE_WD-1 : 0] keep_insert,
input [BYTE_CNT_WD-1 : 0] byte_insert_cnt,
output ready_insert
);
// Your code here
reg [DATA_WD-1:0] shift_reg;
reg [DATA_BYTE_WD-1:0] shift_keep;
reg first_cycle;
reg valid_out_reg;
reg [DATA_WD-1 : 0] data_out_reg;
reg [DATA_BYTE_WD-1 : 0] keep_out_reg;
reg last_out_reg;
reg insert_cnt_invalid;
integer i;

always @(posedge clk or negedge rst_n) begin
    insert_cnt_invalid = DATA_WD-byte_insert_cnt*8;
    i = 0;
    first_cycle = 1;
    if (~rst_n) begin
        shift_reg <= '0;
        shift_keep <= '0;
        valid_out_reg <= '0;
        data_out_reg <= '0;
        keep_out_reg <= '0;
        last_out_reg <= '0;
        first_cycle <= 1'b1;
        i <= 0;
    end else begin
        if (valid_insert && valid_in && ready_out && first_cycle) begin
            first_cycle <= 1'b0;
            valid_out_reg <= 1;
            // remove invalid bytes from the beginning of the insert header
            while(insert_cnt_invalid>0) begin
                shift_reg[DATA_WD-1-i] <= data_insert[DATA_WD-1-i];
                shift_keep[DATA_BYTE_WD-1-i] <= keep_insert[DATA_BYTE_WD-1-i];
                i <= i+1;
                insert_cnt_invalid <= insert_cnt_invalid-1;
            end
        end else if (valid_insert && valid_in && ready_out) begin
            // insert header for the first cycle
            valid_out_reg <= 1'b1;
            while(i < byte_insert_cnt*8)begin
                shift_reg[i] <= data_insert[i];
                i <= i+1;
            end
            while(insert_cnt_invalid>0)begin
                shift_reg[i] <= data_in[i];
                i <= i+1;
                insert_cnt_invalid <= insert_cnt_invalid-1;
            end
            shift_keep[BYTE_CNT_WD-1 : 0] <= keep_insert[BYTE_CNT_WD-1 : 0];
            shift_keep[DATA_BYTE_WD-1 : BYTE_CNT_WD+1] <= keep_in;
        end else if (valid_insert && valid_in) begin
            // shift data and keep
            shift_reg[DATA_WD-1 : 8] <= shift_reg[DATA_WD-9 : 0];
            shift_keep[DATA_BYTE_WD-1 : 1] <= shift_keep[DATA_BYTE_WD-2 : 0];
            shift_reg[7:0] <= data_in;
            shift_keep[0] <= keep_in[BYTE_CNT_WD-1];
            // output shifted data and keep
            valid_out_reg <= 1;
            data_out_reg <= shift_reg;
            keep_out_reg <= shift_keep[DATA_BYTE_WD-1 : 0];
        end
        else begin
            valid_out_reg <= 0;
        end
        // set last signal
        last_out_reg <= last_in;
    end
end



assign ready_in = ~last_out_reg || ready_out;
assign ready_insert = ~last_out_reg || ready_out;
assign valid_out = valid_out_reg;
assign data_out = data_out_reg;
assign keep_out = keep_out_reg;
assign last_out = last_out_reg;

endmodule