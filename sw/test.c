/*
 * Simple RV32I processor test.
 *
 * crt0.S calls main() and then enters an infinite loop. A testbench can
 * inspect register a0 (x10) after the program finishes:
 *
 *     a0 == 0  : all checks passed
 *     a0 != 0  : the value identifies the failed check
 *
 * Volatile local variables force the generated program to exercise data
 * memory instead of allowing the compiler to calculate every result while
 * compiling.
 */
int main(void)
{
    volatile int a = 13;
    volatile int b = 5;
    volatile int result;
    volatile unsigned int unsigned_result;

    result = a + b;
    if (result != 18)
        return 1;

    result = a - b;
    if (result != 8)
        return 2;

    result = a & b;
    if (result != 5)
        return 3;

    result = a | b;
    if (result != 13)
        return 4;

    result = a ^ b;
    if (result != 8)
        return 5;

    result = a << 2;
    if (result != 52)
        return 6;

    unsigned_result = (unsigned int)a >> 1;
    if (unsigned_result != 6u)
        return 7;

    result = -16;
    result = result >> 2;
    if (result != -4)
        return 8;

    if (a <= b)
        return 9;

    if (b >= a)
        return 10;

    /* Explicit store followed by load through a volatile stack object. */
    result = 123;
    if (result != 123)
        return 11;

    return 0;
}
