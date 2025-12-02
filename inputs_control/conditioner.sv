`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: conditioner
// Description: Debounces and generates one-pulse output for button inputs
//////////////////////////////////////////////////////////////////////////////////

module conditioner(
    input  logic clk,
    input  logic buttonPress,
    output logic conditionedSignal,
    output logic pulse              // One-cycle pulse output
);
    
    logic [31:0] counter;
    logic buttonPressFirstFlipFlop;
    logic synchronizedButtonPress;
    logic prev_conditioned;
    
    always_ff @(posedge clk) begin
        // Synchronizer
        buttonPressFirstFlipFlop <= buttonPress;
        synchronizedButtonPress <= buttonPressFirstFlipFlop;
        
        // Debounce logic
        if (synchronizedButtonPress == conditionedSignal)
            counter <= 0;
        else if (counter <= 31'd1_500_000)
            counter <= counter + 1;
        else 
            conditionedSignal <= synchronizedButtonPress;
        
        // One-pulse generation
        prev_conditioned <= conditionedSignal;
    end
    
    // Generate pulse on rising edge of conditioned signal
    assign pulse = conditionedSignal & ~prev_conditioned;
    
endmodule