`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 18:51:37
// Design Name: 
// Module Name: uart_packet_security_fault_top_tb
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

module uart_packet_security_fault_top_tb;

    parameter CLKS_PER_BIT = 8;

    // =====================================================
    // INPUTS
    // =====================================================

    reg clk;
    reg rst;
    reg rx;

    // =====================================================
    // OUTPUTS
    // =====================================================

    wire [7:0]  sensor_data;
    wire        sensor_valid;

    wire [15:0] calculated_crc;
    wire [15:0] received_crc;

    wire        security_ok;
    wire        security_error;
    wire        alert;

    wire [15:0] error_count;
    wire [15:0] last_received_crc;
    wire [15:0] last_calculated_crc;
    wire        fault_flag;

    wire        fifo_full;
    wire        fifo_empty;

    // =====================================================
    // DUT
    // =====================================================

    uart_packet_security_fault_top #(
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

        .error_count(error_count),
        .last_received_crc(last_received_crc),
        .last_calculated_crc(last_calculated_crc),
        .fault_flag(fault_flag),

        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    // =====================================================
    // CLOCK
    // 10 ns period
    // =====================================================

    always #5 clk = ~clk;

    // =====================================================
    // UART BYTE TRANSMISSION TASK
    // =====================================================

    task send_uart_byte(input [7:0] data);
        integer i;

        begin
            // Start bit
            rx = 1'b0;
            repeat (CLKS_PER_BIT) @(posedge clk);

            // 8 data bits - LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                repeat (CLKS_PER_BIT) @(posedge clk);
            end

            // Stop bit
            rx = 1'b1;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    // =====================================================
    // SEND COMPLETE UART PACKET
    //
    // FORMAT:
    // AA | DATA | CRC_H | CRC_L
    // =====================================================

    task send_packet(
        input [7:0] data_byte,
        input [15:0] crc_value
    );

        begin
            send_uart_byte(8'hAA);           // Header
            send_uart_byte(data_byte);       // Data
            send_uart_byte(crc_value[15:8]); // CRC High
            send_uart_byte(crc_value[7:0]);  // CRC Low
        end

    endtask

    // =====================================================
    // MAIN TEST
    // =====================================================

    initial begin

        // Initial values
        clk = 1'b0;
        rst = 1'b1;
        rx  = 1'b1;

        // -------------------------------------------------
        // RESET
        // -------------------------------------------------

        #20;

        @(negedge clk);
        rst = 1'b0;

        // =================================================
        // TEST 1: CORRECT PACKET
        //
        // First send header + data.
        // Wait for CRC calculation.
        // Then send calculated CRC bytes.
        // =================================================

        $display("======================================");
        $display("TEST 1: CORRECT CRC PACKET");
        $display("======================================");

        send_uart_byte(8'hAA);
        send_uart_byte(8'h41);   // Data = 'A'

        // Wait for parser and CRC calculation
        repeat (30) @(posedge clk);

        // Send the calculated CRC
        send_uart_byte(calculated_crc[15:8]);
        send_uart_byte(calculated_crc[7:0]);

        // Wait for security verification
        repeat (40) @(posedge clk);

        $display("Sensor Data       = %h", sensor_data);
        $display("Calculated CRC    = %h", calculated_crc);
        $display("Received CRC      = %h", received_crc);
        $display("Security OK       = %b", security_ok);
        $display("Security Error    = %b", security_error);
        $display("Alert             = %b", alert);
        $display("Error Count       = %d", error_count);

        // =================================================
        // TEST 2: FIRST WRONG CRC PACKET
        // =================================================

        $display("======================================");
        $display("TEST 2: FIRST WRONG CRC PACKET");
        $display("======================================");

        send_packet(8'h42, 16'h1234);  // 'B'

        repeat (50) @(posedge clk);

        $display("Sensor Data       = %h", sensor_data);
        $display("Calculated CRC    = %h", calculated_crc);
        $display("Received CRC      = %h", received_crc);
        $display("Security OK       = %b", security_ok);
        $display("Security Error    = %b", security_error);
        $display("Alert             = %b", alert);
        $display("Error Count       = %d", error_count);

        // =================================================
        // TEST 3: SECOND WRONG CRC PACKET
        // =================================================

        $display("======================================");
        $display("TEST 3: SECOND WRONG CRC PACKET");
        $display("======================================");

        send_packet(8'h43, 16'hAAAA);  // 'C'

        repeat (50) @(posedge clk);

        $display("Sensor Data       = %h", sensor_data);
        $display("Calculated CRC    = %h", calculated_crc);
        $display("Received CRC      = %h", received_crc);
        $display("Security OK       = %b", security_ok);
        $display("Security Error    = %b", security_error);
        $display("Alert             = %b", alert);
        $display("Error Count       = %d", error_count);

        // =================================================
        // TEST 4: THIRD WRONG CRC PACKET
        // =================================================

        $display("======================================");
        $display("TEST 4: THIRD WRONG CRC PACKET");
        $display("======================================");

        send_packet(8'h44, 16'h5555);  // 'D'

        repeat (50) @(posedge clk);

        $display("Sensor Data       = %h", sensor_data);
        $display("Calculated CRC    = %h", calculated_crc);
        $display("Received CRC      = %h", received_crc);
        $display("Security OK       = %b", security_ok);
        $display("Security Error    = %b", security_error);
        $display("Alert             = %b", alert);
        $display("Error Count       = %d", error_count);

        // =================================================
        // FINAL RESULT
        // =================================================

        $display("======================================");
        $display("FINAL RESULT");
        $display("======================================");

        $display("Total CRC Errors      = %d", error_count);
        $display("Last Received CRC     = %h", last_received_crc);
        $display("Last Calculated CRC   = %h", last_calculated_crc);
        $display("Fault Flag            = %b", fault_flag);

        // Wait and finish
        #100;

        $finish;

    end

endmodule
