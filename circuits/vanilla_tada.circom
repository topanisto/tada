pragma circom 2.1.6;

include "./lib/tc_opening.circom";

template vanillaTada(k, N) {
    """
    """
    component generic = Generic();
    component tc_opening = TCOpening(k, N);
    signal output = out;

    component or = OR();
    or.a <== tc_opening.out;
    or.b <== generic.out;

    out <== or.out;
}