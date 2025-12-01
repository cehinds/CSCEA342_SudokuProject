`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
//
// Module: top.sv
// Design: VGA Sudoku Game
//////////////////////////////////////////////////////////////////////////////////

module top(
    input  logic clk,          // 100 MHz Basys3 clock
    input  logic PS2Clk,       // PS/2 keyboard clock
    input  logic PS2Data,      // PS/2 keyboard data
    input  logic btnC,         // Button Center: Reset
    input  logic btnU,         // Button Up: Cycle Puzzle
    output logic Hsync,
    output logic Vsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic [6:0] seg,    // 7-segment segments
    output logic [7:0] an,     // 7-segment anodes
    output logic dp            // 7-segment decimal point
);

    // ============================================================
    // System Reset & Button Control
    // ============================================================
    logic reset;          // Main system reset pulse
    logic puzzle_pulse;   // Pulse to switch puzzles

    // Reset Button Controller (Center Button)
    button_controller BTN_RST (
        .clk(clk),
        .reset(1'b0),     // No external reset for the reset button itself
        .btn_raw(btnC),
        .btn_pulse(reset)
    );

    // Puzzle Select Button Controller (Up Button)
    button_controller BTN_PUZ (
        .clk(clk),
        .reset(reset),
        .btn_raw(btnU),
        .btn_pulse(puzzle_pulse)
    );

    // ============================================================
    // Puzzle Selector Logic
    // Cycles through 0 -> 1 -> 2 -> 0...
    // ============================================================
    logic [1:0] puzzle_selector = 2'b00;

    always_ff @(posedge clk) begin
        if (reset) begin
            puzzle_selector <= 2'b00;
        end else if (puzzle_pulse) begin
            if (puzzle_selector == 2'd2)
                puzzle_selector <= 2'b00;
            else
                puzzle_selector <= puzzle_selector + 1;
        end
    end

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
    // Sudoku Engine
    // ============================================================
    logic [3:0] engine_x, engine_y;
    logic [3:0] engine_val;
    logic       game_won, game_lost;
    logic       engine_ready;
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

        // Grid outputs for VGA DRAW
        .grid_out(grid_from_engine),
        .fixed_mask_out(fixed_from_engine)
    );

    // ============================================================
    // Display Controller (7-Segment)
    // Shows cursor X, cursor Y, and current Value
    // ============================================================
    logic [3:0] cycling_cnt;
    logic [25:0] slow_clk_cnt;
    
    // Generate a slowly cycling number for visual effects (optional)
    always_ff @(posedge clk) begin
        slow_clk_cnt <= slow_clk_cnt + 1;
        if (slow_clk_cnt == 0)
            cycling_cnt <= cycling_cnt + 1;
    end

    display_controller DISP (
        .clk(clk),
        .reset(reset),
        .current_x(engine_x),
        .current_y(engine_y),
        .current_val(engine_val),
        .entry_mode(1'b1),        // Always show coordinates/values
        .cycling_number(cycling_cnt),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    // ============================================================
    // Sudoku Draw (VGA Renderer)
    // ============================================================
    logic [3:0] r, g, b;

    sudoku_draw DRAW(
        .x(x),
        .y(y),
        .grid_vals(grid_from_engine),
        .fixed_mask(fixed_from_engine),
        .cursor_x(engine_x),
        .cursor_y(engine_y),
        .red(r),
        .green(g),
        .blue(b)
    );

    // VGA Output
    assign vgaRed   = video_on ? r : 4'b0000;
    assign vgaGreen = video_on ? g : 4'b0000;
    assign vgaBlue  = video_on ? b : 4'b0000;

endmodule