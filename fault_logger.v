`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 07:45:03
// Design Name: 
// Module Name: fault_logger
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

module fault_logger (
    input  wire        clk,
    input  wire        rst,

    // Security error event
    input  wire        security_error,

    // CRC values to log
    input  wire [15:0] received_crc,
    input  wire [15:0] calculated_crc,

    // Outputs
    output reg [15:0]  error_count,
    output reg [15:0]  last_received_crc,
    output reg [15:0]  last_calculated_crc,
    output reg         fault_flag
);

    always @(posedge clk) begin
        if (rst) begin
            error_count         <= 16'd0;
            last_received_crc   <= 16'd0;
            last_calculated_crc <= 16'd0;
            fault_flag          <= 1'b0;
        end
        else if (security_error) begin
            error_count         <= error_count + 1'b1;
            last_received_crc   <= received_crc;
            last_calculated_crc <= calculated_crc;
            fault_flag          <= 1'b1;
        end
    end

endmodule