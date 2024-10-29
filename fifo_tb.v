`timescale 1ns/1ps

`include "i2c_clk_divider.v"

module FIFO_TB();
    reg        clk;
    reg        rst;
    reg [14:0] data_in;
    wire [14:0] data_out;

    wire fifo_empty;
    wire fifo_full;

    wire i2c_clk;
    CLK_DIVIDER #(
        .DELAY(1000)
    ) divider(
        .REF_CLK(clk),
        .RST(rst),
        .SCL(i2c_clk)
    );
    
    reg write_enable;
    reg read_enable;

    FIFO #(.DATA_LEN(15)) uut(
        .CLK_IW(clk),
        .I2C_CLK_IW(clk),
        .RST_IW(rst),
        .WRITE_EN_IW(write_enable),
        .READ_EN_IW(read_enable),
        .DATA_IN_I(data_in),
        .DATA_OUT_OR(data_out),
        .EMPTY_OW(fifo_empty),
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
                @ (posedge i2c_clk);
            end
        end
    endtask

    task wait_clk_cycles;
        input integer num_cycles;
        integer i;
        begin
            for (i = 0; i < num_cycles; i = i + 1) begin
                @ (posedge clk);
            end
        end
    endtask

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, FIFO_TB);

        rst = 1;
        #100;
        rst = 0;
        #100;

        write_enable = 1;
        read_enable  = 0;
        data_in = 15'b111111111111111;
        wait_clk_cycles(15);

        write_enable = 0;
        read_enable  = 1;
        wait_i2c_cycles(15);

        write_enable = 1;
        read_enable  = 0;
        data_in = 15'b000000000000000;
        wait_clk_cycles(15);

        write_enable = 0;
        read_enable  = 1;
        wait_i2c_cycles(15);

        write_enable = 1;
        read_enable  = 0;
        data_in = 15'b111111111111111;
        wait_clk_cycles(15);

        write_enable = 0;
        read_enable  = 1;
        wait_i2c_cycles(15);

        write_enable = 1;
        read_enable  = 0;
        data_in = 15'b000000000000000;
        wait_clk_cycles(15);

        write_enable = 0;
        read_enable  = 1;
        wait_i2c_cycles(15);

        wait_i2c_cycles(2);

        $finish;
    end
endmodule