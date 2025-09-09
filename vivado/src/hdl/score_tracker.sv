`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 01:13:43 AM
// Design Name: 
// Module Name: score_tracker
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


module score_tracker (
    input  logic        clk,
    input  logic        reset,
    input  logic        pellet_collected,
    input  logic        game_over,
    output logic [15:0] score
);
    
    logic [3:0] ones, tens, hundreds, thousands;
    logic prev_pellet;
    
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            prev_pellet <= 0;
        else
            prev_pellet <= pellet_collected;
    end
    
    logic new_pellet = pellet_collected && (!prev_pellet);
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ones <= 0;
            tens <= 0;
            hundreds <= 0;
            thousands <= 0;
        end
        else if (!game_over && new_pellet) begin
            // 10 pts per pellet
            if (tens == 9) begin
                tens <= 0;
                if (hundreds == 9) begin
                    hundreds <= 0;
                    if (thousands != 9)
                        thousands <= thousands + 1;
                end
                else
                    hundreds <= hundreds + 1;
            end
            else
                tens <= tens + 1;
        end
    end
    
    assign score = {thousands, hundreds, tens, ones};

endmodule
