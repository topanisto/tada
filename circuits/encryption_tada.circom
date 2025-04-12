pragma circom 2.0.0;

include "./lib/tc_opening_committer.circom";
include "../../node_modules/circomlib/circuits/gates.circom";

template PkEncryption() {
    signal input m;
    signal input c;
    signal input sk;
}

template EncryptionTada(k, N) {
    signal input m;
    signal input ciphertext;
    signal output out;
    // signal input all commitment components


    component opening = CommitterTCOpening(k, N);
    opening.m <== m;
    component encryption = PkEncryption();
    encryption.m <== m;

    signal tc_out;
    signal enc_out;
    tc_out <== opening.out;
    encryption_out <== encryption.out;

    component eq_statements = AND();
    eq_statements.a <== tc_out;
    eq_statements.b <== encryption_out;

    out <== eq_statements.out;
    // 
}