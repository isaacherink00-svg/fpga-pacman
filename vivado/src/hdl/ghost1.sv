`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 01:58:03 PM
// Design Name: 
// Module Name: ghost1
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


module ghost1 (
    input  logic        clk,       
    input  logic        reset,      
    output logic [9:0]  ghost_x,   
    output logic [9:0]  ghost_y,     
    input  logic [9:0] drawX,        
    input  logic [9:0] drawY,       
    output logic ghost1_pixel,         // 1 if the pixel is part of the ghost, else 0
    
    input  logic        frame_enable,  
    input  logic        ghost_up_wall,      
    input  logic        ghost_down_wall,     
    input  logic        ghost_left_wall,     
    input  logic        ghost_right_wall,     
    
    input  logic [9:0]  BallX,
    input  logic [9:0]  BallY
);

 
    parameter INITIAL_GHOST_X = 10'd225;
    parameter INITIAL_GHOST_Y = 10'd222;
    parameter MOVE_STEP = 1; 
    parameter TILE_WIDTH = 17;
    parameter TILE_HEIGHT = 15; 
    
    parameter [9:0] GHOST_X_Min=0;     
    parameter [9:0] GHOST_X_Max=639;    
    parameter [9:0] GHOST_Y_Min=0;     
    parameter [9:0] GHOST_Y_Max=479;     
    
    localparam SPRITE_WIDTH  = 16;
    localparam SPRITE_HEIGHT = 16;
    
    parameter MOVE_DELAY = 50;

 /*   logic [3:0] ghost1_relX;
    logic [3:0] ghost1_relY;

 */   
    
    logic signed [9:0] ghost1_relX;
    logic signed [9:0] ghost1_relY;
    
    assign ghost1_relX = drawX - ghost_x;
    assign ghost1_relY = drawY - ghost_y;
    
    logic within_ghost1_sprite;
    assign within_ghost1_sprite = (ghost1_relX >= 0) && (ghost1_relX < 16) && (ghost1_relY >= 0) && (ghost1_relY < 16);
    
    // Determine if the current pixel is part of the ghost
    assign ghost1_pixel = within_ghost1_sprite ? ghost1_sprite[ghost1_relY][ghost1_relX] : 1'b0;

 /* 
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ghost_x <= INITIAL_GHOST_X;
            ghost_y <= INITIAL_GHOST_Y;
        end else begin
            ghost_x <= ghost_x;
            ghost_y <= ghost_y;
        end
    end
*/
logic [15:0] ghost1_sprite [0:15];
/*
initial begin
        integer i;
        for (i = 0; i < 16; i = i + 1) begin
            ghost1_sprite[i] = 16'hFFFF;
        end
    end
*/
    
    // Initialize the ghost sprite
    initial begin
        ghost1_sprite[0]  = 16'h07E0;
        ghost1_sprite[1]  = 16'h0FF0;
        ghost1_sprite[2]  = 16'h1FF8;
        ghost1_sprite[3]  = 16'h3FFC;
        ghost1_sprite[4]  = 16'h7FFE;
        ghost1_sprite[5]  = 16'hFFFF;
        ghost1_sprite[6]  = 16'hFFFF;
        ghost1_sprite[7]  = 16'hFFFF;
        ghost1_sprite[8]  = 16'hFFFF;
        ghost1_sprite[9]  = 16'hFFFF;
        ghost1_sprite[10] = 16'hFFFF;
        ghost1_sprite[11] = 16'hFFFF;
        ghost1_sprite[12] = 16'hFFFF;
        ghost1_sprite[13] = 16'hCE73;
        ghost1_sprite[14] = 16'h8421;
        ghost1_sprite[15] = 16'h0000;
    end

//Movement
    logic signed [10:0] dx, dy;
    assign dx = $signed({1'b0, BallX}) - $signed({1'b0, ghost_x});
    assign dy = $signed({1'b0, BallY}) - $signed({1'b0, ghost_y});
    
    logic [9:0] current_tile_x, current_tile_y;
    
    assign current_tile_x = ghost_x / TILE_WIDTH;
    assign current_tile_y = ghost_y / TILE_HEIGHT;


    logic can_move_right, can_move_left, can_move_up, can_move_down;
    
    assign can_move_right = !ghost_right_wall && (ghost_x + SPRITE_WIDTH + MOVE_STEP <= 639);
    assign can_move_left = !ghost_left_wall && (ghost_x >= MOVE_STEP);
    assign can_move_up = !ghost_up_wall && (ghost_y >= MOVE_STEP);
    assign can_move_down = !ghost_down_wall && (ghost_y + SPRITE_HEIGHT + MOVE_STEP <= 479);

    logic game_over;

    // Movement logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ghost_x <= INITIAL_GHOST_X;
            ghost_y <= INITIAL_GHOST_Y;
        end
        else if (frame_enable) begin
 
            if ($abs(dx) > $abs(dy)) begin
                if (dx > 0 && can_move_right)
                    ghost_x <= ghost_x + MOVE_STEP;
                    
                else if (dx < 0 && can_move_left)
                    ghost_x <= ghost_x - MOVE_STEP;
                    
                else if (dy > 0 && can_move_down)
                    ghost_y <= ghost_y + MOVE_STEP;
                    
                else if (dy < 0 && can_move_up)
                    ghost_y <= ghost_y - MOVE_STEP;
                    
            end
            else begin
                if (dy > 0 && can_move_down)
                    ghost_y <= ghost_y + MOVE_STEP;
                    
                else if (dy < 0 && can_move_up)
                    ghost_y <= ghost_y - MOVE_STEP;
                    
               
                else if (dx > 0 && can_move_right)
                    ghost_x <= ghost_x + MOVE_STEP;
                    
                else if (dx < 0 && can_move_left)
                    ghost_x <= ghost_x - MOVE_STEP;
            end
        end
    end
    
    



/*


always_ff @(posedge clk) begin
    case (ghost_dir)
        UP:    if (!ghost_up_wall)    ghost_y <= ghost_y - 1;
        DOWN:  if (!ghost_down_wall)  ghost_y <= ghost_y + 1;
        LEFT:  if (!ghost_left_wall)  ghost_x <= ghost_x - 1; 
        RIGHT: if (!ghost_right_wall) ghost_x <= ghost_x + 1;
    endcase
end

    logic [1:0] available_dirs;
*/

    //logic [1:0] random_dir = lfsr[7:6];

    //logic [3:0] movement_counter;
    //logic [1:0] available_dirs;


/*
logic [5:0] movement_counter;
// Increment movement counter
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        movement_counter <= 4'd0;
     //   lfsr <= 4'b1011;
    end else if (frame_enable) begin
        if (movement_counter == MOVE_DELAY)
            movement_counter <= 0;
        else
            movement_counter <= movement_counter + 1;

        // Update LFSR
    //    lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]};
    end
end

*/

 
/*
0000011111100000
0000111111110000
0001111111111000
0011111111111100
0111111111111110
1111111111111111
1111111111111111
1111111111111111
1111111111111111
1111111111111111
1111111111111111
1111111111111111
1111111111111111
1100111001110011
1000010000100001
0000000000000000
*/

endmodule
