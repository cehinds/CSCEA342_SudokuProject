`timescale 1ns / 1ps

module sudoku_engine(
    input  logic       clk,
    input  logic       reset,
    input  logic [1:0] puzzle_selector,
    
    // Commands from Keyboard/Buttons
    input  logic [3:0] cmd_number,
    input  logic       cmd_up,
    input  logic       cmd_down,
    input  logic       cmd_left,
    input  logic       cmd_right,
    input  logic       cmd_enter,
    input  logic       cmd_valid,

    // Outputs
    output logic [3:0] current_x,
    output logic [3:0] current_y,
    output logic [3:0] current_val,
    output logic       game_won,
    output logic       game_lost,
    output logic       engine_ready,
    
    // Grid output for VGA (Shadow Copy)
    output logic [3:0] grid_out [0:8][0:8],
    output logic       fixed_mask_out [0:8][0:8]
);

    // ============================================================
    // State Machine
    // ============================================================
    typedef enum logic [1:0] {
        S_INIT,
        S_PLAY,
        S_CHECK_WIN
    } state_t;

    state_t state = S_INIT;

    // Cursor position
    logic [3:0] cur_x = 0;
    logic [3:0] cur_y = 0;

    assign current_x = cur_x;
    assign current_y = cur_y;

    // ============================================================
    // RAM Interface
    // We use RAM to store the authoritative game state.
    // Address mapping: addr = y * 9 + x (0 to 80)
    // ============================================================
    logic [6:0] ram_addr;  // 7 bits needed for 0-80
    logic [3:0] ram_din;
    logic [3:0] ram_dout;
    logic       ram_we;

    // Instantiate the Single Port RAM
    // Parameters: N=7 (address width, 2^7=128 > 81), M=4 (data width)
    ram #(.N(7), .M(4)) GRID_RAM (
        .clk(clk),
        .we(ram_we),
        .adr(ram_addr),
        .din(ram_din),
        .dout(ram_dout)
    );

    // ============================================================
    // Logic Signals
    // ============================================================
    logic [6:0] init_counter = 0;
    logic [6:0] check_counter = 0;
    
    // Puzzles (Solutions and Init masks) would ideally be fetched from a ROM
    // For brevity, we assume a simple mask mechanism or helper module here.
    // In a full implementation, you would load these into RAM at S_INIT.
    logic [3:0] solution_grid [0:8][0:8]; // Driven by puzzle rom
    logic [3:0] init_grid     [0:8][0:8]; // Driven by puzzle rom
    
    // Helper to fetch puzzle data (You would connect your sudoku_puzzles.sv here)
    sudoku_puzzles PUZZLES (
        .selector(puzzle_selector),
        .init_grid(init_grid),
        .solution(solution_grid)
    );

    // ============================================================
    // Shadow Grid for VGA & Logic
    // Since RAM is single-port, we keep a copy for fast VGA read
    // ============================================================
    logic [3:0] grid_shadow [0:8][0:8];
    logic       fixed_mask  [0:8][0:8];
    
    assign grid_out = grid_shadow;
    assign fixed_mask_out = fixed_mask;

    // Current value at cursor (combinational read from shadow for speed)
    assign current_val = grid_shadow[cur_x][cur_y];

    // ============================================================
    // Main Process
    // ============================================================
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= S_INIT;
            init_counter <= 0;
            ram_we <= 0;
            game_won <= 0;
            game_lost <= 0;
            engine_ready <= 0;
            cur_x <= 0;
            cur_y <= 0;
        end else begin
            
            // Default Write Enable off
            ram_we <= 0;

            case (state)
                // --------------------------------------------------------
                // INIT: Load puzzle from ROM into RAM and Shadow Grid
                // --------------------------------------------------------
                S_INIT: begin
                    engine_ready <= 0;
                    
                    // Linear to (row, col) conversion for ROM lookup
                    // init_counter counts 0 to 80
                    // row = init_counter / 9
                    // col = init_counter % 9
                    // (Simplification: using counters for x/y in loop)
                    
                    // Simple Init Logic:
                    // 1. Set RAM address
                    ram_addr <= init_counter;
                    
                    // 2. Set Data (from Puzzle ROM)
                    // We need to calculate row/col from counter for the 2D array
                    // row = init_counter / 9; col = init_counter % 9;
                    // Note: Division is expensive. Better to maintain x/y counters.
                    
                    // Write to RAM
                    ram_we <= 1;
                    ram_din <= init_grid[init_counter/9][init_counter%9];
                    
                    // Update Shadow and Fixed Mask
                    grid_shadow[init_counter/9][init_counter%9] <= init_grid[init_counter/9][init_counter%9];
                    
                    if (init_grid[init_counter/9][init_counter%9] != 0)
                        fixed_mask[init_counter/9][init_counter%9] <= 1;
                    else
                        fixed_mask[init_counter/9][init_counter%9] <= 0;

                    // Increment
                    if (init_counter == 80) begin
                        state <= S_PLAY;
                        init_counter <= 0;
                    end else begin
                        init_counter <= init_counter + 1;
                    end
                end

                // --------------------------------------------------------
                // PLAY: Handle Navigation and Input
                // --------------------------------------------------------
                S_PLAY: begin
                    engine_ready <= 1;

                    // Navigation
                    if (cmd_valid) begin
                        if (cmd_up && cur_y > 0) cur_y <= cur_y - 1;
                        if (cmd_down && cur_y < 8) cur_y <= cur_y + 1;
                        if (cmd_left && cur_x > 0) cur_x <= cur_x - 1;
                        if (cmd_right && cur_x < 8) cur_x <= cur_x + 1;

                        // Number Entry
                        if (cmd_number != 0) begin
                            // Check if cell is editable
                            if (fixed_mask[cur_x][cur_y] == 0) begin
                                // 1. Write to RAM
                                ram_addr <= (cur_y * 9) + cur_x;
                                ram_din  <= cmd_number;
                                ram_we   <= 1;
                                
                                // 2. Update Shadow
                                grid_shadow[cur_x][cur_y] <= cmd_number;
                            end
                        end

                        // Check Win Command
                        if (cmd_enter) begin
                            state <= S_CHECK_WIN;
                            check_counter <= 0;
                            game_won <= 1;  // Assume win, prove wrong
                            game_lost <= 0;
                        end
                    end
                end

                // --------------------------------------------------------
                // CHECK WIN: Compare RAM/Shadow against Solution
                // --------------------------------------------------------
                S_CHECK_WIN: begin
                    // Check one cell per clock cycle (or just check all shadow instantly)
                    // Using Shadow is faster (Instant check)
                    
                    if (grid_shadow[check_counter/9][check_counter%9] != solution_grid[check_counter/9][check_counter%9]) begin
                        game_won <= 0;
                        game_lost <= 1;
                    end

                    if (check_counter == 80) begin
                        // Done checking
                        state <= S_PLAY; // Go back to play (showing Win/Loss flags)
                    end else begin
                        check_counter <= check_counter + 1;
                    end
                end
            endcase
        end
    end

endmodule