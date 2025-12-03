`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
// 
// Module Name: sudoku_checker
// Description: Handles checking if the puzzle solution is correct
//////////////////////////////////////////////////////////////////////////////////

module sudoku_checker(
    input  logic        clk,
    input  logic        reset,
    input  logic        start_check,         // Pulse to start checking
    
    // RAM read data
    input  logic [3:0]  grid_value,          // Current grid value at address
    input  logic [3:0]  solution_value,      // Solution value at address
    
    // RAM address output
    output logic [6:0]  check_adr,           // Address to read from RAMs
    
    // Status outputs
    output logic        checking,            // Currently checking
    output logic        check_done,          // Pulse when done
    output logic        game_won,            // All cells match
    output logic        game_lost            // At least one mismatch
);

    // State machine
    typedef enum logic [1:0] {
        S_IDLE,
        S_CHECK,
        S_DONE
    } state_t;
    
    state_t state;
    logic [6:0] counter;
    
    // Result registers
    logic won_reg;
    logic lost_reg;

    assign checking = (state == S_CHECK);
    assign game_won = won_reg;
    assign game_lost = lost_reg;
    assign check_adr = counter;

    // State machine
    always_ff @(posedge clk) begin
        if (reset) begin
            state      <= S_IDLE;
            counter    <= 7'd0;
            check_done <= 1'b0;
            won_reg    <= 1'b0;
            lost_reg   <= 1'b0;
        end else begin
            check_done <= 1'b0;  // Default: pulse off
            
            case (state)
                S_IDLE: begin
                    if (start_check) begin
                        state    <= S_CHECK;
                        counter  <= 7'd0;
                        won_reg  <= 1'b1;   // Assume win until proven otherwise
                        lost_reg <= 1'b0;
                    end
                end

                S_CHECK: begin
                    // Compare current cell
                    if (grid_value != solution_value) begin
                        won_reg  <= 1'b0;
                        lost_reg <= 1'b1;
                    end

                    if (counter == 7'd80) begin
                        state      <= S_DONE;
                        check_done <= 1'b1;
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

endmodule