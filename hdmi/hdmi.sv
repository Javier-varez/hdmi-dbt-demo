module hdmi#(
    // 640 x 480 @ 60 fps
    // pix_clk 25.2 MHz
    // serial_clk 126 MHz
    parameter integer HACTIVE = 640,
    parameter integer HFPORCH = 16,
    parameter integer HSYNC = 96,
    parameter integer HBPORCH = 48,
    parameter logic HSYNC_POL = 1'b0,
    parameter integer VACTIVE = 480,
    parameter integer VFPORCH = 10,
    parameter integer VSYNC = 2,
    parameter integer VBPORCH = 33,
    parameter logic VSYNC_POL = 1'b0
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

    localparam integer Htotal = HACTIVE + HFPORCH + HSYNC + HBPORCH;
    localparam integer Vtotal = VACTIVE + VFPORCH + VSYNC + VBPORCH;

    always_ff @(posedge pix_clk)
        if (reset || (hcounter == (Htotal-1)))
            hcounter <= 0;
        else
            hcounter <= hcounter + 16'd1;

    always_ff @(posedge pix_clk)
        if (reset)
            vcounter <= 0;
        else if (hcounter == (Htotal-1))
            if (vcounter == (Vtotal-1))
                vcounter <= 0;
            else
                vcounter <= vcounter + 16'd1;
        else
            vcounter <= vcounter;

    localparam integer HsyncBegin = HACTIVE + HFPORCH;
    localparam integer HsyncEnd = HACTIVE + HFPORCH + HSYNC;
    localparam integer VsyncBegin = VACTIVE + VFPORCH;
    localparam integer VsyncEnd = VACTIVE + VFPORCH + VSYNC;

    assign hsync = ((vcounter >= HsyncBegin) && (vcounter < HsyncEnd)) ? HSYNC_POL : ~HSYNC_POL;
    assign vsync = ((hcounter >= VsyncBegin) && (hcounter < VsyncEnd)) ? VSYNC_POL : ~VSYNC_POL;
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
