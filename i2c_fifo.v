`include "fifo.v"
`include "i2c_master.v"

module I2C_FIFO(
    input  wire       CLK_IW,
    input  wire       RST_IW,
    input  wire       START_IW,
    input  wire [6:0] ADDR_IW,
    input  wire [7:0] DATA_IW,
    inout  wire       SCL_IOW,
    inout  wire       SDA_IOW,
    output wire       READY_OW,
    output wire       FULL_OW
);

    wire [14:0] fifo_data_in;
    wire [14:0] fifo_data_out;

    assign fifo_data_in = {ADDR_IW, DATA_IW};

    FIFO #(
        .DATA_LEN(15)
    ) fifo(
        .CLK_IW(CLK_IW),
        .RST_IW(RST_IW),
        .WRITE_EN_IW(START_IW),
        .READ_EN_IW(fifo_start),
        .DATA_IN_I(fifo_data_in),
        .DATA_OUT_OR(fifo_data_out),
        .EMPTY_OW(fifo_empty),
        .FULL_OW(FULL_OW)
    );

    wire ready;
    wire fifo_start;
    wire fifo_empty;

    assign fifo_start = ~fifo_empty & ready;

    I2C_MASTER master(
        .CLK_IW(CLK_IW),
        .RST_IW(RST_IW),
        .START_IW(fifo_start),
        .ADDR_IW(fifo_data_out[14:8]),
        .DATA_IW(fifo_data_out[7:0]),
        .SCL_OW(SCL_IOW),
        .SDA_OR(SDA_IOW),
        .READY_OW(ready)
    );

endmodule