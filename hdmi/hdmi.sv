module hdmi#(
    // 640 x 480 @ 60 fps
    // pix_clk 25.2 MHz
    // serial_clk 126 MHz
    parameter HACTIVE = 640,
    parameter HFPORCH = 16,
    parameter HSYNC = 96,
    parameter HBPORCH = 48,
    parameter HSYNC_POL = 1'b0,
    parameter VACTIVE = 480,
    parameter VFPORCH = 10,
    parameter VSYNC = 2,
    parameter VBPORCH = 33,
    parameter VSYNC_POL = 1'b0
)(
    input [7:0] r,
    input [7:0] g,
    input [7:0] b,
    input pix_clk,
    input serial_clk,
    input reset,
    output ch_r_p,
    output ch_r_n,
    output ch_g_p,
    output ch_g_n,
    output ch_b_p,
    output ch_b_n,
    output clk_p,
    output clk_n,
    output [15:0] row,
    output [15:0] column
);

    logic [15:0] hcounter, vcounter;
    logic hsync, vsync;

    logic [9:0] encoded_r, encoded_g, encoded_b;

    wire hs_clk;

    localparam HTOTAL = HACTIVE + HFPORCH + HSYNC + HBPORCH;
    localparam VTOTAL = VACTIVE + VFPORCH + VSYNC + VBPORCH;

    always_ff @(posedge pix_clk)
        if (reset || (hcounter == (HTOTAL-1)))
            hcounter <= 0;
        else
            hcounter <= hcounter + 16'd1;

    always_ff @(posedge pix_clk)
        if (reset)
            vcounter <= 0;
        else if (hcounter == (HTOTAL-1))
            if (vcounter == (VTOTAL-1))
                vcounter <= 0;
            else
                vcounter <= vcounter + 16'd1;
        else
            vcounter <= vcounter;

    localparam HSYNC_BEGIN = HACTIVE + HFPORCH;
    localparam HSYNC_END = HACTIVE + HFPORCH + HSYNC;
    localparam VSYNC_BEGIN = VACTIVE + VFPORCH;
    localparam VSYNC_END = VACTIVE + VFPORCH + VSYNC;

    assign hsync = ((vcounter >= HSYNC_BEGIN) && (vcounter < HSYNC_END)) ? HSYNC_POL : ~HSYNC_POL;
    assign vsync = ((hcounter >= VSYNC_BEGIN) && (hcounter < VSYNC_END)) ? VSYNC_POL : ~VSYNC_POL;
    assign disp_en = (vcounter < VACTIVE) && (hcounter < HACTIVE);

    assign row = vcounter;
    assign column = hcounter;

    tmds_encoder red_channel(
        .data(r),
        .control_data(2'b0),
        .blanking(~disp_en),
        .encoded_data(encoded_r),
        .pix_clock(pix_clk),
        .reset(reset)
    );

    tmds_encoder green_channel(
        .data(g),
        .control_data(2'b0),
        .blanking(~disp_en),
        .encoded_data(encoded_g),
        .pix_clock(pix_clk),
        .reset(reset)
    );

    tmds_encoder blue_channel(
        .data(b),
        .control_data({vsync, hsync}),
        .blanking(~disp_en),
        .encoded_data(encoded_b),
        .pix_clock(pix_clk),
        .reset(reset)
    );

    serializer red_ch_serializer (
        .data(encoded_r),
        .out_p(ch_r_p),
        .out_n(ch_r_n),
        .pix_clk(pix_clk),
        .serial_clk(serial_clk),
        .reset(reset)
    );

    serializer green_ch_serializer (
        .data(encoded_g),
        .out_p(ch_g_p),
        .out_n(ch_g_n),
        .pix_clk(pix_clk),
        .serial_clk(serial_clk),
        .reset(reset)
    );

    serializer blue_ch_serializer (
        .data(encoded_b),
        .out_p(ch_b_p),
        .out_n(ch_b_n),
        .pix_clk(pix_clk),
        .serial_clk(serial_clk),
        .reset(reset)
    );

    serializer clk_serializer (
        .data(10'b1111100000),
        .out_p(clk_p),
        .out_n(clk_n),
        .pix_clk(pix_clk),
        .serial_clk(serial_clk),
        .reset(reset)
    );

endmodule
