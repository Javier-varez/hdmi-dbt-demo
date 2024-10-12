module tmds_encoder(
    input logic [7:0] data,
    input logic [1:0] control_data,
    input logic blanking,
    output logic [9:0] encoded_data,
    input logic pix_clock,
    input logic reset
    );

    logic [7:0] balance;

    logic [8:0] q_m;
    logic [9:0] q_out;
    logic [7:0] xor_out, xnor_out;

    logic [3:0] n_ones, n_ones_q_m, n_zeros_q_m;
    logic balanced;
    logic invert;

    assign n_ones = data[0] + data[1] + data[2] + data[3] + data[4] + data[5] + data[6] + data[7];

    assign xor_out[0] = data[0];
    assign xor_out[1] = xor_out[0] ^ data[1];
    assign xor_out[2] = xor_out[1] ^ data[2];
    assign xor_out[3] = xor_out[2] ^ data[3];
    assign xor_out[4] = xor_out[3] ^ data[4];
    assign xor_out[5] = xor_out[4] ^ data[5];
    assign xor_out[6] = xor_out[5] ^ data[6];
    assign xor_out[7] = xor_out[6] ^ data[7];

    assign xnor_out[0] = data[0];
    assign xnor_out[1] = ~(xnor_out[0] ^ data[1]);
    assign xnor_out[2] = ~(xnor_out[1] ^ data[2]);
    assign xnor_out[3] = ~(xnor_out[2] ^ data[3]);
    assign xnor_out[4] = ~(xnor_out[3] ^ data[4]);
    assign xnor_out[5] = ~(xnor_out[4] ^ data[5]);
    assign xnor_out[6] = ~(xnor_out[5] ^ data[6]);
    assign xnor_out[7] = ~(xnor_out[6] ^ data[7]);

    assign q_m[8:0] = ((n_ones > 4'd4) || ((n_ones == 4'd4) && data[0] == 0)) ? { 1'b0, xnor_out[7:0] } : { 1'b1, xor_out[7:0] };

    assign n_ones_q_m = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7];
    assign n_zeros_q_m = 8 - n_ones_q_m;

    assign balanced = (n_ones_q_m == 4'd4) || (balance == 8'd0);

    assign invert = ((n_ones_q_m > 4'd4) && ~balance[7]) || ((n_ones_q_m <= 4'd4) && balance[7]);

    always_comb
        if (balanced)
            q_out[9:0] = {~q_m[8], q_m[8], (q_m[7:0] ^ {8{~q_m[8]}}) };
        else
            q_out[9:0] = { invert, q_m[8], (q_m[7:0] ^ {8{invert}}) };

    always_ff @(posedge pix_clock)
        if (reset || blanking)
            balance <= 0;
        else if (balanced)
            if (q_m[8] == 0)
                balance <= balance + (n_zeros_q_m - n_ones_q_m);
            else
                balance <= balance + (n_ones_q_m - n_zeros_q_m);
        else if (invert)
            balance <= balance + {6'b0, q_m[8], 1'b0} + { 4'b0, n_zeros_q_m } - { 4'b0, n_ones_q_m };
        else
            balance <= balance - {6'b0, ~q_m[8], 1'b0} - { 4'b0, n_zeros_q_m } + { 4'b0, n_ones_q_m };

    always_comb
        if (blanking)
            case (control_data)
                2'b00:
                    encoded_data[9:0] = 10'b1101010100;
                2'b01:
                    encoded_data[9:0] = 10'b0010101011;
                2'b10:
                    encoded_data[9:0] = 10'b0101010100;
                2'b11:
                    encoded_data[9:0] = 10'b1010101011;
            endcase
        else
            encoded_data[9:0] = q_out[9:0];

endmodule
