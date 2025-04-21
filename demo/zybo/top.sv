module top(
    input sys_clk,
    input reset,
    output [2:0] hdmi_d_p,
    output [2:0] hdmi_d_n,
    output hdmi_clk_p,
    output hdmi_clk_n,
    output hdmi_out_en);

    wire pix_clk;
    wire serial_clk;

    assign hdmi_out_en = 1'b1;

    video_mmcm pix_clk_gen(
        .pix_clk(pix_clk),
        .serial_clk(serial_clk),
        .sys_clk(sys_clk)
    );

    logic [9:0] row, column;

    hdmi #(
        // 1280 x 720 @ 60 fps
        // pix_clk 74.25 MHz
        // serial_clk 371.25 MHz
        .HACTIVE(1280),
        .HFPORCH(110),
        .HSYNC(40),
        .HBPORCH(220),
        .HSYNC_POL(1'b1),
        .VACTIVE(720),
        .VFPORCH(5),
        .VSYNC(5),
        .VBPORCH(20),
        .VSYNC_POL(1'b1)
    ) hdmi (
        .r(row[7:0]),
        .g(column[7:0]),
        .b(255 - row[7:1] - column[7:1]),
        .serial_clk(serial_clk),
        .pix_clk(pix_clk),
        .reset(reset),
        .ch_r_p(hdmi_d_p[2]),
        .ch_r_n(hdmi_d_n[2]),
        .ch_g_p(hdmi_d_p[1]),
        .ch_g_n(hdmi_d_n[1]),
        .ch_b_p(hdmi_d_p[0]),
        .ch_b_n(hdmi_d_n[0]),
        .clk_p(hdmi_clk_p),
        .clk_n(hdmi_clk_n),
        .row(row),
        .column(column)
    );

endmodule
