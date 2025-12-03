`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
//
// Module: top.sv
// Design: VGA Sudoku Game (Button-only control, conditioner-based, mode-aware cursor)
//////////////////////////////////////////////////////////////////////////////////

module top(
    input  logic clk,          // 100 MHz Basys3 clock

    // Buttons required by XDC
    input  logic btnC,
    input  logic btnU,
    input  logic btnD,
    input  logic btnL,
    input  logic btnR,

    input  logic [15:0] sw,    // Basys3 switches

    // VGA
    output logic Hsync,
    output logic Vsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    
    // Seven Segment Display
    output logic [6:0] seg,    // Cathode segments
    output logic [3:0] an      // Anode enables
);

    logic reset = 1'b0;

    // Clock divider: 100 MHz -> 25 MHz pixel clock
    logic clk25;
    clock_divider DIV(
        .clk100(clk),
        .clk25(clk25)
    );

    // VGA controller
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

    // Puzzle selector
    logic [1:0] puzzle_selector;

    always_comb begin
        if      (sw[0]) puzzle_selector = 2'd0;
        else if (sw[1]) puzzle_selector = 2'd1;
        else if (sw[2]) puzzle_selector = 2'd2;
        else            puzzle_selector = 2'd0;
    end

    // Conditioner for all buttons (replaces debounce + onepulse)
    logic condC, condU, condD, condL, condR;
    logic btnC_edge, btnU_edge, btnD_edge, btnL_edge, btnR_edge;

    conditioner cC (.clk(clk), .buttonPress(btnC), .conditionedSignal(condC), .pulse(btnC_edge));
    conditioner cU (.clk(clk), .buttonPress(btnU), .conditionedSignal(condU), .pulse(btnU_edge));
    conditioner cD (.clk(clk), .buttonPress(btnD), .conditionedSignal(condD), .pulse(btnD_edge));
    conditioner cL (.clk(clk), .buttonPress(btnL), .conditionedSignal(condL), .pulse(btnL_edge));
    conditioner cR (.clk(clk), .buttonPress(btnR), .conditionedSignal(condR), .pulse(btnR_edge));

    // Modes:
    //   MOVE mode   (cursor solid)
    //   NUMBER mode (cursor flashes, UP/DOWN cycles 1-9)
    typedef enum logic { MODE_MOVE = 1'b0, MODE_NUMBER = 1'b1 } mode_t;
    mode_t mode;

    logic [3:0] selected_number;

    always_ff @(posedge clk) begin
        if (reset) begin
            mode <= MODE_MOVE;
            selected_number <= 4'd1;
        end
        else begin
            // Toggle modes with CENTER button
            if (btnC_edge)
                mode <= (mode == MODE_MOVE) ? MODE_NUMBER : MODE_MOVE;

            // Cycle number while in number mode
            if (mode == MODE_NUMBER) begin
                if (btnU_edge)
                    selected_number <= (selected_number == 9) ? 1 : selected_number + 1;
                else if (btnD_edge)
                    selected_number <= (selected_number == 1) ? 9 : selected_number - 1;
            end
        end
    end

    // Cursor flashing logic
    logic [26:0] flash_div;
    always_ff @(posedge clk) flash_div <= flash_div + 1;

    logic flash_state = flash_div[26]; // slow toggle

    logic flash_state_visible =
        (mode == MODE_NUMBER) ? flash_state : 1'b1;

    // Command generation
    logic cmd_up, cmd_down, cmd_left, cmd_right;
    logic [3:0] cmd_number;
    logic cmd_enter, cmd_valid;

    always_comb begin
        cmd_up    = (mode == MODE_MOVE) ? btnU_edge : 1'b0;
        cmd_down  = (mode == MODE_MOVE) ? btnD_edge : 1'b0;
        cmd_left  = (mode == MODE_MOVE) ? btnL_edge : 1'b0;
        cmd_right = (mode == MODE_MOVE) ? btnR_edge : 1'b0;

        if (mode == MODE_NUMBER) begin
            cmd_number = selected_number;
            cmd_valid  = btnC_edge;
        end
        else begin
            cmd_number = 4'd0;
            cmd_valid = (cmd_up | cmd_down | cmd_left | cmd_right);
        end
    end

    assign cmd_enter = btnC_edge;

    // Sudoku engine
    logic [3:0] engine_x, engine_y;
    logic [3:0] engine_val;
    logic game_won, game_lost, engine_ready;

    logic [3:0] grid_out [0:8][0:8];
    logic fixed_mask_out [0:8][0:8];

    sudoku_engine ENGINE(
        .clk(clk),
        .reset(reset),
        .puzzle_selector(puzzle_selector),
        .cmd_number(cmd_number),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_valid(cmd_valid),
        .current_x(engine_x),
        .current_y(engine_y),
        .current_val(engine_val),
        .game_won(game_won),
        .game_lost(game_lost),
        .engine_ready(engine_ready),
        .grid_out(grid_out),
        .fixed_mask_out(fixed_mask_out)
    );

    // Drawing module
    logic [3:0] r, g, b;

    sudoku_draw DRAW(
        .x(x),
        .y(y),
        .grid_vals(grid_out),
        .fixed_mask(fixed_mask_out),
        .cursor_x(engine_x),
        .cursor_y(engine_y),
        .flash_state(flash_state_visible),
        .preview_number( (mode == MODE_NUMBER) ? selected_number : 4'd0 ),
        .red(r),
        .green(g),
        .blue(b)
    );
        
    assign vgaRed   = video_on ? r : 4'b0000;
    assign vgaGreen = video_on ? g : 4'b0000;
    assign vgaBlue  = video_on ? b : 4'b0000;

    // Seven Segment Display for Sudoku
    sevenseg_sudoku SEVENSEG(
        .clk(clk),
        .engine_x(engine_x),
        .engine_y(engine_y),
        .engine_val(engine_val),
        .selected_number(selected_number),
        .mode(mode),
        .fixed_mask(fixed_mask_out),
        .Anode_Activate(an),
        .LED_out(seg)
    );

endmodule