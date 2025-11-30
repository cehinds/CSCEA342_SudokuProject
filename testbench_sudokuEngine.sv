module testbench();

    logic clk, reset;
    logic [1:0] puzzle_selector;
    logic [3:0] cmd_number;
    logic       cmd_up, 
                cmd_down, 
                cmd_left, 
                cmd_right, 
                cmd_enter;
    logic       cmd_valid;
    logic [3:0] current_x, 
                current_y, 
                current_val;
    logic       game_won, 
                game_lost;
    logic       engine_ready;

    integer counter;
    logic [3:0] r, c;

    assign c = counter % 9;
    assign r = counter / 9;

    sudoku_engine dut(
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

    always begin
        clk = 1; #5; clk = 0; #5;
    end

    typedef enum logic [4:0] {
        S_RESET,
        S_WAIT_READY,
        S_PRESS_RIGHT_1,
        S_PRESS_RIGHT_2,
        S_PRESS_DOWN,
        S_CHECK_POS,
        S_ENTER_VAL,
        S_CHECK_VAL,
        S_CHEAT_FILL,
        S_SUBMIT,
        S_CHECK_WIN,
        S_STOP
    } state_t;

    state_t state;

    always_ff @(posedge clk) begin
        cmd_up    <= 0; 
        cmd_down  <= 0; 
        cmd_left  <= 0; 
        cmd_right <= 0;
        cmd_enter <= 0; 
        cmd_valid <= 0; 
        cmd_number <= 0;

        case (state)
            S_RESET: begin
                reset <= 1;
                puzzle_selector <= 0;
                counter <= 0;
                state <= S_WAIT_READY;
            end

            S_WAIT_READY: begin
                reset <= 0;
                if (engine_ready) begin
                    $display("Puzzle Loaded");
                    state <= S_PRESS_RIGHT_1;
                end
            end

            S_PRESS_RIGHT_1: begin
                cmd_right <= 1; 
                cmd_valid <= 1;
                state <= S_PRESS_RIGHT_2;
            end

            S_PRESS_RIGHT_2: begin
                cmd_right <= 1; 
                cmd_valid <= 1;
                state <= S_PRESS_DOWN;
            end

            S_PRESS_DOWN: begin
                cmd_down <= 1; 
                cmd_valid <= 1;
                state <= S_CHECK_POS;
            end

            S_CHECK_POS: begin
                if (current_x == 2 && current_y == 1)
                    $display("Test 1 Passed");
                else
                    $display("Test 1 Failed: %d,%d", current_x, current_y);
                
                state <= S_ENTER_VAL;
            end

            S_ENTER_VAL: begin
                cmd_number <= 7;
                cmd_valid <= 1;
                state <= S_CHECK_VAL;
            end

            S_CHECK_VAL: begin
                if (dut.grid[2][1] == 7)
                    $display("Test 2 Passed");
                else
                    $display("Test 2 Failed: %d", dut.grid[2][1]);

                state <= S_CHEAT_FILL;
                counter <= 0;
            end

            S_CHEAT_FILL: begin
                dut.grid[c][r] <= dut.solution[c][r];

                if (counter == 80) begin
                    $display("Cheat Fill Complete");
                    state <= S_SUBMIT;
                    counter <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end

            S_SUBMIT: begin
                cmd_enter <= 1;
                cmd_valid <= 1;
                state <= S_CHECK_WIN;
            end

            S_CHECK_WIN: begin
                if (game_won) begin
                    $display("Test 3 Passed");
                    state <= S_STOP;
                end else if (game_lost) begin
                    $display("Test 3 Failed");
                    state <= S_STOP;
                end else if (counter > 200) begin
                    $display("Test 3 Timeout");
                    state <= S_STOP;
                end
                counter <= counter + 1;
            end

            S_STOP: begin
                $stop;
            end
        endcase
    end

    initial begin
        state = S_RESET;
    end

endmodule
