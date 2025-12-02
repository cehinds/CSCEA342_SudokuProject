`timescale 1ns / 1ps
module debounce(
    input  logic clk,          // 100 MHz clock
    input  logic btn_raw,      // physical button
    output logic btn_clean     // stable 1/0
);

    // 20 ms debounce @ 100 MHz
    localparam integer COUNT_MAX = 2_000_000;

    logic [$clog2(COUNT_MAX):0] counter = 0;
    logic                       stable_state = 0;

    always_ff @(posedge clk) begin
        if (btn_raw == stable_state) begin
            counter <= 0;              // input matches stable state → reset counter
        end else begin
            if (counter == COUNT_MAX) begin
                stable_state <= btn_raw; // new stable value locked in
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    assign btn_clean = stable_state;
endmodule

