module mode_adder_tree (
    input  wire [1:0]  mode,

    input  wire [7:0]  G0,
    input  wire [8:0]  G1,
    input  wire [9:0]  G2, G3, G4,
    input  wire [8:0]  G5,
    input  wire [7:0]  G6,
    input  wire [7:0]  P11,

    output reg  [31:0] raw_product
);

    wire int4_en  = (mode == 2'b00);
    wire int8_en  = (mode == 2'b01);
    wire int16_en = (mode == 2'b10);

    // ------------------------------------------
    // A = G0 + (G1 << 4)
    // Shared INT8 / INT16
    // ------------------------------------------

    wire [7:0] g0_iso;
    wire [8:0] g1_iso;
    wire [13:0] sum_A;

    assign g0_iso = (int8_en || int16_en) ? G0 : 8'b0;
    assign g1_iso = (int8_en || int16_en) ? G1 : 9'b0;

    wire [13:0] a_operand = {6'b0, g0_iso};
    wire [13:0] b_operand = {1'b0, g1_iso, 4'b0};

    cla_add #(.W(14)) add_A (
        .a(a_operand),
        .b(b_operand),
        .s(sum_A)
    );

    // ------------------------------------------
    // INT8: A + (P11 << 8)
    // Final result: 16 bits
    // ------------------------------------------

    wire [7:0] p11_iso;
    wire [15:0] raw_int8;

    assign p11_iso = int8_en ? P11 : 8'b0;

    wire [15:0] int8_a = {2'b0, sum_A};
    wire [15:0] int8_b = {p11_iso, 8'b0};

    cla_add #(.W(16)) add_INT8 (
        .a(int8_a),
        .b(int8_b),
        .s(raw_int8)
    );

    // ------------------------------------------
    // INT16: B = G2 + (G3 << 4)
    // ------------------------------------------

    wire [9:0] g2_iso, g3_iso, g4_iso;
    wire [8:0] g5_iso;
    wire [7:0] g6_iso;

    assign g2_iso = int16_en ? G2 : 10'b0;
    assign g3_iso = int16_en ? G3 : 10'b0;
    assign g4_iso = int16_en ? G4 : 10'b0;
    assign g5_iso = int16_en ? G5 : 9'b0;
    assign g6_iso = int16_en ? G6 : 8'b0;

    wire [14:0] sum_B;

    wire [14:0] b_a = {5'b0, g2_iso};
    wire [14:0] b_b = {1'b0, g3_iso, 4'b0};

    cla_add #(.W(15)) add_B (
        .a(b_a),
        .b(b_b),
        .s(sum_B)
    );

    // ------------------------------------------
    // INT16: C = G4 + (G5 << 4)
    // ------------------------------------------

    wire [14:0] sum_C;

    wire [14:0] c_a = {5'b0, g4_iso};
    wire [14:0] c_b = {2'b0, g5_iso, 4'b0};

    cla_add #(.W(15)) add_C (
        .a(c_a),
        .b(c_b),
        .s(sum_C)
    );

    // ------------------------------------------
    // INT16: AB = A + (B << 8)
    // ------------------------------------------

    wire [22:0] sum_AB;

    wire [22:0] ab_a = {9'b0, sum_A};
    wire [22:0] ab_b = {sum_B, 8'b0};

    cla_add #(.W(23)) add_AB (
        .a(ab_a),
        .b(ab_b),
        .s(sum_AB)
    );

    // ------------------------------------------
    // INT16: ABC = AB + (C << 16)
    // ------------------------------------------

    wire [30:0] sum_ABC;

    wire [30:0] abc_a = {8'b0, sum_AB};
    wire [30:0] abc_b = {sum_C, 16'b0};

    cla_add #(.W(31)) add_ABC (
        .a(abc_a),
        .b(abc_b),
        .s(sum_ABC)
    );

    // ------------------------------------------
    // INT16: final = ABC + (G6 << 24)
    // ------------------------------------------

    wire [31:0] raw_int16;

    wire [31:0] final_a = {1'b0, sum_ABC};
    wire [31:0] final_b = {g6_iso, 24'b0};

    cla_add #(.W(32)) add_FINAL (
        .a(final_a),
        .b(final_b),
        .s(raw_int16)
    );

    // ------------------------------------------
    // Mode selection
    // ------------------------------------------

    always @(*) begin
        case (mode)
            2'b00: raw_product = {24'b0, G0};
            2'b01: raw_product = {16'b0, raw_int8};
            2'b10: raw_product = raw_int16;
            default: raw_product = 32'b0;
        endcase
    end

endmodule
