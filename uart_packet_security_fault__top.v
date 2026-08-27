`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 18:46:25
// Design Name: 
// Module Name: uart_packet_security_fault__top
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

module uart_packet_security_fault_top #(
    parameter CLKS_PER_BIT = 8,
    parameter FIFO_DEPTH   = 16
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        rx,

    // Packet data outputs
    output wire [7:0]  sensor_data,
    output wire        sensor_valid,

    // CRC information
    output wire [15:0] calculated_crc,
    output wire [15:0] received_crc,

    // Security outputs
    output wire        security_ok,
    output wire        security_error,
    output wire        alert,

    // Fault logger outputs
    output wire [15:0] error_count,
    output wire [15:0] last_received_crc,
    output wire [15:0] last_calculated_crc,
    output wire        fault_flag,

    // FIFO status
    output wire        fifo_full,
    output wire        fifo_empty
);

    wire [7:0] uart_data;
    wire       uart_data_valid;

    wire [7:0] fifo_data_out;
    reg        fifo_rd_en;

    wire check_valid;
    wire fifo_data_valid;

    // UART Receiver
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(uart_data),
        .data_valid(uart_data_valid)
    );

    // FIFO
    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(FIFO_DEPTH)
    ) fifo_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(uart_data_valid),
        .rd_en(fifo_rd_en),
        .data_in(uart_data),
        .data_out(fifo_data_out),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    // FIFO Read Control
    always @(posedge clk) begin
        if (rst)
            fifo_rd_en <= 1'b0;
        else if (!fifo_empty)
            fifo_rd_en <= 1'b1;
        else
            fifo_rd_en <= 1'b0;
    end

    assign fifo_data_valid = fifo_rd_en && !fifo_empty;

    // Packet Parser
    packet_parser parser_inst (
        .clk(clk),
        .rst(rst),
        .data_in(fifo_data_out),
        .data_valid(fifo_data_valid),
        .sensor_data(sensor_data),
        .sensor_valid(sensor_valid),
        .received_crc(received_crc),
        .check_valid(check_valid)
    );

    // CRC-16
    crc16 crc16_inst (
        .clk(clk),
        .rst(rst),
        .data_valid(sensor_valid),
        .data_in(sensor_data),
        .crc_out(calculated_crc)
    );

    // Security Controller
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

    // Fault Logger
    fault_logger fault_logger_inst (
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

endmodule
