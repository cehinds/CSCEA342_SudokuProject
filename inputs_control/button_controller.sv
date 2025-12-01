module button_controller(
    input  logic clk,
    input  logic reset, // Not strictly used by conditioner, but good for consistent interface
    input  logic btn_raw,
    output logic btn_pulse
);

    logic conditioned_signal;
    logic signal_prev;

    // 1. Instantiate the provided Conditioner for debouncing
    conditioner DEBOUNCER (
        .clk(clk),
        .buttonPress(btn_raw),
        .conditionedSignal(conditioned_signal)
    );

    // 2. Edge Detector (Rise Detection)
    // Generates a single-cycle pulse when the conditioned signal goes from 0 to 1
    always_ff @(posedge clk) begin
        signal_prev <= conditioned_signal;
    end

    assign btn_pulse = (conditioned_signal && !signal_prev);

endmodule