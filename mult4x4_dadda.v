
module mult4x4_dadda (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] p
);

    // Step 1: Generate 16 partial-product bits
    wire [3:0] row0, row1, row2, row3;

    assign row0 = a & {4{b[0]}};
    assign row1 = a & {4{b[1]}};
    assign row2 = a & {4{b[2]}};
    assign row3 = a & {4{b[3]}};

    // Step 2: Dadda stage 1
    // Reduce maximum column height from 4 to 3

    wire s13, c13;
    wire s14, c14;

    // Column 3: half-adder operation
    full_adder ha1 (
        .a(row0[3]),
        .b(row1[2]),
        .cin(1'b0),
        .sum(s13),
        .cout(c13)
    );

    // Column 4: half-adder operation
    full_adder ha2 (
        .a(row1[3]),
        .b(row2[2]),
        .cin(1'b0),
        .sum(s14),
        .cout(c14)
    );

    // Step 3: Dadda stage 2
    // Reduce maximum column height from 3 to 2

    wire s22, c22;
    wire s23, c23;
    wire s24, c24;
    wire s25, c25;

    // Column 2
    full_adder fa2 (
        .a(row0[2]),
        .b(row1[1]),
        .cin(row2[0]),
        .sum(s22),
        .cout(c22)
    );

    // Column 3
    full_adder fa3 (
        .a(s13),
        .b(row2[1]),
        .cin(row3[0]),
        .sum(s23),
        .cout(c23)
    );

    // Column 4
    full_adder fa4 (
        .a(s14),
        .b(row3[1]),
        .cin(c13),
        .sum(s24),
        .cout(c24)
    );

    // Column 5
    full_adder fa5 (
        .a(row2[3]),
        .b(row3[2]),
        .cin(c14),
        .sum(s25),
        .cout(c25)
    );

    // Step 4: Form the two final rows
    wire [5:0] x, y;
    wire [5:0] final_sum;
    wire final_carry;

    assign x = {
        row3[3],
        s25,
        s24,
        s23,
        s22,
        row0[1]
    };

    assign y = {
        c25,
        c24,
        c23,
        c22,
        1'b0,
        row1[0]
    };

    // Step 5: Final addition using your separate CLA module
    cla4_cla2 u_final_adder (
        .x(x),
        .y(y),
        .sum(final_sum),
        .cout(final_carry)
    );

    // Step 6: Final 8-bit product
    assign p[0]   = row0[0];
    assign p[6:1] = final_sum;
    assign p[7]   = final_carry;

endmodule

