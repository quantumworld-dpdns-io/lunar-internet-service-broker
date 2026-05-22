// Quantum Key Distribution - BB84 Protocol Simulation
// Lunar Internet Service Broker - Quantum Security Module

OPENQASM 3.0;
include "stdgates.inc";

// BB84 QKD Protocol
// Alice sends qubits in random bases (Z or X)
// Bob measures in random bases (Z or X)
// They compare bases publicly and keep matching results

qubit alice_qubit;
qubit bob_qubit;
creg alice_basis[1];
creg bob_basis[1];
creg measurement[1];

// Alice prepares qubit in |0⟩ state (Z basis)
reset alice_qubit;

// Alice applies Hadamard if she chooses X basis
h alice_qubit;

// Alice sends qubit to Bob (simulated via entanglement)
cx alice_qubit, bob_qubit;

// Bob measures in his randomly chosen basis
// If Bob chooses X basis, apply H before measure
h bob_qubit;

// Measure
measure bob_qubit -> measurement[0];

// Note: In a real implementation, Alice and Bob would:
// 1. Repeat this circuit many times
// 2. Publicly compare their basis choices
// 3. Keep only measurements where bases matched
// 4. Use a subset to detect eavesdropping
// 5. Run error correction and privacy amplification
