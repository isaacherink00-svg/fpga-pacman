`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 05:43:02 PM
// Design Name: 
// Module Name: ghost2
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


module ghost2 (
    input  logic        clk,
    input  logic        reset,
    output logic [9:0]  ghost_x,
    output logic [9:0]  ghost_y,
    input  logic [9:0]  drawX,
    input  logic [9:0]  drawY,
    output logic        ghost2_pixel,
    input  logic        frame_enable,
    input  logic        ghost_up_wall,
    input  logic        ghost_down_wall,
    input  logic        ghost_left_wall,
    input  logic        ghost_right_wall,
    input  logic [9:0]  BallX,
    input  logic [9:0]  BallY,
    input  logic [7:0]  keycode  
);
    
    // Parameters
    parameter INITIAL_GHOST_X = 10'd209;  
    parameter INITIAL_GHOST_Y = 10'd222;
    parameter MOVE_STEP = 1;
    parameter TILES_AHEAD = 4;           // How many tiles to look ahead
    

    localparam SPRITE_WIDTH = 16;
    localparam SPRITE_HEIGHT = 16;
    
    localparam MAZE_COLS = 28;
    localparam MAZE_ROWS = 31;
    parameter TILE_WIDTH = 17;
    parameter TILE_HEIGHT = 15;

    // Calculate target position ahead of Pacman based on direction
    logic [9:0] target_x, target_y;
    always_comb begin
        target_x = BallX;
        target_y = BallY;
        case (keycode)
            8'h1A: begin // W - Up
                target_y = (BallY > TILES_AHEAD * 15) ? BallY - TILES_AHEAD * 15 : BallY;
            end
            8'h16: begin // S - Down
                target_y = BallY + TILES_AHEAD * 15;
            end
            8'h04: begin // A - Left
                target_x = (BallX > TILES_AHEAD * 17) ? BallX - TILES_AHEAD * 17 : BallX;
            end
            8'h07: begin // D - Right
                target_x = BallX + TILES_AHEAD * 17;
            end
        endcase
    end


    logic signed [10:0] dx, dy;
    assign dx = $signed({1'b0, target_x}) - $signed({1'b0, ghost_x});
    assign dy = $signed({1'b0, target_y}) - $signed({1'b0, ghost_y});


    logic [9:0] left_edge, right_edge, top_edge, bottom_edge;
    
    assign left_edge = ghost_x - (SPRITE_WIDTH/2);
    assign right_edge = ghost_x + (SPRITE_WIDTH/2);
    assign top_edge = ghost_y - (SPRITE_HEIGHT/2);
    assign bottom_edge = ghost_y + (SPRITE_HEIGHT/2);




    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ghost_x <= INITIAL_GHOST_X;
            ghost_y <= INITIAL_GHOST_Y;
        end
        else if (frame_enable) begin
            if ($abs(dx) > $abs(dy)) begin
                // Move horizontally first
                if (dx > 0 && !ghost_right_wall)
                    ghost_x <= ghost_x + MOVE_STEP;
                    
                else if (dx < 0 && !ghost_left_wall)
                    ghost_x <= ghost_x - MOVE_STEP;
                    
                // Try vertical
                else if (dy > 0 && !ghost_down_wall)
                    ghost_y <= ghost_y + MOVE_STEP;
                    
                else if (dy < 0 && !ghost_up_wall)
                    ghost_y <= ghost_y - MOVE_STEP;
            end
            else begin
                if (dy > 0 && !ghost_down_wall)
                    ghost_y <= ghost_y + MOVE_STEP;
                    
                else if (dy < 0 && !ghost_up_wall)
                    ghost_y <= ghost_y - MOVE_STEP;
                    
                    
                else if (dx > 0 && !ghost_right_wall)
                    ghost_x <= ghost_x + MOVE_STEP;
                    
                else if (dx < 0 && !ghost_left_wall)
                    ghost_x <= ghost_x - MOVE_STEP;
            end
        end
    end


    logic [15:0] ghost2_sprite [0:15];
    initial begin
        ghost2_sprite[0]  = 16'h07E0;
        ghost2_sprite[1]  = 16'h0FF0;
        ghost2_sprite[2]  = 16'h1FF8;
        ghost2_sprite[3]  = 16'h3FFC;
        ghost2_sprite[4]  = 16'h7FFE;
        ghost2_sprite[5]  = 16'hFFFF;
        ghost2_sprite[6]  = 16'hFFFF;
        ghost2_sprite[7]  = 16'hFFFF;
        ghost2_sprite[8]  = 16'hFFFF;
        ghost2_sprite[9]  = 16'hFFFF;
        ghost2_sprite[10] = 16'hFFFF;
        ghost2_sprite[11] = 16'hFFFF;
        ghost2_sprite[12] = 16'hFFFF;
        ghost2_sprite[13] = 16'hCE73;
        ghost2_sprite[14] = 16'h8421;
        ghost2_sprite[15] = 16'h0000;
    end


    logic signed [9:0] ghost2_relX, ghost2_relY;
    
    assign ghost2_relX = drawX - ghost_x;
    assign ghost2_relY = drawY - ghost_y;
    
    logic within_ghost2_sprite;
    assign within_ghost2_sprite = (ghost2_relX >= 0) && (ghost2_relX < SPRITE_WIDTH) && (ghost2_relY >= 0) && (ghost2_relY < SPRITE_HEIGHT);

    // Output pixel value
    assign ghost2_pixel = within_ghost2_sprite ? ghost2_sprite[ghost2_relY][ghost2_relX] : 1'b0;

endmodule
