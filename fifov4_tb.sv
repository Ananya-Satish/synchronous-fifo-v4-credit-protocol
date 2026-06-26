`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 19:53:41
// Design Name: 
// Module Name: fifov4_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifov4_tb;
parameter DEPTH = 8;
parameter WIDTH = 8;
logic [WIDTH-1:0] data_in;
logic clk;
logic reset;
logic wr_valid;
logic [$clog2(DEPTH):0] credits;
logic rd_ready;
logic rd_valid;
logic [WIDTH-1:0] data_out;
logic full;
logic empty;
fifov4 #(
    .DEPTH(DEPTH),
    .WIDTH(WIDTH)
) dut (
    .data_in(data_in),
    .clk(clk),
    .reset(reset),
    .wr_valid(wr_valid),
    .credits(credits),
    .rd_ready(rd_ready),
    .rd_valid(rd_valid),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 1;
    wr_valid = 0;
    rd_ready = 0;
    data_in = 0;

    #20;
    reset = 0;

    $display("\n========== BASIC WRITE ==========");

    @(negedge clk);
    wr_valid = 1;
    data_in  = 8'hAA;

    @(posedge clk);

    @(negedge clk);
    data_in = 8'hBB;

    @(posedge clk);

    @(negedge clk);
    data_in = 8'hCC;

    @(posedge clk);

    @(negedge clk);
    wr_valid = 0;

    repeat(3)
        @(posedge clk);

    $display("\n========== BASIC READ ==========");

    rd_ready = 1;

    repeat(3)
        @(posedge clk);

    rd_ready = 0;

    repeat(2)
        @(posedge clk);

    $display("\n========== FILL FIFO ==========");

    wr_valid = 1;

    for(int i=0;i<DEPTH;i++)
    begin
        @(negedge clk);
        data_in = i;
        @(posedge clk);
        $display("Credits = %0d", credits);
    end

    wr_valid = 0;

    @(posedge clk);

    $display("\n========== FIFO FULL ==========");
    $display("Credits = %0d", credits);

    @(negedge clk);

    wr_valid = 1;
    data_in = 8'h55;

    @(posedge clk);

    wr_valid = 0;

    $display("Attempted write when credits = %0d", credits);

    $display("\n========== READING DATA ==========");

    rd_ready = 1;

    repeat(4)
    begin
        @(posedge clk);
        $display("Credits = %0d", credits);
    end

    rd_ready = 0;

    $display("\n========== WRITING AFTER CREDITS RETURN ==========");

    wr_valid = 1;

    @(negedge clk);
    data_in = 8'hA1;
    @(posedge clk);

    @(negedge clk);
    data_in = 8'hA2;
    @(posedge clk);

    wr_valid = 0;

    $display("\n========== SIMULTANEOUS READ/WRITE ==========");

    wr_valid = 1;
    rd_ready = 1;

    @(negedge clk);
    data_in = 8'hF0;

    @(posedge clk);

    wr_valid = 0;
    rd_ready = 0;

    $display("\n========== EMPTYING FIFO ==========");

    rd_ready = 1;

    while(!empty)
        @(posedge clk);

    rd_ready = 0;

    $display("\n========== FINAL STATUS ==========");
    $display("Credits = %0d", credits);
    $display("Full    = %0b", full);
    $display("Empty   = %0b", empty);

    #20;
    $finish;

end

endmodule