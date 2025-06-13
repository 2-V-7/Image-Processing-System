`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.06.2025 16:49:08
// Design Name: 
// Module Name: image_processing_system
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

// Top level module
module image_processing_system(
input wire clk,                     //system clock
input wire rst_n,                   //active-low reset
input wire [23:0] pixel_in ,        //24-bit RGB input pixel (8-bits per channel)
input wire pixel_valid            //valid signal for input pixel
);

// Internal signals and memories
reg [32767:0] image_buffer ; //64 x 64 grayscale image storage (4096 * 8 bits)
reg [32767:0] edge_buffer ;  // edge detected image storage
reg [4095:0] output_buffer ; // final 64 x 64 2-scale image storage
reg [6:0] row , col; //image coordinates (0 to 63)
reg [11:0] addr ; //memory address (row * 64 + colunm)

// State machine states
// Define states using parameters
parameter [2:0] IDLE       = 2'b00;
parameter [2:0] GRAYSCALE  = 2'b01;
parameter [2:0] EDGE_DETECT = 2'b10;
parameter [2:0] CNN_PROCESS = 2'b11;

// Declare state registers
reg [1:0] state;
reg [1:0] next_state;

//Grayscale conversion signals
wire [7:0] gray_pixel;
wire gray_valid;

//Sobel edge detection signals
wire [7:0] edge_pixel;
wire edge_valid;

//CNN accelerator signals
wire cnn_valid;
wire cnn_detect;

//Instantiate sub-modules

grayscale_converter gray_conv (
.clk(clk),
.rst_n(rst_n),
.start(state == GRAYSCALE),
.pixel_in(pixel_in),
.pixel_valid(pixel_valid),
.gray_pixel(gray_pixel),
.gray_valid(gray_valid)
);

sobel_edge_detector sobel (
.clk(clk),
.rst_n(rst_n),
.start(state == EDGE_DETECT),
.row(row),
.col(col),
.image_buffer(image_buffer),
.edge_pixel(edge_pixel),
.edge_valid(edge_valid)
);

cnn_accelerator cnn (
.clk(clk),
.rst_n(rst_n),
.start(state == CNN_PROCESS),
.row(row),
.col(col),
.edge_buffer(edge_buffer),
.cnn_valid(cnn_valid),
.cnn_detect(cnn_detect)
);

//Address calculation
always @ (posedge clk , negedge rst_n) begin
if (!rst_n) begin
addr <= 0;
row <= 0;
col <= 0;
end
else begin
addr <= row*64 + col;
if ((state == GRAYSCALE && pixel_valid) || state == EDGE_DETECT || state == CNN_PROCESS) begin
if (col == 7'd63) begin
col <= 0;
row <= row + 7'd1;
end
else begin
col <= col + 7'd1;
end
end
end
end

//State machine : Combinational logic
always @ (*) begin
case (state)
IDLE : if (pixel_valid) next_state = GRAYSCALE;
GRAYSCALE : if (gray_valid && addr == 12'd4095) begin
                                                next_state = EDGE_DETECT;
                                                row = 0;
                                                col = 0;
                                                addr = 0;
                                                end
EDGE_DETECT : if (addr == 12'd4095) begin
                                    next_state = CNN_PROCESS;
                                    row = 0;
                                    col = 0;
                                    addr = 0;
                                    end
CNN_PROCESS : if (addr == 12'd4095) begin
                                    next_state = IDLE;
                                    row = 0;
                                    col = 0;
                                    addr = 0;
                                    end
endcase
end

//State machine : Sequential logic
always @ (posedge clk , negedge rst_n) begin
if (!rst_n) begin
state <= IDLE;
image_buffer <= 0;
edge_buffer <= 0;
output_buffer <= 0;
end
else begin
state <= next_state;

//Store grayscale pixels
if (state == GRAYSCALE && gray_valid)
image_buffer[addr*8 +: 8] <= gray_pixel;

//Store edge detected pixel
if (state == EDGE_DETECT && edge_valid)
edge_buffer[addr*8 +: 8] <= edge_pixel;

//Output CNN result
if (state == CNN_PROCESS && cnn_valid) begin
output_buffer[addr] <= cnn_detect;
end
end


end

endmodule
