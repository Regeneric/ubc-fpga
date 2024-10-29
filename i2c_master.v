`default_nettype none

module I2C_MASTER(
    input  wire       CLK_IW,
    input  wire       RST_IW,
    input  wire       START_IW,
    input  wire [6:0] ADDR_IW,
    input  wire [7:0] DATA_IW,
    output wire       SCL_OW,
    output reg        SDA_OR,
    output wire       READY_OW
);

    reg [7:0] count;
    reg [7:0] state;
    reg [7:0] data;
    reg [6:0] address;
    reg       scl_enable = 0;

    assign SCL_OW   = (scl_enable == 0) ? 1 : ~CLK_IW;
    assign READY_OW = ((RST_IW == 0) && (state == ST_IDLE)) ? 1 : 0;


    always @(negedge CLK_IW) begin
        if(RST_IW) begin
            scl_enable <= 0;
        end else begin
            if((state == ST_IDLE) || (state == ST_START) || (state == ST_STOP)) begin
                scl_enable <= 0;
            end else begin
                scl_enable <= 1;
            end
        end
    end


    localparam ST_IDLE          = 0;
    localparam ST_START         = 1;
    localparam ST_ADDR          = 2;
    localparam ST_READ_WRITE    = 3;
    localparam ST_WAIT_ACK_ADDR = 4;
    localparam ST_DATA          = 5;
    localparam ST_WAIT_ACK_DATA = 6;
    localparam ST_STOP          = 7;

    always @(posedge CLK_IW) begin
        if(RST_IW) begin       
            SDA_OR  <= 1;
            count   <= 8'd0;
            state   <= ST_IDLE;
        end else begin
            case(state)
                ST_IDLE: begin
                    $display("state: %d", state);

                    SDA_OR <= 1;
                    if(START_IW) begin
                        data    <= DATA_IW;
                        address <= ADDR_IW;
                        state   <= ST_START;
                    end else begin
                        state <= ST_IDLE;
                    end 
                end // ST_IDLE

                ST_START: begin
                    $display("state: %d", state);

                    SDA_OR   <= 0;
                    state <= ST_ADDR;
                    count <= 6;
                end // ST_START

                ST_ADDR: begin
                    $display("state: %d, address[%d]: %d", state, count, address[count]);

                    SDA_OR <= address[count]; // MSBF
                    count <= count-1;           

                    if(count == 0) state <= ST_READ_WRITE;
                end // ST_ADDR

                ST_READ_WRITE: begin
                    $display("state: %d", state);

                    SDA_OR <= 1;   // 0 - read ; 1 - write
                    state  <= ST_WAIT_ACK_ADDR;
                end // ST_READ_WRITE

                ST_WAIT_ACK_ADDR: begin
                    $display("state: %d", state);

                    state <= ST_DATA;
                    count <= 7;
                end // ST_WAIT_ACK_ADDR

                ST_DATA: begin
                    $display("state: %d, data[%d]: %d", state, count, data[count]);

                    SDA_OR <= data[count];
                    count  <= count-1;

                    if(count == 0) state <= ST_WAIT_ACK_DATA;
                end // ST_DATA

                ST_WAIT_ACK_DATA: begin
                    $display("state: %d", state);

                    state <= ST_STOP;
                end // ST_WAIT_ACK_DATA

                ST_STOP: begin 
                    $display("state: %d", state);   
                    
                    SDA_OR <= 1;
                    state  <= ST_IDLE;
                end // ST_STOP
            endcase
        end
    end
endmodule