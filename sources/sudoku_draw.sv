`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hindes
//
// Module: sudoku_draw
// Description: VGA renderer for Sudoku board + left-side game selector UI
//////////////////////////////////////////////////////////////////////////////////

module sudoku_draw(
    input  logic [9:0] x,
    input  logic [9:0] y,

    input  logic [3:0] grid_vals  [0:8][0:8],
    input  logic       fixed_mask [0:8][0:8],
    input  logic [3:0] cursor_x,
    input  logic [3:0] cursor_y,

    input  logic       flash_state,
    input  logic [3:0] preview_number,

    input  logic [1:0] puzzle_selector,

    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

    localparam CELL_SIZE = 40;
    localparam BOARD_W   = CELL_SIZE * 9;
    localparam BOARD_H   = CELL_SIZE * 9;
    localparam BOARD_X0  = (640 - BOARD_W) / 2;
    localparam BOARD_Y0  = (480 - BOARD_H) / 2;

    localparam GS_X0 = 20;
    localparam GS_W  = 70;
    localparam GS_H  = 42;
    localparam GS_SP = 12;
    localparam GS_Y0 = 70;

    localparam [11:0] COLOR_BG      = 12'h334;
    localparam [11:0] COLOR_PREFILL = 12'hABB;
    localparam [11:0] COLOR_CELL    = 12'hFFE;
    localparam [11:0] COLOR_CURSOR  = 12'hF59;
    localparam [11:0] COLOR_LINE    = 12'h000;
    localparam [11:0] COLOR_NUM     = 12'h000;

    function automatic void SET_COLOR(
        input [11:0] c,
        output [3:0] r,
        output [3:0] g,
        output [3:0] b
    );
        r = c[11:8];
        g = c[7:4];
        b = c[3:0];
    endfunction

    // Digit font
    logic [7:0] digit_bits;
    logic [3:0] digit_value;
    logic [3:0] digit_row;

    digit_font DIGFONT(
        .digit(digit_value),
        .row(digit_row),
        .bits(digit_bits)
    );

    // Letter font
    logic [7:0] letter_bits;
    logic [5:0] letter_code;
    logic [3:0] letter_row;

    letter_font LFONT(
        .ch(letter_code),
        .row(letter_row),
        .bits(letter_bits)
    );

    // Letter codes
    localparam CH_SPACE = 6'd0;
    localparam CH_D = 6'd5;
    localparam CH_F = 6'd6;
    localparam CH_L = 6'd7;
    localparam CH_T = 6'd8;

    localparam CH_G = 6'd1;
    localparam CH_A = 6'd2;
    localparam CH_M = 6'd3;
    localparam CH_E = 6'd4;

    localparam CH_0 = 6'd13;
    localparam CH_1 = 6'd14;

    // Simplified label: DFLT, GAME 0, GAME 1
    function automatic [5:0] game_label_char(input int game, input int idx);
        case (game)
            0: case (idx)
                    0: game_label_char = CH_D;
                    1: game_label_char = CH_F;
                    2: game_label_char = CH_L;
                    3: game_label_char = CH_T;
                    default: game_label_char = CH_SPACE;
                endcase

            1: case (idx)
                    0: game_label_char = CH_G;
                    1: game_label_char = CH_A;
                    2: game_label_char = CH_M;
                    3: game_label_char = CH_E;
                    4: game_label_char = CH_SPACE;
                    5: game_label_char = CH_0;
                    default: game_label_char = CH_SPACE;
                endcase

            2: case (idx)
                    0: game_label_char = CH_G;
                    1: game_label_char = CH_A;
                    2: game_label_char = CH_M;
                    3: game_label_char = CH_E;
                    4: game_label_char = CH_SPACE;
                    5: game_label_char = CH_1;
                    default: game_label_char = CH_SPACE;
                endcase

            default: game_label_char = CH_SPACE;
        endcase
    endfunction


    // Main render
    always_comb begin

        int rel_x, rel_y;
        int col, row;
        int cell_x, cell_y;
        int dx0, dy0;
        int box_y1, box_y2;
        int tx, ty;
        int dx, dy;
        int charx, chary;
        int idx, bit_idx;
        int g;

        logic is_fixed, is_cursor, thick, thin, draw_d;
        logic [3:0] dsrc;

        // Default background
        SET_COLOR(COLOR_BG, red, green, blue);

        // Init variables
        is_fixed  = 0;
        is_cursor = 0;
        thick     = 0;
        thin      = 0;
        draw_d    = 0;
        dsrc      = 0;

        //Sudoku board
        if (x >= BOARD_X0 && x < BOARD_X0+BOARD_W &&
            y >= BOARD_Y0 && y < BOARD_Y0+BOARD_H)
        begin
            rel_x = x - BOARD_X0;
            rel_y = y - BOARD_Y0;

            col = rel_x / CELL_SIZE;
            row = rel_y / CELL_SIZE;

            is_fixed  = fixed_mask[row][col];
            is_cursor = (cursor_x == col && cursor_y == row);

            // Borders
            thick = ((rel_x % (CELL_SIZE*3)) <= 2 ||
                     (rel_y % (CELL_SIZE*3)) <= 2 ||
                     rel_x <= 2 || rel_y <= 2 ||
                     rel_x >= BOARD_W-3 || rel_y >= BOARD_H-3);

            thin = (!thick &&
                   ((rel_x % CELL_SIZE == 0) ||
                    (rel_y % CELL_SIZE == 0)));

            // Digit drawing
            cell_x = rel_x - col*CELL_SIZE;
            cell_y = rel_y - row*CELL_SIZE;

            dx0 = (CELL_SIZE - 8)/2;
            dy0 = (CELL_SIZE - 12)/2;

            dsrc = 0;
            if (is_cursor && grid_vals[row][col] == 0 && preview_number != 0)
                dsrc = preview_number;
            else if (grid_vals[row][col] != 0)
                dsrc = grid_vals[row][col];

            draw_d = 0;

            if (dsrc != 0 &&
                cell_x >= dx0 && cell_x < dx0+8 &&
                cell_y >= dy0 && cell_y < dy0+12)
            begin
                digit_value = dsrc;
                digit_row   = cell_y - dy0;

                bit_idx = cell_x - dx0;
                if (digit_bits[7 - bit_idx])
                    draw_d = 1;
            end

            // Color priority
            if (thick)
                SET_COLOR(COLOR_LINE, red, green, blue);
            else if (thin)
                SET_COLOR(COLOR_LINE, red, green, blue);
            else begin
                if (is_cursor && flash_state)
                    SET_COLOR(COLOR_CURSOR, red, green, blue);
                else if (is_fixed)
                    SET_COLOR(COLOR_PREFILL, red, green, blue);
                else
                    SET_COLOR(COLOR_CELL, red, green, blue);

                if (draw_d)
                    SET_COLOR(COLOR_NUM, red, green, blue);
            end
        end

        //Game Selector
        for (g = 0; g < 3; g++) begin
            box_y1 = GS_Y0 + g*(GS_H + GS_SP);
            box_y2 = box_y1 + GS_H;

            if (x >= GS_X0 && x < GS_X0+GS_W &&
                y >= box_y1 && y < box_y2)
            begin
                if (puzzle_selector == g)
                    SET_COLOR(COLOR_CURSOR, red, green, blue);
                else
                    SET_COLOR(COLOR_CELL, red, green, blue);

                if (x == GS_X0 || x == GS_X0+GS_W-1 ||
                    y == box_y1 || y == box_y2-1)
                    SET_COLOR(COLOR_LINE, red, green, blue);

                // Text
                tx = x - GS_X0;
                ty = y - box_y1;

                dx = 6;
                dy = (GS_H - 12)/2;

                if (tx >= dx && tx < dx + 8*8 &&
                    ty >= dy && ty < dy + 12)
                begin
                    charx = tx - dx;
                    chary = ty - dy;

                    idx     = charx >> 3;
                    bit_idx = charx & 7;

                    letter_code = game_label_char(g, idx);
                    letter_row  = chary;

                    if (letter_bits[7 - bit_idx])
                        SET_COLOR(COLOR_NUM, red, green, blue);
                end
            end
        end
    end
endmodule

