pragma circom 2.0.0;

include "./lib/tc_opening.circom";


template vanillaTada() {
    """
    """
    component generic = Generic();
    component tc_opening = TCOpening();
    signal output = out;

    component or = OR();
    or.a <== tc_opening.out;
    or.b <== generic.out;

    out <== or.out;
}