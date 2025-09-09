//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//                                                                       --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input  logic [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
                       output logic [3:0]  Red, Green, Blue,
                       input logic clk_25MHz,
                       input logic maze_data,
                     //  input logic within_maze
                     
                        input  logic [9:0] ghost_x, 
                        input  logic [9:0] ghost_y,
                        input logic     ghost1_pixel,
                        input logic     ghost2_pixel,
                        input logic dot_display,
                        input logic pellet_data,
                        input logic [7:0] keycode,
                        
                        input  logic game_over,
                        input  logic win
                       );
    
    
    parameter TILE_SIZE = 8;
    parameter MAZE_COLS = 28;
    parameter MAZE_ROWS = 31;
    
    parameter TILE_WIDTH = 17;
    parameter TILE_HEIGHT = 15; 
    
    parameter GHOST_SIZE = 10'd10;
    
    localparam DISPLAY_WIDTH = 640;
    localparam MAZE_DISPLAY_WIDTH = TILE_WIDTH * MAZE_COLS; // Total maze width
    localparam H_OFFSET = (DISPLAY_WIDTH - MAZE_DISPLAY_WIDTH) / 2;

    localparam PELLET_SIZE = 2;
    
    
     // Tile indices
    logic [4:0] tile_row;
    logic [4:0] tile_col;
    logic [9:0] maze_address;
 //   logic [0:0] maze_data;



//assign within_maze = ((DrawX >= H_OFFSET) && (DrawX < H_OFFSET + MAZE_DISPLAY_WIDTH) && (DrawY < TILE_HEIGHT * MAZE_ROWS));

    
    logic within_maze;
    assign within_maze = (tile_row < MAZE_ROWS) && (tile_col < MAZE_COLS);

    logic [9:0] adjusted_DrawX, adjusted_DrawY;
    


    // Calculate address
 //   assign maze_address = (tile_row * 28) + tile_col;
/*    
    maze_rom rom_inst (
        .tile_row(tile_row),
        .tile_col(tile_col),
        .data(maze_data)
    );
*/
    // Instantiate maze memory
 /*   maze_bram1 maze_mem_inst (
        .tile_row(tile_row),
        .tile_col(tile_col),
        .clk_25MHz(clk_25MHz),
        .maze_data(maze_data),
        .next_maze_data(next_maze_data), // Not used in rendering
        .next_tile_row(tile_row), // Use same values for rendering
        .next_tile_col(tile_col)
    );
*/



logic ghost_on;

// Squared to avoid using multipliers in hardware
assign ghost_on = ((DrawX >= (ghost_x - GHOST_SIZE)) && (DrawX <= (ghost_x + GHOST_SIZE)) &&
                   (DrawY >= (ghost_y - GHOST_SIZE)) && (DrawY <= (ghost_y + GHOST_SIZE))) ?
                  ((DrawX - ghost_x) * (DrawX - ghost_x) + (DrawY - ghost_y) * (DrawY - ghost_y) <= (GHOST_SIZE * GHOST_SIZE)) :
                  1'b0;

// Center pellet

 logic pellet_on;
 assign pellet_on = (pellet_data && 
                       ((DrawX % TILE_WIDTH) >= (TILE_WIDTH/2 - PELLET_SIZE)) &&
                       ((DrawX % TILE_WIDTH) <= (TILE_WIDTH/2 + PELLET_SIZE)) &&
                       ((DrawY % TILE_HEIGHT) >= (TILE_HEIGHT/2 - PELLET_SIZE)) &&
                       ((DrawY % TILE_HEIGHT) <= (TILE_HEIGHT/2 + PELLET_SIZE)));




    // Ball display logic (as before)
    logic ball_on;
    int DistX, DistY, Size;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
   // assign ball_on = (DistX*DistX + DistY*DistY) <= (Size * Size);
    

    
    logic [0:0] maze_data_reg; // Registered output to handle BRAM read latency




    always_ff @(posedge clk_25MHz) begin
        maze_data_reg <= maze_data;
   //     maze_data_reg1 <= maze_data_reg;
    end
   

    always_comb begin
        if (win) begin
            // Green screen
            if (ghost1_pixel || ball_on || maze_data || ghost2_pixel) begin
                Red = 4'h0;    
                Green = 4'hF;
                Blue = 4'h0;
            end
            else begin
                Red = 4'h0;    
                Green = 4'h4;   // Dark green for background
                Blue = 4'h0;
            end
        end
        else if (game_over) begin
            // Red screen
            if (ghost1_pixel || ball_on || maze_data || ghost2_pixel) begin
                Red = 4'hF;    
                Green = 4'h0;
                Blue = 4'h0;
            end
            else begin
                Red = 4'h4;    // Dark red for background
                Green = 4'h0;
                Blue = 4'h0;
            end
        end
        else if (within_maze) begin
            if (ghost1_pixel) begin
                Red   = 4'hF;
                Green = 4'h0;
                Blue  = 4'h0;
            end 
            else if (ball_on == 1'b1) begin
            // Draw Pacman
                Red   = 4'hF;
                Green = 4'hF;
                Blue  = 4'h0;
            end 
            else if (ghost2_pixel) begin
                Red = 4'hF;    // Pinky
                Green = 4'h0;  
                Blue = 4'hF;   
            end
          /*  else if (dot_display) begin
                Red   = 4'h0;
                Green = 4'hF;
                Blue  = 4'h0;       */
            
            else if (maze_data_reg == 1'b1) begin
                // Draw wall
                Red   = 4'h0;
                Green = 4'h0;
                Blue  = 4'hF;
            end
            else if (pellet_on && !maze_data) begin  
                Red = 4'h0;    // Green pellets?
                Green = 4'hF;
                Blue = 4'h0;
          /*  end else if (text_on) begin
                Red = 4'hF;
                Green = 4'hF;
                Blue = 4'h0;  // Yellow text*/
            end else begin
                // Draw path
                Red   = 4'h0;
                Green = 4'h0;
                Blue  = 4'h0;
            end
        end
    end

/*
    // Rendering logic
always_comb begin
    if (DrawX < (TILE_WIDTH * 28) && DrawY < (TILE_HEIGHT * 31)) begin
        // Render maze
        if ((ball_on == 1'b1)) begin 
            Red = 4'hf;
            Green = 4'hf;
            Blue = 4'h0;
        end
        else if (maze_data == 1'b1) begin
            Red = 4'h0;  
            Green = 4'h0;
            Blue = 4'hF;
        end else begin
            Red = 4'h0;   
            Green = 4'h0;
            Blue = 4'h0;
        end
    end
end
*/
/*
logic text_on;
text_rom text_inst (
    .drawX(DrawX),
    .drawY(DrawY),
    .text_on(text_on)`
);
*/
/*
always_comb begin
    if (within_maze && maze_data_reg1 == 1'b1) begin
        // Draw wall
        Red   = 4'h0;
        Green = 4'h0;
        Blue  = 4'hF;
    end else if (within_maze && maze_data_reg1 == 1'b0) begin
        // Draw path
        Red   = 4'h0;
        Green = 4'hF;
        Blue  = 4'h0;
    end else begin
        // Draw background
        Red   = 4'h0;
        Green = 4'h0;
        Blue  = 4'h0;
    end
end
    */

  
  //  logic ball_on;
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*BallS, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))
       )

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 120 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
/* Commented original	  
    int DistX, DistY, Size;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
*/  
always_comb
begin:Ball_on_proc
    ball_on = 1'b0;
    if ((DistX*DistX + DistY*DistY) <= (Size * Size)) begin
        ball_on = 1'b1;   
                    // Mouth cutout
        case (keycode)
            8'h04: begin  // A - Left               
                if (DistX < 0 && DistY < -DistX && DistY > DistX)  
                    ball_on = 1'b0;
            end
            
            8'h07: begin  // D - Right
                if (DistX > 0 && DistY < DistX && DistY > -DistX)  
                    ball_on = 1'b0;
            end
            
            8'h1A: begin  // W - Up
                if (DistY < 0 && DistX < -DistY && DistX > DistY)  
                    ball_on = 1'b0;
            end
            
            8'h16: begin  // S - Down
                if (DistY > 0 && DistX < DistY && DistX > -DistY) 
                    ball_on = 1'b0;
            end
            
            default: begin
                ball_on = 1'b1; 
            end
        endcase
    end
end

 /*      
    always_comb
    begin:RGB_Display
        if ((ball_on == 1'b1)) begin 
            Red = 4'hf;
            Green = 4'hf;
            Blue = 4'h0;
        end
    end
   */ 
    /*    
        else begin 
            Red = 4'hf - DrawX[9:6]; 
            Green = 4'hf - DrawX[9:6];
            Blue = 4'hf - DrawX[9:6];
        end      
    end 
  */  


endmodule