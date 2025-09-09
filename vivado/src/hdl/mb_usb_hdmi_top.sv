//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//                                                                       --
//                                                                       --
//    Spring 2024 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------
   
    

module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk, clk_100MHz;
    logic locked;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballsizesig;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    
    logic [9:0] ghost_x, ghost_y;
   
    assign reset_ah = reset_rtl_0;
    
    logic reset_sync1, reset_sync2;
    always_ff @(posedge clk_25MHz) begin
        reset_sync1 <= reset_rtl_0;
        reset_sync2 <= reset_sync1;
    end

assign reset_ah1 = reset_sync2;
    
    
 // for maze dispaly
    logic [4:0] render_tile_row, render_tile_col;
    assign render_tile_row = (drawY < (TILE_HEIGHT * MAZE_ROWS)) ? (drawY / TILE_HEIGHT) : (MAZE_ROWS-1);
    assign render_tile_col = (drawX < (TILE_WIDTH * MAZE_COLS)) ? (drawX / TILE_WIDTH) : (MAZE_COLS-1);
    
    logic [4:0] next_tile_row, next_tile_col;
    logic [0:0] maze_data;       // For rendering current tile
    logic [0:0] next_maze_data;  // For collision checking next tile
    
    parameter TILE_WIDTH = 17;      //Previously 22
    parameter TILE_HEIGHT = 15;
    parameter MAZE_COLS = 28;
    parameter MAZE_ROWS = 31;
    
 //   localparam MARGIN_X = 82;
//    localparam MARGIN_Y = 8;
    
    logic ghost1_pixel;             
                   
    logic vsync_d, vsync_r;
    always_ff @(posedge clk_25MHz or posedge reset_ah) begin
        if (reset_ah) begin
            vsync_d <= 1'b0;
            vsync_r <= 1'b0;
        end else begin
            vsync_d <= vsync;
            vsync_r <= vsync_d;
        end
    end
    
    logic frame_enable;
    assign frame_enable = (~vsync_r & vsync_d);


    
 //   assign adjusted_DrawX = drawX - MARGIN_X;  
 //   assign adjusted_DrawY = drawY - MARGIN_Y; 
    
    logic ghost_up_wall, ghost_down_wall, ghost_left_wall, ghost_right_wall;
    
    logic win;
    logic all_pellets_cleared; 
    
    // Win state logic
    always_ff @(posedge clk_25MHz or posedge reset_ah) begin
        if (reset_ah)
            win <= 1'b0;
        else if (all_pellets_cleared)
            win <= 1'b1;
    end
    
/*

 /*   
    always_comb begin
        Ball_X_Motion_next = 0;
        Ball_Y_Motion_next = 0;
        case (keycode0_gpio[7:0])
            8'h1A: Ball_Y_Motion_next = -10'd1; 
            8'h16: Ball_Y_Motion_next = 10'd1;  
            8'h04: Ball_X_Motion_next = -10'd1; 
            8'h07: Ball_X_Motion_next = 10'd1;  
        endcase
    end

   
 */   
    
    logic pellet_collected;
    logic [15:0] score;
    
    // Track score
    score_tracker score_inst (
        .clk(clk_25MHz),
        .reset(reset_ah),
        .pellet_collected(pellet_collected),
        .game_over(game_over),
        .score(score)
    );
    
    
    //Keycode HEX drivers
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({score[15:12], score[11:8], score[7:4], score[3:0]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    mb_block mb_block_i (           //Changed to mb_block
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );

logic [4:0] next_left_col = (ballxsig - 4) / TILE_WIDTH;
logic [4:0] next_right_col = (ballxsig + 4) / TILE_WIDTH;


logic [0:0] left_wall_data, right_wall_data;

// Left and right check
maze_rom left_check (
    .tile_row(next_tile_row),
    .tile_col(next_left_col),
    .wall_data(left_wall_data)
);

maze_rom right_check (
    .tile_row(next_tile_row),
    .tile_col(next_right_col),
    .wall_data(right_wall_data)
);


    
    //Ball Module
    ball ball_instance(
        .Reset(reset_ah),
        .frame_clk(vsync),                    //Figure out what this should be so that the ball will move
        .frame_enable(frame_enable),
        .keycode(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
        .BallX(ballxsig),
        .BallY(ballysig),
        .BallS(ballsizesig),
 //       .maze_data(maze_data_reg),  // 
        .next_tile_row(next_tile_row),       // Tile row from color_mapper
        .next_tile_col(next_tile_col),
        .next_maze_data(next_maze_data),      // Tile column from color_mapper
        
        .clk_25MHz(clk_25MHz),
        .left_wall_data(left_wall_data),
        .right_wall_data(right_wall_data)
    );
    
    //Color Mapper Module   
    color_mapper color_instance(
        .BallX(ballxsig),
        .BallY(ballysig),
        .DrawX(drawX),
        .DrawY(drawY),
        .Ball_size(ballsizesig),
        .Red(red),
        .Green(green),
        .Blue(blue),
        .clk_25MHz(clk_25MHz),
        .maze_data(maze_data),
 //       .within_maze(within_maze)
 
        .ghost_x(ghost_x),
        .ghost_y(ghost_y),
        .ghost1_pixel(ghost1_pixel),
        .ghost2_pixel(ghost2_pixel),
        
        .dot_display(dot_display),
        .pellet_data(pellet_data),
        
        .game_over(game_over),
        .win(win),
        
        .keycode(keycode0_gpio[7:0])
    );
 /*   
        maze_bram1 maze_mem_inst (
        .tile_row(render_tile_row),
        .tile_col(render_tile_col),
        .maze_data(maze_data),
 //       .next_tile_row(next_tile_row),
 //       .next_tile_col(next_tile_col),
 //       .next_maze_data(next_maze_data),
        .clk_25MHz(clk_25MHz)
    );
*/

    maze_rom current_tile_rom (
        .tile_row(render_tile_row),
        .tile_col(render_tile_col),
        .wall_data(maze_data)
    );
    
    // 2. Next tile for detecting collisions
    maze_rom next_tile_rom (
        .tile_row(next_tile_row),
        .tile_col(next_tile_col),
        .wall_data(next_maze_data)
    );
    
 //up   
    logic [4:0] ghost_tile_row = ghost_y / TILE_HEIGHT;
    logic [4:0] ghost_tile_col = ghost_x / TILE_WIDTH;
    logic ghost_up_wall_temp;
    
    logic [4:0] ghost_up_row    = (ghost_tile_row > 0) ? (ghost_tile_row - 1) : ghost_tile_row;
    logic [4:0] ghost_down_row  = (ghost_tile_row < MAZE_ROWS-1) ? (ghost_tile_row + 1) : ghost_tile_row;
    logic [4:0] ghost_left_col  = (ghost_tile_col > 0) ? (ghost_tile_col - 1) : ghost_tile_col;
    logic [4:0] ghost_right_col = (ghost_tile_col < MAZE_COLS-1) ? (ghost_tile_col + 1) : ghost_tile_col;
    
    
    
    maze_rom ghost_up_rom (
        .tile_row(ghost_up_row),
        .tile_col(ghost_tile_col),
        .wall_data(ghost_up_wall)
    );
    
    // Down
    logic ghost_down_wall_temp;
    
    
    maze_rom ghost_down_rom (
        .tile_row(ghost_down_row),
        .tile_col(ghost_tile_col),
        .wall_data(ghost_down_wall)
    );
    
    // Left
    logic ghost_left_wall_temp;
    
    maze_rom ghost_left_rom (
        .tile_row(ghost_tile_row),
        .tile_col(ghost_left_col),
        .wall_data(ghost_left_wall)
    );
    
    // 4. Right
    logic ghost_right_wall_temp;
//    logic [4:0] ghost_right_row = render_tile_row;
 //   logic [4:0] ghost_right_col = (render_tile_col < MAZE_COLS-1) ? (render_tile_col + 1) : render_tile_col;
    
    maze_rom ghost_right_rom (
        .tile_row(ghost_tile_row),
        .tile_col(ghost_right_col),
        .wall_data(ghost_right_wall)
    );
    
 /*   
    assign ghost_up_wall    = ghost_up_wall_temp;
    assign ghost_down_wall  = ghost_down_wall_temp;
    assign ghost_left_wall  = ghost_left_wall_temp;
    assign ghost_right_wall = ghost_right_wall_temp;
 */   
      // Blinky red ghost
ghost1 ghost_instance (
    .clk(clk_25MHz),        
    .reset(reset_ah),       
    .ghost_x(ghost_x),      
    .ghost_y(ghost_y),     
    .ghost1_pixel(ghost1_pixel),
    .drawX(drawX),           // Current x pixel
    .drawY(drawY),         // Current y pixel
    
    .frame_enable(frame_enable),
    .ghost_up_wall(ghost_up_wall),
    .ghost_down_wall(ghost_down_wall),
    .ghost_left_wall(ghost_left_wall),
    .ghost_right_wall(ghost_right_wall),
    
    .BallX(ballxsig),
    .BallY(ballysig)
);
/*    
    dot_manager dot_inst (
    .clk(clk_25MHz),
    .reset(reset_ah),
    .drawX(drawX),
    .drawY(drawY),
    .current_tile_row(render_tile_row),
    .current_tile_col(render_tile_col),
    .maze_wall(maze_data),
    .dot_display(dot_display)
);
    */
    
    logic [4:0] pacman_tile_row, pacman_tile_col;
    assign pacman_tile_row = ballysig / TILE_HEIGHT;
    assign pacman_tile_col = ballxsig / TILE_WIDTH;

  
    logic pellet_data;
    // Pellet ram
    pellet_ram pellet_inst (
        .clk(clk_25MHz),
        .reset(reset_ah1),
        .read_row(render_tile_row),
        .read_col(render_tile_col),
        .pacman_row(pacman_tile_row),
        .pacman_col(pacman_tile_col),
        .pellet_data(pellet_data),
        .frame_clk(frame_enable),
        
        .pellet_collected(pellet_collected),
        .all_pellets_cleared(all_pellets_cleared)
    );
    
    logic game_over;
    logic collision;
    
    // Instantiate collision detector
    collision_detector collision_inst (
        .ghost_x(ghost_x),
        .ghost_y(ghost_y),
        .pacman_x(ballxsig),
        .pacman_y(ballysig),
        .sprite_size(10'd16), 
        .collision(collision)
    );
    

    
    logic [9:0] ghost2_x, ghost2_y;
       
    logic [4:0] ghost2_tile_row = ghost2_y / TILE_HEIGHT;
     logic [4:0] ghost2_tile_col = ghost2_x / TILE_WIDTH;


logic [4:0] ghost2_up_row    = (ghost2_tile_row > 0) ? (ghost2_tile_row - 1) : ghost2_tile_row;
logic [4:0] ghost2_down_row  = (ghost2_tile_row < MAZE_ROWS-1) ? (ghost2_tile_row + 1) : ghost2_tile_row;
logic [4:0] ghost2_left_col  = (ghost2_tile_col > 0) ? (ghost2_tile_col - 1) : ghost2_tile_col;
logic [4:0] ghost2_right_col = (ghost2_tile_col < MAZE_COLS-1) ? (ghost2_tile_col + 1) : ghost2_tile_col;


maze_rom ghost2_up_rom (
    .tile_row(ghost2_up_row),
    .tile_col(ghost2_tile_col),
    .wall_data(ghost_up_wall2)
);

maze_rom ghost2_down_rom (
    .tile_row(ghost2_down_row),
    .tile_col(ghost2_tile_col),
    .wall_data(ghost_down_wall2)
);

maze_rom ghost2_left_rom (
    .tile_row(ghost2_tile_row),
    .tile_col(ghost2_left_col),
    .wall_data(ghost_left_wall2)
);

maze_rom ghost2_right_rom (
    .tile_row(ghost2_tile_row),
    .tile_col(ghost2_right_col),
    .wall_data(ghost_right_wall2)
);   
       
logic ghost2_pixel;

ghost2 ghost2_instance (
    .clk(clk_25MHz),
    .reset(reset_ah),
    .ghost_x(ghost2_x),
    .ghost_y(ghost2_y),
    .ghost2_pixel(ghost2_pixel),
    .drawX(drawX),
    .drawY(drawY),
    .frame_enable(frame_enable),
    .ghost_up_wall(ghost_up_wall2),    
    .ghost_down_wall(ghost_down_wall2),
    .ghost_left_wall(ghost_left_wall2),
    .ghost_right_wall(ghost_right_wall2),
    .BallX(ballxsig),   
    .BallY(ballysig),
    
    .keycode(keycode0_gpio[7:0])       
);
       
  logic collision2;  // Pinky


collision_detector collision2_inst (
    .ghost_x(ghost2_x),
    .ghost_y(ghost2_y),
    .pacman_x(ballxsig),
    .pacman_y(ballysig),
    .sprite_size(10'd16),
    .collision(collision2)
);
    
    
    always_ff @(posedge clk_25MHz or posedge reset_ah) begin
        if (reset_ah)
            game_over <= 1'b0;
        else if (collision || collision2)
            game_over <= 1'b1;
    end
    
endmodule
