pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom"; 
include "../../node_modules/circomlib/circuits/gates.circom";
include "../../node_modules/circomlib/circuits/comparators.circom"; 
include "./modulus.circom";

template TCOpening(k, N) {
    """
    ZKP of knowledge of committed value m to a timed commitment.
    The full structure of a timed commitment is
        {<h, g, u, S>, W, exp_primes}
    Only S, W, and m are necessary inputs to this circuit.
    """
    // get number of bits of N
    var n_bits = 0;
    var temp = N;
    while (temp > 0) {
        n_bits = n_bits + 1;
        temp = temp \ 2;  // Integer division by 2
    }

    // generator
    signal input g;
    // commitment body
    signal input S[256];
    // verification vector := <g^{2^{2^i}> for 0 <= i <= k
    signal input W[k+1];

    // check W is generated correctly
    component gmodN = ModuloOperator(N, 252);
    signal g_2 <== g * g;
    gmodN.in <== g_2;
    W[0] === gmodN.out;

    // private msg
    signal input m;
    component m2bits = Num2Bits(256);
    m2bits.in <== m;

    signal output out;

    // exponent
    signal g_exp[2**(k-1)];
    g_exp[0] <== W[k-2]; // first entry (g^2^(2^(k-1)))

    // signals for modulo N operations
    component mods_exp[2**(k-1)-1];
    signal temp_exp[2**(k-1)-1];

    // need to first exponentiate g^{2{2^{k-1}} 2^{k-1} - 256 times
    for (var i = 1; i < 2**(k-1); i++) {
        mods_exp[i-1] = ModuloOperator(N, 252);
        temp_exp[i-1] <== g_exp[i-1] * g_exp[i-1];
        mods_exp[i-1].in <== temp_exp[i-1];
        g_exp[i] <== mods_exp[i-1].out;
    }

    // apply XOR
    component xors[256];
    signal LSB[256];
    component getlsb[256];

    // compare bitwise
    signal res_comp[257];
    res_comp[0] <== 1;
    component comp[256];
    // check s[i] = m_bits[i] XOR lsb(g^{2^{2^k-i}})
    for (var i=0; i<256; i++) {
        var j = 2**(k-1) - i -1; // index 
        // calculate LSB
        getlsb[i] = Num2Bits(n_bits);
        getlsb[i].in <== g_exp[j];
        LSB[i] <== getlsb[i].out[0];

        xors[i] = XOR(); // new XOR gate
        xors[i].a <== m2bits.out[i];
        xors[i].b <== LSB[i];

        // compare S[i] to computed XOR
        comp[i] = IsEqual();
        comp[i].in[0] <== S[i];
        comp[i].in[1] <== xors[i].out;

        // need an AND function
        res_comp[i+1] <== comp[i].out * res__comp[i];
    }

    //TODO: fix output
    out <== res_comp[256];
}