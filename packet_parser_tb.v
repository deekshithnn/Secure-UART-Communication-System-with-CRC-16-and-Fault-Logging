`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 07:31:40
// Design Name: 
// Module Name: packet_parser_tb
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

module packet_parser_tb;

    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg data_valid;

    wire [7:0] sensor_data;
    wire sensor_valid;
    wire [15:0] received_crc;
    wire check_valid;

    // DUT
    packet_parser uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_valid(data_valid),
        .sensor_data(sensor_data),
        .sensor_valid(sensor_valid),
        .received_crc(received_crc),
        .check_valid(check_valid)
    );

    // Clock
    always #5 clk = ~clk;

    // Send one byte
    task send_byte(input [7:0] data);
        begin
            @(negedge clk);
            data_in = data;
            data_valid = 1'b1;

            @(negedge clk);
            data_valid = 1'b0;
        end
    endtask

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        data_in = 8'h00;
        data_valid = 0;

        // Reset
        #20;
        @(negedge clk);
        rst = 0;

        // Send packet:
        // AA | 41 | 58 | F5
        // Header | Data | CRC_H | CRC_L

        send_byte(8'hAA);
        send_byte(8'h41);
        send_byte(8'h58);
        send_byte(8'hF5);

        // Wait
        repeat (5) @(posedge clk);

        $display("Sensor Data  = %h", sensor_data);
        $display("Received CRC = %h", received_crc);
        $display("Check Valid  = %b", check_valid);

        #20;
        $finish;
    end

endmodule
