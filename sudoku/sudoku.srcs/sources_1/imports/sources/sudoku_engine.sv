`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
// 
// Module Name: sudoku_engine
// Description: Top-level Sudoku game engine - instantiates and connects all
//              submodules: loader, gameplay, checker, RAMs, and shadow register
//////////////////////////////////////////////////////////////////////////////////

module sudoku_engine(
    input  logic       clk,
    input  logic       reset,
    input  logic [1:0] puzzle_selector,
    input  logic [3:0] cmd_number,
    input  logic       cmd_up,
    input  logic       cmd_down,
    input  logic       cmd_left,
    input  logic       cmd_right,
    input  logic       cmd_enter,
    input  logic       cmd_valid,
    output logic [3:0] current_x,
    output logic [3:0] current_y,
    output logic [3:0] current_val,
    output logic       game_won,
    output logic       game_lost,
    output logic       engine_ready,
    
    // Expose grid and fixed_mask to VGA
    output logic [3:0] grid_out       [0:8][0:8],
    output logic       fixed_mask_out [0:8][0:8]
);

    // =========================================================================
    // State Machine (high-level game state)
    // =========================================================================
    typedef enum logic [1:0] {
        S_LOADING,
        S_PLAY,
        S_CHECKING
    } state_t;

    state_t state;

    // =========================================================================
    // Input Event Latching
    // =========================================================================
    logic up_evt, down_evt, left_evt, right_evt, enter_evt;
    logic [3:0] number_evt;

    always_ff @(posedge clk) begin
        if (reset) begin
            up_evt     <= 1'b0;
            down_evt   <= 1'b0;
            left_evt   <= 1'b0;
            right_evt  <= 1'b0;
            enter_evt  <= 1'b0;
            number_evt <= 4'd0;
        end else begin
            up_evt     <= cmd_valid && cmd_up;
            down_evt   <= cmd_valid && cmd_down;
            left_evt   <= cmd_valid && cmd_left;
            right_evt  <= cmd_valid && cmd_right;
            enter_evt  <= cmd_valid && cmd_enter;

            if (cmd_valid)
                number_evt <= cmd_number;
            else
                number_evt <= 4'd0;
        end
    end

    // =========================================================================
    // RAM Instances
    // =========================================================================
    // Grid RAM
    logic        grid_we;
    logic [6:0]  grid_adr;
    logic [3:0]  grid_din;
    logic [3:0]  grid_dout;
    
    ram #(.N(7), .M(4)) GRID_RAM (
        .clk(clk),
        .we(grid_we),
        .adr(grid_adr),
        .din(grid_din),
        .dout(grid_dout)
    );
    
    // Solution RAM
    logic        sol_we;
    logic [6:0]  sol_adr;
    logic [3:0]  sol_din;
    logic [3:0]  sol_dout;
    
    ram #(.N(7), .M(4)) SOLUTION_RAM (
        .clk(clk),
        .we(sol_we),
        .adr(sol_adr),
        .din(sol_din),
        .dout(sol_dout)
    );
    
    // Fixed Mask RAM
    logic        mask_we;
    logic [6:0]  mask_adr;
    logic        mask_din;
    logic        mask_dout;
    
    ram #(.N(7), .M(1)) MASK_RAM (
        .clk(clk),
        .we(mask_we),
        .adr(mask_adr),
        .din(mask_din),
        .dout(mask_dout)
    );

    // =========================================================================
    // Shadow Register for VGA Display
    // =========================================================================
    logic        shadow_we;
    logic [6:0]  shadow_adr;
    logic [3:0]  shadow_grid_din;
    logic        shadow_mask_din;

    shadow_register SHADOW_REG (
        .clk(clk),
        .we(shadow_we),
        .write_adr(shadow_adr),
        .grid_din(shadow_grid_din),
        .mask_din(shadow_mask_din),
        .grid_out(grid_out),
        .fixed_mask_out(fixed_mask_out)
    );

    // =========================================================================
    // Loader Module
    // =========================================================================
    logic        loader_start;
    logic        loader_grid_we;
    logic [6:0]  loader_grid_adr;
    logic [3:0]  loader_grid_din;
    logic        loader_sol_we;
    logic [6:0]  loader_sol_adr;
    logic [3:0]  loader_sol_din;
    logic        loader_mask_we;
    logic [6:0]  loader_mask_adr;
    logic        loader_mask_din;
    logic        loader_shadow_we;
    logic [6:0]  loader_shadow_adr;
    logic [3:0]  loader_shadow_grid_din;
    logic        loader_shadow_mask_din;
    logic        loader_loading;
    logic        loader_done;

    sudoku_loader LOADER (
        .clk(clk),
        .reset(reset),
        .start_load(loader_start),
        .puzzle_selector(puzzle_selector),
        .grid_we(loader_grid_we),
        .grid_adr(loader_grid_adr),
        .grid_din(loader_grid_din),
        .sol_we(loader_sol_we),
        .sol_adr(loader_sol_adr),
        .sol_din(loader_sol_din),
        .mask_we(loader_mask_we),
        .mask_adr(loader_mask_adr),
        .mask_din(loader_mask_din),
        .shadow_we(loader_shadow_we),
        .shadow_adr(loader_shadow_adr),
        .shadow_grid_din(loader_shadow_grid_din),
        .shadow_mask_din(loader_shadow_mask_din),
        .loading(loader_loading),
        .load_done(loader_done)
    );

    // =========================================================================
    // Gameplay Module
    // =========================================================================
    logic        gameplay_enable;
    logic [3:0]  gameplay_cursor_x;
    logic [3:0]  gameplay_cursor_y;
    logic [6:0]  gameplay_cursor_adr;
    logic        gameplay_grid_we;
    logic [6:0]  gameplay_grid_adr;
    logic [3:0]  gameplay_grid_din;
    logic        gameplay_shadow_we;
    logic [6:0]  gameplay_shadow_adr;
    logic [3:0]  gameplay_shadow_grid_din;
    logic [3:0]  gameplay_current_val;
    logic        gameplay_current_fixed;

    sudoku_gameplay GAMEPLAY (
        .clk(clk),
        .reset(reset),
        .enable(gameplay_enable),
        .btn_up(up_evt),
        .btn_down(down_evt),
        .btn_left(left_evt),
        .btn_right(right_evt),
        .number_in(number_evt),
        .cell_value(grid_dout),
        .cell_fixed(mask_dout),
        .cursor_x(gameplay_cursor_x),
        .cursor_y(gameplay_cursor_y),
        .cursor_adr(gameplay_cursor_adr),
        .grid_we(gameplay_grid_we),
        .grid_adr(gameplay_grid_adr),
        .grid_din(gameplay_grid_din),
        .shadow_we(gameplay_shadow_we),
        .shadow_adr(gameplay_shadow_adr),
        .shadow_grid_din(gameplay_shadow_grid_din),
        .current_val(gameplay_current_val),
        .current_fixed(gameplay_current_fixed)
    );

    // =========================================================================
    // Checker Module
    // =========================================================================
    logic        checker_start;
    logic [6:0]  checker_adr;
    logic        checker_checking;
    logic        checker_done;
    logic        checker_won;
    logic        checker_lost;

    sudoku_checker CHECKER (
        .clk(clk),
        .reset(reset),
        .start_check(checker_start),
        .grid_value(grid_dout),
        .solution_value(sol_dout),
        .check_adr(checker_adr),
        .checking(checker_checking),
        .check_done(checker_done),
        .game_won(checker_won),
        .game_lost(checker_lost)
    );

    // =========================================================================
    // Output Assignments
    // =========================================================================
    assign current_x    = gameplay_cursor_x;
    assign current_y    = gameplay_cursor_y;
    assign current_val  = gameplay_current_val;
    assign engine_ready = (state == S_PLAY);
    assign game_won     = checker_won;
    assign game_lost    = checker_lost;

    // =========================================================================
    // Main State Machine
    // =========================================================================
    always_ff @(posedge clk) begin
        if (reset) begin
            state        <= S_LOADING;
            loader_start <= 1'b0;
            checker_start <= 1'b0;
        end else begin
            loader_start  <= 1'b0;  // Default: no start pulse
            checker_start <= 1'b0;
            
            case (state)
                S_LOADING: begin
                    // Wait for loader to finish (loader auto-starts)
                    if (loader_done) begin
                        state <= S_PLAY;
                    end
                end

                S_PLAY: begin
                    if (enter_evt) begin
                        state <= S_CHECKING;
                        checker_start <= 1'b1;
                    end
                end

                S_CHECKING: begin
                    if (checker_done) begin
                        state <= S_PLAY;
                    end
                end

                default: state <= S_LOADING;
            endcase
        end
    end

    // =========================================================================
    // Gameplay Enable
    // =========================================================================
    assign gameplay_enable = (state == S_PLAY);

    // =========================================================================
    // RAM and Shadow Register Multiplexing
    // =========================================================================
    always_comb begin
        // Default to gameplay addressing
        grid_we  = 1'b0;
        grid_adr = gameplay_cursor_adr;
        grid_din = 4'd0;
        
        sol_we   = 1'b0;
        sol_adr  = gameplay_cursor_adr;
        sol_din  = 4'd0;
        
        mask_we  = 1'b0;
        mask_adr = gameplay_cursor_adr;
        mask_din = 1'b0;

        shadow_we       = 1'b0;
        shadow_adr      = 7'd0;
        shadow_grid_din = 4'd0;
        shadow_mask_din = 1'b0;

        case (state)
            S_LOADING: begin
                // Loader controls all RAMs and shadow
                grid_we  = loader_grid_we;
                grid_adr = loader_grid_adr;
                grid_din = loader_grid_din;
                
                sol_we   = loader_sol_we;
                sol_adr  = loader_sol_adr;
                sol_din  = loader_sol_din;
                
                mask_we  = loader_mask_we;
                mask_adr = loader_mask_adr;
                mask_din = loader_mask_din;

                shadow_we       = loader_shadow_we;
                shadow_adr      = loader_shadow_adr;
                shadow_grid_din = loader_shadow_grid_din;
                shadow_mask_din = loader_shadow_mask_din;
            end

            S_PLAY: begin
                // Gameplay controls grid RAM and shadow
                grid_we  = gameplay_grid_we;
                grid_adr = gameplay_grid_adr;
                grid_din = gameplay_grid_din;
                
                // Mask RAM just reads at cursor position
                mask_adr = gameplay_cursor_adr;

                shadow_we       = gameplay_shadow_we;
                shadow_adr      = gameplay_shadow_adr;
                shadow_grid_din = gameplay_shadow_grid_din;
                shadow_mask_din = 1'b0;
            end

            S_CHECKING: begin
                // Checker controls grid and solution read addresses
                grid_adr = checker_adr;
                sol_adr  = checker_adr;
            end

            default: begin
                // Keep defaults
            end
        endcase
    end

endmodule