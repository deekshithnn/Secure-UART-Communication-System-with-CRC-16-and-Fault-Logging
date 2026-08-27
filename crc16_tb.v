`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 17:52:05
// Design Name: 
// Module Name: crc16_tb
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

module crc16_tb;

    reg        clk;
    reg        rst;
    reg        data_valid;
    reg [7:0]  data_in;
    wire [15:0] crc_out;

    crc16 uut (
        .clk(clk),
        .rst(rst),
        .data_valid(data_valid),
        .data_in(data_in),
        .crc_out(crc_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        data_valid = 0;
        data_in = 8'h00;

        #20;
        rst = 0;

        // Send "123456789"
        send_byte(8'h31);
        send_byte(8'h32);
        send_byte(8'h33);
        send_byte(8'h34);
        send_byte(8'h35);
        send_byte(8'h36);
        send_byte(8'h37);
        send_byte(8'h38);
        send_byte(8'h39);

        #20;

        $display("CRC = %h", crc_out);

        #20;
        $finish;
    end

    task send_byte(input [7:0] data);
        begin
            @(negedge clk);
            data_in = data;
            data_valid = 1;

            @(negedge clk);
            data_valid = 0;
        end
    endtask

endmodule
