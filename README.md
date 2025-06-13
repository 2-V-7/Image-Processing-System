## Image-Processing-System
Verilog-based image processing system for FPGA with grayscale conversion, Sobel edge detection, and CNN

# Overview
This project implements a real-time image processing system in Verilog, targeting FPGA platforms. The system processes 64x64 RGB images through a pipeline that includes:

1. Grayscale Conversion : Converts RGB pixels to 8-bit grayscale using the luminance formula (Y = 0.299R + 0.587G + 0.114B).
2. Sobel Edge Detection : Applies 3x3 Sobel kernels to detect edges.
3. CNN Accelerator : Performs convolution with a hardcoded 3x3 kernel for object detection.

The system uses a finite state machine (FSM) to manage data flow and stores intermediate results in memory buffers.
The FSM transitions through four states: IDLE, GRAYSCALE, EDGE_DETECT, and CNN_PROCESS.
A testbench generates test patterns and validates the output.

# Features
Processes 64x64 RGB images (24-bit input) in real-time.
Modular design with separate modules for grayscale conversion, edge detection, and CNN processing.
Fixed-point arithmetic for grayscale conversion (77/256R + 150/256G + 29/256B).
Sobel edge detection with approximate gradient magnitude (|Gx| + |Gy|).
CNN-based detection with a 3x3 edge-enhancing kernel and thresholding.
Testbench with customizable test patterns (e.g., monument, person, tripod shapes).
Output saved as a 64x64 binary matrix for verification.

# System Architecture
The system consists of four main modules:

1. Top-Level Module (image_processing_system): Manages the FSM and coordinates data flow between sub-modules.
2. Grayscale Converter (grayscale_converter): Converts RGB pixels to grayscale.
3. Sobel Edge Detector (sobel_edge_detector): Computes edge gradients using Sobel kernels.
4. CNN Accelerator (cnn_accelerator): Performs convolution and thresholding for object detection.

Data is stored in three buffers:

1. image_buffer: 64x64 grayscale image (32768 bits).
2. edge_buffer: 64x64 edge-detected image (32768 bits).
3. output_buffer: 64x64 binary detection results (4096 bits).

# Modules
Module Name	                              Description

1. image_processing_system	              Top-level module with FSM and memory buffers.
2. grayscale_converter	Converts          24-bit RGB to 8-bit grayscale using fixed-point arithmetic.
3. sobel_edge_detector	Applies 3x3       Sobel kernels to compute edge gradients.
4. cnn_accelerator	                      Performs convolution with a 3x3 kernel and thresholds for object detection.
5. tb_image_processing_system	            Testbench for simulation and output validation.

# Usage
1. Simulation:
Run the testbench (tb_image_processing_system.v) in your simulator.
The testbench generates a 64x64 test pattern (e.g., monument, person, tripod) and processes it through the pipeline.
Output is saved to output_matrix.txt as a 64x64 binary matrix.
Waveforms are dumped to waves.vcd for analysis.

2. FPGA Deployment:
Synthesize the design using an FPGA tool (e.g., Vivado).
Map the top-level module inputs/outputs to FPGA pins.
Provide a clock signal (e.g., 100 MHz) and pixel input stream.

3. Customizing Test Patterns:
Modify the testbench to create new test patterns by editing the pixel generation loop in tb_image_processing_system.v.
Example test pattern includes a gray background, monument, person, and tripod shapes.

# Testbench
The testbench (tb_image_processing_system.v) simulates the system by:

Generating a 64x64 RGB test image with features like a monument (cols 55-57, rows 10-40), person (rows 30-40, cols 20-25), and tripod (converging lines).
Driving the pixel_in and pixel_valid signals.
Monitoring FSM states, row, and column progress.
Saving the final binary output to output_matrix.txt.
Dumping waveforms to waves.vcd for debugging.

# Results
Output: A 64x64 binary matrix (output_matrix.txt) where 1 indicates detected objects and 0 indicates background.
Performance: Processes 64x64 images in real-time, with latency dependent on clock frequency (100 MHz).
Verification: Waveform analysis confirms correct FSM transitions and data flow.
