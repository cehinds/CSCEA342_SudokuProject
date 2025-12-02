`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Constantine Hindes
// 
// Design Name: VGA Sudoku Game
// Module Name: sudoku_engine
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
    
    // Expose internal grid and fixed_mask to VGA
    output logic [3:0] grid_out       [0:8][0:8],
    output logic       fixed_mask_out [0:8][0:8]
);

    // Internal storage: [row][col] (row = Y, col = X)
    logic [3:0] grid       [0:8][0:8];
    logic [3:0] solution   [0:8][0:8];
    logic       fixed_mask [0:8][0:8];
    
    // ROM with puzzles: 3 puzzles * 2 (init + solution) = 6 entries
    logic [323:0] puzzle_rom [0:5];

    initial begin
        $readmemh("puzzles.mem", puzzle_rom);
    end

    typedef enum logic [1:0] {
        S_LOAD_INIT,
        S_LOAD_SOL,
        S_PLAY,
        S_CHECK_WIN
    } state_t;

    state_t state;
    
    // Loading variables
    logic [6:0] load_counter;
    logic [3:0] load_row, load_col;
    logic [2:0] rom_idx_init;
    logic [2:0] rom_idx_sol;
    logic [3:0] nibble_init;
    logic [3:0] nibble_sol;

    // Map selector to ROM indices
    assign rom_idx_init = {1'b0, puzzle_selector} * 2;     
    assign rom_idx_sol  = {1'b0, puzzle_selector} * 2 + 1; 

    // Counter → Grid coordinates (row-major)
    //   load_row = load_counter / 9 = y
    //   load_col = load_counter % 9 = x
    assign load_col = load_counter % 9;
    assign load_row = load_counter / 9;

    // Outputs
    // NOTE: grid is [row][col], but current_x/y are [col]/[row]
    assign current_val  = grid[current_y][current_x];   
    assign engine_ready = (state == S_PLAY);
    
    // Bit slicing: Extract 4 bits for each cell
    assign nibble_init = puzzle_rom[rom_idx_init][323 - (load_counter * 4) -: 4];
    assign nibble_sol  = puzzle_rom[rom_idx_sol] [323 - (load_counter * 4) -: 4];

   
    // Latch one-cycle button events based on cmd_valid
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
            // One-cycle registered events derived from debounced/onepulse inputs
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
    
    // Main state machine
    always_ff @(posedge clk) begin
        if (reset) begin
            state        <= S_LOAD_INIT;
            load_counter <= 0;
            current_x    <= 0;
            current_y    <= 0;
            game_won     <= 0;
            game_lost    <= 0;
        end else begin
            case (state)

                // Load initial grid (puzzle with blanks)
                S_LOAD_INIT: begin
                    // Write nibble into grid[row][col]
                    grid[load_row][load_col] <= nibble_init;

                    // Set fixed_mask[row][col] if prefilled (non-zero)
                    if (nibble_init != 0)
                        fixed_mask[load_row][load_col] <= 1;
                    else
                        fixed_mask[load_row][load_col] <= 0;

                    if (load_counter == 80) begin
                        state        <= S_LOAD_SOL;
                        load_counter <= 0;
                    end else begin
                        load_counter <= load_counter + 1;
                    end
                end

                // Load solution grid
                S_LOAD_SOL: begin
                    solution[load_row][load_col] <= nibble_sol;

                    if (load_counter == 80) begin
                        state <= S_PLAY;
                    end else begin
                        load_counter <= load_counter + 1;
                    end
                end

                // Game play
                S_PLAY: begin
                    // Movement (current_x = col, current_y = row)
                    if (up_evt)    current_y <= (current_y == 0) ? 8 : current_y - 1;
                    if (down_evt)  current_y <= (current_y == 8) ? 0 : current_y + 1;
                    if (left_evt)  current_x <= (current_x == 0) ? 8 : current_x - 1;
                    if (right_evt) current_x <= (current_x == 8) ? 0 : current_x + 1;

                    // Entry - use [row][col] = [current_y][current_x]
                    if (number_evt != 0 && fixed_mask[current_y][current_x] == 0) begin
                        grid[current_y][current_x] <= number_evt;
                    end

                    // Check Win
                    if (enter_evt) begin
                        state        <= S_CHECK_WIN;
                        load_counter <= 0; 
                        game_won     <= 1;
                        game_lost    <= 0;
                    end
                end

                // Check grid to see if it matches solution
                S_CHECK_WIN: begin
                    if (grid[load_row][load_col] != solution[load_row][load_col]) begin
                        game_won  <= 0;
                        game_lost <= 1; 
                    end

                    if (load_counter == 80) begin
                        state <= S_PLAY; 
                    end else begin
                        load_counter <= load_counter + 1;
                    end
                end
            endcase
        end
    end
    
    // Drive grid outputs for VGA
    always_comb begin
        for (int r = 0; r < 9; r++)
            for (int c = 0; c < 9; c++) begin
                grid_out[r][c]       = grid[r][c];
                fixed_mask_out[r][c] = fixed_mask[r][c];
            end
    end

endmodule

