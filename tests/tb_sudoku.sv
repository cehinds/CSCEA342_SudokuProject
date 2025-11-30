module tb_sudoku();

    // --- Signal Declarations ---
    logic clk, reset;
    
    // Inputs
    logic [1:0] puzzle_selector;
    logic [3:0] cmd_number;
    logic       cmd_up, cmd_down, cmd_left, cmd_right, cmd_enter, cmd_valid;

    // Outputs
    logic [3:0] current_x, current_y;
    logic [3:0] current_val;
    logic       game_won, game_lost, engine_ready;

    // Test Vectors
    // Format: [15:12] CmdType, [11:8] InputVal, [7:0] Expected_Grid_Val
    logic [15:0] vectors [0:99];
    logic [3:0]  v_type;
    logic [3:0]  v_input_val;
    logic [3:0]  v_expected_result;
    int i;
    int error_count = 0;

    // --- Instantiate DUT ---
    sudoku_engine dut (
        .clk(clk),
        .reset(reset),
        .puzzle_selector(puzzle_selector),
        .cmd_number(cmd_number),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_valid(cmd_valid),
        .current_x(current_x),
        .current_y(current_y),
        .current_val(current_val),
        .game_won(game_won),
        .game_lost(game_lost),
        .engine_ready(engine_ready)
    );

    // --- Clock Generation ---
    always begin
        clk = 1; #5; clk = 0; #5;
    end

    // --- Main Test Process ---
    initial begin
        $display("Loading Sudoku test vectors...");
        $readmemh("sudoku.tv", vectors);
        
        // Init
        reset = 1; 
        puzzle_selector = 0; 
        cmd_valid = 0;
        cmd_number = 0;
        cmd_up = 0; cmd_down = 0; cmd_left = 0; cmd_right = 0; cmd_enter = 0;
        
        #50;
        reset = 0;
        
        // Wait for ROM Load
        $display("Waiting for Engine Ready...");
        wait(engine_ready == 1);
        $display("Engine Ready! Starting Tests.");

        i = 0;
        while(vectors[i] !== 16'hFFFF) begin
            v_type            = vectors[i][15:12];
            v_input_val       = vectors[i][11:8]; 
            v_expected_result = vectors[i][7:0]; // The value we expect at current_x,y after move
            
            @(negedge clk); 
            
            // 1. Setup Command
            cmd_up = 0; cmd_down = 0; cmd_left = 0; cmd_right = 0; 
            cmd_enter = 0; cmd_number = 0; cmd_valid = 0;

            case (v_type)
                4'h1: begin cmd_up = 1;    cmd_valid = 1; end
                4'h2: begin cmd_down = 1;  cmd_valid = 1; end
                4'h3: begin cmd_left = 1;  cmd_valid = 1; end
                4'h4: begin cmd_right = 1; cmd_valid = 1; end
                4'h5: begin cmd_number = v_input_val; cmd_valid = 1; end
                4'h6: begin cmd_enter = 1; cmd_valid = 1; end
            endcase

            // 2. Pulse Trigger
            @(negedge clk);
            cmd_valid = 0;
            cmd_up = 0; cmd_down = 0; cmd_left = 0; cmd_right = 0; 
            cmd_enter = 0; cmd_number = 0;

            // 3. Wait for Logic Update
            #20; 

            // 4. CHECK RESULTS
            // We check if the value at the cursor matches our expectation.
            // (Note: v_expected_result = 0xF means "Don't Care" / Skip Check)
            if (v_expected_result !== 4'hF) begin
                if (current_val == v_expected_result) begin
                    $display("Test %2d PASS: Type=%h Val=%d | Grid[%d][%d] == %d", 
                             i, v_type, v_input_val, current_x, current_y, current_val);
                end else begin
                    $display("Test %2d FAIL: Type=%h | Grid[%d][%d] is %d (Expected %d)", 
                             i, v_type, current_x, current_y, current_val, v_expected_result);
                    error_count++;
                end
            end else begin
                $display("Test %2d INFO: Type=%h (Check Skipped)", i, v_type);
            end
            
            i++;
        end
        
        if (error_count == 0)
            $display("ALL SUDOKU TESTS PASSED!");
        else
            $display("FINISHED WITH %d ERRORS", error_count);
            
        $stop;
    end

endmodule