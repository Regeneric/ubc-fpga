module CLK_DIVIDER(
    input  wire REF_CLK,
    input  wire RST,
    output reg  SCL
);

    parameter DELAY = 1000;
    reg [9:0] count = 0;
    initial   SCL   = 0;
    
    always @(REF_CLK) begin
        if(count == (DELAY/2)) begin
            SCL = ~SCL;
            count = 1000;
        end else begin
            count = count+1;
        end
    end

endmodule