module conditioner(  input   logic   clk,
                     input   logic   buttonPress,
                     output  logic   conditionedSignal );
    
    logic [31:0] counter;
    
    logic buttonPressFirstFlipFlop;
    logic synchronizedButtonPress;
            
    always_ff @ ( posedge clk ) begin
        
        buttonPressFirstFlipFlop <= buttonPress;
        synchronizedButtonPress <= buttonPressFirstFlipFlop;
    
        if( synchronizedButtonPress == conditionedSignal )
            counter <= 0;
        else if( counter <= 31'd1_500_000 )
            counter <= counter + 1;
        else 
            conditionedSignal <= synchronizedButtonPress;
            
    end
    
endmodule
