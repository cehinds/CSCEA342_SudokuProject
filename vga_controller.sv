`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Gwendolyn Beecher
// 
// Create Date: 11/30/2025 04:56:51 PM
// Design Name: VGA Sudoku Game
// Module Name: vga_controller
// Project Name: VGA Sudoku
//////////////////////////////////////////////////////////////////////////////////


module vga_controller(
    input  logic clk25,            // 25 MHz pixel clock
    input  logic reset,
    output logic hsync,
    output logic vsync,
    output logic [9:0] x,          // 0-639
    output logic [9:0] y,          // 0-479
    output logic video_on          // High during visible region
);

    // Timing constants
    localparam H_ACTIVE = 640;
    localparam H_FRONT  = 16;
    localparam H_SYNC   = 96;
    localparam H_BACK   = 48;
    localparam H_TOTAL  = H_ACTIVE + H_FRONT + H_SYNC + H_BACK; // 800

    localparam V_ACTIVE = 480;
    localparam V_FRONT  = 10;
    localparam V_SYNC   = 2;
    localparam V_BACK   = 33;
    localparam V_TOTAL  = V_ACTIVE + V_FRONT + V_SYNC + V_BACK; // 525

    logic [9:0] h_count = 0;
    logic [9:0] v_count = 0;

    always_ff @(posedge clk25, posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    assign hsync = ~(h_count >= H_ACTIVE + H_FRONT &&
                     h_count <  H_ACTIVE + H_FRONT + H_SYNC);

    assign vsync = ~(v_count >= V_ACTIVE + V_FRONT &&
                     v_count <  V_ACTIVE + V_FRONT + V_SYNC);

    assign x = (h_count < H_ACTIVE) ? h_count : 10'd0;
    assign y = (v_count < V_ACTIVE) ? v_count : 10'd0;

    assign video_on = (h_count < H_ACTIVE && v_count < V_ACTIVE);

endmodule
