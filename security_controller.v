`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 17:56:59
// Design Name: 
// Module Name: security_controller
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


module security_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire        check_valid,
    input  wire [15:0] received_crc,
    input  wire [15:0] calculated_crc,

    output reg         security_ok,
    output reg         security_error,
    output reg         alert
);

    always @(posedge clk) begin
        if (rst) begin
            security_ok    <= 1'b0;
            security_error <= 1'b0;
            alert          <= 1'b0;
        end
        else if (check_valid) begin
            if (received_crc == calculated_crc) begin
                security_ok    <= 1'b1;
                security_error <= 1'b0;
                alert          <= 1'b0;
            end
            else begin
                security_ok    <= 1'b0;
                security_error <= 1'b1;
                alert          <= 1'b1;
            end
        end
    end

endmodule