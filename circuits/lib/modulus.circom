pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom"; 

template ModuloOperator(modulo, n) {
    signal input in;
    signal output out;
 
    signal quotient <-- in \ modulo;
 
    out <-- in % modulo;
 
    in === quotient * modulo + out;
 
    component lessThan = LessThan(n);
    lessThan.in[0] <== out;
    lessThan.in[1] <== modulo;
    lessThan.out === 1;
}