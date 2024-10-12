module serializer(
    input [9:0] data,
    output out_p,
    output out_n,
    input pix_clk,
    input serial_clk,
    input reset
    );

    logic [1:0] shiftout;
    logic out;

    OSERDESE2
       # (
         .DATA_RATE_OQ   ("DDR"),
         .DATA_RATE_TQ   ("SDR"),
         .DATA_WIDTH     (10),
         .TRISTATE_WIDTH (1),
         .SERDES_MODE    ("MASTER"))
       oserdese2_master (
         .D1             (data[0]),
         .D2             (data[1]),
         .D3             (data[2]),
         .D4             (data[3]),
         .D5             (data[4]),
         .D6             (data[5]),
         .D7             (data[6]),
         .D8             (data[7]),
         .T1             (1'b0),
         .T2             (1'b0),
         .T3             (1'b0),
         .T4             (1'b0),
         .SHIFTIN1       (shiftout[0]),
         .SHIFTIN2       (shiftout[1]),
         .SHIFTOUT1      (),
         .SHIFTOUT2      (),
         .OCE            (1'b1),
         .CLK            (serial_clk),
         .CLKDIV         (pix_clk),
         .OQ             (out),
         .TQ             (),
         .OFB            (),
         .TFB            (),
         .TBYTEIN        (1'b0),
         .TBYTEOUT       (),
         .TCE            (1'b0),
         .RST            (reset));


     OSERDESE2
     #(
         .DATA_RATE_OQ   ("DDR"),
         .DATA_RATE_TQ   ("SDR"),
         .DATA_WIDTH     (10),
         .TRISTATE_WIDTH (1),
         .SERDES_MODE    ("SLAVE"))
     oserdese2_slave (
         .D1             (1'b0),
         .D2             (1'b0),
         .D3             (data[8]),
         .D4             (data[9]),
         .D5             (1'b0),
         .D6             (1'b0),
         .D7             (1'b0),
         .D8             (1'b0),
         .T1             (1'b0),
         .T2             (1'b0),
         .T3             (1'b0),
         .T4             (1'b0),
         .SHIFTOUT1      (shiftout[0]),
         .SHIFTOUT2      (shiftout[1]),
         .SHIFTIN1       (1'b0),
         .SHIFTIN2       (1'b0),
         .OCE            (1'b1),
         .CLK            (serial_clk),
         .CLKDIV         (pix_clk),
         .OQ             (),
         .TQ             (),
         .OFB            (),
         .TFB            (),
         .TBYTEIN        (1'b0),
         .TBYTEOUT       (),
         .TCE            (1'b0),
         .RST            (reset));

    OBUFDS
    #(.IOSTANDARD ("TMDS_33"))
    diff_buff(
        .O          (out_p),
        .OB         (out_n),
        .I          (out)
    );

endmodule
