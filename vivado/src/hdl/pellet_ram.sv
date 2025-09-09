`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 11:58:37 PM
// Design Name: 
// Module Name: pellet_ram
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


module pellet_ram (
    input  logic        clk,
    input  logic        reset,
    input  logic [4:0]  read_row,
    input  logic [4:0]  read_col,
    input  logic [4:0]  pacman_row,
    input  logic [4:0]  pacman_col,
    input  logic        frame_clk,
    output logic        pellet_data,
    output logic        pellet_collected,
    output logic        all_pellets_cleared
);

    logic pellets [0:30][0:27];
    logic [9:0] pellets_remaining;
    

    parameter INITIAL_PELLETS = 10'd298;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            // Initialize pellets
            for (int i = 0; i < 31; i++) begin
                for (int j = 0; j < 28; j++) begin
                    pellets[i][j] <= 1'b1;
                end
            end
            
            pellets[14][26] <= 1'b0;
            
            pellets[5][13] <= 1'b0;  // Pacman spawn
            pellets[5][14] <= 1'b0;
           
            pellets[12][13] <= 1'b0;
            pellets[12][14] <= 1'b0;
            
            pellets[13][16] <= 1'b0;  // Top row
            pellets[13][15] <= 1'b0;
            pellets[13][14] <= 1'b0;
            pellets[13][13] <= 1'b0;  
            pellets[13][12] <= 1'b0;
            pellets[13][11] <= 1'b0;
            
            pellets[14][0] <= 1'b0;  // Middle
            
            pellets[14][16] <= 1'b0;  // Middle
            pellets[14][15] <= 1'b0;
            pellets[14][14] <= 1'b0;
            pellets[14][13] <= 1'b0;  
            pellets[14][12] <= 1'b0;
            pellets[14][11] <= 1'b0;
            
            pellets[15][16] <= 1'b0;  // Bottom
            pellets[15][15] <= 1'b0;
            pellets[15][14] <= 1'b0;
            pellets[15][13] <= 1'b0;  
            pellets[15][12] <= 1'b0;
            pellets[15][11] <= 1'b0;
            
            pellets[16][13] <= 1'b0;            //Bottom exit 
            pellets[16][14] <= 1'b0;
           
            
            pellets_remaining <= INITIAL_PELLETS;
            pellet_collected <= 0;
            all_pellets_cleared <= 0;
        end
        else if (frame_clk) begin
            if (pellets[pacman_row][pacman_col]) begin
                pellets[pacman_row][pacman_col] <= 0;
                pellet_collected <= 1;
                
                if (pellets_remaining > 0)
                    pellets_remaining <= pellets_remaining - 1;
                    
                // Check win
                if (pellets_remaining == 1)  
                    all_pellets_cleared <= 1;
            end
            else begin
                pellet_collected <= 0;
            end
        end
    end
    
    assign pellet_data = pellets[read_row][read_col];

endmodule