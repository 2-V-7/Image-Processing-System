`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.06.2025 16:47:35
// Design Name: 
// Module Name: grayscale_converter
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


module grayscale_converter(
input wire clk,
input wire rst_n,
input start,
input wire [23:0] pixel_in, //24-bit RGB
input wire pixel_valid,
output reg [7:0] gray_pixel,
output reg gray_valid
    );
    
 //Coefficients for grayscale : Y = 0.299R + 0.587G + 0.114B
 //Aproximated as fixed point : 77/256 , 150/256 , 29/256
 wire [7:0] R = pixel_in [23:16];
 wire [7:0] G = pixel_in [15:8];
 wire [7:0] B = pixel_in [7:0];
 reg [15:0] R_term , G_term , B_term ;
 
 always @ (posedge clk , negedge rst_n) begin
 if (!rst_n) begin
 gray_pixel <= 0;
 gray_valid <= 0;
 end
 else if (pixel_valid) begin
 R_term = R * 77;
 G_term = G * 150;
 B_term = B * 29;
 gray_pixel <= (R_term + G_term + B_term) >> 8;
 gray_valid <= 1;
 end
 else begin
 gray_valid <= 0;
 end
 
 end
 
 endmodule
