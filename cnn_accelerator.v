`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.06.2025 23:05:32
// Design Name: 
// Module Name: cnn_accelerator
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


module cnn_accelerator(
input wire clk,
input wire rst_n,
input start,
input wire [6:0] row , col ,
input wire [32767:0] edge_buffer,
output reg cnn_valid,
output reg cnn_detect
);

//Hardcoded 3 x 3 kernel for convolution
reg signed [15:0] kernel [0:8];
reg signed [31:0] conv_sum;
reg [7:0] window [0:8];



initial begin
//example kernal edge enhancing
kernel[0] = -1 ; kernel[1] = -1 ; kernel[2] = -1;
kernel[3] = -1 ; kernel[4] = 8 ; kernel[5] = -1;
kernel[6] = -1 ; kernel[7] = -1 ; kernel[8] = -1;
end

always @ (posedge clk , negedge rst_n) begin
if (!rst_n) begin
cnn_valid <= 0;
cnn_detect <= 0;
end
else if ((row >= 1 && row < 63 && col >= 1 && col < 63) && start) begin
//fetch 3 x 3 window 
                window[0] = edge_buffer[(((row-7'd1)*64 + (col-7'd1))*8) +: 8];
                window[1] = edge_buffer[(((row-7'd1)*64 + col)*8) +: 8];
                window[2] = edge_buffer[(((row-7'd1)*64 + (col+7'd1))*8) +: 8];
                window[3] = edge_buffer[((row*64 + (col-7'd1))*8) +: 8];
                window[4] = edge_buffer[((row*64 + col)*8) +: 8];
                window[5] = edge_buffer[((row*64 + (col+7'd1))*8) +: 8];
                window[6] = edge_buffer[(((row+7'd1)*64 + (col-7'd1))*8) +: 8];
                window[7] = edge_buffer[(((row+7'd1)*64 + col)*8) +: 8];
                window[8] = edge_buffer[(((row+7'd1)*64 + (col+7'd1))*8) +: 8];


//convolution
conv_sum = window[0]*kernel[0] + window[1]*kernel[1] + window[2]*kernel[2] +
           window[3]*kernel[3] + window[4]*kernel[4] + window[5]*kernel[5] +
           window[6]*kernel[6] + window[7]*kernel[7] + window[8]*kernel[8];

//thershold for detection           
cnn_detect <= (conv_sum > 1000) ? 1 : 0;
cnn_valid <= 1;
end
else begin
cnn_detect <= 0;
cnn_valid <= 0;
end
end

endmodule 




