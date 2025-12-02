`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hindes
//
// Module: sudoku_draw
// Project: VGA Sudoku
//////////////////////////////////////////////////////////////////////////////////

module sudoku_draw(
    input  logic [9:0] x,
    input  logic [9:0] y,

    // Engine-supplied live grid & mask
    input  logic [3:0] grid_vals  [0:8][0:8],
    input  logic       fixed_mask [0:8][0:8],
    input  logic [3:0] cursor_x,
    input  logic [3:0] cursor_y,

    // Flashing controls (mode-aware flash_state from top.sv)
    input  logic       flash_state,
    input  logic [3:0] preview_number,

    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

    // Layout and Color Constants
    localparam CELL_SIZE = 40;
    localparam BOARD_W   = CELL_SIZE * 9;
    localparam BOARD_H   = CELL_SIZE * 9;

    localparam BOARD_X0 = (640 - BOARD_W) / 2;
    localparam BOARD_Y0 = (480 - BOARD_H) / 2;

    // Palette
    localparam [11:0] COLOR_BG      = 12'h334; // #3E3E48
    localparam [11:0] COLOR_PREFILL = 12'hABB; // #A2BABA
    localparam [11:0] COLOR_CELL    = 12'hFFE; // #F7F7EF
    localparam [11:0] COLOR_CURSOR  = 12'hF59; // #FF5393
    localparam [11:0] COLOR_LINE    = 12'h000;
    localparam [11:0] COLOR_NUM     = 12'h000;

    // Color unpack helper
    function automatic void SET_COLOR(
        input  [11:0] c,
        output [3:0]  r,
        output [3:0]  g,
        output [3:0]  b
    );
    begin
        r = c[11:8];
        g = c[7:4];
        b = c[3:0];
    end
    endfunction

    // Font ROM
    logic [7:0] font_bits;
    logic [3:0] digit_value;
    logic [3:0] font_row;

    digit_font FONT(
        .digit(digit_value),
        .row(font_row),
        .bits(font_bits)
    );

    // Rendering control signals
    logic draw_digit;
    logic grid_pixel;
    logic thick_border;
    logic prefilled_cell;
    logic cursor_cell;
    logic [3:0] digit_src;


    always_comb begin
        // Default background
        SET_COLOR(COLOR_BG, red, green, blue);

        draw_digit     = 0;
        grid_pixel     = 0;
        thick_border   = 0;
        prefilled_cell = 0;
        cursor_cell    = 0;
        digit_src      = 4'd0;

        // Check if pixel is inside Sudoku board
        if (x >= BOARD_X0 && x < BOARD_X0 + BOARD_W &&
            y >= BOARD_Y0 && y < BOARD_Y0 + BOARD_H)
        begin
            int rel_x = x - BOARD_X0;
            int rel_y = y - BOARD_Y0;

            int col = rel_x / CELL_SIZE;
            int row = rel_y / CELL_SIZE;

            prefilled_cell = fixed_mask[row][col];
            cursor_cell    = (cursor_x == col && cursor_y == row);

            // Thick borders (outer + 3x3)
            if ((rel_x % (CELL_SIZE * 3)) <= 2 ||
                (rel_y % (CELL_SIZE * 3)) <= 2)
                thick_border = 1;

            if (rel_x <= 2 || rel_y <= 2 ||
                rel_x >= BOARD_W - 3 || rel_y >= BOARD_H - 3)
                thick_border = 1;

            // Thin cell lines
            if (!thick_border &&
                ((rel_x % CELL_SIZE == 0) || (rel_y % CELL_SIZE == 0)))
                grid_pixel = 1;

            // Select digit to draw (preview OR saved grid value)
            // PREVIEW digit (only if cursor is on empty cell)
            if (cursor_cell && (grid_vals[row][col] == 4'd0) && (preview_number != 4'd0))
                digit_src = preview_number;

            // Actual grid value
            else if (grid_vals[row][col] != 4'd0)
                digit_src = grid_vals[row][col];

            // Convert digit into pixel mask
            if (digit_src != 4'd0) begin
                int cell_x = rel_x - col * CELL_SIZE;
                int cell_y = rel_y - row * CELL_SIZE;

                int dx0 = (CELL_SIZE - 8) / 2;
                int dy0 = (CELL_SIZE - 12) / 2;

                if (cell_x >= dx0 && cell_x < dx0 + 8 &&
                    cell_y >= dy0 && cell_y < dy0 + 12)
                begin
                    int fx = cell_x - dx0;
                    int fy = cell_y - dy0;

                    digit_value = digit_src;
                    font_row    = fy;

                    if (font_bits[7 - fx])
                        draw_digit = 1;
                end
            end
        
        // COLOR PRIORITY
        if (thick_border) begin
            SET_COLOR(COLOR_LINE, red, green, blue);
        
        end else if (grid_pixel) begin
            SET_COLOR(COLOR_LINE, red, green, blue);
        
        end else begin
            // BACKGROUND 
            // Cursor should override prefilled-cell color
            if (cursor_cell && flash_state)
                SET_COLOR(COLOR_CURSOR, red, green, blue);
            else if (prefilled_cell)
                SET_COLOR(COLOR_PREFILL, red, green, blue);
            else
                SET_COLOR(COLOR_CELL, red, green, blue);
        
            // DIGITS ALWAYS ON TOP
            if (draw_digit)
                SET_COLOR(COLOR_NUM, red, green, blue);
        end
        
    end
 end

endmodule

