// Input sys_clk = 100 MHz
// Output pix_clk = 74.25 MHz
// Output serial_clk = 371.25 MHz
module video_mmcm(
    output        serial_clk,
    output        pix_clk,
    input         sys_clk
    );

    logic sys_clk_buffered;

    IBUF sys_clk_buffer(
        .O(sys_clk_buffered),
        .I(sys_clk)
    );

    logic        serial_clk_unbuffered;
    logic        pix_clk_unbuffered;

    logic        clkfbout_unbuffered;
    logic        clkfbout_buffered;

    MMCME2_BASE #(
        .DIVCLK_DIVIDE(5),
        .CLKFBOUT_MULT_F(37.125), // VCO frequency = 100 MHz * 37.125 / 5 = 742.5 MHz
        .CLKOUT0_DIVIDE_F(2.0), // serial_clk = 742.5 MHz / 3 = 371.25 MHz
        .CLKOUT1_DIVIDE(10), // pix_clk = 742.5 MHz / 3 = 74.25 MHz
        .CLKIN1_PERIOD(10.0) // 10 ns
    ) mmcm (
        .CLKOUT0(serial_clk_unbuffered),
        .CLKOUT1(pix_clk_unbuffered),

        // Feedback network of the VCO
        .CLKFBOUT(clkfbout_unbuffered),
        .CLKFBIN(clkfbout_buffered),

        .CLKIN1(sys_clk_buffered),

        .PWRDWN(1'b0),
        .RST(1'b0)
    );

    BUFG clkfbout_buffer(
        .O(clkfbout_buffered),
        .I(clkfbout_unbuffered)
    );

    BUFG serial_clk_buffer(
        .O(serial_clk),
        .I(serial_clk_unbuffered)
    );

    BUFG pix_clk_buffer(
        .O(pix_clk),
        .I(pix_clk_unbuffered)
    );

endmodule
