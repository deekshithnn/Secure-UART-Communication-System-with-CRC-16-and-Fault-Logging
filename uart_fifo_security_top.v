`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 18:30:28
// Design Name: 
// Module Name: uart_fifo_security_top
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


module uart_fifo_security_top #(
    parameter CLKS_PER_BIT = 8,
    parameter FIFO_DEPTH = 16
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        rx,

    input  wire [15:0] received_crc,
    input  wire        check_valid,

    output wire [7:0]  received_data,
    output wire        data_valid,

    output wire [15:0] calculated_crc,

    output wire        security_ok,
    output wire        security_error,
    output wire        alert,

    output wire        fifo_full,
    output wire        fifo_empty
);

    // =========================================================
    // UART RX signals
    // =========================================================

    wire [7:0] uart_data;
    wire       uart_data_valid;

    // =========================================================
    // FIFO signals
    // =========================================================

    wire [7:0] fifo_data_out;
    reg        fifo_rd_en;
    wire       fifo_wr_en;

    assign fifo_wr_en = uart_data_valid;

    // =========================================================
    // UART Receiver
    // =========================================================

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(uart_data),
        .data_valid(uart_data_valid)
    );

    // =========================================================
    // FIFO
    // =========================================================

    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(FIFO_DEPTH)
    ) fifo_inst (
        .clk(clk),
        .rst(rst),

        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),

        .data_in(uart_data),
        .data_out(fifo_data_out),

        .full(fifo_full),
        .empty(fifo_empty)
    );

    // =========================================================
    // Read FIFO whenever data is available
    // =========================================================

    always @(posedge clk) begin
        if (rst) begin
            fifo_rd_en <= 1'b0;
        end
        else begin
            if (!fifo_empty)
                fifo_rd_en <= 1'b1;
            else
                fifo_rd_en <= 1'b0;
        end
    end

    // =========================================================
    // Output received data
    // =========================================================

    assign received_data = fifo_data_out;

    assign data_valid = fifo_rd_en;

    // =========================================================
    // CRC-16
    // =========================================================

    crc16 crc16_inst (
        .clk(clk),
        .rst(rst),
        .data_valid(data_valid),
        .data_in(received_data),
        .crc_out(calculated_crc)
    );

    // =========================================================
    // Security Controller
    // =========================================================

    security_controller security_inst (
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
