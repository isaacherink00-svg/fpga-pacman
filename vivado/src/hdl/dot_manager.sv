`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 06:34:21 PM
// Design Name: 
// Module Name: dot_manager
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


module dot_manager (
    input  logic        clk,
    input  logic        reset,
    input  logic [9:0]  drawX,
    input  logic [9:0]  drawY,
    input  logic [4:0]  current_tile_row,
    input  logic [4:0]  current_tile_col,
    input  logic        maze_wall,
    output logic        dot_display
);

    parameter TILE_WIDTH = 17;
    parameter TILE_HEIGHT = 15;
    parameter DOT_SIZE = 2;
    
    // Memory array for dots
    logic dot_array[31:0][28:0];
    

    logic [4:0] tile_x, tile_y;
    logic [4:0] center_x, center_y;
    
    assign tile_x = drawX % TILE_WIDTH;
    assign tile_y = drawY % TILE_HEIGHT;
    
    assign center_x = TILE_WIDTH/2;
    assign center_y = TILE_HEIGHT/2;
    

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int row = 0; row < 31; row++) begin
                for (int col = 0; col < 28; col++) begin
                   
                        dot_array[row][col] <= 1'b1;
                    end
                end
            end
        end
 
    
    // Dot display logic
    always_comb begin
        if (current_tile_row < 31 && current_tile_col < 28 && dot_array[current_tile_row][current_tile_col] && !maze_wall &&
        
            tile_x >= center_x - DOT_SIZE &&
            tile_x <= center_x + DOT_SIZE &&
            tile_y >= center_y - DOT_SIZE &&
            tile_y <= center_y + DOT_SIZE) begin
            dot_display = 1'b1;
        end else begin
            dot_display = 1'b0;
        end
    end

endmodule
