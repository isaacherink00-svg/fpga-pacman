//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf     03-01-2006                           --
//                                  03-12-2007                           --
//    Translated by Joe Meng        07-07-2013                           --
//    Modified by Zuofu Cheng       08-19-2023                           --
//    Modified by Satvik Yellanki   12-17-2023                           --
//    Fall 2024 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI Lab                                --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball 
( 
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode,
    input logic         frame_enable,
    
    input logic     clk_25MHz,
    
    input  logic [0:0]  next_maze_data, // Next tile value
    output  logic [4:0]  next_tile_row,  
    output  logic [4:0]  next_tile_col,  

    output logic [9:0]  BallX, 
    output logic [9:0]  BallY, 
    output logic [9:0]  BallS,
    

    input  logic [0:0]  left_wall_data,     // Left edge check
    input  logic [0:0]  right_wall_data    // Right edge check
    
);
    

	 
    parameter [9:0] Ball_X_Center=243;  // Center position on the X axis. PREVIOSLY 320
    parameter [9:0] Ball_Y_Center=84;  // Center position on the Y axis. PREVIOUSLY 240
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=2;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=2;      // Step size on the Y axis
    
    parameter TILE_WIDTH = 17;  // Tile width (pixels)
    parameter TILE_HEIGHT = 15; // Tile height (pixels)
    parameter WRAP_Y_POS = 15;  // y position of the tunnel
    parameter WRAP_MARGIN = 7;   

    parameter WRAP_TOP_MARGIN = 12;    // Increased margin for top of tunnel
    parameter WRAP_BOTTOM_MARGIN = 8;  // Keep original margin for bottom

    localparam LEFT_WRAP_X = 17;
    localparam RIGHT_WRAP_X = (TILE_WIDTH * 26);  // 27 columns * 17 pixels per tile


    logic [9:0] Ball_X_Motion;
    logic [9:0] Ball_X_Motion_next;
    logic [9:0] Ball_Y_Motion;
    logic [9:0] Ball_Y_Motion_next;

    logic [9:0] Ball_X_next;
    logic [9:0] Ball_Y_next;
    
    
    // Nextext tile position

//    logic [9:0] X_sum_reg, Y_sum_reg;
   logic [4:0] requested_tile_row, requested_tile_col;
   logic [4:0] next_tile_row_piped, next_tile_col_piped;
   
   
   always_ff @(posedge clk_25MHz or posedge Reset) begin
        if (Reset) begin
            next_tile_row_piped <= Ball_Y_Center / TILE_HEIGHT;
            next_tile_col_piped <= Ball_X_Center / TILE_WIDTH;
        end else if (frame_enable) begin
            case (keycode)
                8'h1A: begin // W - Up
                    next_tile_row_piped <= (BallY - Ball_Y_Step - BallS) / TILE_HEIGHT; // BallS to account for outsid eof Pacman
                    next_tile_col_piped <= BallX / TILE_WIDTH;
                end
                8'h16: begin // S - Down
                    next_tile_row_piped <= (BallY + Ball_Y_Step + BallS) / TILE_HEIGHT;
                    next_tile_col_piped <= BallX / TILE_WIDTH;
                end
                8'h04: begin // A - Left
                    next_tile_col_piped <= (BallX - Ball_X_Step - BallS) / TILE_WIDTH;
                    next_tile_row_piped <= BallY / TILE_HEIGHT;
                end
                8'h07: begin // D - Right
                    next_tile_col_piped <= (BallX + Ball_X_Step + BallS) / TILE_WIDTH;
                    next_tile_row_piped <= BallY / TILE_HEIGHT;
                end
                default: begin
                    next_tile_row_piped <= BallY / TILE_HEIGHT;
                    next_tile_col_piped <= BallX / TILE_WIDTH;
                end
            endcase
        end
    end

    // Pipelining to lower worst negative slack
    assign next_tile_row = next_tile_row_piped;
    assign next_tile_col = next_tile_col_piped;

/*    
    always_comb begin
        // Default no motion
        Ball_Y_Motion_next = 0;
        Ball_X_Motion_next = 0;

        if (next_maze_data == 0) begin // 
            case (keycode)
                8'h1A: begin // W - Up
                    Ball_Y_Motion_next = -Ball_Y_Step;
                    Ball_X_Motion_next = 0;
                end
                8'h16: begin // S - Down
                    Ball_Y_Motion_next = Ball_Y_Step;
                    Ball_X_Motion_next = 0;
                end
                8'h04: begin // A - Left
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = -Ball_X_Step;
                end
                8'h07: begin // D - Right
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = Ball_X_Step;
                end
                default: begin
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = 0;
                end
            endcase
        end else begin
        
            Ball_Y_Motion_next = 0;
            Ball_X_Motion_next = 0;
        end
    end
*/

always_comb begin
    // Default no motion
    Ball_Y_Motion_next = 0;
    Ball_X_Motion_next = 0;

    if (next_maze_data == 0) begin // Center path is clear
        case (keycode)
            8'h1A: begin // W - Up
                if (!left_wall_data && !right_wall_data) begin 
                    Ball_Y_Motion_next = -Ball_Y_Step;
                    Ball_X_Motion_next = 0;
                end
            end
            8'h16: begin // S - Down
                if (!left_wall_data && !right_wall_data) begin 
                    Ball_Y_Motion_next = Ball_Y_Step;
                    Ball_X_Motion_next = 0;
                end
            end
            8'h04: begin // A - Left
                if (!left_wall_data) begin 
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = -Ball_X_Step;
                end
            end
            8'h07: begin // D - Right
                if (!right_wall_data) begin 
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = Ball_X_Step;
                end
            end
            default: begin
                Ball_Y_Motion_next = 0;
                Ball_X_Motion_next = 0;
            end
        endcase
    end else begin
        // collision
        Ball_Y_Motion_next = 0;
        Ball_X_Motion_next = 0;
    end
end

    
    always_ff @(posedge clk_25MHz or posedge Reset) begin
        if (Reset) begin
            BallX <= Ball_X_Center;
            BallY <= Ball_Y_Center;
            Ball_X_Motion <= 0;
            Ball_Y_Motion <= 0;

            requested_tile_row <= Ball_Y_Center / TILE_HEIGHT;
            requested_tile_col <= Ball_X_Center / TILE_WIDTH;
        end else if (frame_enable) begin
           
            Ball_X_Motion <= Ball_X_Motion_next;
            Ball_Y_Motion <= Ball_Y_Motion_next;
           
            if (next_maze_data == 0) begin
                if ((BallY >= (WRAP_Y_POS * TILE_HEIGHT - WRAP_TOP_MARGIN)) && (BallY <= (WRAP_Y_POS * TILE_HEIGHT + WRAP_BOTTOM_MARGIN))) begin 
                    // Right to left  wrap
                    if (BallX >= RIGHT_WRAP_X) begin
                        BallX <= LEFT_WRAP_X + Ball_X_Motion_next;
                    end
                    // Left to right
                    else if (BallX <= LEFT_WRAP_X) begin
                        BallX <= RIGHT_WRAP_X + Ball_X_Motion_next;
                    end
                    // Normal movement
                    else begin
                        BallX <= BallX + Ball_X_Motion_next;
                    end
                    BallY <= BallY + Ball_Y_Motion_next;
                end
                // Normal movement outside tunnel
                else begin
                    if ((BallX + Ball_X_Motion_next >= Ball_X_Min) && (BallX + Ball_X_Motion_next <= Ball_X_Max)) begin
                        BallX <= BallX + Ball_X_Motion_next;
                    end
                    if ((BallY + Ball_Y_Motion_next >= Ball_Y_Min) && (BallY + Ball_Y_Motion_next <= Ball_Y_Max)) begin
                        BallY <= BallY + Ball_Y_Motion_next;
                    end
                end
            end
        end
    end
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
 /*   
   always_comb begin
        // Default assignments to current tile indices
        next_tile_row = BallY / TILE_HEIGHT;
        next_tile_col = BallX / TILE_WIDTH;
        
        case (keycode)
            8'h1A: begin // W - Up
                next_tile_row = (BallY - Ball_Y_Step) / TILE_HEIGHT;
                next_tile_col = BallX / TILE_WIDTH;
            end
            8'h16: begin // S - Down
                next_tile_row = (BallY + Ball_Y_Step) / TILE_HEIGHT;
                next_tile_col = BallX / TILE_WIDTH;
            end
            8'h04: begin // A - Left
                next_tile_col = (BallX - Ball_X_Step) / TILE_WIDTH;
                next_tile_row = BallY / TILE_HEIGHT;
            end
            8'h07: begin // D - Right
                next_tile_col = (BallX + Ball_X_Step) / TILE_WIDTH;
                next_tile_row = BallY / TILE_HEIGHT;
            end
            default: begin
                next_tile_row = BallY / TILE_HEIGHT;
                next_tile_col = BallX / TILE_WIDTH;
            end
        endcase
    end
    
   

 
 always_comb begin
        // Default no motion
        Ball_Y_Motion_next = 0;
        Ball_X_Motion_next = 0;

        if (next_maze_data == 0) begin
            case (keycode)
                8'h1A: begin // W - Up
                    Ball_Y_Motion_next = -Ball_Y_Step;
                    Ball_X_Motion_next = 0;
                end
                8'h16: begin // S - Down
                    Ball_Y_Motion_next = Ball_Y_Step;
                    Ball_X_Motion_next = 0;
                end
                8'h04: begin // A - Left
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = -Ball_X_Step;
                end
                8'h07: begin // D - Right
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = Ball_X_Step;
                end
                default: begin
                    Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = 0;
                end
            endcase
        end else begin
            // collision
            Ball_Y_Motion_next = 0;
            Ball_X_Motion_next = 0;
        end
    end
 
 
 
 
 
 /*
    always_comb begin
        Ball_Y_Motion_next = 0; // Default motion is 0 
        Ball_X_Motion_next = 0;
    if (next_maze_data == 0) begin
        case (keycode)
            8'h1A: begin
                Ball_Y_Motion_next = -10'd1;
                Ball_X_Motion_next = 0;
                end
            8'h16: begin
                Ball_Y_Motion_next = 10'd1;
                Ball_X_Motion_next = 0;
                end
            8'h04: begin
                Ball_Y_Motion_next = 0;
                Ball_X_Motion_next = -10'd1;
                end
             8'h07: begin
                Ball_Y_Motion_next = 0;
                Ball_X_Motion_next = 10'd1;
                end
                default: ;
            endcase
        end
    end
  */  
 /*   
    always_comb begin
    //Default, no motion
        Ball_Y_Motion_next = 0; // Default motion is 0 
        Ball_X_Motion_next = 0;

        //modify to control ball motion with the keycode
 
        case (keycode)
            8'h1A:// begin            //W key
               // if ((reg_next_tile_row > 0) && (reg_next_maze_data == 1'b0))
                    Ball_Y_Motion_next = -10'd1;
 //               Ball_X_Motion_next = 0;
         //   end
            
            8'h16:// begin            //S key
        //        if ((reg_next_tile_row < 30) && (reg_next_maze_data == 1'b0))
                    Ball_Y_Motion_next = 10'd1;
  //              Ball_X_Motion_next = 0;
     //       end
            
            8'h04:// begin            //A key
      //          if ((reg_next_tile_col > 0) && (reg_next_maze_data == 1'b0))
   //             Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = -10'd1;
       //     end
            
            8'h07:// begin            //D key
      //          if ((reg_next_tile_col < 27) && (reg_next_maze_data == 1'b0))
 //               Ball_Y_Motion_next = 0;
                    Ball_X_Motion_next = 10'd1;
      //      end
            
            default: ;
        endcase
 */           
        
 //       if (keycode == 8'h1A)
 //           Ball_Y_Motion_next = -10'd1;
 /*
    always_comb begin
        if ( (BallY + BallS) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
        begin
            Ball_Y_Motion_next = (~ (Ball_Y_Step) + 1'b1);  // set to -1 via 2's complement.
        end
        else if ( (BallY - BallS) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
        begin
            Ball_Y_Motion_next = Ball_Y_Step;
        end  
       //fill in the rest of the motion equations here to bounce left and right
       
        if ( (BallX + BallS) >= Ball_X_Max ) 
        begin
            Ball_X_Motion_next = (~ (Ball_X_Step) + 1'b1); // Bounce left
        end
        else if ((BallX - BallS) <= Ball_X_Min) begin
            Ball_X_Motion_next = Ball_X_Step;  // Bounce right
        end

    end
  */

/*
    always_ff @(posedge frame_clk) begin
        reg_next_maze_data <= next_maze_data;
    end
*/

    

    assign BallS = 8;  // default ball size
//    assign Ball_X_next = (BallX + Ball_X_Motion_next);
//    assign Ball_Y_next = (BallY + Ball_Y_Motion_next);
    
   /*
    always_ff @(posedge frame_clk) //make sure the frame clock is instantiated correctly
    begin: Move_Ball
        if (Reset)
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
			Ball_X_Motion <= 10'd0; //Ball_X_Step;
            
			BallY <= Ball_Y_Center;
			BallX <= Ball_X_Center;
        end
        else 
        begin 

			Ball_Y_Motion <= Ball_Y_Motion_next;                                                                                                                                                                                                                                                                                                                                                                     
			Ball_X_Motion <= Ball_X_Motion_next; 

            BallY <= Ball_Y_next;  // Update ball position
            BallX <= Ball_X_next;
			
		end  
    end
*/

    
      
endmodule
