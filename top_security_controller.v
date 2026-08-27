`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 18:11:26
// Design Name: 
// Module Name: top_security_controller
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

module top_security_controller (
    input  wire        clk,
    input  wire        rst,

    // Input data for CRC calculation
    input  wire        data_valid,
    input  wire [7:0]  data_in,

    // CRC received with the message
    input  wire [15:0] received_crc,

    // Start security comparison
    input  wire        check_valid,

    // Outputs
    output wire [15:0] calculated_crc,
    output wire        security_ok,
    output wire        security_error,
    output wire        alert
);

    // CRC-16 module
    crc16 crc_unit (
        .clk(clk),
        .rst(rst),
        .data_valid(data_valid),
        .data_in(data_in),
        .crc_out(calculated_crc)
    );

    // Security Controller module
    security_controller security_unit (
        .clk(clk),
        .rst(rst),
        .check_valid(check_valid),
        .received_crc(received_crc),
        .calculated_crc(calculated_crc),
        .security_ok(security_ok),
        .security_error(security_error),
        .alert(alert)
    );

endmodule
