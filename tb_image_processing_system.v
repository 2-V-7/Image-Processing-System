`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.06.2025 23:31:33
// Design Name: 
// Module Name: tb_image_processing_system
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

module tb_image_processing_system();

// Parameters
parameter CLK_PERIOD = 10; // 100 MHz clock

// Signals
reg clk;
reg rst_n;
reg [23:0] pixel_in;
reg pixel_valid;

// Instantiate DUT
image_processing_system dut (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_in(pixel_in),
    .pixel_valid(pixel_valid)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test pattern generation
integer row, col;
integer out_file;
initial begin
    // Initialize
    rst_n = 0;
    pixel_in = 0;
    pixel_valid = 0;
    
    // Open output file
    out_file = $fopen("output_matrix.txt", "w");
    if (!out_file) begin
        $display("Error: Could not open output file");
        $finish;
    end
    
    // Reset
    #100;
    rst_n = 1;
    /*
    // Send test pattern (64x64 image)
    for (row = 0; row < 64; row = row + 1) begin
        for (col = 0; col < 64; col = col + 1) begin
            // Create test pattern with different features:
            // - White square in center (20x20)
            // - Red horizontal line
            // - Green vertical line
            // - Blue diagonal
            
            // Center square (rows 22-41, cols 22-41)
            if (row >= 22 && row < 42 && col >= 22 && col < 42)
                pixel_in = 24'hFFFFFF; // White
            // Horizontal line (row 10)
            else if (row == 10)
                pixel_in = 24'hFF0000; // Red
            // Vertical line (col 10)
            else if (col == 10)
                pixel_in = 24'h00FF00; // Green
            // Diagonal line (row == col)
            else if (row == col)
                pixel_in = 24'h0000FF; // Blue
            else
                pixel_in = 24'h404040; // Gray background
          */  
          // Send test pattern (64x64 image)
    for (row = 0; row < 64; row = row + 1) begin
        for (col = 0; col < 64; col = col + 1) begin
            // Default: gray background (equivalent to 0x808080 in grayscale)
            pixel_in = 24'h808080; // Medium gray background
            
            // Monument in the background (tall, narrow rectangle, cols 55-57, rows 10-40)
            if (col >= 55 && col <= 57 && row >= 10 && row <= 40) begin
                pixel_in = 24'hA0A0A0; // Lighter gray for monument
            end
            
            // Person: Simplified as a small black rectangle (rows 30-40, cols 20-25)
            if (row >= 30 && row <= 40 && col >= 20 && col <= 25) begin
                pixel_in = 24'h404040; // Dark gray (almost black) for person
            end
            
            // Surveying instrument: Small square on top of tripod (rows 25-28, cols 30-33)
            if (row >= 25 && row <= 28 && col >= 30 && col <= 33) begin
                pixel_in = 24'h606060; // Medium-dark gray for instrument
            end
            
            // Tripod: Three lines converging at (row 28, col 31)
            // Left leg: from (row 28, col 31) to (row 40, col 25)
            if (row >= 28 && row <= 40 && col == 31 - (row - 28)/2 && col >= 25) begin
                pixel_in = 24'h606060; // Medium-dark gray for tripod
            end
            // Right leg: from (row 28, col 31) to (row 40, col 37)
            if (row >= 28 && row <= 40 && col == 31 + (row - 28)/2 && col <= 37) begin
                pixel_in = 24'h606060; // Medium-dark gray for tripod
            end
            // Middle leg: from (row 28, col 31) to (row 40, col 31)
            if (row >= 28 && row <= 40 && col == 31) begin
                pixel_in = 24'h606060; // Medium-dark gray for tripod
            end
            
            pixel_valid = 1;
            @(posedge clk);
            #1;
        end
    end 
    
    /*
    // Send test pattern (64x64 image)
    for (row = 0; row < 64; row = row + 1) begin
        for (col = 0; col < 64; col = col + 1) begin
            // Default: black background
            pixel_in = 24'h000000; // Black
            
            // Set 5 random pixels to red
            // Hardcoded random coordinates: (5,10), (15,25), (30,40), (45,15), (60,50)
            if ((row == 5 && col == 10) ||
                (row == 15 && col == 25) ||
                (row == 30 && col == 40) ||
                (row == 45 && col == 15) ||
                (row == 60 && col == 50))
                pixel_in = 24'hFF0000; // Red
            
            pixel_valid = 1;
            @(posedge clk);
            #1;
        end
    end
    */
    
    // End of frame
    pixel_valid = 0;
    pixel_in = 0;
    
    // Wait for processing to complete
    wait(dut.state == dut.IDLE);
    #100;
    
    // Save output buffer to file
    $display("Writing output to file...");
    for (row = 0; row < 64; row = row + 1) begin
        for (col = 0; col < 64; col = col + 1) begin
            $fwrite(out_file, "%1d ", dut.output_buffer[row*64 + col]);
        end
        $fwrite(out_file, "\n");
    end
    $fclose(out_file);
    
    // Finish simulation
    $display("Simulation completed successfully");
    $finish;
end

// Monitor progress
initial begin
    $timeformat(-9, 2, " ns", 10);
    $monitor("Time=%t State=%b Row=%0d Col=%0d", 
             $time, dut.state, dut.row, dut.col);
end

// Waveform dumping
initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_image_processing_system);
end

endmodule
