`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 18:19:36
// Design Name: 
// Module Name: uart_rx_tb
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


`timescale 1ns/1ps

module uart_rx_tb;

    // Use a small value to make simulation fast
    parameter CLKS_PER_BIT = 8;

    reg clk;
    reg rst;
    reg rx;

    wire [7:0] data_out;
    wire data_valid;

    // DUT
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Send one UART byte
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx = 1'b0;
            repeat (CLKS_PER_BIT) @(posedge clk);

            // 8 data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                repeat (CLKS_PER_BIT) @(posedge clk);
            end

            // Stop bit
            rx = 1'b1;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        rx  = 1;

        // Reset
        #20;
        @(posedge clk);
        rst = 0;

        // Send ASCII 'A' = 0x41
        #20;
        send_uart_byte(8'h41);

        // Wait and finish
        #100;
        $finish;
    end

endmodule