`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 12:52:51 AM
// Design Name: 
// Module Name: collision_detector
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


module collision_detector (
    input  logic [9:0] ghost_x,
    input  logic [9:0] ghost_y,
    input  logic [9:0] pacman_x,
    input  logic [9:0] pacman_y,
    input  logic [9:0] sprite_size, 
    output logic collision           // 1 when collision occurs
);

    // Distance between ghost and pacman
    logic [9:0] dx, dy;
    assign dx = (ghost_x > pacman_x) ? (ghost_x - pacman_x) : (pacman_x - ghost_x);
    assign dy = (ghost_y > pacman_y) ? (ghost_y - pacman_y) : (pacman_y - ghost_y);


    assign collision = (dx < sprite_size) && (dy < sprite_size);

endmodule
