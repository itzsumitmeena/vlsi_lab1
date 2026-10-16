import random

# Matrix dimension (16 x 16 tensor unit)
N = 16


# 1. Select precision from user
def select_precision():
    while True:
        print("\nSelect Input Precision:")
        print("1. INT4")
        print("2. INT8")
        print("3. INT16")
        choice = input("Enter your choice (1/2/3): ").strip()
        if choice == "1":
            return 4
        elif choice == "2":
            return 8
        elif choice == "3":
            return 16
        else:
            print("Invalid choice! Please enter 1, 2, or 3.")


# 2. Signed operand range
def get_range(bits):
    return -(2 ** (bits - 1)), (2 ** (bits - 1)) - 1


# 3. Generate random matrix
def generate_matrix(bits):
    low, high = get_range(bits)
    return [
        [random.randint(low, high) for _ in range(N)]
        for _ in range(N)
    ]


# 4. Signed multiplication
def multiply_signed(a, b, bits):
    low, high = get_range(bits)
    if not (low <= a <= high and low <= b <= high):
        raise ValueError("Operand outside signed range")
    return a * b


# 5. Golden Reference Model
def golden_model(A, B, bits):
    C = [[0] * N for _ in range(N)]
    for i in range(N):
        for j in range(N):
            acc = 0
            for k in range(N):
                acc += multiply_signed(A[i][k], B[k][j], bits)
            C[i][j] = acc
    return C


# 6. Accumulator width calculation
def accumulator_width(bits):
    low, high = get_range(bits)
    max_product = max(
        abs(low * low),
        abs(low * high),
        abs(high * low),
        abs(high * high),
    )
    max_sum = N * max_product
    width = 1
    while not (
        -(2 ** (width - 1)) <= -max_sum
        and max_sum <= (2 ** (width - 1)) - 1
    ):
        width += 1
    return width, -max_sum, max_sum


# 7. Verification tests
def run_tests(bits, num_random_tests=10):
    low, high = get_range(bits)

    # Boundary multiplication tests
    assert multiply_signed(low, low, bits) == low * low
    assert multiply_signed(low, high, bits) == low * high
    assert multiply_signed(high, high, bits) == high * high
    assert multiply_signed(0, low, bits) == 0

    # Invalid operand test
    try:
        multiply_signed(low - 1, 1, bits)
        raise AssertionError("Invalid operand accepted")
    except ValueError:
        pass

    # Identity matrix test
    A = generate_matrix(bits)
    I = [[int(i == j) for j in range(N)] for i in range(N)]
    assert golden_model(A, I, bits) == A

    # Zero matrix test
    Z = [[0] * N for _ in range(N)]
    assert golden_model(A, Z, bits) == Z

    # Random matrix tests
    for test_no in range(num_random_tests):
        A_test = generate_matrix(bits)
        B_test = generate_matrix(bits)
        C_test = golden_model(A_test, B_test, bits)
        for i in range(N):
            for j in range(N):
                expected = sum(
                    A_test[i][k] * B_test[k][j] for k in range(N)
                )
                assert C_test[i][j] == expected, f"Mismatch at ({i},{j})"

    width, min_sum, max_sum = accumulator_width(bits)
    print(f"\nINT{bits}: ALL TESTS PASSED")
    print(f"Operand range: {low} to {high}")
    print(f"Accumulator width: {width} bits")
    print(f"Conservative sum bounds: {min_sum} to {max_sum}")


# 8. Main program
if __name__ == "__main__":
    random.seed(42)
    bits = select_precision()
    print(f"\nSelected mode: INT{bits}")
    print("Generating random 16 x 16 matrices...")

    A = generate_matrix(bits)
    B = generate_matrix(bits)
    C = golden_model(A, B, bits)

    print("\nMatrix A:")
    for row in A:
        print(row)

    print("\nMatrix B:")
    for row in B:
        print(row)

    print("\nGolden Reference Output C = A x B:")
    for row in C:
        print(row)

    print("\nRunning verification tests...")
    run_tests(bits, num_random_tests=10)
    print(f"\nINT{bits} verification completed successfully!")
