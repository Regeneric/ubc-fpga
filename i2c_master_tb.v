`timescale 1ns/1ps

`include "i2c_clk_divider.v"

module I2C_MASTER_TB();
    reg       clk;
    reg       rst;
    reg       start;
    reg [6:0] addr_in;
    reg [7:0] data_in;

    wire sda;
    wire scl;
    wire ready;

    wire i2c_clk;
    CLK_DIVIDER #(
        .DELAY(1000)
    ) divider(
        .REF_CLK(clk),
        .RST(rst),
        .SCL(i2c_clk)
    );

    I2C_MASTER uut(
        .CLK_IW(i2c_clk),
        .RST_IW(rst),
        .START_IW(start),
        .ADDR_IW(addr_in),
        .DATA_IW(data_in),
        .SCL_OW(SCL),
        .SDA_OR(SDA),
        .READY_OW(ready)
    );

    initial begin
        clk = 0;
        forever begin
            clk = #5 ~clk;
        end
    end

    initial begin
        $dumpfile("i2c_master.vcd");
        $dumpvars(0, I2C_MASTER_TB);

        start   = 1;
        addr_in = 7'b1011001;
        data_in = 8'b11001011;

        rst = 1;
        #10000;
        rst = 0;
        #112500;
        $finish;
    end
endmodule