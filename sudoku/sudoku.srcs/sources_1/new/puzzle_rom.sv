`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
// 
// Module Name: puzzle_rom
// Description: ROM containing Sudoku puzzles and their solutions
//////////////////////////////////////////////////////////////////////////////////

module puzzle_rom(
    input  logic [1:0]  puzzle_selector,  // Which puzzle (0-2)
    input  logic [6:0]  cell_index,       // Which cell (0-80)
    output logic [3:0]  init_value,       // Initial puzzle value
    output logic [3:0]  solution_value    // Solution value
);

    // ROM with puzzles: 3 puzzles * 2 (init + solution) = 6 entries
    logic [323:0] puzzle_data [0:5];

    initial begin
        $readmemh("puzzles.mem", puzzle_data);
    end

    // Map selector to ROM indices
    logic [2:0] rom_idx_init;
    logic [2:0] rom_idx_sol;
    assign rom_idx_init = {1'b0, puzzle_selector} * 2;     
    assign rom_idx_sol  = {1'b0, puzzle_selector} * 2 + 1; 

    // Bit slicing: Extract 4 bits for each cell
    assign init_value     = puzzle_data[rom_idx_init][323 - (cell_index * 4) -: 4];
    assign solution_value = puzzle_data[rom_idx_sol] [323 - (cell_index * 4) -: 4];

endmodule