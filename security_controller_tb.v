`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 18:02:50
// Design Name: 
// Module Name: security_controller_tb
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

module security_controller_tb;

    reg clk;
    reg rst;
    reg check_valid;
    reg [15:0] received_crc;
    reg [15:0] calculated_crc;

    wire security_ok;
    wire security_error;
    wire alert;

    security_controller uut (
        .clk(clk),
        .rst(rst),
        .check_valid(check_valid),
        .received_crc(received_crc),
        .calculated_crc(calculated_crc),
        .security_ok(security_ok),
        .security_error(security_error),
        .alert(alert)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        check_valid = 0;
        received_crc = 16'h0000;
        calculated_crc = 16'h0000;

        // Reset
        #20;
        @(negedge clk);
        rst = 0;

        // TEST 1: Correct CRC
        @(negedge clk);
        received_crc   = 16'h29B1;
        calculated_crc = 16'h29B1;
        check_valid    = 1;

        @(negedge clk);
        check_valid = 0;

        // TEST 2: Wrong CRC
        @(negedge clk);
        received_crc   = 16'h1234;
        calculated_crc = 16'h29B1;
        check_valid    = 1;

        @(negedge clk);
        check_valid = 0;

        #20;
        $finish;
    end

endmodule
