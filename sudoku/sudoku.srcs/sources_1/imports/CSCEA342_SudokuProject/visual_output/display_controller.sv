module display_controller(
    input  logic clk,
    input  logic reset,
    input  logic [3:0] current_x,   // Cursor X (0-8)
    input  logic [3:0] current_y,   // Cursor Y (0-8)
    input  logic [3:0] current_val, // Value at Cursor
    
    output logic [6:0] seg,         // Cathodes
    output logic [3:0] an           // Anodes (Active Low)
);

    // Format the 16-bit number to display:
    // Digit 3 (Left): Y coordinate
    // Digit 2: X coordinate
    // Digit 1: 0 (Spacer)
    // Digit 0 (Right): Current Value
    logic [15:0] displayed_number;
    assign displayed_number = {current_y, current_x, 4'b0000, current_val};

    // Instantiate the provided 7-segment driver
    sevenseg SEG_DRIVER (
        .clk(clk),
        .displayed_number(displayed_number),
        .Anode_Activate(an),
        .LED_out(seg)
    );

endmodule