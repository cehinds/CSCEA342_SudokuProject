module ps2_host(
    input  logic       clk,
    input  logic       reset,
    input  logic       ps2_clk,
    input  logic       ps2_data,
    output logic [7:0] rx_data,
    output logic       rx_ready
);

    // Synchronizers
    logic ps2_clk_sync_1, ps2_clk_sync_2;
    logic ps2_data_sync_1, ps2_data_sync_2;

    always_ff @(posedge clk) begin
        ps2_clk_sync_1 <= ps2_clk;
        ps2_clk_sync_2 <= ps2_clk_sync_1;
        
        ps2_data_sync_1 <= ps2_data;
        ps2_data_sync_2 <= ps2_data_sync_1;
    end

    // Falling edge detection
    logic ps2_clk_prev;
    logic ps2_clk_negedge;
    
    always_ff @(posedge clk) begin
        ps2_clk_prev <= ps2_clk_sync_2;
    end
    
    assign ps2_clk_negedge = (ps2_clk_prev && !ps2_clk_sync_2);

    // Shift register and bit counter
    logic [10:0] shift_reg;
    logic [3:0]  bit_count;

    always_ff @(posedge clk) begin
        if (reset) begin
            bit_count <= 0;
            rx_ready  <= 0;
            rx_data   <= 0;
        end else begin
            rx_ready <= 0;

            if (ps2_clk_negedge) begin
                shift_reg <= {ps2_data_sync_2, shift_reg[10:1]};
                
                if (bit_count == 10) begin
                    bit_count <= 0;
                    if (shift_reg[0] == 0 && ps2_data_sync_2 == 1) begin
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
