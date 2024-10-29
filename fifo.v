module FIFO #(
    parameter DATA_LEN = 8,
    parameter DEPTH = 16
) (
    input       [DATA_LEN-1:0] DATA_IN_I,
    input  wire                CLK_IW,
    input  wire                RST_IW,
    input  wire                WRITE_EN_IW,
    input  wire                READ_EN_IW,
    output reg  [DATA_LEN-1:0] DATA_OUT_OR,
    output wire                FULL_OW,
    output wire                EMPTY_OW
    // output wire             NOT_FULL_OW,
    // output wire             NOT_EMPTY_OW
);

    reg [DATA_LEN-1:0]         memory [0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] write_ptr;
    reg [$clog2(DEPTH)-1:0] read_ptr;

    assign EMPTY_OW     = (write_ptr == read_ptr)  ? 1'b1 : 1'b0;
    assign FULL_OW      = (write_ptr == (DEPTH-1)) ? 1'b1 : 1'b0;
    assign NOT_EMPTY_OW = ~EMPTY_OW;
    assign NOT_FULL_OW  = ~FULL_OW;

    always @(posedge CLK_IW) begin
        if(RST_IW) begin
            write_ptr = 0;
            read_ptr  = 0;

            integer i = 0;
            for (integer i = 0; i < DEPTH; i = i+1) begin
                memory[i] <= {DATA_LEN{1'b0}};
            end
    
            if(DATA_LEN <= 0) begin
                $error("%m ** Illegal condition **, you used %d WIDTH", DATA_LEN);
            end
            if(DEPTH <= 0) begin
                $error("%m ** Illegal condition **, you used %d DEPTH", DEPTH);
            end
        end
    end

    always @(posedge CLK_IW) begin
        if(!RST_IW && WRITE_EN_IW) memory[write_ptr] <= DATA_IN_I;
        if(!RST_IW && READ_EN_IW)  DATA_OUT_OR       <= memory[read_ptr];
    end

    always @(posedge CLK_IW) begin
        if(!RST_IW && WRITE_EN_IW)                 write_ptr <= write_ptr+1;
        if(!RST_IW && READ_EN_IW && NOT_EMPTY_OW)  read_ptr  <= read_ptr+1;
    end

endmodule
