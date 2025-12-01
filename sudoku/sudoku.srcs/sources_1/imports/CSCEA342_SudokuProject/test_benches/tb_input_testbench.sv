// Testbench for Input Controller - Moore FSM

module tb_input_controller();

    // Clock and reset
    logic clk, reset;
    
    // Button inputs
    logic btn_up, btn_down, btn_left, btn_right, btn_center;
    
    // Keyboard inputs
    logic kb_cmd_up, kb_cmd_down, kb_cmd_left, kb_cmd_right, kb_cmd_enter;
    logic [3:0] kb_cmd_number;
    logic kb_cmd_valid;
    
    // Outputs
    logic cmd_up, cmd_down, cmd_left, cmd_right, cmd_enter;
    logic [3:0] cmd_number;
    logic cmd_valid;
    logic entry_mode;
    logic [3:0] cycling_number;
    
    // Test vectors
    logic [15:0] vectors [0:99];
    int error_count = 0;
    
    // Moore FSM for test control
    typedef enum logic [2:0] {
        TB_INIT,
        TB_LOAD_VECTOR,
        TB_APPLY_STIMULUS,
        TB_WAIT_CLOCK,
        TB_CHECK_RESULTS,
        TB_CLEANUP,
        TB_DONE
    } tb_state_t;
    
    tb_state_t tb_state;
    int vector_index;
    logic [3:0] v_source;
    logic [3:0] v_expected_state;
    logic [3:0] v_expected_output;
    
    // DUT instantiation
    input_controller dut (
        .clk(clk),
        .reset(reset),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .btn_center(btn_center),
        .kb_cmd_up(kb_cmd_up),
        .kb_cmd_down(kb_cmd_down),
        .kb_cmd_left(kb_cmd_left),
        .kb_cmd_right(kb_cmd_right),
        .kb_cmd_enter(kb_cmd_enter),
        .kb_cmd_number(kb_cmd_number),
        .kb_cmd_valid(kb_cmd_valid),
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_number(cmd_number),
        .cmd_valid(cmd_valid),
        .entry_mode(entry_mode),
        .cycling_number(cycling_number)
    );
    
    // Clock generation
    always begin
        clk = 1; #5; clk = 0; #5;
    end
    
    // Moore FSM for test execution
    always_ff @(posedge clk) begin
        if (reset) begin
            tb_state <= TB_INIT;
            vector_index <= 0;
            error_count <= 0;
            btn_up <= 0; btn_down <= 0; btn_left <= 0; btn_right <= 0; btn_center <= 0;
            kb_cmd_up <= 0; kb_cmd_down <= 0; kb_cmd_left <= 0; kb_cmd_right <= 0;
            kb_cmd_enter <= 0; kb_cmd_number <= 0; kb_cmd_valid <= 0;
        end else begin
            case (tb_state)
                TB_INIT: begin
                    $display("Loading input controller test vectors...");
                    $readmemh("input_controller.tv", vectors);
                    $display("Starting Input Controller Tests...");
                    tb_state <= TB_LOAD_VECTOR;
                end
                
                TB_LOAD_VECTOR: begin
                    if (vectors[vector_index] === 16'hFFFF) begin
                        tb_state <= TB_DONE;
                    end else begin
                        v_source <= vectors[vector_index][15:12];
                        v_expected_state <= vectors[vector_index][11:8];
                        v_expected_output <= vectors[vector_index][7:0];
                        tb_state <= TB_APPLY_STIMULUS;
                    end
                end
                
                TB_APPLY_STIMULUS: begin
                    // Reset all inputs
                    btn_up <= 0; btn_down <= 0; btn_left <= 0; btn_right <= 0; btn_center <= 0;
                    kb_cmd_up <= 0; kb_cmd_down <= 0; kb_cmd_left <= 0; kb_cmd_right <= 0;
                    kb_cmd_enter <= 0; kb_cmd_number <= 0; kb_cmd_valid <= 0;
                    
                    // Apply stimulus based on source
                    case (v_source)
                        4'h1: btn_up <= 1;
                        4'h2: btn_down <= 1;
                        4'h3: btn_left <= 1;
                        4'h4: btn_right <= 1;
                        4'h5: btn_center <= 1;
                        4'h6: begin
                            kb_cmd_valid <= 1;
                            case (v_expected_output)
                                4'h1: kb_cmd_up <= 1;
                                4'h2: kb_cmd_down <= 1;
                                4'h3: kb_cmd_left <= 1;
                                4'h4: kb_cmd_right <= 1;
                                4'h5: kb_cmd_number <= 5;
                                default: kb_cmd_enter <= 1;
                            endcase
                        end
                    endcase
                    
                    tb_state <= TB_WAIT_CLOCK;
                end
                
                TB_WAIT_CLOCK: begin
                    // Wait one more cycle for DUT to process
                    tb_state <= TB_CHECK_RESULTS;
                end
                
                TB_CHECK_RESULTS: begin
                    // Check results
                    logic state_match, output_match;
                    
                    state_match = (entry_mode == v_expected_state[0]);
                    
                    if (v_expected_state[0]) begin // ENTRY mode
                        output_match = (cycling_number == v_expected_output);
                    end else begin // NAVIGATE mode
                        case (v_source)
                            4'h1, 4'h6: output_match = cmd_up;
                            4'h2: output_match = cmd_down;
                            4'h3: output_match = cmd_left;
                            4'h4: output_match = cmd_right;
                            4'h5: output_match = (cmd_number == v_expected_output) || (v_expected_output == 0);
                            default: output_match = 1;
                        endcase
                    end
                    
                    if (state_match && output_match) begin
                        $display("Test %2d PASS: Source=%h State=%s CycNum=%d", 
                                 vector_index, v_source, entry_mode ? "ENTRY" : "NAVIGATE", cycling_number);
                    end else begin
                        $display("Test %2d FAIL: Source=%h | Expected State=%s Output=%h | Got State=%s CycNum=%d",
                                 vector_index, v_source, v_expected_state[0] ? "ENTRY" : "NAVIGATE", v_expected_output,
                                 entry_mode ? "ENTRY" : "NAVIGATE", cycling_number);
                        error_count <= error_count + 1;
                    end
                    
                    tb_state <= TB_CLEANUP;
                end
                
                TB_CLEANUP: begin
                    // Clear inputs
                    btn_up <= 0; btn_down <= 0; btn_left <= 0; btn_right <= 0; btn_center <= 0;
                    kb_cmd_valid <= 0;
                    vector_index <= vector_index + 1;
                    tb_state <= TB_LOAD_VECTOR;
                end
                
                TB_DONE: begin
                    if (error_count == 0)
                        $display("ALL INPUT CONTROLLER TESTS PASSED!");
                    else
                        $display("FINISHED WITH %d ERRORS", error_count);
                    $stop;
                end
            endcase
        end
    end
    
    // Initial block to start test
    initial begin
        reset = 1;
        #50;
        reset = 0;
    end

endmodule
