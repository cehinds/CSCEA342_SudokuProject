`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: sevenseg_custom
// Description: Seven segment display controller with support for digits 0-9, 
//              'E' character, and blank display
//////////////////////////////////////////////////////////////////////////////////

module sevenseg(
    input   logic           clk,        // 100 MHz clock source on Basys 3 FPGA
    input   logic   [3:0]   digit_0,    // Leftmost digit
    input   logic   [3:0]   digit_1,    
    input   logic   [3:0]   digit_2,    
    input   logic   [3:0]   digit_3,    // Rightmost digit
    output  logic   [3:0]   Anode_Activate,
    output  logic   [6:0]   LED_out
);
      
    logic [3:0] LED_BCD;
    logic [20:0] refresh_counter;
    logic [1:0] LED_activating_counter; 

    always_ff @(posedge clk)
        refresh_counter <= refresh_counter + 1;
  
    assign LED_activating_counter = refresh_counter[20:19];
    
    // Anode activating signals and digit selection
    always_comb begin
        case(LED_activating_counter)
            2'b00: begin
                Anode_Activate = 4'b0111;  // Activate leftmost LED
                LED_BCD = digit_0;
            end
            2'b01: begin
                Anode_Activate = 4'b1011;
                LED_BCD = digit_1;
            end
            2'b10: begin
                Anode_Activate = 4'b1101;
                LED_BCD = digit_2;
            end
            2'b11: begin
                Anode_Activate = 4'b1110;  // Activate rightmost LED
                LED_BCD = digit_3;
            end
        endcase
    end
    
    // Cathode patterns of the 7-segment LED display 
    always_comb begin
        case(LED_BCD)
            4'h0: LED_out = 7'b0000001; // "0"     
            4'h1: LED_out = 7'b1001111; // "1" 
            4'h2: LED_out = 7'b0010010; // "2" 
            4'h3: LED_out = 7'b0000110; // "3" 
            4'h4: LED_out = 7'b1001100; // "4" 
            4'h5: LED_out = 7'b0100100; // "5" 
            4'h6: LED_out = 7'b0100000; // "6" 
            4'h7: LED_out = 7'b0001111; // "7" 
            4'h8: LED_out = 7'b0000000; // "8"     
            4'h9: LED_out = 7'b0000100; // "9"
            4'hE: LED_out = 7'b0110000; // "E"
            4'hF: LED_out = 7'b1111111; // Blank (all segments off)
            default: LED_out = 7'b1111111; // Blank
        endcase
    end
    
endmodule