`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
//
// Module: sudoku_draw
// Description: VGA renderer for Sudoku board + left/right UI panels
//////////////////////////////////////////////////////////////////////////////////

module sudoku_draw(

    // Correctness overlay from sudoku_engine
    input  logic       check_enable,
    input  logic       check_win,
    input  logic       check_lose,
    input  logic       cell_match [0:8][0:8],

    // VGA pixel position
    input  logic [9:0] x,
    input  logic [9:0] y,

    // Sudoku data
    input  logic [3:0] grid_vals  [0:8][0:8],
    input  logic       fixed_mask [0:8][0:8],
    input  logic [3:0] cursor_x,
    input  logic [3:0] cursor_y,

    input  logic       flash_state,
    input  logic [3:0] preview_number,

    input  logic [1:0] puzzle_selector,

    // VGA color output
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

    // Layout constants
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

    // Right-side status boxes
    localparam RS_X0 = 640 - GS_X0 - GS_W;

    // Colors
    localparam [11:0] COLOR_BG      = 12'h334;
    localparam [11:0] COLOR_PREFILL = 12'hABB;
    localparam [11:0] COLOR_CELL    = 12'hFFE;
    localparam [11:0] COLOR_CURSOR  = 12'hF59;
    localparam [11:0] COLOR_LINE    = 12'h000;
    localparam [11:0] COLOR_NUM     = 12'h000;
    localparam [11:0] COLOR_GOOD    = 12'h4F4;   // green
    localparam [11:0] COLOR_BAD     = 12'hF44;   // red
    localparam [11:0] COLOR_WARN    = 12'hDD7;   // yellow for ENTER 2

    // Color helper
    function automatic void SET_COLOR(
        input  [11:0] c,
        output [3:0]  r,
        output [3:0]  g,
        output [3:0]  b
    );
        r = c[11:8];
        g = c[7:4];
        b = c[3:0];
    endfunction

    // Fonts
    logic [7:0] digit_bits;
    logic [3:0] digit_value;
    logic [3:0] digit_row;

    digit_font DIGFONT(
        .digit(digit_value),
        .row(digit_row),
        .bits(digit_bits)
    );

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
    localparam CH_G = 6'd1;
    localparam CH_A = 6'd2;
    localparam CH_M = 6'd3;
    localparam CH_E = 6'd4;
    localparam CH_D = 6'd5;
    localparam CH_F = 6'd6;
    localparam CH_L = 6'd7;
    localparam CH_T = 6'd8;
    localparam CH_S = 6'd9;
    localparam CH_W = 6'd10;
    localparam CH_I = 6'd16;
    localparam CH_N = 6'd17;
    localparam CH_R = 6'd18;
    localparam CH_O = 6'd19;

    // digits rendered by letter_font (0,1,2)
    localparam CH_0 = 6'd13;
    localparam CH_1 = 6'd14;
    localparam CH_2 = 6'd15;

    // GAME labels
    function automatic [5:0] game_label_char(input int game, input int idx);
        case (game)
            // "DFLT"
            0: case (idx)
                    0: game_label_char = CH_D;
                    1: game_label_char = CH_F;
                    2: game_label_char = CH_L;
                    3: game_label_char = CH_T;
                    default: game_label_char = CH_SPACE;
                endcase

            // "GAME 0"
            1: case (idx)
                    0: game_label_char = CH_G;
                    1: game_label_char = CH_A;
                    2: game_label_char = CH_M;
                    3: game_label_char = CH_E;
                    4: game_label_char = CH_SPACE;
                    5: game_label_char = CH_0;
                    default: game_label_char = CH_SPACE;
                endcase

            // "GAME 1"
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

    // ENTER 2 text
    function automatic [5:0] enter2_char(input int idx);
        case (idx)
            0: enter2_char = CH_E;
            1: enter2_char = CH_N;
            2: enter2_char = CH_T;
            3: enter2_char = CH_E;
            4: enter2_char = CH_R;
            5: enter2_char = CH_SPACE;
            6: enter2_char = CH_2;
            default: enter2_char = CH_SPACE;
        endcase
    endfunction

    integer rel_x, rel_y;
    integer col, row;
    integer cell_x, cell_y;
    integer dx0, dy0;
    integer tx, ty, dx, dy;
    integer charx, chary;
    integer idx, bit_idx;
    integer g;
    integer y1, y2;
    integer WIN_y1, WIN_y2;
    integer LOSE_y1, LOSE_y2;
    integer EN2_y1, EN2_y2;

    logic  is_fixed, is_cursor, thick, thin, draw_d;
    logic [3:0] dsrc;

    // Main rendering loop
    always_comb begin
        // Default background
        SET_COLOR(COLOR_BG, red, green, blue);

        // Init flags
        is_fixed  = 1'b0;
        is_cursor = 1'b0;
        thick     = 1'b0;
        thin      = 1'b0;
        draw_d    = 1'b0;
        dsrc      = 4'd0;

        // The Sudoku Grid
        if (x >= BOARD_X0 && x < BOARD_X0+BOARD_W &&
            y >= BOARD_Y0 && y < BOARD_Y0+BOARD_H)
        begin
            rel_x = x - BOARD_X0;
            rel_y = y - BOARD_Y0;

            col = rel_x / CELL_SIZE;
            row = rel_y / CELL_SIZE;

            is_fixed  = fixed_mask[row][col];
            is_cursor = (cursor_x == col && cursor_y == row);

            // 3×3 block borders and outer borders
            thick = ((rel_x % (CELL_SIZE*3)) <= 2 ||
                     (rel_y % (CELL_SIZE*3)) <= 2 ||
                     rel_x <= 2 || rel_y <= 2 ||
                     rel_x >= BOARD_W-3 || rel_y >= BOARD_H-3);

            // thin cell borders
            thin = (!thick &&
                   ((rel_x % CELL_SIZE == 0) ||
                    (rel_y % CELL_SIZE == 0)));

            cell_x = rel_x - col*CELL_SIZE;
            cell_y = rel_y - row*CELL_SIZE;

            dx0 = (CELL_SIZE - 8)/2;
            dy0 = (CELL_SIZE - 12)/2;

            // digit source: preview or stored value
            if (is_cursor && preview_number != 0)
                dsrc = preview_number;
            else
                dsrc = grid_vals[row][col];

            draw_d = 1'b0;
            if (dsrc != 0 &&
                cell_x >= dx0 && cell_x < dx0+8 &&
                cell_y >= dy0 && cell_y < dy0+12)
            begin
                digit_value = dsrc;
                digit_row   = cell_y - dy0;

                bit_idx = cell_x - dx0;
                if (digit_bits[7-bit_idx])
                    draw_d = 1'b1;
            end

            // Color
            if (thick)
                SET_COLOR(COLOR_LINE, red, green, blue);
            else if (thin)
                SET_COLOR(COLOR_LINE, red, green, blue);
            else begin
                // Correctness mode (SW2)
                if (check_enable) begin
                    if (cell_match[row][col])
                        SET_COLOR(COLOR_GOOD, red, green, blue);
                    else
                        SET_COLOR(COLOR_BAD, red, green, blue);
                end
                // Normal display
                else begin
                    if (is_cursor && flash_state)
                        SET_COLOR(COLOR_CURSOR, red, green, blue);
                    else if (is_fixed)
                        SET_COLOR(COLOR_PREFILL, red, green, blue);
                    else
                        SET_COLOR(COLOR_CELL, red, green, blue);
                end

                // Digits drawn last
                if (draw_d)
                    SET_COLOR(COLOR_NUM, red, green, blue);
            end
        end

        // Left: Game selector UI boxes
        for (g = 0; g < 3; g = g + 1) begin
            y1 = GS_Y0 + g*(GS_H + GS_SP);
            y2 = y1 + GS_H;

            if (x >= GS_X0 && x < GS_X0+GS_W &&
                y >= y1 && y < y2)
            begin
                if (puzzle_selector == g[1:0])
                    SET_COLOR(COLOR_CURSOR, red, green, blue);
                else
                    SET_COLOR(COLOR_CELL, red, green, blue);

                // border
                if (x == GS_X0 || x == GS_X0+GS_W-1 ||
                    y == y1 || y == y2-1)
                    SET_COLOR(COLOR_LINE, red, green, blue);

                // text
                tx = x - GS_X0;
                ty = y - y1;

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
                    letter_row  = chary[3:0];

                    if (letter_bits[7-bit_idx])
                        SET_COLOR(COLOR_NUM, red, green, blue);
                end
            end
        end

        // RIGHT STATUS BOXES
        // WIN
        WIN_y1 = GS_Y0;
        WIN_y2 = GS_Y0 + GS_H;

        if (x >= RS_X0 && x < RS_X0+GS_W &&
            y >= WIN_y1 && y < WIN_y2)
        begin
            if (check_win)
                SET_COLOR(COLOR_GOOD, red, green, blue);
            else
                SET_COLOR(COLOR_CELL, red, green, blue);

            if (x == RS_X0 || x == RS_X0+GS_W-1 ||
                y == WIN_y1 || y == WIN_y2-1)
                SET_COLOR(COLOR_LINE, red, green, blue);

            tx = x - RS_X0;
            ty = y - WIN_y1;

            dx = 6;
            dy = (GS_H - 12)/2;

            if (tx >= dx && tx < dx + 3*8 &&
                ty >= dy && ty < dy + 12)
            begin
                charx = tx - dx;
                chary = ty - dy;

                idx     = charx >> 3;
                bit_idx = charx & 7;

                // Win
                case (idx)
                    0: letter_code = CH_W;
                    1: letter_code = CH_I;
                    2: letter_code = CH_N;
                    default: letter_code = CH_SPACE;
                endcase
                letter_row = chary[3:0];

                if (letter_bits[7-bit_idx])
                    SET_COLOR(COLOR_NUM, red, green, blue);
            end
        end

        // LOSE 
        LOSE_y1 = GS_Y0 + (GS_H + GS_SP);
        LOSE_y2 = LOSE_y1 + GS_H;

        if (x >= RS_X0 && x < RS_X0+GS_W &&
            y >= LOSE_y1 && y < LOSE_y2)
        begin
            if (check_lose)
                SET_COLOR(COLOR_BAD, red, green, blue);
            else
                SET_COLOR(COLOR_CELL, red, green, blue);

            if (x == RS_X0 || x == RS_X0+GS_W-1 ||
                y == LOSE_y1 || y == LOSE_y2-1)
                SET_COLOR(COLOR_LINE, red, green, blue);

            tx = x - RS_X0;
            ty = y - LOSE_y1;

            dx = 4;
            dy = (GS_H - 12)/2;

            if (tx >= dx && tx < dx + 4*8 &&
                ty >= dy && ty < dy + 12)
            begin
                charx = tx - dx;
                chary = ty - dy;

                idx     = charx >> 3;
                bit_idx = charx & 7;

                // L O S E
                case (idx)
                    0: letter_code = CH_L;
                    1: letter_code = CH_O;
                    2: letter_code = CH_S;
                    3: letter_code = CH_E;
                    default: letter_code = CH_SPACE;
                endcase

                letter_row = chary[3:0];

                if (letter_bits[7-bit_idx])
                    SET_COLOR(COLOR_NUM, red, green, blue);
            end
        end

        // ENTER 2
        EN2_y1 = GS_Y0 + 2*(GS_H + GS_SP);
        EN2_y2 = EN2_y1 + GS_H;

        if (x >= RS_X0 && x < RS_X0+GS_W &&
            y >= EN2_y1 && y < EN2_y2)
        begin
            SET_COLOR(COLOR_WARN, red, green, blue);

            if (x == RS_X0 || x == RS_X0+GS_W-1 ||
                y == EN2_y1 || y == EN2_y2-1)
                SET_COLOR(COLOR_LINE, red, green, blue);

            tx = x - RS_X0;
            ty = y - EN2_y1;

            dx = 6;
            dy = (GS_H - 12)/2;

            if (tx >= dx && tx < dx + 7*8 &&
                ty >= dy && ty < dy + 12)
            begin
                charx = tx - dx;
                chary = ty - dy;

                idx     = charx >> 3;
                bit_idx = charx & 7;

                letter_code = enter2_char(idx);
                letter_row  = chary[3:0];

                if (letter_bits[7-bit_idx])
                    SET_COLOR(COLOR_NUM, red, green, blue);
            end
        end

    end

endmodule