
module sign_correction (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire [1:0]  mode,
    input  wire [31:0] raw_product,
    output wire [31:0] signed_product
);

    reg [15:0] a_unsigned, b_unsigned;
    reg sign_a, sign_b;

    reg [31:0] corr_a, corr_b, corr_both;

    wire [31:0] corr_sum;
    wire [31:0] neg_corr;
    wire [31:0] temp_product;

    wire [31:0] one;
    assign one = 32'd1;

    // ------------------------------------
    // 1. Mode decode and operand selection
    // ------------------------------------
    always @(*) begin
        a_unsigned = 16'd0;
        b_unsigned = 16'd0;
        sign_a = 1'b0;
        sign_b = 1'b0;

        case (mode)
            2'b00: begin
                a_unsigned = {12'b0, A[3:0]};
                b_unsigned = {12'b0, B[3:0]};
                sign_a = A[3];
                sign_b = B[3];
            end

            2'b01: begin
                a_unsigned = {8'b0, A[7:0]};
                b_unsigned = {8'b0, B[7:0]};
                sign_a = A[7];
                sign_b = B[7];
            end

            2'b10: begin
                a_unsigned = A;
                b_unsigned = B;
                sign_a = A[15];
                sign_b = B[15];
            end

            default: begin
                a_unsigned = 16'd0;
                b_unsigned = 16'd0;
                sign_a = 1'b0;
                sign_b = 1'b0;
            end
        endcase
    end

    // ------------------------------------
    // 2. Generate correction terms
    // ------------------------------------
    always @(*) begin
        corr_a = 32'd0;
        corr_b = 32'd0;
        corr_both = 32'd0;

        case (mode)
            2'b00: begin
                if (sign_a)
                    corr_a = {12'b0, b_unsigned, 4'b0};

                if (sign_b)
                    corr_b = {12'b0, a_unsigned, 4'b0};

                if (sign_a && sign_b)
                    corr_both = 32'h00000100;
            end

            2'b01: begin
                if (sign_a)
                    corr_a = {8'b0, b_unsigned, 8'b0};

                if (sign_b)
                    corr_b = {8'b0, a_unsigned, 8'b0};

                if (sign_a && sign_b)
                    corr_both = 32'h00010000;
            end

            2'b10: begin
                if (sign_a)
                    corr_a = {b_unsigned, 16'b0};

                if (sign_b)
                    corr_b = {a_unsigned, 16'b0};

                // 2^32 is zero modulo 2^32
                corr_both = 32'd0;
            end

            default: begin
                corr_a = 32'd0;
                corr_b = 32'd0;
                corr_both = 32'd0;
            end
        endcase
    end

    // ------------------------------------
    // 3. Add both negative correction terms
    // ------------------------------------
    cla_add #(.W(32)) u_corr_sum (
        .a(corr_a),
        .b(corr_b),
        .s(corr_sum)
    );

    // ------------------------------------
    // 4. Two's-complement of correction sum
    //    -corr_sum = ~corr_sum + 1
    // ------------------------------------
    cla_add #(.W(32)) u_neg_corr (
        .a(~corr_sum),
        .b(one),
        .s(neg_corr)
    );

    // ------------------------------------
    // 5. Add negative correction to raw result
    // ------------------------------------
    cla_add #(.W(32)) u_product (
        .a(raw_product),
        .b(neg_corr),
        .s(temp_product)
    );

    // ------------------------------------
    // 6. Add both-negative correction
    // ------------------------------------
    cla_add #(.W(32)) u_both (
        .a(temp_product),
        .b(corr_both),
        .s(signed_product)
    );

endmodule

