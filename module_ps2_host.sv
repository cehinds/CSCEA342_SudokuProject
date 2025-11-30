module ps2_host(
    input  logic       clk,
    input  logic       reset,
    input  logic       ps2_clk,
    input  logic       ps2_data,
    output logic [7:0] rx_data,     // The 8-bit scancode received
    output logic       rx_ready     // Pulse when a new byte is valid
);

    // --- Synchronization (The Fix) ---
    logic [1:0] ps2_clk_sync;
    logic [1:0] ps2_data_sync;

    always_ff @(posedge clk) begin
        ps2_clk_sync  <= {ps2_clk_sync[0], ps2_clk};
        ps2_data_sync <= {ps2_data_sync[0], ps2_data};
    end

    // Falling edge detection on the synchronized clock
    logic ps2_clk_negedge;
    assign ps2_clk_negedge = (ps2_clk_sync[1] && !ps2_clk_sync[0]);

    // --- Serial Deserialization ---
    logic [10:0] shift_reg;
    logic [3:0]  bit_count;

    always_ff @(posedge clk) begin
        if (reset) begin
            bit_count <= 0;
            rx_ready  <= 0;
            rx_data   <= 0;
        end else begin
            rx_ready <= 0; // Default pulse low

            if (ps2_clk_negedge) begin
                shift_reg <= {ps2_data_sync[1], shift_reg[10:1]};
                
                if (bit_count == 10) begin
                    bit_count <= 0;
                    // Check Start bit (0) and Stop bit (1) for basic integrity
                    if (shift_reg[0] == 0 && ps2_data_sync[1] == 1) begin
                        rx_data <= shift_reg[8:1];
                        rx_ready <= 1;
                    end
                end else begin
                    bit_count <= bit_count + 1;
                end
            end
        end
    end
endmodule
