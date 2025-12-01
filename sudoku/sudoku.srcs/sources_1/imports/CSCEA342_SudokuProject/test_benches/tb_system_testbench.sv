// Integrated System Testbench - Moore FSM
// Tests the complete flow: buttons -> input controller -> game engine -> display

module tb_sudoku_system();

    logic clk, reset;
    
    // Button inputs
    logic btnU, btnD, btnL, btnR, btnC;
    
    // PS/2 (not tested here, set to idle)
    logic ps2_clk, ps2_data;
    
    // Outputs
    logic [6:0] seg;
    logic [7:0] an;
    logic dp;
    logic [15:0] led;
    
    // Moore FSM for test control
    typedef enum logic [4:0] {
        TB_INIT,
        TB_WAIT_ENGINE,
        TB_TEST1_PRESS,
        TB_TEST1_WAIT,
        TB_TEST1_CHECK,
        TB_TEST2_PRESS,
        TB_TEST2_WAIT,
        TB_TEST2_CHECK,
        TB_TEST3_PRESS,
        TB_TEST3_WAIT,
        TB_TEST3_CHECK,
        TB_TEST4_PRESS,
        TB_TEST4_WAIT,
        TB_TEST4_CHECK,
        TB_TEST5_PRESS,
        TB_TEST5_WAIT,
        TB_TEST5_CHECK,
        TB_TEST6_CYCLE,
        TB_TEST6_WAIT,
        TB_TEST7_CYCLE,
        TB_TEST7_WAIT,
        TB_TEST8_PRESS,
        TB_TEST8_WAIT,
        TB_TEST8_CHECK,
        TB_TEST9_ENTER,
        TB_TEST9_CYCLE_TO_9,
        TB_TEST9_WRAP,
        TB_TEST10_WRAP,
        TB_CLEANUP,
        TB_DONE
    } tb_state_t;
    
    tb_state_t tb_state;
    int wait_counter;
    int cycle_count;
    
    // DUT - Top level
    sudoku_top dut (
        .clk(clk),
        .reset(reset),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .btnC(btnC),
        .seg(seg),
        .an(an),
        .dp(dp),
        .led(led)
    );
    
    // Clock generation
    always begin
        clk = 1; #5; clk = 0; #5;
    end
    
    // Moore FSM for test execution
    always_ff @(posedge clk) begin
        if (reset) begin
            tb_state <= TB_INIT;
            btnU <= 0; btnD <= 0; btnL <= 0; btnR <= 0; btnC <= 0;
            wait_counter <= 0;
            cycle_count <= 0;
        end else begin
            case (tb_state)
                TB_INIT: begin
                    $display("=== Starting Sudoku System Integration Test ===\n");
                    btnU <= 0; btnD <= 0; btnL <= 0; btnR <= 0; btnC <= 0;
                    ps2_clk <= 1; ps2_data <= 1;
                    wait_counter <= 0;
                    tb_state <= TB_WAIT_ENGINE;
                end
                
                TB_WAIT_ENGINE: begin
                    if (led[13] == 1) begin // engine_ready
                        $display("Engine ready! Starting tests.\n");
                        tb_state <= TB_TEST1_PRESS;
                        wait_counter <= 0;
                    end
                end
                
                // Test 1: Press Right
                TB_TEST1_PRESS: begin
                    $display("Test 1: Press Right Button");
                    $display("Before: X=%d Y=%d", led[7:4], led[3:0]);
                    btnR <= 1;
                    tb_state <= TB_TEST1_WAIT;
                    wait_counter <= 0;
                end
                
                TB_TEST1_WAIT: begin
                    if (wait_counter >= 1500000) begin // 15ms button hold
                        btnR <= 0;
                        tb_state <= TB_TEST1_CHECK;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_TEST1_CHECK: begin
                    if (wait_counter >= 100000) begin
                        $display("After:  X=%d Y=%d", led[7:4], led[3:0]);
                        $display("Expected: X=1 Y=0\n");
                        tb_state <= TB_TEST2_PRESS;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 2: Press Down
                TB_TEST2_PRESS: begin
                    $display("Test 2: Press Down Button");
                    $display("Before: X=%d Y=%d", led[7:4], led[3:0]);
                    btnD <= 1;
                    tb_state <= TB_TEST2_WAIT;
                    wait_counter <= 0;
                end
                
                TB_TEST2_WAIT: begin
                    if (wait_counter >= 1500000) begin
                        btnD <= 0;
                        tb_state <= TB_TEST2_CHECK;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_TEST2_CHECK: begin
                    if (wait_counter >= 100000) begin
                        $display("After:  X=%d Y=%d", led[7:4], led[3:0]);
                        $display("Expected: X=1 Y=1\n");
                        tb_state <= TB_TEST3_PRESS;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 3: Press Up
                TB_TEST3_PRESS: begin
                    $display("Test 3: Press Up Button");
                    $display("Before: X=%d Y=%d", led[7:4], led[3:0]);
                    btnU <= 1;
                    tb_state <= TB_TEST3_WAIT;
                    wait_counter <= 0;
                end
                
                TB_TEST3_WAIT: begin
                    if (wait_counter >= 1500000) begin
                        btnU <= 0;
                        tb_state <= TB_TEST3_CHECK;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_TEST3_CHECK: begin
                    if (wait_counter >= 100000) begin
                        $display("After:  X=%d Y=%d", led[7:4], led[3:0]);
                        $display("Expected: X=1 Y=0\n");
                        tb_state <= TB_TEST4_PRESS;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 4: Press Left
                TB_TEST4_PRESS: begin
                    $display("Test 4: Press Left Button");
                    $display("Before: X=%d Y=%d", led[7:4], led[3:0]);
                    btnL <= 1;
                    tb_state <= TB_TEST4_WAIT;
                    wait_counter <= 0;
                end
                
                TB_TEST4_WAIT: begin
                    if (wait_counter >= 1500000) begin
                        btnL <= 0;
                        tb_state <= TB_TEST4_CHECK;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_TEST4_CHECK: begin
                    if (wait_counter >= 100000) begin
                        $display("After:  X=%d Y=%d", led[7:4], led[3:0]);
                        $display("Expected: X=0 Y=0\n");
                        tb_state <= TB_TEST5_PRESS;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 5: Enter Entry Mode
                TB_TEST5_PRESS: begin
                    $display("Test 5: Press Center Button (Enter Entry Mode)");
                    $display("Before: Entry_mode=%d", led[12]);
                    btnC <= 1;
                    tb_state <= TB_TEST5_WAIT;
                    wait_counter <= 0;
                end
                
                TB_TEST5_WAIT: begin
                    if (wait_counter >= 1500000) begin
                        btnC <= 0;
                        tb_state <= TB_TEST5_CHECK;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_TEST5_CHECK: begin
                    if (wait_counter >= 100000) begin
                        $display("After:  Entry_mode=%d Cycling=%d", led[12], led[11:8]);
                        $display("Expected: Entry_mode=1 Cycling=1\n");
                        tb_state <= TB_TEST6_CYCLE;
                        wait_counter <= 0;
                        cycle_count <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 6: Cycle Up 5 times
                TB_TEST6_CYCLE: begin
                    if (cycle_count >= 5) begin
                        $display("Test 6: Cycle Numbers Up");
                        $display("Final Cycling: %d", led[11:8]);
                        $display("Expected: 6\n");
                        tb_state <= TB_TEST7_CYCLE;
                        cycle_count <= 0;
                        wait_counter <= 0;
                    end else begin
                        $display("Cycling: %d", led[11:8]);
                        btnU <= 1;
                        tb_state <= TB_TEST6_WAIT;
                        wait_counter <= 0;
                    end
                end
                
                TB_TEST6_WAIT: begin
                    if (wait_counter >= 1500000) begin
                        btnU <= 0;
                        cycle_count <= cycle_count + 1;
                        tb_state <= TB_TEST6_CYCLE;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 7: Cycle Down 2 times
                TB_TEST7_CYCLE: begin
                    if (cycle_count >= 2) begin
                        $display("Test 7: Cycle Numbers Down");
                        $display("Final Cycling: %d", led[11:8]);
                        $display("Expected: 4\n");
                        tb_state <= TB_TEST8_PRESS;
                        wait_counter <= 0;
                    end else begin
                        $display("Cycling: %d", led[11:8]);
                        btnD <= 1;
                        tb_state <= TB_TEST7_WAIT;
                        wait_counter <= 0;
                    end
                end
                
                TB_TEST7_WAIT: begin
                    if (wait_counter >= 1500000) begin
                        btnD <= 0;
                        cycle_count <= cycle_count + 1;
                        tb_state <= TB_TEST7_CYCLE;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 8: Exit Entry Mode
                TB_TEST8_PRESS: begin
                    $display("Test 8: Press Center Button (Confirm and Exit)");
                    $display("Before: Entry_mode=%d", led[12]);
                    btnC <= 1;
                    tb_state <= TB_TEST8_WAIT;
                    wait_counter <= 0;
                end
                
                TB_TEST8_WAIT: begin
                    if (wait_counter >= 1500000) begin
                        btnC <= 0;
                        tb_state <= TB_TEST8_CHECK;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_TEST8_CHECK: begin
                    if (wait_counter >= 100000) begin
                        $display("After:  Entry_mode=%d", led[12]);
                        $display("Expected: Entry_mode=0\n");
                        tb_state <= TB_TEST9_ENTER;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 9: Wraparound 9->1
                TB_TEST9_ENTER: begin
                    $display("Test 9: Test Wraparound 9->1");
                    btnC <= 1;
                    tb_state <= TB_TEST9_CYCLE_TO_9;
                    wait_counter <= 0;
                    cycle_count <= 0;
                end
                
                TB_TEST9_CYCLE_TO_9: begin
                    if (wait_counter >= 1500000) begin
                        btnC <= 0;
                        if (cycle_count >= 8) begin
                            $display("At 9: Cycling=%d", led[11:8]);
                            tb_state <= TB_TEST9_WRAP;
                            wait_counter <= 0;
                        end else begin
                            btnU <= 1;
                            cycle_count <= cycle_count + 1;
                            wait_counter <= 0;
                        end
                    end else if (cycle_count > 0 && wait_counter == 0) begin
                        btnU <= 0;
                        wait_counter <= wait_counter + 1;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_TEST9_WRAP: begin
                    btnU <= 1;
                    if (wait_counter >= 1500000) begin
                        btnU <= 0;
                        $display("After wrap: Cycling=%d", led[11:8]);
                        $display("Expected: 1\n");
                        tb_state <= TB_TEST10_WRAP;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                // Test 10: Wraparound 1->9
                TB_TEST10_WRAP: begin
                    if (wait_counter >= 100000) begin
                        $display("Test 10: Test Wraparound 1->9");
                        $display("At 1: Cycling=%d", led[11:8]);
                        btnD <= 1;
                        tb_state <= TB_CLEANUP;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_CLEANUP: begin
                    if (wait_counter >= 1500000) begin
                        btnD <= 0;
                        $display("After wrap: Cycling=%d", led[11:8]);
                        $display("Expected: 9\n");
                        tb_state <= TB_DONE;
                        wait_counter <= 0;
                    end else begin
                        wait_counter <= wait_counter + 1;
                    end
                end
                
                TB_DONE: begin
                    $display("\n=== All System Tests Complete ===");
                    $display("Check LED outputs:");
                    $display("  LED[15]: game_won = %d", led[15]);
                    $display("  LED[14]: game_lost = %d", led[14]);
                    $display("  LED[13]: engine_ready = %d", led[13]);
                    $display("  LED[12]: entry_mode = %d", led[12]);
                    $stop;
                end
            endcase
        end
    end
    
    // Initial reset
    initial begin
        reset = 1;
        #1000;
        reset = 0;
    end

endmodule
