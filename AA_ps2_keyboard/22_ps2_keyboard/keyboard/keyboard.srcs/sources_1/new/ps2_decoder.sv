module PS2Decoder(
        input   logic           i_CLK,
        input   logic           i_RESET,
        input   logic           i_PS2_CLK,
        input   logic           i_PS2_DATA,
        output  logic   [7:0]   o_DATA
    );
    
    logic           l_PREV_PS2_CLK;
    logic [10:0]    l_RECEIVED;
  
    always_ff @ (posedge i_CLK ) begin
        l_PREV_PS2_CLK <= i_PS2_CLK;
        
        if( i_RESET ) begin
            l_RECEIVED <= 11'b000_0000_0000;
        end
        else if( {l_PREV_PS2_CLK, i_PS2_CLK} == 2'b10 ) begin
            l_RECEIVED <= { i_PS2_DATA, l_RECEIVED[10:1] };
        end
        
      end
        
      assign o_DATA = l_RECEIVED[8:1];
      
endmodule
