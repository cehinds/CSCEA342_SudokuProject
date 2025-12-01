
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Gwendolyn Beecher
//           Constantine Hinds
//
// Module Name: sudoku_draw
// Project: VGA Sudoku
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module sudoku_draw(
    input  logic [9:0] x,
    input  logic [9:0] y,
    input  logic [3:0] grid_vals [0:8][0:8],  // The numbers 1-9
    input  logic       fixed_mask [0:8][0:8], // 1 = Fixed (Green), 0 = User (White)
    input  logic [3:0] cursor_x,
    input  logic [3:0] cursor_y,
    
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

    // ============================================================
    // Parameters & Layout
    // ============================================================
    // Screen is 640x480. Let's center a 360x360 grid.
    // Cell size = 40x40 pixels.
    // Grid starts at x=140, y=60.
    
    localparam GRID_START_X = 140;
    localparam GRID_START_Y = 60;
    localparam CELL_SIZE    = 40;
    localparam GRID_SIZE    = CELL_SIZE * 9; // 360
    
    // Internal signals for coordinate calculation
    logic in_grid;
    logic [3:0] grid_col; // 0-8
    logic [3:0] grid_row; // 0-8
    
    // Relative position inside a cell (0-39)
    logic [5:0] rel_x;
    logic [5:0] rel_y;
    
    // Borders
    logic is_border;
    logic is_thick_border;
    
    // Font Drawing
    logic [3:0] cell_value;
    logic       is_fixed;
    logic [7:0] font_bits;
    logic       pixel_on;
    
    // Font ROM Instance
    // Calculates which pixels are "on" for a specific number
    digit_font FONT (
        .digit(cell_value),
        .row(rel_y[5:2]), // Scaling: Use bits [5:2] to make font larger (approx 10 lines)
        .bits(font_bits)
    );

    // ============================================================
    // Drawing Logic
    // ============================================================
    always_comb begin
        // Default Background (Dark Grey)
        red   = 4'h1;
        green = 4'h1;
        blue  = 4'h2;
        
        in_grid = 0;
        grid_col = 0;
        grid_row = 0;
        rel_x = 0;
        rel_y = 0;
        cell_value = 0;
        is_fixed = 0;
        pixel_on = 0;

        // Check if we are inside the main sudoku grid area
        if (x >= GRID_START_X && x < GRID_START_X + GRID_SIZE &&
            y >= GRID_START_Y && y < GRID_START_Y + GRID_SIZE) begin
            
            in_grid = 1;
            
            // Calculate which Cell (Row/Col) we are in
            grid_col = (x - GRID_START_X) / CELL_SIZE;
            grid_row = (y - GRID_START_Y) / CELL_SIZE;
            
            // Calculate pixel offset within that cell
            rel_x = (x - GRID_START_X) % CELL_SIZE;
            rel_y = (y - GRID_START_Y) % CELL_SIZE;
            
            // Fetch Value from Engine Grid
            cell_value = grid_vals[grid_col][grid_row];
            is_fixed   = fixed_mask[grid_col][grid_row];

            // ----------------------------------------------------
            // 1. Draw Grid Lines
            // ----------------------------------------------------
            // Draw lines at edges of cells
            is_border = (rel_x == 0 || rel_x == CELL_SIZE-1 || 
                         rel_y == 0 || rel_y == CELL_SIZE-1);
                         
            // Thick borders every 3 cells (Subgrid dividers)
            is_thick_border = ((grid_col % 3 == 0 && rel_x < 2) || 
                               (grid_row % 3 == 0 && rel_y < 2));
                               
            if (is_thick_border) begin
                red = 4'hF; green = 4'hF; blue = 4'hF; // Thick White
            end else if (is_border) begin
                red = 4'h8; green = 4'h8; blue = 4'h8; // Grey
            end else begin
                // ------------------------------------------------
                // 2. Draw Cell Background (Cursor Highlight)
                // ------------------------------------------------
                if (grid_col == cursor_x && grid_row == cursor_y) begin
                    red = 4'h4; green = 4'h4; blue = 4'h4; // Highlight Cursor
                end else begin
                    red = 4'h0; green = 4'h0; blue = 4'h0; // Black cell background
                end

                // ------------------------------------------------
                // 3. Draw Numbers
                // ------------------------------------------------
                // Check if font pixel is ON
                // rel_x[5:3] scales width. font_bits is 8 bits wide.
                // We shift to find the specific bit for current x.
                if (rel_x >= 12 && rel_x < 28 && rel_y >= 10 && rel_y < 30) begin
                    // Simple centering logic
                    // Check bit (7 - bit_index)
                    if (font_bits[7 - ((rel_x - 12) >> 1)]) begin
                        if (is_fixed) begin
                            red = 4'hF; green = 4'hF; blue = 4'h0; // Yellow for Fixed
                        end else begin
                            red = 4'hF; green = 4'hF; blue = 4'hF; // White for User
                        end
                    end
                end
            end
        end
    end

endmodule