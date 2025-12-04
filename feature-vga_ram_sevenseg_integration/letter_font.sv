//============================================================
// 8×12 FONT FOR LETTERS USED IN GAME LABELS
// Supports only the letters we actually need.
//============================================================

module letter_font(
    input  logic [5:0]  ch,     // character code
    input  logic [3:0]  row,    // row 0-11
    output logic [7:0]  bits    // 8 pixels wide
);

    // Character encoding
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
    localparam CH_LP = 6'd11;   // '('
    localparam CH_RP = 6'd12;   // ')'

    always_comb begin
        bits = 8'h00;

        unique case (ch)

        // --------------------
        // Letter G
        // --------------------
        CH_G: begin
            case (row)
                0: bits = 8'b00111100;
                1: bits = 8'b01100110;
                2: bits = 8'b11000000;
                3: bits = 8'b11000000;
                4: bits = 8'b11001110;
                5: bits = 8'b11000110;
                6: bits = 8'b01100110;
                7: bits = 8'b00111100;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter A
        CH_A: begin
            case(row)
                0: bits = 8'b00111100;
                1: bits = 8'b01100110;
                2: bits = 8'b11000011;
                3: bits = 8'b11111111;
                4: bits = 8'b11000011;
                5: bits = 8'b11000011;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter M
        CH_M: begin
            case(row)
                0: bits = 8'b11000011;
                1: bits = 8'b11100111;
                2: bits = 8'b11111111;
                3: bits = 8'b11011011;
                4: bits = 8'b11000011;
                5: bits = 8'b11000011;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter E
        CH_E: begin
            case(row)
                0: bits = 8'b11111111;
                1: bits = 8'b11000000;
                2: bits = 8'b11111110;
                3: bits = 8'b11000000;
                4: bits = 8'b11111111;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter D
        CH_D: begin
            case(row)
                0: bits = 8'b11111100;
                1: bits = 8'b11000110;
                2: bits = 8'b11000110;
                3: bits = 8'b11000110;
                4: bits = 8'b11111100;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter F
        CH_F: begin
            case(row)
                0: bits = 8'b11111111;
                1: bits = 8'b11000000;
                2: bits = 8'b11111110;
                3: bits = 8'b11000000;
                4: bits = 8'b11000000;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter L
        CH_L: begin
            case(row)
                0: bits = 8'b11000000;
                1: bits = 8'b11000000;
                2: bits = 8'b11000000;
                3: bits = 8'b11000000;
                4: bits = 8'b11111111;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter T
        CH_T: begin
            case(row)
                0: bits = 8'b11111111;
                1: bits = 8'b00011000;
                2: bits = 8'b00011000;
                3: bits = 8'b00011000;
                4: bits = 8'b00011000;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter S
        CH_S: begin
            case(row)
                0: bits = 8'b01111110;
                1: bits = 8'b11000000;
                2: bits = 8'b01111100;
                3: bits = 8'b00000110;
                4: bits = 8'b11111100;
                default: bits = 8'b00000000;
            endcase
        end

        // Letter W
        CH_W: begin
            case(row)
                0: bits = 8'b11000011;
                1: bits = 8'b11000011;
                2: bits = 8'b11011011;
                3: bits = 8'b11111111;
                4: bits = 8'b01100110;
                default: bits = 8'b00000000;
            endcase
        end
        // --------------------
        // Digit 0
        // --------------------
        6'd13: begin  // CH_0
            case (row)
                0: bits = 8'b00111100;
                1: bits = 8'b01100110;
                2: bits = 8'b01101110;
                3: bits = 8'b01110110;
                4: bits = 8'b01100110;
                5: bits = 8'b01100110;
                6: bits = 8'b00111100;
                default: bits = 8'b00000000;
            endcase
        end

        // Digit 1
        6'd14: begin  // CH_1
            case (row)
                0: bits = 8'b00011000;
                1: bits = 8'b00111000;
                2: bits = 8'b00011000;
                3: bits = 8'b00011000;
                4: bits = 8'b00011000;
                5: bits = 8'b00011000;
                6: bits = 8'b01111110;
                default: bits = 8'b00000000;
            endcase
        end

        // Digit 2
        6'd15: begin  // CH_2
            case (row)
                0: bits = 8'b00111100;
                1: bits = 8'b01100110;
                2: bits = 8'b00000110;
                3: bits = 8'b00011100;
                4: bits = 8'b00110000;
                5: bits = 8'b01100000;
                6: bits = 8'b01111110;
                default: bits = 8'b00000000;
            endcase
        end

        // Digit 3
        6'd16: begin  // CH_3
            case (row)
                0: bits = 8'b01111100;
                1: bits = 8'b00000110;
                2: bits = 8'b00111100;
                3: bits = 8'b00000110;
                4: bits = 8'b00000110;
                5: bits = 8'b01100110;
                6: bits = 8'b00111100;
                default: bits = 8'b00000000;
            endcase
        end

        // '('
        CH_LP: bits = 8'b00111100;

        // ')'
        CH_RP: bits = 8'b00111100;

        default: bits = 8'h00;

        endcase
    end
endmodule
