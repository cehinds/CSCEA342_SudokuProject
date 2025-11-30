module SevenSegmentDecoder(
                            input   logic           i_CLK, 
                            input   logic   [15:0]  i_NUMBER_TO_DISPLAY, 
                            output  logic   [3:0]   o_ANODES,  // anode signals of the 7-segment LED display
                            output  logic   [6:0]   o_SEGMENTS 
                            );

    logic   [20:0]  l_COUNTER;
    always_ff @(posedge i_CLK)
	   l_COUNTER <= l_COUNTER + 1;    
     
    logic   [1:0]   l_SLOW_COUNTER;
    assign l_SLOW_COUNTER = l_COUNTER[20:19];
    // counts  0 -> 1 -> 2 -> 3 -> 0 (repeat) at 190 Hz 

    logic   [3:0]   l_ENABLE_DIGIT;
    logic   [3:0]   l_DIGIT_TO_DISPLAY;
    always_comb
    begin
        case(l_SLOW_COUNTER)
            2'b00: begin
                l_ENABLE_DIGIT = 4'b1000;                        // enable digit 0
                l_DIGIT_TO_DISPLAY = i_NUMBER_TO_DISPLAY[15:12]; // first hex digit of the 16-bit number
                
            end
            2'b01: begin
                l_ENABLE_DIGIT = 4'b0100; 
                l_DIGIT_TO_DISPLAY = i_NUMBER_TO_DISPLAY[11:8];
            end
            2'b10: begin
                l_ENABLE_DIGIT = 4'b0010;
                l_DIGIT_TO_DISPLAY = i_NUMBER_TO_DISPLAY[7:4];
            end
            2'b11: begin
                l_ENABLE_DIGIT = 4'b0001; 
                l_DIGIT_TO_DISPLAY = i_NUMBER_TO_DISPLAY[3:0];   
            end
        endcase
    end
    
    logic   [6:0]   l_SEGMENTS_TO_LIGHT;
    always_comb
    begin
        case(l_DIGIT_TO_DISPLAY)
            4'b0000: l_SEGMENTS_TO_LIGHT = 7'b1111110; // "0"     
            4'b0001: l_SEGMENTS_TO_LIGHT = 7'b0110000; // "1" 
            4'b0010: l_SEGMENTS_TO_LIGHT = 7'b1101101; // "2" 
            4'b0011: l_SEGMENTS_TO_LIGHT = 7'b1111001; // "3" 
            4'b0100: l_SEGMENTS_TO_LIGHT = 7'b0110011; // "4" 
            4'b0101: l_SEGMENTS_TO_LIGHT = 7'b1011011; // "5" 
            4'b0110: l_SEGMENTS_TO_LIGHT = 7'b1011111; // "6" 
            4'b0111: l_SEGMENTS_TO_LIGHT = 7'b1110000; // "7" 
            4'b1000: l_SEGMENTS_TO_LIGHT = 7'b1111111; // "8"     
            4'b1001: l_SEGMENTS_TO_LIGHT = 7'b1111011; // "9"
            4'b1010: l_SEGMENTS_TO_LIGHT = 7'b1110111; // "A" 
            4'b1011: l_SEGMENTS_TO_LIGHT = 7'b0011111; // "B" 
            4'b1100: l_SEGMENTS_TO_LIGHT = 7'b1001110; // "C" 
            4'b1101: l_SEGMENTS_TO_LIGHT = 7'b0111101; // "D" 
            4'b1110: l_SEGMENTS_TO_LIGHT = 7'b1001111; // "E"     
            4'b1111: l_SEGMENTS_TO_LIGHT = 7'b1000111; // "F"             
            default: l_SEGMENTS_TO_LIGHT = 7'b0000001; // "-"
        endcase
    end
    
    assign o_ANODES     = ~l_ENABLE_DIGIT;        // anodes are active low
    assign o_SEGMENTS   = ~{l_SEGMENTS_TO_LIGHT[0],
                            l_SEGMENTS_TO_LIGHT[1],
                            l_SEGMENTS_TO_LIGHT[2],
                            l_SEGMENTS_TO_LIGHT[3],
                            l_SEGMENTS_TO_LIGHT[4],
                            l_SEGMENTS_TO_LIGHT[5],
                            l_SEGMENTS_TO_LIGHT[6]};
    // segments are active low and must be reordered for 
    // the BASYS3 default constraint file
 
    
endmodule
