`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 02:18:36 AM
// Design Name: 
// Module Name: maze_bram1
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


module maze_bram1 (
    input  logic [4:0] tile_row,  
    input  logic [4:0] tile_col,   
    output logic [0:0]  maze_data,
    input  logic [4:0] next_tile_row,    
    input  logic [4:0] next_tile_col,   
    output logic [0:0] next_maze_data,    
    input logic clk_25MHz,
    
    input  logic        frame_clk
);

    logic [9:0] maze_address;
    logic [9:0] next_tile_address;

    // Calculate the linear address from tile_row and tile_col
    assign maze_address = (tile_row * 28) + tile_col; // Assuming 28 columns in the maze
    assign next_tile_address = (next_tile_row * 28) + next_tile_col;

    // Instantiate the BRAM
    maze_memory1 maze_bram_inst (
        .clka(clk_25MHz),
        .addra(maze_address),
        .douta(maze_data),
        .clkb(clk_25MHz),
        .addrb(next_tile_address),
        .doutb(next_maze_data)
    );
endmodule



