
module cla4_cla2_rca (
    input  [5:0] x,
    input  [5:0] y,
    output [5:0] sum,
    output       cout
);

    wire [3:0] p4, g4;
    wire c1, c2, c3, c4;

    wire [1:0] p2, g2;
    wire c5, c6;

    // ------------------------------------------------
    // Lower 4-bit CLA (carry-in = 0)
    // ------------------------------------------------
    assign p4 = x[3:0] ^ y[3:0];
    assign g4 = x[3:0] & y[3:0];

    assign c1 = g4[0];
    assign c2 = g4[1] | (p4[1] & g4[0]);

    assign c3 = g4[2]
              | (p4[2] & g4[1])
              | (p4[2] & p4[1] & g4[0]);

    assign c4 = g4[3]
              | (p4[3] & g4[2])
              | (p4[3] & p4[2] & g4[1])
              | (p4[3] & p4[2] & p4[1] & g4[0]);

    assign sum[0] = p4[0];
    assign sum[1] = p4[1] ^ c1;
    assign sum[2] = p4[2] ^ c2;
    assign sum[3] = p4[3] ^ c3;

    // ------------------------------------------------
    // Upper 2-bit CLA
    // Carry-in is lower CLA carry c4
    // ------------------------------------------------
    assign p2 = x[5:4] ^ y[5:4];
    assign g2 = x[5:4] & y[5:4];

    assign c5 = g2[0] | (p2[0] & c4);
    assign c6 = g2[1]
              | (p2[1] & g2[0])
              | (p2[1] & p2[0] & c4);

    assign sum[4] = p2[0] ^ c4;
    assign sum[5] = p2[1] ^ c5;

    // Final carry-out
    assign cout = c6;

endmodule

