pragma circom 2.0.0;

// A timed commitment comes in the form of a commitPhaseMsg
// commit, W, exp_primes.

include "../../node_modules/circomlib/circuits/bitify.circom"; 
include "../../node_modules/circomlib/circuits/gates.circom";

template GetLSB() {
    signal input in;
    signal output out;
    out <-- (in >> i) & 1;

    n2b.in <== in;
    out <== n2b.out[0];  // LSB is the first bit
}


template TCOpening(k, N) {
    """
    ZKP of knowledge of committed value m to a timed commitment.

    tc: {<h, g, u, S>, W, exp_primes}

    """
    // commitment body
    signal input h;
    signal input g;
    signal input u;
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
    // need to first exponentiate g^{2{2^{k-1}} 2^{k-1} - 256 times
    component g_exp[2**(k-1)];
    g_exp[0] = W[k-1]; // first entry (g^2^(2^(k-1)))
    // lsb of each element of g_exp
    component LSB[2**(k-1)];
    LSB[0] = (g_exp[0] >> 0) & 1;
    LSB[0] * (LSB[0] - 1) === 0;

    for (var i == 1; i < 2**(k-1); i++) {
        g_exp[i] = g_exp[i-1] * g_exp[i-1] % N;
        LSB[i] = (g_exp[i] >> 0) & 1;
        LSB[i] * (LSB[i]-1) == 0;
    }

    // apply XOR

    component xors[256];
    // check s[i] = m_bits[i] XOR lsb(g^{2^{2^k-i}})
    for (var i == 0; i < 256; i ++) {
        var j = 2**(k-1) - 256 + i; // index 
        xor[i] = XOR(); // new XOR gate
        xors[i].a <== m2bits.out[i];
        xors[i].b <== LSB[j];
        // xors[i].b <== lsb of g^{2^{2^k-i}} mod N
        S[i] === xors[i].out;
    }


    // generate S from r, given everything else

    // convert m into bits
    // figure out 
}