`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 07:46:03
// Design Name: 
// Module Name: fault_logger_tb
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

module fault_logger_tb;

    reg clk;
    reg rst;
    reg security_error;
    reg [15:0] received_crc;
    reg [15:0] calculated_crc;

    wire [15:0] error_count;
    wire [15:0] last_received_crc;
    wire [15:0] last_calculated_crc;
    wire fault_flag;

    // DUT
    fault_logger uut (
        .clk(clk),
        .rst(rst),
        .security_error(security_error),
        .received_crc(received_crc),
        .calculated_crc(calculated_crc),
        .error_count(error_count),
        .last_received_crc(last_received_crc),
        .last_calculated_crc(last_calculated_crc),
        .fault_flag(fault_flag)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Task to generate one CRC error event
    task generate_error(
        input [15:0] rx_crc,
        input [15:0] calc_crc
    );
        begin
            @(negedge clk);
            received_crc   = rx_crc;
            calculated_crc = calc_crc;
            security_error = 1'b1;

            @(negedge clk);
            security_error = 1'b0;

            // Wait one clock
            @(posedge clk);
        end
    endtask

    initial begin

        // Initial values
        clk = 0;
        rst = 1;
        security_error = 0;
        received_crc = 16'h0000;
        calculated_crc = 16'h0000;

        // Reset
        #20;
        @(negedge clk);
        rst = 0;

        // =========================================
        // TEST 1: First CRC Error
        // =========================================
        generate_error(16'h1234, 16'h29B1);

        $display("-----------------------------");
        $display("TEST 1: First CRC Error");
        $display("Error Count = %d", error_count);
        $display("Last Received CRC = %h", last_received_crc);
        $display("Last Calculated CRC = %h", last_calculated_crc);
        $display("Fault Flag = %b", fault_flag);

        // =========================================
        // TEST 2: Second CRC Error
        // =========================================
        generate_error(16'hAAAA, 16'h58F5);

        $display("-----------------------------");
        $display("TEST 2: Second CRC Error");
        $display("Error Count = %d", error_count);
        $display("Last Received CRC = %h", last_received_crc);
        $display("Last Calculated CRC = %h", last_calculated_crc);
        $display("Fault Flag = %b", fault_flag);

        // =========================================
        // TEST 3: Third CRC Error
        // =========================================
        generate_error(16'h5555, 16'hBEEF);

        $display("-----------------------------");
        $display("TEST 3: Third CRC Error");
        $display("Error Count = %d", error_count);
        $display("Last Received CRC = %h", last_received_crc);
        $display("Last Calculated CRC = %h", last_calculated_crc);
        $display("Fault Flag = %b", fault_flag);

        #20;

        $display("-----------------------------");
        $display("FINAL RESULT");
        $display("Total Errors = %d", error_count);

        $finish;

    end

endmodule
