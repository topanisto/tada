pragma circom 2.1.6;

include "./lib/tc_opening.circom";
include "../../node_modules/circomlib/circuits/comparators.circom"; 

template PythagoreanTriple() {
    signal input a;
    signal input b;
    signal output c;

    signal a2 <== a * a;
    signal b2 <== b * b;
    c <== a2 + b2;
}

template VanillaTada(k, N) {
    """
    A simple Vanilla TADA circuit for proving knowledge of (a, b) of a Pythagorean
    triple a^2 + b^2 = c^2.
    """
    // generic arm, idk
    signal input a;
    signal input b;
    signal input c; // public

    component triple = PythagoreanTriple();
    triple.a <== a;
    triple.b <== b;

    // opening to timed commitment
    signal input g;
    signal input S[256];
    signal input W[k+1];
    signal input m;

    component tc_opening = TCOpening(k, N);
    tc_opening.g <== g;
    tc_opening.m <== m;

    for (var i = 0; i < 256; i++) {
        tc_opening.S[i] <== S[i];
    }
    for (var i = 0; i < k+1; i++) {
        tc_opening.W[i] <== W[i];
    }

    // OR the outputs
    signal output = out;
    component check_triple = IsEqual();
    check_triple.in[0] <== c;
    check_triple.in[1] <== triple.out;

    component or = OR();
    or.a <== check_triple.out;
    or.b <== tc_opening.out;

    out <== or.out;
}