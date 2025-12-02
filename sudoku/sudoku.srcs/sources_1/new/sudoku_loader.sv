`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
// 
// Module Name: sudoku_loader
// Description: Handles loading puzzles from ROM into RAM and shadow registers
//////////////////////////////////////////////////////////////////////////////////

module sudoku_loader(
    input  logic        clk,
    input  logic        reset,
    input  logic        start_load,          // Pulse to start loading
    input  logic [1:0]  puzzle_selector,     // Which puzzle (0-2)
    
    // RAM write interface for grid
    output logic        grid_we,
    output logic [6:0]  grid_adr,
    output logic [3:0]  grid_din,
    
    // RAM write interface for solution
    output logic        sol_we,
    output logic [6:0]  sol_adr,
    output logic [3:0]  sol_din,
    
    // RAM write interface for mask
    output logic        mask_we,
    output logic [6:0]  mask_adr,
    output logic        mask_din,
    
    // Shadow register write interface
    output logic        shadow_we,
    output logic [6:0]  shadow_adr,
    output logic [3:0]  shadow_grid_din,
    output logic        shadow_mask_din,
    
    // Status
    output logic        loading,             // Currently loading
    output logic        load_done            // Pulse when done
);

    // State machine
    typedef enum logic [1:0] {
        S_IDLE,
        S_LOAD_INIT,
        S_LOAD_SOL,
        S_DONE
    } state_t;
    
    state_t state;
    logic [6:0] counter;

    // Puzzle ROM interface
    logic [3:0] nibble_init;
    logic [3:0] nibble_sol;

    puzzle_rom PUZZLE_ROM (
        .puzzle_selector(puzzle_selector),
        .cell_index(counter),
        .init_value(nibble_init),
        .solution_value(nibble_sol)
    );

    // Status outputs
    assign loading = (state == S_LOAD_INIT) || (state == S_LOAD_SOL);

    // State machine
    always_ff @(posedge clk) begin
        if (reset) begin
            state     <= S_IDLE;
            counter   <= 7'd0;
            load_done <= 1'b0;
        end else begin
            load_done <= 1'b0;  // Default: pulse off
            
            case (state)
                S_IDLE: begin
                    if (start_load) begin
                        state   <= S_LOAD_INIT;
                        counter <= 7'd0;
                    end
                end

                S_LOAD_INIT: begin
                    if (counter == 7'd80) begin
                        state   <= S_LOAD_SOL;
                        counter <= 7'd0;
                    end else begin
                        counter <= counter + 7'd1;
                    end
                end

                S_LOAD_SOL: begin
                    if (counter == 7'd80) begin
                        state     <= S_DONE;
                        load_done <= 1'b1;
                    end else begin
                        counter <= counter + 7'd1;
                    end
                end

                S_DONE: begin
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    // Output control logic
    always_comb begin
        // Defaults
        grid_we   = 1'b0;
        grid_adr  = counter;
        grid_din  = 4'd0;
        
        sol_we    = 1'b0;
        sol_adr   = counter;
        sol_din   = 4'd0;
        
        mask_we   = 1'b0;
        mask_adr  = counter;
        mask_din  = 1'b0;
        
        shadow_we       = 1'b0;
        shadow_adr      = counter;
        shadow_grid_din = 4'd0;
        shadow_mask_din = 1'b0;

        case (state)
            S_LOAD_INIT: begin
                // Write to grid RAM and mask RAM
                grid_we  = 1'b1;
                grid_adr = counter;
                grid_din = nibble_init;
                
                mask_we  = 1'b1;
                mask_adr = counter;
                mask_din = (nibble_init != 4'd0);

                // Also write to shadow register
                shadow_we       = 1'b1;
                shadow_adr      = counter;
                shadow_grid_din = nibble_init;
                shadow_mask_din = (nibble_init != 4'd0);
            end

            S_LOAD_SOL: begin
                // Write to solution RAM only
                sol_we  = 1'b1;
                sol_adr = counter;
                sol_din = nibble_sol;
            end

            default: begin
                // Keep defaults
            end
        endcase
    end

endmodule