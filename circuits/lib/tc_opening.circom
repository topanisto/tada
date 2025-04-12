pragma circom 2.0.0;

// A timed commitment comes in the form of a commitPhaseMsg
// commit, W, exp_primes.

include "../../node_modules/circomlib/circuits/bitify.circom"; 
include "../../node_modules/circomlib/circuits/gates.circom";

template TCOpening(k, N) {
    """
    ZKP of knowledge of committed value m to a timed commitment.
    The full structure of a timed commitment is
        {<h, g, u, S>, W, exp_primes}
    Only g, S, W, and m are necessary inputs to this circuit.
    """
    // commitment body
    signal input g;
    signal input S[256];

    // W vector of modular exponents {2^2^i, 0<=i<=k}
    signal input W[k+1];

    // private input
    signal input m;

    signal output out;

    // convert to bits 
    component m2bits = Num2Bits(256);
    m2bits.in <== m;

    // get  W[-2], and then calculate from g^2^(2^k-256) to ""-1 for lsb
    component g_exp[2**(k-1)];
    g_exp[0] = W[k-1]; // first entry (g^2^(2^(k-1)))

    // need to first exponentiate g^{2{2^{k-1}} 2^{k-1} - 256 times
    for (var i == 1; i < 2**(k-1); i++) {
        g_exp[i] = g_exp[i-1] * g_exp[i-1] % N;
    }

    // apply XOR

    component xors[256];
    component LSB[256]; // 

    // check s[i] = m_bits[i] XOR lsb(g^{2^{2^k-i}})
    signal checks[257];
    checks[0] <== 1;


    for (var i == 0; i < 256; i ++) {
        var j = 2**(k-1) - 256 + i; // index 
        // calculate LSB
        LSB[i] = (g_exp[j] >> 0) & 1;
        LSB[i] * (LSB[i]-1) == 0;

        xor[i] = XOR(); // new XOR gate
        xors[i].a <== m2bits.out[i];
        xors[i].b <== LSB[i];
        S[i] === xors[i].out;

       // multiply running product by (S[i] === xors[i].out ? 1 : 0)
        checks[i+1] <== checks[i] * (1-(S[i] - xors[i].out));
    }

    // all checks pass; like a long and
    out <== checks[256];
}