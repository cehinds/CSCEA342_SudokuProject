`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineer: Constantine Hindes
// 
// Create Date: 11/30/2025 04:56:51 PM
// Design Name: VGA Sudoku Game
// Module Name: keyboard_parser
// Project Name: VGA Sudoku
//////////////////////////////////////////////////////////////////////////////////

module keyboard_parser(
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] rx_data,     // From ps2_host
    input  logic       rx_ready,    // From ps2_host
    
    // Game Commands
    output logic       cmd_up,
    output logic       cmd_down,
    output logic       cmd_left,
    output logic       cmd_right,
    output logic       cmd_enter,
    output logic [3:0] cmd_number,  // 1-9, 0 if invalid
    output logic       cmd_valid    // Pulse when any command is issued
);

    // State to handle Break Codes (F0) and Extended Codes (E0)
    typedef enum logic [1:0] {IDLE, SEEN_E0, SEEN_F0} state_t;
    state_t state;

    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            cmd_number <= 0; 
            cmd_up <= 0; 
            cmd_down <= 0; 
            cmd_left <= 0; 
            cmd_right <= 0;
            cmd_enter <= 0; 
            cmd_valid <= 0;
        end else begin
            // Defaults
            cmd_valid <= 0;
            cmd_up <= 0; 
            cmd_down <= 0; 
            cmd_left <= 0; 
            cmd_right <= 0;
            cmd_enter <= 0; 
            cmd_number <= 0;

            if (rx_ready) begin
                case (state)
                    IDLE: begin
                        if (rx_data == 8'hE0) begin
                            state <= SEEN_E0; // Extended key incoming (Arrows)
                        end else if (rx_data == 8'hF0) begin
                            state <= SEEN_F0; // Break code incoming (Key release)
                        end else begin
                            // Handle Standard Keys (Make Codes)
                            state <= IDLE; 
                            cmd_valid <= 1;
                            case (rx_data)
                                8'h16: cmd_number <= 1; // 1
                                8'h1E: cmd_number <= 2; // 2
                                8'h26: cmd_number <= 3; // 3
                                8'h25: cmd_number <= 4; // 4
                                8'h2E: cmd_number <= 5; // 5
                                8'h36: cmd_number <= 6; // 6
                                8'h3D: cmd_number <= 7; // 7
                                8'h3E: cmd_number <= 8; // 8
                                8'h46: cmd_number <= 9; // 9
                                8'h5A: cmd_enter  <= 1; // Enter
                                default: cmd_valid <= 0; // Ignore other keys
                            endcase
                        end
                    end

                    SEEN_E0: begin
                        if (rx_data == 8'hF0) begin
                            state <= SEEN_F0; // Key release of extended key
                        end else begin
                            state <= IDLE;
                            cmd_valid <= 1;
                            case (rx_data)
                                8'h75: cmd_up    <= 1;
                                8'h72: cmd_down  <= 1;
                                8'h6B: cmd_left  <= 1;
                                8'h74: cmd_right <= 1;
                                default: cmd_valid <= 0;
                            endcase
                        end
                    end

                    SEEN_F0: begin
                        // Just consume the break code byte and return to IDLE
                        state <= IDLE;
                    end
                endcase
            end
        end
    end
endmodule