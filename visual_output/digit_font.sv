`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Gwendolyn Beecher
// 
// Create Date: 11/30/2025 04:56:51 PM
// Design Name: VGA Sudoku Game
// Module Name: digit_font
// Project Name: VGA Sudoku
//////////////////////////////////////////////////////////////////////////////////

module digit_font (
    input  logic [3:0] digit,      // 1-9
    input  logic [3:0] row,        // 0-11 (font row)
    output logic [7:0] bits        // 8 pixels per row
);

    always_comb begin
        case (digit)

        4'd1: case(row)
            0: bits = 8'b00011000;
            1: bits = 8'b00111000;
            2: bits = 8'b00011000;
            3: bits = 8'b00011000;
            4: bits = 8'b00011000;
            5: bits = 8'b00011000;
            6: bits = 8'b00011000;
            7: bits = 8'b00011000;
            8: bits = 8'b00011000;
            9: bits = 8'b00011000;
            10: bits = 8'b00111100;
            11: bits = 8'b00111100;
            default: bits = 8'b00000000;
        endcase

        4'd2: case(row)
            0:  bits = 8'b00111100;
            1:  bits = 8'b01100110;
            2:  bits = 8'b00000110;
            3:  bits = 8'b00001100;
            4:  bits = 8'b00011000;
            5:  bits = 8'b00110000;
            6:  bits = 8'b01100000;
            7:  bits = 8'b11000000;
            8:  bits = 8'b11000000;
            9:  bits = 8'b11000000;
            10: bits = 8'b11111110;
            11: bits = 8'b11111110;
            default: bits = 8'b00000000;
        endcase

        4'd3: case(row)
            0:  bits = 8'b01111100;
            1:  bits = 8'b11000110;
            2:  bits = 8'b00000110;
            3:  bits = 8'b00001110;
            4:  bits = 8'b00111100;
            5:  bits = 8'b00111100;
            6:  bits = 8'b00001110;
            7:  bits = 8'b00000110;
            8:  bits = 8'b00000110;
            9:  bits = 8'b11000110;
            10: bits = 8'b01111100;
            11: bits = 8'b00111100;
            default: bits = 8'b00000000;
        endcase

        4'd4: case(row)
            0: bits = 8'b00001100;
            1: bits = 8'b00011100;
            2: bits = 8'b00111100;
            3: bits = 8'b01101100;
            4: bits = 8'b11001100;
            5: bits = 8'b11001100;
            6: bits = 8'b11111110;
            7: bits = 8'b11111110;
            8: bits = 8'b00001100;
            9: bits = 8'b00001100;
            10: bits = 8'b00001100;
            11: bits = 8'b00001100;
            default: bits = 8'b00000000;
        endcase

        4'd5: case(row)
            0: bits = 8'b11111110;
            1: bits = 8'b11111110;
            2: bits = 8'b11000000;
            3: bits = 8'b11000000;
            4: bits = 8'b11111100;
            5: bits = 8'b11111110;
            6: bits = 8'b00000110;
            7: bits = 8'b00000110;
            8: bits = 8'b00000110;
            9: bits = 8'b11000110;
            10: bits = 8'b01111100;
            11: bits = 8'b00111000;
            default: bits = 8'b00000000;
        endcase

        4'd6: case(row)
            0: bits = 8'b00111100;
            1: bits = 8'b01100000;
            2: bits = 8'b11000000;
            3: bits = 8'b11000000;
            4: bits = 8'b11111100;
            5: bits = 8'b11111110;
            6: bits = 8'b11000110;
            7: bits = 8'b11000110;
            8: bits = 8'b11000110;
            9: bits = 8'b11000110;
            10: bits = 8'b01111100;
            11: bits = 8'b00111000;
            default: bits = 8'b00000000;
        endcase

        4'd7: case(row)
            0: bits = 8'b11111110;
            1: bits = 8'b11111110;
            2: bits = 8'b00000110;
            3: bits = 8'b00001100;
            4: bits = 8'b00011000;
            5: bits = 8'b00110000;
            6: bits = 8'b01100000;
            7: bits = 8'b11000000;
            8: bits = 8'b11000000;
            9: bits = 8'b11000000;
            10: bits = 8'b11000000;
            11: bits = 8'b11000000;
            default: bits = 8'b00000000;
        endcase

        4'd8: case(row)
            0: bits = 8'b00111100;
            1: bits = 8'b01100110;
            2: bits = 8'b11000110;
            3: bits = 8'b11000110;
            4: bits = 8'b01111100;
            5: bits = 8'b01111100;
            6: bits = 8'b11000110;
            7: bits = 8'b11000110;
            8: bits = 8'b11000110;
            9: bits = 8'b11000110;
            10: bits = 8'b01111100;
            11: bits = 8'b00111000;
            default: bits = 8'b00000000;
        endcase

        4'd9: case(row)
            0: bits = 8'b00111100;
            1: bits = 8'b01100110;
            2: bits = 8'b11000110;
            3: bits = 8'b11000110;
            4: bits = 8'b11111110;
            5: bits = 8'b01111110;
            6: bits = 8'b00000110;
            7: bits = 8'b00000110;
            8: bits = 8'b00000110;
            9: bits = 8'b00000110;
            10: bits = 8'b01111100;
            11: bits = 8'b00111000;
            default: bits = 8'b00000000;
        endcase

        default: bits = 8'b00000000;
        endcase
    end
endmodule
