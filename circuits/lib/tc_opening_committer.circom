pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/bitify.circom"; 
include "../../node_modules/circomlib/circuits/gates.circom";


template CommitterTCOpening(k, N) {
    """
    ZKP of knowledge of committed value m to a timed commitment, 
    generated by a committer. Used in Encryption-TADA to prove that
    the committed value is equal to the preimage of an encrypted value.
    Much faster than TCOpening since p1, p2 are known btw!

    The full structure of a timed commitment is
        {<h, g, u, S>, W, exp_primes}
    Only g, S, W, and m are necessary inputs to this circuit.
    """

    // number of bits of N
    var n_bits = 0;
    var temp = N;
    while (temp > 0) {
        n_bits = n_bits + 1;
        temp = temp \ 2;  // Integer division by 2
    }

    // commitment body
    signal input g;
    signal input S[256];

    // W vector of modular exponents {2^2^i, 0<=i<=k}
    signal input W[k+1];

    // private input
    signal input m;

    // primes
    signal input p1;
    signal input p2;
    signal totient;

    N === p1 * p2;
    totient <== p1 * p2;

    signal output out;

    // convert to bits 
    component m2bits = Num2Bits(256);
    m2bits.in <== m;

    // compute the starting exponent
    var start_exponent = 2**k - 256;
    signal start_exponent_reduced <-- 2**start_exponent % totient; // ok there is no way this doesn't crash rn

    // decompose exponent into bits
    component exponent_bits = Num2Bits(n_bits);
    exponent_bits.in <== start_exponent_reduced;

    // a vector of <g^1, g^2^i>
    signal g_powers[n_bits];
    g_powers[0] <-- g;
    for (var i = 1; i < n_bits; i++) {
        g_powers[i] <-- powers[i-1] * powers[i-1] % N;
    }

    // then multiply bits and corresponding powers together
    signal start_exponent_accumulator[n_bits];
    start_exponent_accumulator[0] <-- g_powers[0] * exponent_bits.out[0];
    for (var i=1; i< n_bits; i++) {
        start_exponent_accumulator[i] <-- (start_exponent_accumulator[i-1] + g_powers[i] * exponent_bits.out[i]) % N;
    }

    signal g_exp[256];
    g_exp[0] <-- start_exponent_accumulator[n_bits-1];
    for (var i=1; i < 256; i++) {
        g_exp[i] <-- (g_exp[i-1] ** g_exp[i-1]) % N;
    }

    // we can proceed now as usual..
    component xors[256];
    signal LSB[256]; // 

    // check s[i] = m_bits[i] XOR lsb(g^{2^{2^k-i}})
    signal checks[257];
    checks[0] <== 1;

    for (var i == 0; i < 256; i ++) {
        // calculate LSB of power of g
        LSB[i] = (g_exp[255-i] >> 0) & 1;

        xor[i] = XOR(); // new XOR gate
        xors[i].a <== m2bits.out[i];
        xors[i].b <== LSB[i];
        S[i] === xors[i].out;

       // multiply running product by (S[i] === xors[i].out ? 1 : 0)
        checks[i+1] <== checks[i] * (1-(S[i] - xors[i].out));
    }

    // all checks pass; like an AND across all bits.
    out <== checks[256];
}