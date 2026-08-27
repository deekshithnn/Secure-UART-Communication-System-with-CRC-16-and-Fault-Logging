`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 17:50:58
// Design Name: 
// Module Name: crc16
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


module crc16 (
    input  wire        clk,
    input  wire        rst,
    input  wire        data_valid,
    input  wire [7:0]  data_in,
    output reg  [15:0] crc_out
);

    integer i;
    reg [15:0] crc;

    always @(posedge clk) begin
        if (rst) begin
            crc <= 16'hFFFF;
        end
        else if (data_valid) begin
            crc = crc ^ (data_in << 8);

            for (i = 0; i < 8; i = i + 1) begin
                if (crc[15])
                    crc = (crc << 1) ^ 16'h1021;
                else
                    crc = crc << 1;
            end

            crc_out <= crc;
        end
    end

endmodule
