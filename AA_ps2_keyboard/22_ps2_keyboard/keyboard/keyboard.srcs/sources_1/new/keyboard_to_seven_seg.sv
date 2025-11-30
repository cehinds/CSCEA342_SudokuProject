module KeyboardToSevenSegment(
        input   logic           clk,
        input   logic           btnC,
        input   logic           PS2Clk,
        input   logic           PS2Data,                        
        output  logic   [3:0]   an, 
        output  logic   [6:0]   seg);
          
    logic l_SYNCHRONIZED_BTN_C;
    Synchronizer synchronizer_btn_c(    .i_CLK(clk),
                                        .i_SIGNAL(btnC),
                                        .o_SYNCHRONIZED_SIGNAL(l_SYNCHRONIZEDD_BTN_C) );

    logic l_SYNCHRONIZED_PS2_CLK;
    Synchronizer synchronizer_ps2clk(   .i_CLK(clk),
                                        .i_SIGNAL(PS2Clk),
                                        .o_SYNCHRONIZED_SIGNAL(l_SYNCHRONIZED_PS2_CLK) );
    
    logic l_SYNCHRONIZED_PS2_DATA;
    Synchronizer synchronizer_ps2data(  .i_CLK(clk), 
                                        .i_SIGNAL(PS2Data), 
                                        .o_SYNCHRONIZED_SIGNAL(l_SYNCHRONIZED_PS2_DATA) );                 
             
    logic [7:0] l_DATA;             
    PS2Decoder ps2_decoder_instance(    .i_CLK(clk),
                                        .i_RESET(l_SYNCHRONIZEDD_BTN_C),
                                        .i_PS2_CLK(l_SYNCHRONIZED_PS2_CLK),
                                        .i_PS2_DATA(l_SYNCHRONIZED_PS2_DATA), 
                                        .o_DATA(l_DATA) );

    SevenSegmentDecoder seven_segment_decoder_instance( .i_CLK(clk),
                                                        .i_NUMBER_TO_DISPLAY({8'b0000_0000,l_DATA}),
                                                        .o_ANODES(an),
                                                        .o_SEGMENTS(seg) );
                                                        
                                                                                                       
       

endmodule