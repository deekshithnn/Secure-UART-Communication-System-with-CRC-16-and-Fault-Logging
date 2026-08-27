`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 18:13:57
// Design Name: 
// Module Name: top_security_controller_tb
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

module top_security_controller_tb;

    reg clk;
    reg rst;
    reg data_valid;
    reg [7:0] data_in;
    reg [15:0] received_crc;
    reg check_valid;

    wire [15:0] calculated_crc;
    wire security_ok;
    wire security_error;
    wire alert;

    // DUT
    top_security_controller uut (
        .clk(clk),
        .rst(rst),
        .data_valid(data_valid),
        .data_in(data_in),
        .received_crc(received_crc),
        .check_valid(check_valid),
        .calculated_crc(calculated_crc),
        .security_ok(security_ok),
        .security_error(security_error),
        .alert(alert)
    );

    // 10 ns clock
    always #5 clk = ~clk;

    // Task to send one byte
    task send_byte(input [7:0] data);
        begin
            @(negedge clk);
            data_in = data;
            data_valid = 1;

            @(negedge clk);
            data_valid = 0;
        end
    endtask

    initial begin
        // Initial values
        clk = 0;
        rst = 1;
        data_valid = 0;
        data_in = 8'h00;
        received_crc = 16'h0000;
        check_valid = 0;

        // Reset
        #20;
        @(negedge clk);
        rst = 0;

        // =====================================
        // Send "123456789"
        // Expected CRC = 29B1
        // =====================================

        send_byte(8'h31); // 1
        send_byte(8'h32); // 2
        send_byte(8'h33); // 3
        send_byte(8'h34); // 4
        send_byte(8'h35); // 5
        send_byte(8'h36); // 6
        send_byte(8'h37); // 7
        send_byte(8'h38); // 8
        send_byte(8'h39); // 9

        // Wait for CRC calculation
        #20;

        // =====================================
        // TEST 1: Correct CRC
        // =====================================
        @(negedge clk);
        received_crc = 16'h29B1;
        check_valid = 1;

        @(negedge clk);
        check_valid = 0;

        #20;

        // =====================================
        // TEST 2: Wrong CRC
        // =====================================
        @(negedge clk);
        received_crc = 16'h1234;
        check_valid = 1;

        @(negedge clk);
        check_valid = 0;

        #30;
        $finish;
    end

endmodule
