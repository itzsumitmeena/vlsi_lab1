module add8_cla (
    input  [7:0] a, b,
    output [8:0] s
);
    wire c4, c8;
    wire [3:0] lo, hi;

    cla4 u0 (
        .x(a[3:0]), .y(b[3:0]), .cin(1'b0),
        .sum(lo), .cout(c4)
    );

    cla4 u1 (
        .x(a[7:4]), .y(b[7:4]), .cin(c4),
        .sum(hi), .cout(c8)
    );

    assign s = {c8, hi, lo};
endmodule


module add9_cla(
    input  [8:0] a, b,
    output [9:0] s
);
    wire [8:0] low_sum;
    wire top_carry;
    wire top_sum;
    wire carry9;

    add8_cla u0 (
        .a(a[7:0]),
        .b(b[7:0]),
        .s(low_sum)
    );

    assign top_sum = a[8] ^ b[8] ^ low_sum[8];

    assign carry9 =
        (a[8] & b[8]) |
        (a[8] & low_sum[8]) |
        (b[8] & low_sum[8]);

    assign s = {carry9, top_sum, low_sum[7:0]};
endmodule

module add10_cla(
    input  [9:0] a, b,
    output [10:0] s
);
    wire [8:0] low_sum;
    wire [1:0] upper_sum;
    wire c9, c10;

    add8_cla u0 (
        .a(a[7:0]),
        .b(b[7:0]),
        .s(low_sum)
    );

    assign upper_sum[0] = a[8] ^ b[8] ^ low_sum[8];

    assign c9 =
        (a[8] & b[8]) |
        (a[8] & low_sum[8]) |
        (b[8] & low_sum[8]);

    assign upper_sum[1] = a[9] ^ b[9] ^ c9;

    assign c10 =
        (a[9] & b[9]) |
        (a[9] & c9) |
        (b[9] & c9);

    assign s = {c10, upper_sum, low_sum[7:0]};
endmodule

module partial_sum_groups (
    input [7:0] P00, P01, P02, P03,
    input [7:0] P10, P11, P12, P13,
    input [7:0] P20, P21, P22, P23,
    input [7:0] P30, P31, P32, P33,

    output [7:0] G0,
    output [8:0] G1,
    output [9:0] G2, G3, G4,
    output [8:0] G5,
    output [7:0] G6
);

    wire [8:0] g2_t1;
    wire [8:0] g4_t1;

    wire [8:0] g3_t1, g3_t2;
    wire [9:0] g3_result;

    wire [9:0] g2_result;
    wire [9:0] g4_result;

    // G0: no addition
    assign G0 = P00;

    // G1: 2 operands
    add8_cla g1_add (
        .a(P01), .b(P10), .s(G1)
    );

    // G2: 3 operands, 2 additions
    add8_cla g2_add1 (
        .a(P02), .b(P11), .s(g2_t1)
    );

    add9_cla g2_add2 (
        .a(g2_t1), .b({1'b0, P20}), .s(g2_result)
    );

    assign G2 = g2_result;

    // G3: 2 parallel first-stage additions
    add8_cla g3_add1 (
        .a(P03), .b(P12), .s(g3_t1)
    );

    add8_cla g3_add2 (
        .a(P21), .b(P30), .s(g3_t2)
    );

    // Add the two 9-bit intermediate results
    add9_cla g3_add3 (
        .a(g3_t1), .b(g3_t2), .s(g3_result)
    );

    assign G3 = g3_result;

    // G4: 3 operands, 2 additions
    add8_cla g4_add1 (
        .a(P13), .b(P22), .s(g4_t1)
    );

    add9_cla g4_add2 (
        .a(g4_t1), .b({1'b0, P31}), .s(g4_result)
    );

    assign G4 = g4_result;

    // G5: 2 operands
    add8_cla g5_add (
        .a(P23), .b(P32), .s(G5)
    );

    // G6: no addition
    assign G6 = P33;

endmodule
