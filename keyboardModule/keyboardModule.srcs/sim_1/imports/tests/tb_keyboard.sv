module tb_keyboard();

    // --- Signal Declarations ---
    logic clk, reset;
    
    // PS/2 Physical Interface
    logic ps2_clk;
    logic ps2_data;

    // Interconnects
    logic [7:0] rx_data;
    logic       rx_ready;

    // Parser Outputs (DUT Outputs)
    logic cmd_up, cmd_down, cmd_left, cmd_right;
    logic cmd_enter, cmd_valid;
    logic [3:0] cmd_number;

    // Test Vector Variables
    // Format: [15:8] Scancode, [7:0] Expected Command Type (Arbitrary encoding for TB)
    logic [15:0] vectors [0:50]; 
    logic [31:0] vector_count;
    logic [7:0]  current_scancode;
    logic [7:0]  expected_type;
    int i;

    // --- Instantiate Devices Under Test (DUTs) ---
    
    // 1. The PS/2 Host Interface
    ps2_host host_inst (
        .clk(clk),
        .reset(reset),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .rx_data(rx_data),   // 
        .rx_ready(rx_ready)
    );

    // 2. The Keyboard Parser
    keyboard_parser parser_inst (
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_ready(rx_ready), // [cite: 138]
        .cmd_up(cmd_up),
        .cmd_down(cmd_down),
        .cmd_left(cmd_left),
        .cmd_right(cmd_right),
        .cmd_enter(cmd_enter),
        .cmd_number(cmd_number),
        .cmd_valid(cmd_valid)
    );

    // --- Clock Generation ---
    always begin
        clk = 1; #5; clk = 0; #5; // 10ns period (100MHz)
    end

    // --- PS/2 Serial Simulation Task ---
    // This task mimics the physical keyboard behavior.
    // Protocol: 1 Start bit (0), 8 Data bits (LSB first), 1 Parity (Odd), 1 Stop bit (1)
    task send_ps2_byte(input [7:0] data);
        integer j;
        logic parity;
        begin
            parity = ~(^data); // Odd parity calculation
            
            // 1. Start Bit (Low)
            ps2_data = 0;
            #2000; ps2_clk = 0; #2000; ps2_clk = 1; // Pulse clock low then high
            
            // 2. Data Bits (LSB First)
            j = 0;
            while(j < 8) begin
                ps2_data = data[j];
                #2000; ps2_clk = 0; #2000; ps2_clk = 1;
                j++;
            end

            // 3. Parity Bit
            ps2_data = parity;
            #2000; ps2_clk = 0; #2000; ps2_clk = 1;

            // 4. Stop Bit (High)
            ps2_data = 1;
            #2000; ps2_clk = 0; #2000; ps2_clk = 1;
            
            // Idle state
            #5000; 
        end
    endtask

    // --- Main Test Process ---
    initial begin
        // Debug: Load vectors
        $display("Loading keyboard test vectors...");
        $readmemh("keyboard.tv", vectors);

        // Initialize signals
        reset = 1;
        ps2_clk = 1;
        ps2_data = 1;
        
        #100;
        reset = 0;
        #100;

        i = 0;
        // Loop through vectors until we hit a zero entry (End of file marker)
        while (vectors[i] !== 16'h0000) begin
            current_scancode = vectors[i][15:8];
            expected_type    = vectors[i][7:0];

            $display("--- Test %0d: Sending Scancode %h ---", i, current_scancode);
            
            // Send the byte serially
            send_ps2_byte(current_scancode);

            // Wait for system to process (allow parser state machine to tick)
            #100;

            // Debug: Check outputs based on expected type
            // 0x01 = Number, 0x02 = Arrow/Enter, 0x00 = Ignore/Idle
            if (expected_type == 8'h01) begin
                if (cmd_valid && cmd_number != 0) 
                    $display("PASS: Detected Number %d", cmd_number);
                else 
                    $display("FAIL: Expected Number, got Valid=%b Num=%d", cmd_valid, cmd_number);
            end 
            else if (expected_type == 8'h02) begin
                // Note: Arrows are E0 followed by code. If we just sent the second byte, check validity.
                if (cmd_valid && (cmd_up || cmd_down || cmd_left || cmd_right || cmd_enter))
                    $display("PASS: Detected Command/Direction");
                else
                    $display("FAIL: Expected Direction/Enter");
            end
            else begin
                 $display("INFO: Scancode sent (likely Setup byte or Release). Valid=%b", cmd_valid);
            end

            i++;
        end

        $display("Keyboard Tests Completed.");
        $stop;
    end

endmodule