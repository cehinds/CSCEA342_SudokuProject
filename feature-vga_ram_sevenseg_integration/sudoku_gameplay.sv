`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
// 
// Module Name: sudoku_gameplay
// Description: Handles cursor movement and number entry during gameplay
//////////////////////////////////////////////////////////////////////////////////

module sudoku_gameplay(
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,              // Only active during play state
    
    // Button inputs (active for one cycle)
    input  logic        btn_up,
    input  logic        btn_down,
    input  logic        btn_left,
    input  logic        btn_right,
    input  logic [3:0]  number_in,           // Number to enter (1-9, 0=none)
    
    // Current cell info from RAM
    input  logic [3:0]  cell_value,          // Current value at cursor
    input  logic        cell_fixed,          // Is current cell fixed?
    
    // Cursor position
    output logic [3:0]  cursor_x,            // Column (0-8)
    output logic [3:0]  cursor_y,            // Row (0-8)
    output logic [6:0]  cursor_adr,          // Linear address (0-80)
    
    // RAM write interface for grid
    output logic        grid_we,
    output logic [6:0]  grid_adr,
    output logic [3:0]  grid_din,
    
    // Shadow register write interface
    output logic        shadow_we,
    output logic [6:0]  shadow_adr,
    output logic [3:0]  shadow_grid_din,
    
    // Current value output
    output logic [3:0]  current_val,
    output logic        current_fixed
);

    // Cursor position registers
    logic [3:0] cursor_x_reg;
    logic [3:0] cursor_y_reg;

    assign cursor_x = cursor_x_reg;
    assign cursor_y = cursor_y_reg;
    assign cursor_adr = cursor_y_reg * 7'd9 + cursor_x_reg;

    // Current cell tracking
    logic [3:0] current_val_reg;
    logic       current_fixed_reg;
    
    assign current_val = current_val_reg;
    assign current_fixed = current_fixed_reg;

    // Cursor movement logic
    always_ff @(posedge clk) begin
        if (reset) begin
            cursor_x_reg <= 4'd0;
            cursor_y_reg <= 4'd0;
            current_val_reg <= 4'd0;
            current_fixed_reg <= 1'b0;
        end
        else if (enable) begin
            // Update current cell info from RAM
            current_val_reg   <= cell_value;
            current_fixed_reg <= cell_fixed;
            
            // Cursor movement with wrap-around
            if (btn_up)
                cursor_y_reg <= (cursor_y_reg == 4'd0) ? 4'd8 : cursor_y_reg - 4'd1;
            
            if (btn_down)
                cursor_y_reg <= (cursor_y_reg == 4'd8) ? 4'd0 : cursor_y_reg + 4'd1;
            
            if (btn_left)
                cursor_x_reg <= (cursor_x_reg == 4'd0) ? 4'd8 : cursor_x_reg - 4'd1;
            
            if (btn_right)
                cursor_x_reg <= (cursor_x_reg == 4'd8) ? 4'd0 : cursor_x_reg + 4'd1;
        end
    end

    // Number entry logic (combinational)
    always_comb begin
        // Defaults
        grid_we         = 1'b0;
        grid_adr        = cursor_adr;
        grid_din        = 4'd0;
        shadow_we       = 1'b0;
        shadow_adr      = cursor_adr;
        shadow_grid_din = 4'd0;

        // Write number if valid and cell is not fixed
        if (enable && number_in != 4'd0 && !current_fixed_reg) begin
            grid_we         = 1'b1;
            grid_adr        = cursor_adr;
            grid_din        = number_in;
            shadow_we       = 1'b1;
            shadow_adr      = cursor_adr;
            shadow_grid_din = number_in;
        end
    end

endmodule