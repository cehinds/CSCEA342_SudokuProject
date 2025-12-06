`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
//
// Module: top.sv
// Design: VGA Sudoku Game (enhanced with WIN/LOSE/ENTER 2 UI + correctness mode)
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

    // Switch synchronizers (SW0, SW1)
    logic sw0_sync, sw1_sync;
    always_ff @(posedge clk) begin
        sw0_sync <= sw[0];
        sw1_sync <= sw[1];
    end

    // Correctness-check mode (SW2)
    logic check_enable;
    assign check_enable = sw[2];

    // Puzzle selector (0,1,2)
    logic [1:0] puzzle_selector;
    always_comb begin
        if (sw1_sync)          puzzle_selector = 2'd2;
        else if (sw0_sync)     puzzle_selector = 2'd1;
        else                   puzzle_selector = 2'd0;
    end

    // Soft reset when puzzle selection changes
    logic [1:0] puzzle_sel_prev;
    logic       soft_reset;

    always_ff @(posedge clk) begin
        if (reset) begin
            puzzle_sel_prev <= 2'd0;
            soft_reset      <= 1'b0;
        end
        else begin
            if (puzzle_selector != puzzle_sel_prev) begin
                soft_reset      <= 1'b1;
                puzzle_sel_prev <= puzzle_selector;
            end
            else begin
                soft_reset <= 1'b0;
            end
        end
    end

    // Button conditioners
    logic condC, condU, condD, condL, condR;
    logic btnC_edge, btnU_edge, btnD_edge, btnL_edge, btnR_edge;

    conditioner cC (.clk(clk), .buttonPress(btnC), .conditionedSignal(condC), .pulse(btnC_edge));
    conditioner cU (.clk(clk), .buttonPress(btnU), .conditionedSignal(condU), .pulse(btnU_edge));
    conditioner cD (.clk(clk), .buttonPress(btnD), .conditionedSignal(condD), .pulse(btnD_edge));
    conditioner cL (.clk(clk), .buttonPress(btnL), .conditionedSignal(condL), .pulse(btnL_edge));
    conditioner cR (.clk(clk), .buttonPress(btnR), .conditionedSignal(condR), .pulse(btnR_edge));

    // Modes: Move and pick number
    typedef enum logic { MODE_MOVE = 1'b0, MODE_NUMBER = 1'b1 } mode_t;
    mode_t mode;

    logic [3:0] selected_number;
    logic [3:0] prev_engine_x, prev_engine_y;

    // Sudoku engine signals
    logic [3:0] engine_x, engine_y;
    logic [3:0] engine_val;
    logic game_won, game_lost, engine_ready;

    logic [3:0] grid_out [0:8][0:8];
    logic fixed_mask_out [0:8][0:8];

    // Outputs for correctness UI
    logic        check_win, check_lose;
    logic        cell_match [0:8][0:8];

    // Cursor and number selection
    always_ff @(posedge clk) begin
        if (reset || soft_reset) begin
            mode            <= MODE_MOVE;
            selected_number <= 4'd1;
            prev_engine_x   <= 0;
            prev_engine_y   <= 0;
        end
        else begin
            // Detect cursor movement while in NUMBER mode
            if (mode == MODE_NUMBER &&
               (engine_x != prev_engine_x || engine_y != prev_engine_y))
            begin
                if (engine_val != 4'd0)
                    selected_number <= engine_val;
                else
                    selected_number <= 4'd1;
            end

            prev_engine_x <= engine_x;
            prev_engine_y <= engine_y;

            // Toggle modes
            if (btnC_edge) begin
                if (mode == MODE_MOVE && !fixed_mask_out[engine_y][engine_x]) begin
                    mode <= MODE_NUMBER;
                    selected_number <= (engine_val != 0) ? engine_val : 4'd1;
                end
                else begin
                    mode <= MODE_MOVE;
                end
            end
            
            else if (mode == MODE_NUMBER && !fixed_mask_out[engine_y][engine_x]) begin
                if (btnU_edge)
                    selected_number <= (selected_number == 9) ? 1 : selected_number + 1;
                else if (btnD_edge)
                    selected_number <= (selected_number == 1) ? 9 : selected_number - 1;
            end       
        end
    end

    // Flashing cursor
    logic [26:0] flash_div;
    always_ff @(posedge clk) flash_div <= flash_div + 1;
    logic flash_state;
    assign flash_state = flash_div[26];
    logic flash_state_visible;
    assign flash_state_visible = (mode == MODE_NUMBER) ? flash_state : 1'b1;

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
            if (!fixed_mask_out[engine_y][engine_x]) begin
                cmd_number = selected_number;
                cmd_valid  = btnC_edge;
            end else begin
                cmd_number = 0;
                cmd_valid  = 0;
            end
        end
        else begin
            cmd_number = 4'd0;
            cmd_valid  = cmd_up | cmd_down | cmd_left | cmd_right;
        end
    end

    assign cmd_enter = btnC_edge;

    // Sudoku Engine Instance
    sudoku_engine ENGINE(
        .clk(clk),
        .reset(reset | soft_reset),

        .puzzle_selector(puzzle_selector),

        .cmd_number(cmd_number),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_valid(cmd_valid),

        //correctness input
        .check_enable(check_enable),

        // Standard outputs
        .current_x(engine_x),
        .current_y(engine_y),
        .current_val(engine_val),
        .game_won(game_won),
        .game_lost(game_lost),
        .engine_ready(engine_ready),

        // correctness outputs
        .check_win(check_win),
        .check_lose(check_lose),
        .cell_match(cell_match),

        // Grid output for drawing
        .grid_out(grid_out),
        .fixed_mask_out(fixed_mask_out)
    );

    // Drawing module
    logic [3:0] r, g, b;

    sudoku_draw DRAW(
        //correctness overlay
        .check_enable(check_enable),
        .check_win(check_win),
        .check_lose(check_lose),
        .cell_match(cell_match),

        // VGA pixel
        .x(x),
        .y(y),

        // Values
        .grid_vals(grid_out),
        .fixed_mask(fixed_mask_out),
        .cursor_x(engine_x),
        .cursor_y(engine_y),
        .flash_state(flash_state_visible),
        .preview_number((mode == MODE_NUMBER) ? selected_number : 4'd0),
        .puzzle_selector(puzzle_selector),

        // Output color
        .red(r),
        .green(g),
        .blue(b)
    );

    assign vgaRed   = video_on ? r : 4'b0000;
    assign vgaGreen = video_on ? g : 4'b0000;
    assign vgaBlue  = video_on ? b : 4'b0000;

    // Seven Segment Display
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