module reset#(
    parameter integer CYCLES = 100
)(
    input sys_clk,
    output reset
);

    localparam integer NUM_CNT_BITS = $clog2(CYCLES + 1);

    logic [NUM_CNT_BITS-1:0] counter;
    initial counter = 0;

    always_ff @(posedge sys_clk)
        if (counter < CYCLES)
            counter <= counter + 1;
        else
            counter <= counter;

    assign reset = counter < CYCLES;
endmodule
