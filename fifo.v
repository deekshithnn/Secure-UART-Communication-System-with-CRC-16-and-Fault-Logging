`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 07:21:35
// Design Name: 
// Module Name: fifo
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

module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                  clk,
    input  wire                  rst,

    input  wire                  wr_en,
    input  wire                  rd_en,

    input  wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out,

    output wire                  full,
    output wire                  empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;

    reg [ADDR_WIDTH:0] count;

    // FIFO status
    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    // Read data
    assign data_out = mem[rd_ptr];

    always @(posedge clk) begin

        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end

        else begin

            // Write
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Count
            case ({wr_en && !full, rd_en && !empty})

                2'b10:
                    count <= count + 1'b1;

                2'b01:
                    count <= count - 1'b1;

                default:
                    count <= count;

            endcase

        end
    end

endmodule
