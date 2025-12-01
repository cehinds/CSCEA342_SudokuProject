`timescale 1ns / 1ps

module tb_conditioner();

    logic clk, btn_in;
    logic conditioned_out, expected_out;

    logic [31:0] vectornum, errors, linenum;
    logic [2:0] testvectors[10000:0]; // Format: Btn_In Expected_Out

    conditioner uut (
        .clk(clk),
        .buttonPress(btn_in),
        .conditionedSignal(conditioned_out)
    );

    always begin
        clk = 0; #5; clk = 1; #5;
    end

    initial begin
        $readmemb("conditioner.tv", testvectors);
        vectornum = 0; errors = 0; linenum = 1;
    end

    always @(negedge clk) begin
        #1;
        {btn_in, expected_out} = testvectors[vectornum];
    end

    always @(posedge clk) begin
        #1;
        if (conditioned_out !== expected_out) begin
            $display("Error at vector %d: Input=%b | Output=%b | Expected=%b", 
                     vectornum, btn_in, conditioned_out, expected_out);
            errors = errors + 1;
        end
        
        vectornum = vectornum + 1;
        
        if (testvectors[vectornum] === 3'bx) begin
            $display("Tests completed with %d errors", errors);
            $finish;
        end
    end

endmodule