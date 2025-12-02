`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Gwendolyn Beecher, Constantine Hinds
// 
// Module: sevenseg_sudoku
// Description: Seven segment display controller for Sudoku game
//              Displays grid position, edit mode indicator, and cell value
//////////////////////////////////////////////////////////////////////////////////

module sevenseg_sudoku(
    input  logic           clk,
    input  logic [3:0]     engine_x,           // Current X position (0-8)
    input  logic [3:0]     engine_y,           // Current Y position (0-8)
    input  logic [3:0]     engine_val,         // Current cell value
    input  logic [3:0]     selected_number,    // Number selected in NUMBER mode
    input  logic           mode,               // 0=MOVE, 1=NUMBER
    input  logic           fixed_mask [0:8][0:8], // Grid fixed mask
    output logic [3:0]     Anode_Activate,
    output logic [6:0]     LED_out
);

    // Check if current cell is editable (not fixed)
    logic cell_is_editable;
    assign cell_is_editable = ~fixed_mask[engine_y][engine_x];
    
    // Slow flash for the fourth digit (slower than VGA flash)
    logic [25:0] sevenseg_flash_div;
    always_ff @(posedge clk) sevenseg_flash_div <= sevenseg_flash_div + 1;
    logic sevenseg_flash = sevenseg_flash_div[25]; // Slower flash
    
    // Build display value for seven segment
    logic [3:0] digit_0, digit_1, digit_2, digit_3;
    
    always_comb begin
        // Digit 0 (leftmost): X position (0-8)
        digit_0 = engine_x;
        
        // Digit 1: Y position (0-8)
        digit_1 = engine_y;
        
        // Digit 2: 'E' if in NUMBER mode and cell is editable, else blank
        if (mode == 1'b1 && cell_is_editable)
            digit_2 = 4'hE;  // 'E' character
        else
            digit_2 = 4'hF;  // Blank
        
        // Digit 3: Current value or flashing selected number
        if (mode == 1'b1 && cell_is_editable) begin
            // Flash the selected number
            if (sevenseg_flash)
                digit_3 = selected_number;
            else
                digit_3 = 4'hF;  // Blank during off phase
        end
        else begin
            // Show current grid value (or blank if 0)
            if (engine_val == 4'd0)
                digit_3 = 4'hF;  // Blank
            else
                digit_3 = engine_val;
        end
    end
    
    // Instantiate the low-level seven segment display driver
    sevenseg SEVENSEG_DRIVER(
        .clk(clk),
        .digit_0(digit_0),
        .digit_1(digit_1),
        .digit_2(digit_2),
        .digit_3(digit_3),
        .Anode_Activate(Anode_Activate),
        .LED_out(LED_out)
    );

endmodule