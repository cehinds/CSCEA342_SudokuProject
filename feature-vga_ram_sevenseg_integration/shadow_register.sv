`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UAA Digital Circuits A342
// Engineers: Gwendolyn Beecher, Constantine Hinds
// 
// Module Name: shadow_register
// Description: Shadow registers for VGA display - stores grid and fixed mask
//              values that can be read simultaneously by the VGA controller
//////////////////////////////////////////////////////////////////////////////////

module shadow_register(
    input  logic        clk,
    input  logic        we,              // Write enable
    input  logic [6:0]  write_adr,       // Write address (0-80)
    input  logic [3:0]  grid_din,        // Grid data in
    input  logic        mask_din,        // Fixed mask data in
    
    // Full grid outputs for VGA
    output logic [3:0]  grid_out       [0:8][0:8],
    output logic        fixed_mask_out [0:8][0:8]
);

    // Internal shadow registers
    logic [3:0] grid_shadow       [0:8][0:8];
    logic       fixed_mask_shadow [0:8][0:8];

    // Write logic using case statement
    always_ff @(posedge clk) begin
        if (we) begin
            case (write_adr)
                7'd0:  begin grid_shadow[0][0] <= grid_din; fixed_mask_shadow[0][0] <= mask_din; end
                7'd1:  begin grid_shadow[0][1] <= grid_din; fixed_mask_shadow[0][1] <= mask_din; end
                7'd2:  begin grid_shadow[0][2] <= grid_din; fixed_mask_shadow[0][2] <= mask_din; end
                7'd3:  begin grid_shadow[0][3] <= grid_din; fixed_mask_shadow[0][3] <= mask_din; end
                7'd4:  begin grid_shadow[0][4] <= grid_din; fixed_mask_shadow[0][4] <= mask_din; end
                7'd5:  begin grid_shadow[0][5] <= grid_din; fixed_mask_shadow[0][5] <= mask_din; end
                7'd6:  begin grid_shadow[0][6] <= grid_din; fixed_mask_shadow[0][6] <= mask_din; end
                7'd7:  begin grid_shadow[0][7] <= grid_din; fixed_mask_shadow[0][7] <= mask_din; end
                7'd8:  begin grid_shadow[0][8] <= grid_din; fixed_mask_shadow[0][8] <= mask_din; end
                7'd9:  begin grid_shadow[1][0] <= grid_din; fixed_mask_shadow[1][0] <= mask_din; end
                7'd10: begin grid_shadow[1][1] <= grid_din; fixed_mask_shadow[1][1] <= mask_din; end
                7'd11: begin grid_shadow[1][2] <= grid_din; fixed_mask_shadow[1][2] <= mask_din; end
                7'd12: begin grid_shadow[1][3] <= grid_din; fixed_mask_shadow[1][3] <= mask_din; end
                7'd13: begin grid_shadow[1][4] <= grid_din; fixed_mask_shadow[1][4] <= mask_din; end
                7'd14: begin grid_shadow[1][5] <= grid_din; fixed_mask_shadow[1][5] <= mask_din; end
                7'd15: begin grid_shadow[1][6] <= grid_din; fixed_mask_shadow[1][6] <= mask_din; end
                7'd16: begin grid_shadow[1][7] <= grid_din; fixed_mask_shadow[1][7] <= mask_din; end
                7'd17: begin grid_shadow[1][8] <= grid_din; fixed_mask_shadow[1][8] <= mask_din; end
                7'd18: begin grid_shadow[2][0] <= grid_din; fixed_mask_shadow[2][0] <= mask_din; end
                7'd19: begin grid_shadow[2][1] <= grid_din; fixed_mask_shadow[2][1] <= mask_din; end
                7'd20: begin grid_shadow[2][2] <= grid_din; fixed_mask_shadow[2][2] <= mask_din; end
                7'd21: begin grid_shadow[2][3] <= grid_din; fixed_mask_shadow[2][3] <= mask_din; end
                7'd22: begin grid_shadow[2][4] <= grid_din; fixed_mask_shadow[2][4] <= mask_din; end
                7'd23: begin grid_shadow[2][5] <= grid_din; fixed_mask_shadow[2][5] <= mask_din; end
                7'd24: begin grid_shadow[2][6] <= grid_din; fixed_mask_shadow[2][6] <= mask_din; end
                7'd25: begin grid_shadow[2][7] <= grid_din; fixed_mask_shadow[2][7] <= mask_din; end
                7'd26: begin grid_shadow[2][8] <= grid_din; fixed_mask_shadow[2][8] <= mask_din; end
                7'd27: begin grid_shadow[3][0] <= grid_din; fixed_mask_shadow[3][0] <= mask_din; end
                7'd28: begin grid_shadow[3][1] <= grid_din; fixed_mask_shadow[3][1] <= mask_din; end
                7'd29: begin grid_shadow[3][2] <= grid_din; fixed_mask_shadow[3][2] <= mask_din; end
                7'd30: begin grid_shadow[3][3] <= grid_din; fixed_mask_shadow[3][3] <= mask_din; end
                7'd31: begin grid_shadow[3][4] <= grid_din; fixed_mask_shadow[3][4] <= mask_din; end
                7'd32: begin grid_shadow[3][5] <= grid_din; fixed_mask_shadow[3][5] <= mask_din; end
                7'd33: begin grid_shadow[3][6] <= grid_din; fixed_mask_shadow[3][6] <= mask_din; end
                7'd34: begin grid_shadow[3][7] <= grid_din; fixed_mask_shadow[3][7] <= mask_din; end
                7'd35: begin grid_shadow[3][8] <= grid_din; fixed_mask_shadow[3][8] <= mask_din; end
                7'd36: begin grid_shadow[4][0] <= grid_din; fixed_mask_shadow[4][0] <= mask_din; end
                7'd37: begin grid_shadow[4][1] <= grid_din; fixed_mask_shadow[4][1] <= mask_din; end
                7'd38: begin grid_shadow[4][2] <= grid_din; fixed_mask_shadow[4][2] <= mask_din; end
                7'd39: begin grid_shadow[4][3] <= grid_din; fixed_mask_shadow[4][3] <= mask_din; end
                7'd40: begin grid_shadow[4][4] <= grid_din; fixed_mask_shadow[4][4] <= mask_din; end
                7'd41: begin grid_shadow[4][5] <= grid_din; fixed_mask_shadow[4][5] <= mask_din; end
                7'd42: begin grid_shadow[4][6] <= grid_din; fixed_mask_shadow[4][6] <= mask_din; end
                7'd43: begin grid_shadow[4][7] <= grid_din; fixed_mask_shadow[4][7] <= mask_din; end
                7'd44: begin grid_shadow[4][8] <= grid_din; fixed_mask_shadow[4][8] <= mask_din; end
                7'd45: begin grid_shadow[5][0] <= grid_din; fixed_mask_shadow[5][0] <= mask_din; end
                7'd46: begin grid_shadow[5][1] <= grid_din; fixed_mask_shadow[5][1] <= mask_din; end
                7'd47: begin grid_shadow[5][2] <= grid_din; fixed_mask_shadow[5][2] <= mask_din; end
                7'd48: begin grid_shadow[5][3] <= grid_din; fixed_mask_shadow[5][3] <= mask_din; end
                7'd49: begin grid_shadow[5][4] <= grid_din; fixed_mask_shadow[5][4] <= mask_din; end
                7'd50: begin grid_shadow[5][5] <= grid_din; fixed_mask_shadow[5][5] <= mask_din; end
                7'd51: begin grid_shadow[5][6] <= grid_din; fixed_mask_shadow[5][6] <= mask_din; end
                7'd52: begin grid_shadow[5][7] <= grid_din; fixed_mask_shadow[5][7] <= mask_din; end
                7'd53: begin grid_shadow[5][8] <= grid_din; fixed_mask_shadow[5][8] <= mask_din; end
                7'd54: begin grid_shadow[6][0] <= grid_din; fixed_mask_shadow[6][0] <= mask_din; end
                7'd55: begin grid_shadow[6][1] <= grid_din; fixed_mask_shadow[6][1] <= mask_din; end
                7'd56: begin grid_shadow[6][2] <= grid_din; fixed_mask_shadow[6][2] <= mask_din; end
                7'd57: begin grid_shadow[6][3] <= grid_din; fixed_mask_shadow[6][3] <= mask_din; end
                7'd58: begin grid_shadow[6][4] <= grid_din; fixed_mask_shadow[6][4] <= mask_din; end
                7'd59: begin grid_shadow[6][5] <= grid_din; fixed_mask_shadow[6][5] <= mask_din; end
                7'd60: begin grid_shadow[6][6] <= grid_din; fixed_mask_shadow[6][6] <= mask_din; end
                7'd61: begin grid_shadow[6][7] <= grid_din; fixed_mask_shadow[6][7] <= mask_din; end
                7'd62: begin grid_shadow[6][8] <= grid_din; fixed_mask_shadow[6][8] <= mask_din; end
                7'd63: begin grid_shadow[7][0] <= grid_din; fixed_mask_shadow[7][0] <= mask_din; end
                7'd64: begin grid_shadow[7][1] <= grid_din; fixed_mask_shadow[7][1] <= mask_din; end
                7'd65: begin grid_shadow[7][2] <= grid_din; fixed_mask_shadow[7][2] <= mask_din; end
                7'd66: begin grid_shadow[7][3] <= grid_din; fixed_mask_shadow[7][3] <= mask_din; end
                7'd67: begin grid_shadow[7][4] <= grid_din; fixed_mask_shadow[7][4] <= mask_din; end
                7'd68: begin grid_shadow[7][5] <= grid_din; fixed_mask_shadow[7][5] <= mask_din; end
                7'd69: begin grid_shadow[7][6] <= grid_din; fixed_mask_shadow[7][6] <= mask_din; end
                7'd70: begin grid_shadow[7][7] <= grid_din; fixed_mask_shadow[7][7] <= mask_din; end
                7'd71: begin grid_shadow[7][8] <= grid_din; fixed_mask_shadow[7][8] <= mask_din; end
                7'd72: begin grid_shadow[8][0] <= grid_din; fixed_mask_shadow[8][0] <= mask_din; end
                7'd73: begin grid_shadow[8][1] <= grid_din; fixed_mask_shadow[8][1] <= mask_din; end
                7'd74: begin grid_shadow[8][2] <= grid_din; fixed_mask_shadow[8][2] <= mask_din; end
                7'd75: begin grid_shadow[8][3] <= grid_din; fixed_mask_shadow[8][3] <= mask_din; end
                7'd76: begin grid_shadow[8][4] <= grid_din; fixed_mask_shadow[8][4] <= mask_din; end
                7'd77: begin grid_shadow[8][5] <= grid_din; fixed_mask_shadow[8][5] <= mask_din; end
                7'd78: begin grid_shadow[8][6] <= grid_din; fixed_mask_shadow[8][6] <= mask_din; end
                7'd79: begin grid_shadow[8][7] <= grid_din; fixed_mask_shadow[8][7] <= mask_din; end
                7'd80: begin grid_shadow[8][8] <= grid_din; fixed_mask_shadow[8][8] <= mask_din; end
                default: ; // Do nothing
            endcase
        end
    end

    // Drive outputs from shadow registers (directly wired)
    // Row 0
    assign grid_out[0][0] = grid_shadow[0][0];
    assign grid_out[0][1] = grid_shadow[0][1];
    assign grid_out[0][2] = grid_shadow[0][2];
    assign grid_out[0][3] = grid_shadow[0][3];
    assign grid_out[0][4] = grid_shadow[0][4];
    assign grid_out[0][5] = grid_shadow[0][5];
    assign grid_out[0][6] = grid_shadow[0][6];
    assign grid_out[0][7] = grid_shadow[0][7];
    assign grid_out[0][8] = grid_shadow[0][8];
    // Row 1
    assign grid_out[1][0] = grid_shadow[1][0];
    assign grid_out[1][1] = grid_shadow[1][1];
    assign grid_out[1][2] = grid_shadow[1][2];
    assign grid_out[1][3] = grid_shadow[1][3];
    assign grid_out[1][4] = grid_shadow[1][4];
    assign grid_out[1][5] = grid_shadow[1][5];
    assign grid_out[1][6] = grid_shadow[1][6];
    assign grid_out[1][7] = grid_shadow[1][7];
    assign grid_out[1][8] = grid_shadow[1][8];
    // Row 2
    assign grid_out[2][0] = grid_shadow[2][0];
    assign grid_out[2][1] = grid_shadow[2][1];
    assign grid_out[2][2] = grid_shadow[2][2];
    assign grid_out[2][3] = grid_shadow[2][3];
    assign grid_out[2][4] = grid_shadow[2][4];
    assign grid_out[2][5] = grid_shadow[2][5];
    assign grid_out[2][6] = grid_shadow[2][6];
    assign grid_out[2][7] = grid_shadow[2][7];
    assign grid_out[2][8] = grid_shadow[2][8];
    // Row 3
    assign grid_out[3][0] = grid_shadow[3][0];
    assign grid_out[3][1] = grid_shadow[3][1];
    assign grid_out[3][2] = grid_shadow[3][2];
    assign grid_out[3][3] = grid_shadow[3][3];
    assign grid_out[3][4] = grid_shadow[3][4];
    assign grid_out[3][5] = grid_shadow[3][5];
    assign grid_out[3][6] = grid_shadow[3][6];
    assign grid_out[3][7] = grid_shadow[3][7];
    assign grid_out[3][8] = grid_shadow[3][8];
    // Row 4
    assign grid_out[4][0] = grid_shadow[4][0];
    assign grid_out[4][1] = grid_shadow[4][1];
    assign grid_out[4][2] = grid_shadow[4][2];
    assign grid_out[4][3] = grid_shadow[4][3];
    assign grid_out[4][4] = grid_shadow[4][4];
    assign grid_out[4][5] = grid_shadow[4][5];
    assign grid_out[4][6] = grid_shadow[4][6];
    assign grid_out[4][7] = grid_shadow[4][7];
    assign grid_out[4][8] = grid_shadow[4][8];
    // Row 5
    assign grid_out[5][0] = grid_shadow[5][0];
    assign grid_out[5][1] = grid_shadow[5][1];
    assign grid_out[5][2] = grid_shadow[5][2];
    assign grid_out[5][3] = grid_shadow[5][3];
    assign grid_out[5][4] = grid_shadow[5][4];
    assign grid_out[5][5] = grid_shadow[5][5];
    assign grid_out[5][6] = grid_shadow[5][6];
    assign grid_out[5][7] = grid_shadow[5][7];
    assign grid_out[5][8] = grid_shadow[5][8];
    // Row 6
    assign grid_out[6][0] = grid_shadow[6][0];
    assign grid_out[6][1] = grid_shadow[6][1];
    assign grid_out[6][2] = grid_shadow[6][2];
    assign grid_out[6][3] = grid_shadow[6][3];
    assign grid_out[6][4] = grid_shadow[6][4];
    assign grid_out[6][5] = grid_shadow[6][5];
    assign grid_out[6][6] = grid_shadow[6][6];
    assign grid_out[6][7] = grid_shadow[6][7];
    assign grid_out[6][8] = grid_shadow[6][8];
    // Row 7
    assign grid_out[7][0] = grid_shadow[7][0];
    assign grid_out[7][1] = grid_shadow[7][1];
    assign grid_out[7][2] = grid_shadow[7][2];
    assign grid_out[7][3] = grid_shadow[7][3];
    assign grid_out[7][4] = grid_shadow[7][4];
    assign grid_out[7][5] = grid_shadow[7][5];
    assign grid_out[7][6] = grid_shadow[7][6];
    assign grid_out[7][7] = grid_shadow[7][7];
    assign grid_out[7][8] = grid_shadow[7][8];
    // Row 8
    assign grid_out[8][0] = grid_shadow[8][0];
    assign grid_out[8][1] = grid_shadow[8][1];
    assign grid_out[8][2] = grid_shadow[8][2];
    assign grid_out[8][3] = grid_shadow[8][3];
    assign grid_out[8][4] = grid_shadow[8][4];
    assign grid_out[8][5] = grid_shadow[8][5];
    assign grid_out[8][6] = grid_shadow[8][6];
    assign grid_out[8][7] = grid_shadow[8][7];
    assign grid_out[8][8] = grid_shadow[8][8];

    // Fixed mask outputs
    // Row 0
    assign fixed_mask_out[0][0] = fixed_mask_shadow[0][0];
    assign fixed_mask_out[0][1] = fixed_mask_shadow[0][1];
    assign fixed_mask_out[0][2] = fixed_mask_shadow[0][2];
    assign fixed_mask_out[0][3] = fixed_mask_shadow[0][3];
    assign fixed_mask_out[0][4] = fixed_mask_shadow[0][4];
    assign fixed_mask_out[0][5] = fixed_mask_shadow[0][5];
    assign fixed_mask_out[0][6] = fixed_mask_shadow[0][6];
    assign fixed_mask_out[0][7] = fixed_mask_shadow[0][7];
    assign fixed_mask_out[0][8] = fixed_mask_shadow[0][8];
    // Row 1
    assign fixed_mask_out[1][0] = fixed_mask_shadow[1][0];
    assign fixed_mask_out[1][1] = fixed_mask_shadow[1][1];
    assign fixed_mask_out[1][2] = fixed_mask_shadow[1][2];
    assign fixed_mask_out[1][3] = fixed_mask_shadow[1][3];
    assign fixed_mask_out[1][4] = fixed_mask_shadow[1][4];
    assign fixed_mask_out[1][5] = fixed_mask_shadow[1][5];
    assign fixed_mask_out[1][6] = fixed_mask_shadow[1][6];
    assign fixed_mask_out[1][7] = fixed_mask_shadow[1][7];
    assign fixed_mask_out[1][8] = fixed_mask_shadow[1][8];
    // Row 2
    assign fixed_mask_out[2][0] = fixed_mask_shadow[2][0];
    assign fixed_mask_out[2][1] = fixed_mask_shadow[2][1];
    assign fixed_mask_out[2][2] = fixed_mask_shadow[2][2];
    assign fixed_mask_out[2][3] = fixed_mask_shadow[2][3];
    assign fixed_mask_out[2][4] = fixed_mask_shadow[2][4];
    assign fixed_mask_out[2][5] = fixed_mask_shadow[2][5];
    assign fixed_mask_out[2][6] = fixed_mask_shadow[2][6];
    assign fixed_mask_out[2][7] = fixed_mask_shadow[2][7];
    assign fixed_mask_out[2][8] = fixed_mask_shadow[2][8];
    // Row 3
    assign fixed_mask_out[3][0] = fixed_mask_shadow[3][0];
    assign fixed_mask_out[3][1] = fixed_mask_shadow[3][1];
    assign fixed_mask_out[3][2] = fixed_mask_shadow[3][2];
    assign fixed_mask_out[3][3] = fixed_mask_shadow[3][3];
    assign fixed_mask_out[3][4] = fixed_mask_shadow[3][4];
    assign fixed_mask_out[3][5] = fixed_mask_shadow[3][5];
    assign fixed_mask_out[3][6] = fixed_mask_shadow[3][6];
    assign fixed_mask_out[3][7] = fixed_mask_shadow[3][7];
    assign fixed_mask_out[3][8] = fixed_mask_shadow[3][8];
    // Row 4
    assign fixed_mask_out[4][0] = fixed_mask_shadow[4][0];
    assign fixed_mask_out[4][1] = fixed_mask_shadow[4][1];
    assign fixed_mask_out[4][2] = fixed_mask_shadow[4][2];
    assign fixed_mask_out[4][3] = fixed_mask_shadow[4][3];
    assign fixed_mask_out[4][4] = fixed_mask_shadow[4][4];
    assign fixed_mask_out[4][5] = fixed_mask_shadow[4][5];
    assign fixed_mask_out[4][6] = fixed_mask_shadow[4][6];
    assign fixed_mask_out[4][7] = fixed_mask_shadow[4][7];
    assign fixed_mask_out[4][8] = fixed_mask_shadow[4][8];
    // Row 5
    assign fixed_mask_out[5][0] = fixed_mask_shadow[5][0];
    assign fixed_mask_out[5][1] = fixed_mask_shadow[5][1];
    assign fixed_mask_out[5][2] = fixed_mask_shadow[5][2];
    assign fixed_mask_out[5][3] = fixed_mask_shadow[5][3];
    assign fixed_mask_out[5][4] = fixed_mask_shadow[5][4];
    assign fixed_mask_out[5][5] = fixed_mask_shadow[5][5];
    assign fixed_mask_out[5][6] = fixed_mask_shadow[5][6];
    assign fixed_mask_out[5][7] = fixed_mask_shadow[5][7];
    assign fixed_mask_out[5][8] = fixed_mask_shadow[5][8];
    // Row 6
    assign fixed_mask_out[6][0] = fixed_mask_shadow[6][0];
    assign fixed_mask_out[6][1] = fixed_mask_shadow[6][1];
    assign fixed_mask_out[6][2] = fixed_mask_shadow[6][2];
    assign fixed_mask_out[6][3] = fixed_mask_shadow[6][3];
    assign fixed_mask_out[6][4] = fixed_mask_shadow[6][4];
    assign fixed_mask_out[6][5] = fixed_mask_shadow[6][5];
    assign fixed_mask_out[6][6] = fixed_mask_shadow[6][6];
    assign fixed_mask_out[6][7] = fixed_mask_shadow[6][7];
    assign fixed_mask_out[6][8] = fixed_mask_shadow[6][8];
    // Row 7
    assign fixed_mask_out[7][0] = fixed_mask_shadow[7][0];
    assign fixed_mask_out[7][1] = fixed_mask_shadow[7][1];
    assign fixed_mask_out[7][2] = fixed_mask_shadow[7][2];
    assign fixed_mask_out[7][3] = fixed_mask_shadow[7][3];
    assign fixed_mask_out[7][4] = fixed_mask_shadow[7][4];
    assign fixed_mask_out[7][5] = fixed_mask_shadow[7][5];
    assign fixed_mask_out[7][6] = fixed_mask_shadow[7][6];
    assign fixed_mask_out[7][7] = fixed_mask_shadow[7][7];
    assign fixed_mask_out[7][8] = fixed_mask_shadow[7][8];
    // Row 8
    assign fixed_mask_out[8][0] = fixed_mask_shadow[8][0];
    assign fixed_mask_out[8][1] = fixed_mask_shadow[8][1];
    assign fixed_mask_out[8][2] = fixed_mask_shadow[8][2];
    assign fixed_mask_out[8][3] = fixed_mask_shadow[8][3];
    assign fixed_mask_out[8][4] = fixed_mask_shadow[8][4];
    assign fixed_mask_out[8][5] = fixed_mask_shadow[8][5];
    assign fixed_mask_out[8][6] = fixed_mask_shadow[8][6];
    assign fixed_mask_out[8][7] = fixed_mask_shadow[8][7];
    assign fixed_mask_out[8][8] = fixed_mask_shadow[8][8];

endmodule