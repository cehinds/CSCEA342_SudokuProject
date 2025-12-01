`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hindes
//
// Module: top.sv
// Design: VGA Sudoku Game
//////////////////////////////////////////////////////////////////////////////////

module top(
    input  logic clk,          // 100 MHz Basys3 clock
    input  logic PS2Clk,      // PS/2 keyboard clock
    input  logic PS2Data,     // PS/2 keyboard data
    output logic Hsync,
    output logic Vsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue
);

    logic reset = 1'b0;

    // ============================================================
    // Clock Divider:  25 MHz for VGA
    // ============================================================
    logic clk25;
    clock_divider DIV(
        .clk100(clk),
        .clk25(clk25)
    );

    // ============================================================
    // VGA Controller: generates (x,y) pixel coordinates
    // ============================================================
    logic [9:0] x, y;
    logic video_on;

    vga_controller VGA(
        .clk25(clk25),
        .reset(reset),
        .hsync(Hsync),
        .vsync(Vsync),
        .x(x),
        .y(y),
        .video_on(video_on)
    );

    // ============================================================
    // PS/2 Keyboard Receiver
    // Converts raw PS/2 signals: 8-bit scan codes
    // ============================================================
    logic [7:0] kbd_rx_data;
    logic       kbd_rx_ready;

    ps2_host KBD_HOST (
        .clk(clk),           // high-speed sampling
        .reset(reset),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .rx_data(kbd_rx_data),
        .rx_ready(kbd_rx_ready)
    );

    // ============================================================
    // Keyboard Parser
    // Converts scan codes → game commands:
    //  - arrows (movement)
    //  - 1-9 (number entry)
    //  - enter (win check)
    // ============================================================
    logic       cmd_up, cmd_down, cmd_left, cmd_right;
    logic       cmd_enter;
    logic [3:0] cmd_number;
    logic       cmd_valid;

    keyboard_parser PARSE (
        .clk(clk),
        .reset(reset),
        .rx_data(kbd_rx_data),
        .rx_ready(kbd_rx_ready),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_number(cmd_number),
        .cmd_valid(cmd_valid)
    );

    // ============================================================
    // Sudoku_engine
    // Loads puzzle from puzzles.mem
    // Maintains solution, current grid, cursor, win logic
    // ============================================================
    logic [1:0] puzzle_selector = 2'b00;

    logic [3:0] engine_x, engine_y;
    logic [3:0] engine_val;
    logic       game_won, game_lost;
    logic       engine_ready;

    // NEW: expose grid and fixed mask from engine
    logic [3:0] grid_from_engine [0:8][0:8];
    logic       fixed_from_engine [0:8][0:8];

    sudoku_engine ENGINE (
        .clk(clk),
        .reset(reset),
        .puzzle_selector(puzzle_selector),

        // keyboard commands
        .cmd_number(cmd_number),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_valid(cmd_valid),

        // cursor + status outputs
        .current_x(engine_x),
        .current_y(engine_y),
        .current_val(engine_val),
        .game_won(game_won),
        .game_lost(game_lost),
        .engine_ready(engine_ready),

        // NEW grid outputs for VGA DRAW
        .grid_out(grid_from_engine),
        .fixed_mask_out(fixed_from_engine)
    );

    // ============================================================
    // SUDOKU DRAW (updated to use engine grid)
    // Renders:
    //   - editable cells
    //   - fixed mask cells
    //   - cursor highlight
    // ============================================================
    logic [3:0] r, g, b;

    sudoku_draw DRAW(
        .x(x),
        .y(y),

        // NEW: actual puzzle state from engine
        .grid_vals(grid_from_engine),

        // NEW: fixed mask (prefilled cells)
        .fixed_mask(fixed_from_engine),

        // NEW: cursor location
        .cursor_x(engine_x),
        .cursor_y(engine_y),

        .red(r),
        .green(g),
        .blue(b)
    );

    // VGA Output (blank when outside active region)
    assign vgaRed   = video_on ? r : 4'b0000;
    assign vgaGreen = video_on ? g : 4'b0000;
    assign vgaBlue  = video_on ? b : 4'b0000;

endmodule