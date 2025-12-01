`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Constantine Hindes
// 
// Create Date: 11/30/2025 04:56:51 PM
// Design Name: VGA Sudoku Game
// Module Name: Sudoku_engine
// Project Name: VGA Sudoku
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
    
    // ============================================================
    // NEW OUTPUTS FOR VGA DRAW
    // These expose the internal grid and fixed_mask so that
    // sudoku_draw can display user entries + prefilled cells.
    // ============================================================
    output logic [3:0] grid_out [0:8][0:8],
    output logic       fixed_mask_out [0:8][0:8]
);
    //Internal Storage
    logic [3:0] grid       [0:8][0:8];
    logic [3:0] solution   [0:8][0:8];
    logic       fixed_mask [0:8][0:8];
    
    // ROM to hold 6 strings (3 puzzles * 2 states). 
    // Width is 324 bits (81 cells * 4 bits)
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
    logic [3:0] load_x, load_y;
    logic [2:0] rom_idx_init;
    logic [2:0] rom_idx_sol;
    logic [3:0] nibble_init;
    logic [3:0] nibble_sol;

    // Map selector to ROM indices
    assign rom_idx_init = {1'b0, puzzle_selector} * 2;     
    assign rom_idx_sol  = {1'b0, puzzle_selector} * 2 + 1; 

    // Counter to Grid Coordinates
    assign load_x = load_counter % 9;
    assign load_y = load_counter / 9;

    // Outputs
    assign current_val = grid[current_x][current_y];
    assign engine_ready = (state == S_PLAY);
    
    // Bit Slicing: Extract 4 bits based on counter
    assign nibble_init = puzzle_rom[rom_idx_init][323 - (load_counter * 4) -: 4];
    assign nibble_sol  = puzzle_rom[rom_idx_sol] [323 - (load_counter * 4) -: 4];
    
    //Main state machine
    always_ff @(posedge clk) begin
        if (reset) 
        begin
            state        <= S_LOAD_INIT;
            load_counter <= 0;
            current_x    <= 0;
            current_y    <= 0;
            game_won     <= 0;
            game_lost    <= 0;
        end 
        else begin
            case (state)
                S_LOAD_INIT: 
                begin
                    grid[load_x][load_y] <= nibble_init;
                    
                    if (nibble_init != 0)
                        fixed_mask[load_x][load_y] <= 1;
                    else
                        fixed_mask[load_x][load_y] <= 0;

                    if (load_counter == 80) 
                    begin
                        state <= S_LOAD_SOL;
                        load_counter <= 0;
                    end else begin
                        load_counter <= load_counter + 1;
                    end
                end

                S_LOAD_SOL: 
                begin
                    solution[load_x][load_y] <= nibble_sol;
                    if (load_counter == 80) begin
                        state <= S_PLAY;
                    end 
                    else begin
                        load_counter <= load_counter + 1;
                    end
                end

                S_PLAY: 
                    begin
                    if (cmd_valid) 
                    begin
                        // Movement
                        if (cmd_up)    current_y <= (current_y == 0) ? 8 : current_y - 1;
                        if (cmd_down)  current_y <= (current_y == 8) ? 0 : current_y + 1;
                        if (cmd_left)  current_x <= (current_x == 0) ? 8 : current_x - 1;
                        if (cmd_right) current_x <= (current_x == 8) ? 0 : current_x + 1;

                        // Entry
                        if (cmd_number != 0 && fixed_mask[current_x][current_y] == 0) 
                        begin
                            grid[current_x][current_y] <= cmd_number;
                        end

                        // Check Win
                        if (cmd_enter) 
                        begin
                            state <= S_CHECK_WIN;
                            load_counter <= 0; 
                            game_won <= 1;
                            game_lost <= 0;
                        end
                    end
                end

                S_CHECK_WIN: 
                begin
                    if (grid[load_x][load_y] != solution[load_x][load_y]) 
                    begin
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
    
    //NEW: Drive grid outpute for VGA
        always_comb begin
        for (int r = 0; r < 9; r++)
            for (int c = 0; c < 9; c++) begin
                grid_out[r][c]       = grid[r][c];
                fixed_mask_out[r][c] = fixed_mask[r][c];
            end
    end
endmodule