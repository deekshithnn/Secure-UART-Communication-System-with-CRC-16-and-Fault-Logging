`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 07:38:17
// Design Name: 
// Module Name: uart_packet_security_top_tb
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

module uart_packet_security_top_tb;

    parameter CLKS_PER_BIT = 8;

    reg clk;
    reg rst;
    reg rx;

    wire [7:0]  sensor_data;
    wire        sensor_valid;
    wire [15:0] calculated_crc;
    wire [15:0] received_crc;

    wire security_ok;
    wire security_error;
    wire alert;

    wire fifo_full;
    wire fifo_empty;

    // DUT
    uart_packet_security_top #(
        .CLKS_PER_BIT(CLKS_PER_BIT),
        .FIFO_DEPTH(16)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),

        .sensor_data(sensor_data),
        .sensor_valid(sensor_valid),
        .calculated_crc(calculated_crc),
        .received_crc(received_crc),

        .security_ok(security_ok),
        .security_error(security_error),
        .alert(alert),

        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    // Clock
    always #5 clk = ~clk;

    // UART byte transmitter
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

        // Initial values
        clk = 0;
        rst = 1;
        rx  = 1;

        // Reset
        #20;
        @(negedge clk);
        rst = 0;

        // ============================================
        // TEST 1: CORRECT PACKET
        // Packet: AA | 41 | CRC_H | CRC_L
        // ============================================

        send_uart_byte(8'hAA);   // Header
        send_uart_byte(8'h41);   // Data = 'A'

        // Wait for CRC calculation
        repeat (20) @(posedge clk);

        // Send CRC bytes from calculated CRC
        send_uart_byte(calculated_crc[15:8]);
        send_uart_byte(calculated_crc[7:0]);

        // Wait for security check
        repeat (30) @(posedge clk);

        $display("----------------------------");
        $display("CORRECT PACKET TEST");
        $display("Sensor Data    = %h", sensor_data);
        $display("Calculated CRC = %h", calculated_crc);
        $display("Received CRC   = %h", received_crc);
        $display("Security OK    = %b", security_ok);
        $display("Security Error = %b", security_error);
        $display("Alert          = %b", alert);
        $display("----------------------------");

        // ============================================
        // TEST 2: WRONG CRC PACKET
        // ============================================

        send_uart_byte(8'hAA);   // Header
        send_uart_byte(8'h42);   // Data = 'B'

        send_uart_byte(8'h12);   // Wrong CRC High
        send_uart_byte(8'h34);   // Wrong CRC Low

        // Wait for security check
        repeat (30) @(posedge clk);

        $display("----------------------------");
        $display("WRONG CRC PACKET TEST");
        $display("Sensor Data    = %h", sensor_data);
        $display("Calculated CRC = %h", calculated_crc);
        $display("Received CRC   = %h", received_crc);
        $display("Security OK    = %b", security_ok);
        $display("Security Error = %b", security_error);
        $display("Alert          = %b", alert);
        $display("----------------------------");

        #50;
        $finish;

    end

endmodule
