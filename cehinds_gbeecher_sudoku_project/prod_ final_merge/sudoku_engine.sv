`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
//
// Module: sudoku_engine
// Description: Loads puzzle + solution, handles cursor movement,
//              number entry, correctness checking, and win/lose logic.
//////////////////////////////////////////////////////////////////////////////////

module sudoku_engine(
    input  logic       clk,
    input  logic       reset,

    // puzzle index 0-2
    input  logic [1:0] puzzle_selector,

    // commands from top-level state machine
    input  logic [3:0] cmd_number,
    input  logic       cmd_up,
    input  logic       cmd_down,
    input  logic       cmd_left,
    input  logic       cmd_right,
    input  logic       cmd_enter,
    input  logic       cmd_valid,

    // SW2 correctness check
    input  logic       check_enable,

    // cursor
    output logic [3:0] current_x,
    output logic [3:0] current_y,
    output logic [3:0] current_val,

    output logic       game_won,
    output logic       game_lost,
    output logic       engine_ready,

    // UI correctness outputs
    output logic       check_win,
    output logic       check_lose,
    output logic       cell_match     [0:8][0:8],

    // grid exposed to VGA
    output logic [3:0] grid_out       [0:8][0:8],
    output logic       fixed_mask_out [0:8][0:8]
);

    // Internal Storage
    logic [3:0] grid       [0:8][0:8]; 
    logic [3:0] solution   [0:8][0:8]; 
    logic       fixed_mask [0:8][0:8]; 

    // Rom
    logic [323:0] puzzle_rom [0:5];
    initial begin
        $readmemh("puzzles.mem", puzzle_rom);
    end

    // map selector
    logic [2:0] rom_idx_init;
    logic [2:0] rom_idx_sol;

    assign rom_idx_init = puzzle_selector * 2;
    assign rom_idx_sol  = puzzle_selector * 2 + 1;

    //State machine
    typedef enum logic [1:0] {
        S_LOAD_INIT,
        S_LOAD_SOL,
        S_PLAY,
        S_CHECK_WIN
    } state_t;

    state_t state;

    // grid loading counter
    logic [6:0] load_counter;
    logic [3:0] load_row, load_col;

    assign load_col = load_counter % 9;
    assign load_row = load_counter / 9;

    // extract nibble for each cell
    logic [3:0] nibble_init, nibble_sol;

    assign nibble_init = puzzle_rom[rom_idx_init][323 - (load_counter * 4) -: 4];
    assign nibble_sol  = puzzle_rom[rom_idx_sol] [323 - (load_counter * 4) -: 4];

    //cmd_valid events
    logic up_evt, down_evt, left_evt, right_evt, enter_evt;
    logic [3:0] number_evt;

    always_ff @(posedge clk) begin
        if (reset) begin
            up_evt <= 0; down_evt <= 0; left_evt <= 0;
            right_evt <= 0; enter_evt <= 0;
            number_evt <= 0;
        end
        else begin
            up_evt     <= cmd_valid && cmd_up;
            down_evt   <= cmd_valid && cmd_down;
            left_evt   <= cmd_valid && cmd_left;
            right_evt  <= cmd_valid && cmd_right;
            enter_evt  <= cmd_valid && cmd_enter;

            if (cmd_valid)
                number_evt <= cmd_number;
            else
                number_evt <= 0;
        end
    end

    // Main engine logic
    always_ff @(posedge clk) begin
        if (reset) begin
            state        <= S_LOAD_INIT;
            load_counter <= 0;
            current_x    <= 0;
            current_y    <= 0;
            game_won     <= 0;
            game_lost    <= 0;
        end
        else begin
            case (state)

            // Load default puzzle grid
            S_LOAD_INIT: begin
                grid[load_row][load_col] <= nibble_init;
                fixed_mask[load_row][load_col] <= (nibble_init != 0);

                if (load_counter == 80) begin
                    load_counter <= 0;
                    state <= S_LOAD_SOL;
                end
                else
                    load_counter <= load_counter + 1;
            end

            // Load the solution grid
            S_LOAD_SOL: begin
                solution[load_row][load_col] <= nibble_sol;

                if (load_counter == 80) begin
                    load_counter <= 0;
                    state <= S_PLAY;
                end
                else
                    load_counter <= load_counter + 1;
            end

            // Game play
            S_PLAY: begin
                // cursor motion
                if (up_evt)    current_y <= (current_y == 0) ? 8 : current_y - 1;
                if (down_evt)  current_y <= (current_y == 8) ? 0 : current_y + 1;
                if (left_evt)  current_x <= (current_x == 0) ? 8 : current_x - 1;
                if (right_evt) current_x <= (current_x == 8) ? 0 : current_x + 1;

                // writing a number
                if (number_evt != 0 && !fixed_mask[current_y][current_x])
                    grid[current_y][current_x] <= number_evt;

                // when ENTER pressed check for correctness
                if (enter_evt) begin
                    game_won <= 1;
                    game_lost <= 0;
                    load_counter <= 0;
                    state <= S_CHECK_WIN;
                end
            end

            // Verify the entire grid
            S_CHECK_WIN: begin
                if (grid[load_row][load_col] != solution[load_row][load_col]) begin
                    game_won  <= 0;
                    game_lost <= 1;
                end

                if (load_counter == 80) begin
                    state <= S_PLAY;
                end
                else begin
                    load_counter <= load_counter + 1;
                end
            end

            endcase
        end
    end

    assign current_val = grid[current_y][current_x];
    assign engine_ready = (state == S_PLAY);
    
    //Correctness check
    logic full_match_int;

    always_comb begin
        full_match_int = 1;

        for (int r = 0; r < 9; r++) begin
            for (int c = 0; c < 9; c++) begin
                // VGA output mirrors grid
                grid_out[r][c]       = grid[r][c];
                fixed_mask_out[r][c] = fixed_mask[r][c];

                if (check_enable) begin
                    cell_match[r][c] = (grid[r][c] == solution[r][c]);
                    if (!cell_match[r][c])
                        full_match_int = 0;
                end
                else begin
                    cell_match[r][c] = 0;
                end
            end
        end
    end

    assign check_win  = check_enable && full_match_int;
    assign check_lose = check_enable && !full_match_int;

endmodule