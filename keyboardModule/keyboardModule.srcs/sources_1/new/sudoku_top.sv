module sudoku_top(
    input  logic       clk,           // 100 MHz clock from W5
    input  logic       btnC,          // Center button for reset
    input  logic       PS2Clk,        // PS/2 keyboard clock
    input  logic       PS2Data,       // PS/2 keyboard data
    output logic [6:0] seg,           // 7-segment cathodes
    output logic [3:0] an             // 7-segment anodes (active low)
);

    // Internal signals
    logic reset;
    logic [1:0] puzzle_selector;
    logic [3:0] cmd_number;
    logic cmd_up, cmd_down, cmd_left, cmd_right, cmd_enter;
    logic cmd_valid;
    logic [3:0] current_x, current_y, current_val;
    logic game_won, game_lost;
    logic engine_ready;
    
    // PS/2 receiver signals
    logic [7:0] rx_data;
    logic rx_ready;
    
    // Button debouncing for reset
    logic btnC_sync1, btnC_sync2, btnC_debounced;
    always_ff @(posedge clk) begin
        btnC_sync1 <= btnC;
        btnC_sync2 <= btnC_sync1;
    end
    
    // Simple debounce (hold for ~10ms at 100MHz)
    logic [19:0] debounce_counter;
    always_ff @(posedge clk) begin
        if (btnC_sync2) begin
            if (debounce_counter < 1000000)
                debounce_counter <= debounce_counter + 1;
            else
                btnC_debounced <= 1;
        end else begin
            debounce_counter <= 0;
            btnC_debounced <= 0;
        end
    end
    
    assign reset = btnC_debounced;
    assign puzzle_selector = 2'b00; // Default to puzzle 0
    
    // PS/2 Host (receiver)
    ps2_host ps2_receiver(
        .clk(clk),
        .reset(reset),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );
    
    // Keyboard Parser
    keyboard_parser kbd_parser(
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_number(cmd_number),
        .cmd_valid(cmd_valid)
    );
    
    // Sudoku Engine
    sudoku_engine engine(
        .clk(clk),
        .reset(reset),
        .puzzle_selector(puzzle_selector),
        .cmd_number(cmd_number),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_valid(cmd_valid),
        .current_x(current_x),
        .current_y(current_y),
        .current_val(current_val),
        .game_won(game_won),
        .game_lost(game_lost),
        .engine_ready(engine_ready)
    );
    
    // 7-Segment Display Controller
    seven_segment_display display(
        .clk(clk),
        .reset(reset),
        .current_x(current_x),
        .current_y(current_y),
        .current_val(current_val),
        .game_won(game_won),
        .game_lost(game_lost),
        .seg(seg),
        .an(an)
    );

endmodule

// Simple 7-segment display module
module seven_segment_display(
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] current_x,
    input  logic [3:0] current_y,
    input  logic [3:0] current_val,
    input  logic       game_won,
    input  logic       game_lost,
    output logic [6:0] seg,
    output logic [3:0] an
);
    
    // Multiplexing counter (refresh ~240Hz for each digit at 100MHz)
    logic [17:0] refresh_counter;
    logic [1:0] digit_select;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end
    
    assign digit_select = refresh_counter[17:16];
    
    // Select which digit to display
    logic [3:0] digit_value;
    always_comb begin
        case (digit_select)
            2'b00: digit_value = current_x;      // Rightmost: X position
            2'b01: digit_value = current_y;      // Y position
            2'b10: digit_value = current_val;    // Cell value
            2'b11: begin
                if (game_won)      digit_value = 4'hE; // 'E' for win
                else if (game_lost) digit_value = 4'hF; // 'F' for loss
                else               digit_value = 4'h0; // '0' for playing
            end
            default: digit_value = 4'h0;
        endcase
    end
    
    // Anode control (active low, one at a time)
    always_comb begin
        an = 4'b1111;
        an[digit_select] = 0;
    end
    
    // 7-segment decoder (active low for common anode)
    always_comb begin
        case (digit_value)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // b
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // d
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111; // blank
        endcase
    end

endmodule