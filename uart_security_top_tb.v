`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 18:24:46
// Design Name: 
// Module Name: uart_security_top_tb
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

module uart_security_top_tb;

    parameter CLKS_PER_BIT = 8;

    reg clk;
    reg rst;
    reg rx;
    reg [15:0] received_crc;
    reg check_valid;

    wire [7:0] received_data;
    wire data_valid;
    wire [15:0] calculated_crc;
    wire security_ok;
    wire security_error;
    wire alert;

    // DUT
    uart_security_top #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .received_crc(received_crc),
        .check_valid(check_valid),
        .received_data(received_data),
        .data_valid(data_valid),
        .calculated_crc(calculated_crc),
        .security_ok(security_ok),
        .security_error(security_error),
        .alert(alert)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // UART transmit task
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx = 1'b0;
            repeat (CLKS_PER_BIT) @(posedge clk);

            // Data bits - LSB first
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

        // Initial values
        clk = 0;
        rst = 1;
        rx = 1;
        received_crc = 16'h0000;
        check_valid = 0;

        // Reset
        #20;
        @(negedge clk);
        rst = 0;

        // ====================================
        // Send UART byte 'A' = 8'h41
        // ====================================
        #20;
        send_uart_byte(8'h41);

        // Wait for UART RX and CRC calculation
        repeat (10) @(posedge clk);

        // ====================================
        // TEST 1: Correct CRC
        // Use calculated CRC automatically
        // ====================================
        @(negedge clk);
        received_crc = calculated_crc;
        check_valid = 1;

        @(negedge clk);
        check_valid = 0;

        // Wait
        repeat (5) @(posedge clk);

        // ====================================
        // TEST 2: Wrong CRC
        // ====================================
        @(negedge clk);
        received_crc = 16'h1234;
        check_valid = 1;

        @(negedge clk);
        check_valid = 0;

        // Wait before finish
        repeat (10) @(posedge clk);

        $finish;

    end

endmodule
