`timescale 1ns / 1ps
module onepulse(
    input  logic clk,
    input  logic din,      // debounced signal
    output logic pulse     // 1-cycle pulse
);

    logic prev = 0;

    always_ff @(posedge clk) begin
        prev <= din;
        pulse <= din & ~prev;
    end
endmodule

