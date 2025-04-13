# TADA: Time-Assured Deniable Authentication

## UNDER CONSTRUCTION ‼️ 
> This is a proof of concept! Circuits have absolutely not been audited!

A library of Circom circuits for TADA, or [Time-Assured Deniable Authentication](https://hackmd.io/b9e47uvCQ7u8psDqM05toA), including
- `VanillaTada(k, N)` - A basic TADA circuit that proves knowledge of either a Pythagorean triple OR timed commitment opening with timing difficulty parameter k
- `EncryptionTada(k, N)` *(UNDER CONSTRUCTION!)* - A TADA circuit that proves equality of the preimage of some ciphertext AND the opening of a timed commitment 

as well as the following library circuits that may be useful:
- `TCOpening(k, N)` - A circuit for proving knowledge of a valid [Boneh-Naor timed commitment](https://crypto.stanford.edu/~dabo/abstracts/timedcommit.html) opening with public parameter N and timing difficulty parameter k
- `CommitterTCOpening(k, N)` - A *faster opening circuit*, to be used by the creator of the timed commitment

We base our circuits off a [Rust implementation](https://github.com/topanisto/timed-commitments) of Boneh-Naor timed commitments as well as [0xPARC's ECDSA circom-ecdsa circuits](https://github.com/0xPARC/circom-ecdsa/tree/d87eb7068cb35c951187093abe966275c1839ead) to make example TADA attestation proofs.

## TODOs
- Finish and benchmark `EncryptionTada` implementation.
- Make a `VanillaTada` variant for proving knowledge of a valid ECDSA signature.
- Benchmark `VanillaTada`.
- Efficiency improvements for `TCOpening`.