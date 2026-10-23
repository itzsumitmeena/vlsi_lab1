
module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    wire x;
    wire n1, n2;

    xor  (x,    a, b);
    xor  (sum,  x, cin);

    nand (n1, a, b);
    nand (n2, x, cin);
    nand (cout, n1, n2);

endmodule

