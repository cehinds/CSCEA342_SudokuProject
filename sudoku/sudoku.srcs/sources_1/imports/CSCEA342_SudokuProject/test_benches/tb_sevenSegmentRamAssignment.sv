`timescale 1ns / 1ps

module tb_sevenSegmentRamAssignment();

    // Inputs
    logic clk, storeButton, upButton, downButton;
    logic [15:0] sw;
    
    // Outputs
    logic [3:0] led;
    logic [6:0] SSD_LED_out;
    logic [3:0] Anode_Activate;

    // Expected Outputs (for checking)
    logic [3:0] led_expected;
    // We won't check 7seg pattern bit-by-bit in vector file as it's complex, 
    // but we can check the LED address debug output.

    // Test Vector Variables
    logic [31:0] vectornum, errors, linenum;
    // Format: Store Up Down SwitchVal_Hex | Expected_LED_Addr
    logic [22:0] testvectors[1000:0]; 

    // Instantiate UUT
    sevenSegmentRamAssignment #(.N(4), .M(16)) uut (
        .clk(clk),
        .storeButton(storeButton),
        .upButton(upButton),
        .downButton(downButton),
        .sw(sw),
        .led(led),
        .SSD_LED_out(SSD_LED_out),
        .Anode_Activate(Anode_Activate)
    );

    // Clock Generation
    always begin
        clk = 0; #5; clk = 1; #5;
    end

    // Load Vectors
    initial begin
        // Note: You must create "sevenSeg.tv" with binary/hex vectors
        $readmemh("sevenSeg.tv", testvectors);
        vectornum = 0; errors = 0; linenum = 1;
        
        // Reset inputs
        storeButton = 0; upButton = 0; downButton = 0; sw = 0;
    end

    // Apply Inputs (Falling Edge)
    always @(negedge clk) begin
        #1;
        {storeButton, upButton, downButton, sw, led_expected} = testvectors[vectornum];
    end

    // Check Outputs (Rising Edge)
    always @(posedge clk) begin
        #1;
        // Check if the Address LED matches the expected address
        if (led !== led_expected) begin
            $display("Error at line %d (vector %d)", linenum, vectornum);
            $display(" Inputs: Store=%b Up=%b Down=%b SW=%h", storeButton, upButton, downButton, sw);
            $display(" Output LED: %b  Expected: %b", led, led_expected);
            errors = errors + 1;
        end
        
        vectornum = vectornum + 1;
        linenum = linenum + 1;
        
        if (testvectors[vectornum] === 23'bx) begin
            $display("%d tests completed with %d errors", vectornum, errors);
            $finish;
        end
    end

endmodule