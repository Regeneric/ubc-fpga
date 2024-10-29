`timescale 1ns/1ps

`include "i2c_clk_divider.v"

module I2C_FIFO_TB();
    reg       clk;
    reg       rst;
    reg       start;
    reg [6:0] addr_in;
    reg [7:0] data_in;

    wire sda;
    wire scl;
    wire ready;
    wire fifo_full;

    wire i2c_clk;
    CLK_DIVIDER #(
        .DELAY(1000)
    ) divider(
        .REF_CLK(clk),
        .RST(rst),
        .SCL(i2c_clk)
    );
    
    I2C_FIFO uut(
        .CLK_IW(i2c_clk),
        .RST_IW(rst),
        .START_IW(start),
        .ADDR_IW(addr_in),
        .DATA_IW(data_in),
        .SCL_IOW(scl),
        .SDA_IOW(sda),
        .READY_OW(ready),
        .FULL_OW(fifo_full)
    );

    initial begin
        clk = 0;
        forever begin
            clk = #5 ~clk;
        end
    end

    task wait_i2c_cycles;
        input integer num_cycles;
        integer i;
        begin
            for (i = 0; i < num_cycles; i = i + 1) begin
                @(posedge i2c_clk);
            end
        end
    endtask

    initial begin
        $dumpfile("i2c_fifo.vcd");
        $dumpvars(0, I2C_FIFO_TB);

        rst = 1;
        @(negedge i2c_clk);
        rst = 0;

        @(negedge i2c_clk);
        addr_in = 7'h55;
        data_in = 8'h55;
        start   = 1;

        @(negedge i2c_clk);
        start = 0;

        @(negedge i2c_clk);
        addr_in = 7'h00;
        data_in = 8'hff;
        start   = 1;
        
        @(negedge i2c_clk);
        start = 0;

        @(negedge i2c_clk);
        addr_in = 7'hff;
        data_in = 8'h00;
        start   = 1;

        @(negedge i2c_clk);
        start = 0;

        @(negedge i2c_clk);
        addr_in = 7'hab;
        data_in = 8'hba;
        start   = 1;

        @(negedge i2c_clk);
        start = 0;

        @(negedge i2c_clk);
        addr_in = 7'hab;
        data_in = 8'hcd;
        start   = 1;

        @(negedge i2c_clk);
        start = 0;

        wait_i2c_cycles(99);

        $finish;
    end
endmodule