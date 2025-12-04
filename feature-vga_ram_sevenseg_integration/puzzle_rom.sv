`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
// 
// Module Name: puzzle_rom
// Description: ROM containing Sudoku puzzles and their solutions
//              Reads decimal format from puzzles.mem with fallback to hardcoded
//////////////////////////////////////////////////////////////////////////////////

module puzzle_rom(
    input  logic [1:0]  puzzle_selector,  // Which puzzle (0-2)
    input  logic [6:0]  cell_index,       // Which cell (0-80)
    output logic [3:0]  init_value,       // Initial puzzle value
    output logic [3:0]  solution_value    // Solution value
);

    // ROM with puzzles: 3 puzzles * 2 (init + solution) = 6 entries
    logic [3:0] puzzle_data [0:5][0:80];
    logic use_fallback;

    integer file, i, j, char;
    
    initial begin
        use_fallback = 0;
        file = $fopen("puzzles.mem", "r");
        
        if (file == 0) begin
            $display("WARNING: Could not open puzzles.mem, using hardcoded puzzles");
            use_fallback = 1;
        end else begin
            // Read 6 lines (3 puzzles × 2 for init + solution)
            for (i = 0; i < 6; i = i + 1) begin
                // Read 81 characters per line
                for (j = 0; j <= 80; j = j + 1) begin
                    char = $fgetc(file);
                    
                    // Check for read errors or EOF
                    if (char == -1) begin
                        $display("WARNING: Error reading puzzles.mem at line %0d, char %0d", i, j);
                        $display("         Switching to hardcoded puzzles");
                        use_fallback = 1;
                        break;
                    end
                    
                    // Convert ASCII digit to decimal value
                    if (char >= "0" && char <= "9") begin
                        puzzle_data[i][j] = char - "0";
                    end else begin
                        puzzle_data[i][j] = 4'h0;
                    end
                end
                
                if (use_fallback) break;
                
                // Skip to next line (read newline character)
                char = $fgetc(file);
            end
            
            $fclose(file);
        end
        
        // Load hardcoded puzzles if file failed
        if (use_fallback) begin
            // Puzzle 0 - Init
            puzzle_data[0] = '{5,3,0,0,7,0,0,0,0,6,0,0,1,9,5,0,0,0,0,9,8,0,0,0,0,6,0,8,0,0,0,6,0,0,0,3,4,0,0,8,0,3,0,0,1,7,0,0,0,2,0,0,0,6,0,6,0,0,0,0,2,8,0,0,0,0,4,1,9,0,0,5,0,0,0,0,8,0,0,7,9};
            
            // Puzzle 0 - Solution
            puzzle_data[1] = '{5,3,4,6,7,8,9,1,2,6,7,2,1,9,5,3,4,8,1,9,8,3,4,2,5,6,7,8,5,9,7,6,1,4,2,3,4,2,6,8,5,3,7,9,1,7,1,3,9,2,4,8,5,6,9,6,1,5,3,7,2,8,4,2,8,7,4,1,9,6,3,5,3,4,5,2,8,6,1,7,9};
            
            // Puzzle 1 - Init
            puzzle_data[2] = '{1,2,3,4,5,6,7,8,0,4,5,6,7,8,9,1,2,3,7,8,9,1,2,3,4,5,6,2,3,1,5,6,4,8,9,7,5,6,4,8,9,7,2,3,1,8,9,7,2,3,1,5,6,4,3,1,2,6,4,5,9,7,8,6,4,5,9,7,8,3,1,2,9,7,8,3,1,2,6,4,5};
            
            // Puzzle 1 - Solution
            puzzle_data[3] = '{1,2,3,4,5,6,7,8,9,4,5,6,7,8,9,1,2,3,7,8,9,1,2,3,4,5,6,2,3,1,5,6,4,8,9,7,5,6,4,8,9,7,2,3,1,8,9,7,2,3,1,5,6,4,3,1,2,6,4,5,9,7,8,6,4,5,9,7,8,3,1,2,9,7,8,3,1,2,6,4,5};
            
            // Puzzle 2 - Init
            puzzle_data[4] = '{0,0,0,2,6,0,7,0,1,6,8,0,0,7,0,0,9,0,1,9,0,0,0,4,5,0,0,8,2,0,1,0,0,0,4,0,0,4,0,6,0,2,9,0,0,0,5,0,0,0,3,0,2,8,0,9,0,3,0,0,0,7,4,0,4,0,0,5,0,0,3,6,7,0,3,0,1,8,0,0,0};
            
            // Puzzle 2 - Solution
            puzzle_data[5] = '{4,3,5,2,6,9,7,8,1,6,8,2,5,7,1,4,9,3,1,9,7,8,3,4,5,6,2,8,2,6,1,9,5,3,4,7,3,7,4,6,8,2,9,1,5,9,5,1,7,4,3,6,2,8,5,1,9,3,2,6,8,7,4,2,4,8,9,5,7,1,3,6,7,6,3,4,1,8,2,5,9};
        end
    end

    // Map selector to ROM indices
    logic [2:0] rom_idx_init;
    logic [2:0] rom_idx_sol;
    assign rom_idx_init = {1'b0, puzzle_selector} * 2;     
    assign rom_idx_sol  = {1'b0, puzzle_selector} * 2 + 1; 

    // Output values
    assign init_value     = puzzle_data[rom_idx_init][cell_index];
    assign solution_value = puzzle_data[rom_idx_sol][cell_index];

endmodule