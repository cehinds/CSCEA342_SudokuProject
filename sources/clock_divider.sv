`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Gwendolyn Beecher
// 
// Create Date: 11/30/2025 04:56:51 PM
// Design Name: VGA Sudoku Game
// Module Name: clock divider
// Project Name: VGA Sudoku
//////////////////////////////////////////////////////////////////////////////////



module clock_divider(
    input  logic clk100,
    output logic clk25
);

    logic [1:0] div = 0;

    always_ff @(posedge clk100)
        div <= div + 1;

    assign clk25 = div[1];

endmodule
