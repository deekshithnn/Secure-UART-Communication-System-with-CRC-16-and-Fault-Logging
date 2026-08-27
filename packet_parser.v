`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 07:28:26
// Design Name: 
// Module Name: packet_parser
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
module packet_parser (
    input  wire       clk,
    input  wire       rst,

    // Input byte from FIFO
    input  wire [7:0] data_in,
    input  wire       data_valid,

    // Parsed sensor data
    output reg [7:0]  sensor_data,
    output reg        sensor_valid,

    // Received CRC
    output reg [15:0] received_crc,
    output reg        check_valid
);

    localparam WAIT_HEADER = 2'd0;
    localparam READ_DATA   = 2'd1;
    localparam READ_CRC_H  = 2'd2;
    localparam READ_CRC_L  = 2'd3;

    reg [1:0] state;
    reg [7:0] crc_high;

    always @(posedge clk) begin
        if (rst) begin
            state         <= WAIT_HEADER;
            sensor_data   <= 8'h00;
            sensor_valid  <= 1'b0;
            received_crc  <= 16'h0000;
            check_valid   <= 1'b0;
            crc_high      <= 8'h00;
        end
        else begin
            sensor_valid <= 1'b0;
            check_valid  <= 1'b0;

            if (data_valid) begin
                case (state)

                    // Wait for packet header: 0xAA
                    WAIT_HEADER: begin
                        if (data_in == 8'hAA)
                            state <= READ_DATA;
                    end

                    // Read sensor data byte
                    READ_DATA: begin
                        sensor_data  <= data_in;
                        sensor_valid <= 1'b1;
                        state        <= READ_CRC_H;
                    end

                    // Read CRC high byte
                    READ_CRC_H: begin
                        crc_high <= data_in;
                        state    <= READ_CRC_L;
                    end

                    // Read CRC low byte
                    READ_CRC_L: begin
                        received_crc <= {crc_high, data_in};
                        check_valid  <= 1'b1;
                        state        <= WAIT_HEADER;
                    end

                    default: begin
                        state <= WAIT_HEADER;
                    end

                endcase
            end
        end
    end

endmodule
