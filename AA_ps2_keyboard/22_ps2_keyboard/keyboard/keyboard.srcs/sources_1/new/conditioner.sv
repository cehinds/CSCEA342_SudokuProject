module Synchronizer( input   logic   i_CLK,
                    input   logic   i_SIGNAL,
                    output  logic   o_SYNCHRONIZED_SIGNAL );
    
    logic           l_SIGNAL_FIRST_FF;
    logic           l_SYNCHRONIZED_SIGNAL;
    
    always_ff @ ( posedge i_CLK ) begin 
        l_SIGNAL_FIRST_FF <= i_SIGNAL;
        l_SYNCHRONIZED_SIGNAL <= l_SIGNAL_FIRST_FF;
    end
    
    assign o_SYNCHRONIZED_SIGNAL = l_SYNCHRONIZED_SIGNAL;
    
endmodule