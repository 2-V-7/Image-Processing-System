`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.06.2025 17:05:31
// Design Name: 
// Module Name: sobel_edge_detector
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


module sobel_edge_detector(
input wire clk,
input wire rst_n,
input start,
input wire [6:0] row , col,
input wire [32767:0] image_buffer,
output reg [7:0] edge_pixel,
output reg edge_valid
);

//Sobel kernels
reg signed [15:0] Gx , Gy;
reg [7:0] pixel_window [0:8]; //3 x 3 window



always @ (posedge clk , negedge rst_n) begin
if (!rst_n) begin
edge_pixel <= 0;
edge_valid <= 0;
end
else if ((row >= 1 && row < 63 && col >= 1 && col < 63) && start) begin
//Fetch 3 x 3 window
            pixel_window[0] = image_buffer[(((row-7'd1)*64 + (col-7'd1))*8) +: 8];
            pixel_window[1] = image_buffer[(((row-7'd1)*64 + col)*8) +: 8];
            pixel_window[2] = image_buffer[(((row-7'd1)*64 + (col+7'd1))*8) +: 8];
            pixel_window[3] = image_buffer[((row*64 + (col-7'd1))*8) +: 8];
            pixel_window[4] = image_buffer[((row*64 + col)*8) +: 8];
            pixel_window[5] = image_buffer[((row*64 + (col+7'd1))*8) +: 8];
            pixel_window[6] = image_buffer[(((row+7'd1)*64 + (col-7'd1))*8) +: 8];
            pixel_window[7] = image_buffer[(((row+7'd1)*64 + col)*8) +: 8];
            pixel_window[8] = image_buffer[(((row+7'd1)*64 + (col+7'd1))*8) +: 8];
//Compute Gx and Gy
Gx = pixel_window[2] + 2*pixel_window[5] + pixel_window[8] - (pixel_window[0] + 2*pixel_window[3] + pixel_window[6]);
Gy = pixel_window[6] + 2*pixel_window[7] + pixel_window[8] - (pixel_window[0] + 2*pixel_window[1] + pixel_window[2]);

//Approximate magnitude |Gx| + |Gy|
edge_pixel <= (Gx[15] ? -Gx : Gx) + (Gy[15] ? -Gy : Gy) ;
edge_valid <= 1;
end
else begin
edge_pixel <= 0;
edge_valid <= 0;
end

end

endmodule 



