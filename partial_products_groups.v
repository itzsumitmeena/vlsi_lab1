
module partial_products_16 (
    input  [15:0] A,
    input  [15:0] B,

    output [7:0] P00, P01, P02, P03,
    output [7:0] P10, P11, P12, P13,
    output [7:0] P20, P21, P22, P23,
    output [7:0] P30, P31, P32, P33
);

    // Split 16-bit A into four 4-bit chunks
    wire [3:0] A0 = A[3:0];
    wire [3:0] A1 = A[7:4];
    wire [3:0] A2 = A[11:8];
    wire [3:0] A3 = A[15:12];

    // Split 16-bit B into four 4-bit chunks
    wire [3:0] B0 = B[3:0];
    wire [3:0] B1 = B[7:4];
    wire [3:0] B2 = B[11:8];
    wire [3:0] B3 = B[15:12];

    // Row 0: A0 multiplied by B0, B1, B2, B3
    mult4x4_dadda u00 (.a(A0), .b(B0), .p(P00));
    mult4x4_dadda u01 (.a(A0), .b(B1), .p(P01));
    mult4x4_dadda u02 (.a(A0), .b(B2), .p(P02));
    mult4x4_dadda u03 (.a(A0), .b(B3), .p(P03));

    // Row 1: A1 multiplied by B0, B1, B2, B3
    mult4x4_dadda u10 (.a(A1), .b(B0), .p(P10));
    mult4x4_dadda u11 (.a(A1), .b(B1), .p(P11));
    mult4x4_dadda u12 (.a(A1), .b(B2), .p(P12));
    mult4x4_dadda u13 (.a(A1), .b(B3), .p(P13));

    // Row 2: A2 multiplied by B0, B1, B2, B3
    mult4x4_dadda u20 (.a(A2), .b(B0), .p(P20));
    mult4x4_dadda u21 (.a(A2), .b(B1), .p(P21));
    mult4x4_dadda u22 (.a(A2), .b(B2), .p(P22));
    mult4x4_dadda u23 (.a(A2), .b(B3), .p(P23));

    // Row 3: A3 multiplied by B0, B1, B2, B3
    mult4x4_dadda u30 (.a(A3), .b(B0), .p(P30));
    mult4x4_dadda u31 (.a(A3), .b(B1), .p(P31));
    mult4x4_dadda u32 (.a(A3), .b(B2), .p(P32));
    mult4x4_dadda u33 (.a(A3), .b(B3), .p(P33));

endmodule

