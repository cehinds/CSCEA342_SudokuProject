`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: TestbenchSudokuEngine
// Description: Tests sudoku_engine state machine transitions
// 
// IMPORTANT: Update NUM_VECTORS when adding/removing test vectors!
// AI Acknowledgement: First, I asked it to assign dut input and output lines so that I can see the wave form for debugging. Due to timing errors, the test_vector repeatedly failed, AI was used to help debug to a point where it could not solve the issue, but narrowed the issue down to it being a timing issue and it was related to lines 150+. Also, since my first 163 cycles are dedicated to loading the puzzle, solution, and mask, it recommended I add this in the initial block "// UPDATED: Initialize memory to X
            //for (int i=0; i<256; i=i+1) testvectors[i] = 15'bx;
//I ultimately solved the issue by flipping bits line by line until I narrowed down to lines 161 to 163. Turns out the timing was off by two cycles. I then removed all extra comments between lines and added exactly two comment lines at the top. I also asked the AI to add line number comments to the fixed test_vector.
//////////////////////////////////////////////////////////////////////////////////

module TestbenchSudokuEngine();

  
    parameter NUM_VECTORS = 175;  // Total vectors in SudokuEngine.tv (0 to 175)
    
    logic l_CLK, l_RESET;
    logic l_SEL, l_VALID, l_UP, l_DOWN, l_LEFT, l_RIGHT, l_ENTER;
    logic l_READY, l_WON, l_LOST;
    logic l_READY_EXP, l_WON_EXP, l_LOST_EXP;
    logic [1:0] l_CUR_X_EXP, l_CUR_Y_EXP;
    logic [3:0] l_CUR_X, l_CUR_Y;
    logic [31:0] vectornum, errors;
    
    logic [14:0] testvectors[0:NUM_VECTORS-1];

    // Unused outputs
    logic [3:0] l_VAL;
    logic l_CHKW, l_CHKL;
    logic l_MATCH [0:8][0:8];
    logic [3:0] l_GRID [0:8][0:8];
    logic l_FIXED [0:8][0:8];
    
    // Debug Signals
    logic [1:0]  dbg_state;
    logic [6:0]  dbg_load_counter;
    logic [3:0]  dbg_load_row, dbg_load_col;
    logic        dbg_up_evt, dbg_down_evt, dbg_left_evt, dbg_right_evt, dbg_enter_evt;
    logic [3:0]  dbg_current_x, dbg_current_y, dbg_current_val;
    logic        dbg_engine_ready, dbg_game_won, dbg_game_lost;

    assign dbg_state        = dut.state;
    assign dbg_load_counter = dut.load_counter;
    assign dbg_load_row     = dut.load_row;
    assign dbg_load_col     = dut.load_col;
    assign dbg_up_evt       = dut.up_evt;
    assign dbg_down_evt     = dut.down_evt;
    assign dbg_left_evt     = dut.left_evt;
    assign dbg_right_evt    = dut.right_evt;
    assign dbg_enter_evt    = dut.enter_evt;
    assign dbg_current_x    = dut.current_x;
    assign dbg_current_y    = dut.current_y;
    assign dbg_current_val  = dut.current_val;
    assign dbg_engine_ready = dut.engine_ready;
    assign dbg_game_won     = dut.game_won;
    assign dbg_game_lost    = dut.game_lost;

    sudoku_engine dut (
        .clk(l_CLK),
        .reset(l_RESET),
        .puzzle_selector({1'b0, l_SEL}),
        .cmd_number(4'b0000),
        .cmd_up(l_UP),
        .cmd_down(l_DOWN),
        .cmd_left(l_LEFT),
        .cmd_right(l_RIGHT),
        .cmd_enter(l_ENTER),
        .cmd_valid(l_VALID),
        .check_enable(1'b0),
        .current_x(l_CUR_X),
        .current_y(l_CUR_Y),
        .current_val(l_VAL),
        .game_won(l_WON),
        .game_lost(l_LOST),
        .engine_ready(l_READY),
        .check_win(l_CHKW),
        .check_lose(l_CHKL),
        .cell_match(l_MATCH),
        .grid_out(l_GRID),
        .fixed_mask_out(l_FIXED)
    );

    // Clock generation
    always begin
        l_CLK = 0; #5; l_CLK = 1; #5;
    end

initial
        begin
            // UPDATED: Initialize memory to X
            for (int i=0; i<256; i=i+1) testvectors[i] = 15'bx;
            
            // NEW FIX: Initialize the expected signal so we don't quit early
            l_READY_EXP = 0; 
            
            $readmemb("SudokuEngine.tv", testvectors);
            vectornum = 0; errors = 0;
            
                    // Pre-load first vector before simulation starts
        {l_RESET, l_SEL, l_VALID, l_UP, l_DOWN, l_LEFT, l_RIGHT, l_ENTER,
         l_READY_EXP, l_CUR_X_EXP, l_CUR_Y_EXP, l_WON_EXP, l_LOST_EXP} = testvectors[0];
    
        end


    // Main test logic - runs on every positive clock edge
    always @(posedge l_CLK) begin
        #1;  // Wait for signals to settle
        
        // Check for errors on current vector
        if (l_READY !== l_READY_EXP) begin
            $display("Error vec %0d: ready=%b, expected=%b", vectornum, l_READY, l_READY_EXP);
            errors = errors + 1;
        end
        if (l_CUR_X[1:0] !== l_CUR_X_EXP) begin
            $display("Error vec %0d: curX=%0d, expected=%0d", vectornum, l_CUR_X[1:0], l_CUR_X_EXP);
            errors = errors + 1;
        end
        if (l_CUR_Y[1:0] !== l_CUR_Y_EXP) begin
            $display("Error vec %0d: curY=%0d, expected=%0d", vectornum, l_CUR_Y[1:0], l_CUR_Y_EXP);
            errors = errors + 1;
        end
        if (l_WON !== l_WON_EXP) begin
            $display("Error vec %0d: won=%b, expected=%b", vectornum, l_WON, l_WON_EXP);
            errors = errors + 1;
        end
        if (l_LOST !== l_LOST_EXP) begin
            $display("Error vec %0d: lost=%b, expected=%b", vectornum, l_LOST, l_LOST_EXP);
            errors = errors + 1;
        end
        
        // Move to next vector
        vectornum = vectornum + 1;
        
        // Check if we've processed all vectors
        if (vectornum >= NUM_VECTORS) begin
            $display("----------------------------------------------");
            if (errors == 0)
                $display("SUCCESS: All %0d vectors passed!", NUM_VECTORS);
            else
                $display("COMPLETED: %0d vectors, %0d errors", NUM_VECTORS, errors);
            $display("----------------------------------------------");
            $finish;
        end
        
        // AI Acknowledgement: Added for debugging timing error --Load next vector
        {l_RESET, l_SEL, l_VALID, l_UP, l_DOWN, l_LEFT, l_RIGHT, l_ENTER,
         l_READY_EXP, l_CUR_X_EXP, l_CUR_Y_EXP, l_WON_EXP, l_LOST_EXP} = testvectors[vectornum];
    end

endmodule
