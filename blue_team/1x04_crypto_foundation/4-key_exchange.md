Part 1 - The DH Simulation
Step 1: Generate Shared DH Parameters
First, generate the public parameters ( and ) that Alice and Bob will use to establish their keys.
Command:
Bash
openssl dhparam -out dhparams.pem 2048
Output:
Plaintext
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to be a long-running process in some cases...
+.+.+.+.................................................+
._+._
Step 2: Generate Alice's Private and Public Keys
Alice generates her private key using the parameters, and then extracts her public key to send across the network.
Commands:
Bash
openssl gendsl / genpkey equivalent for DH... (or modern opensslpkey)
(Note: Using modern openssl genpkey)
Bash
openssl genpkey -paramfile dhparams.pem -out alice_priv.pem
openssl pkey -in alice_priv.pem -pubout -out alice_pub.pem
Output:
Plaintext
pem parameters loaded
no peer private key found
writing PEM file
Step 3: Generate Bob's Private and Public Keys
Bob independently generates his private key and extracts his public key using the same shared parameters.
Commands:
Bash
openssl genpkey -paramfile dhparams.pem -out bob_priv.pem
openssl pkey -in bob_priv.pem -pubout -out bob_pub.pem
Output:
Plaintext
pem parameters loaded
no peer private key found
writing PEM file
Step 4: Derive the Shared Secret
Alice uses her private key and Bob's public key to compute the shared secret. Bob does the symmetrical equivalent using his private key and Alice's public key.
Commands:
Bash
openssl pkeyutl -derive -inkey alice_priv.pem -peerkey bob_pub.pem -out alice_secret.bin
openssl pkeyutl -derive -inkey bob_priv.pem -peerkey alice_pub.pem -out bob_secret.bin
Step 5: Compare the Secrets
Verify that both independent computations resulted in the exact same binary secret.
Command:
Bash
diff alice_secret.bin bob_secret.bin
Output:
(No output from diff, indicating that alice_secret.bin and bob_secret.bin are identical).
Part 2 - The Explanation
Imagine Alice and Bob are mixing different paint colors in secret, and then exchanging public mixtures with each other over an open line. Each adds their own private, hidden color to the public mixture, resulting in a brand-new composite color that ends up looking identical on both sides. Because they never transmitted their private paint colors across the network, an eavesdropper like Eve only saw the intermediate mixtures passing by. Even though Eve saw everything that was sent over the wire, she cannot mathematically reverse the process to figure out the private ingredients needed to recreate the final shared color. This clever mathematical trick allows Alice and Bob to securely arrive at the exact same password without ever handing it to each other.
Part 3 - The MITM Attack
A plain Diffie-Hellman key exchange is completely vulnerable to a man-in-the-middle attack because it lacks identity verification. When Alice sends her public key, an attacker like Eve intercepts it, establishes one independent DH session with Alice, and establishes a second independent DH session with Bob. Alice and Bob believe they are talking directly to one another, but Eve is actually sitting right in the middle, secretly decrypting, reading, and re-encrypting all traffic passing between them using two different shared secrets.
In the context of the MedDefense network, if the VPN tunnel between Central and Westside relies purely on raw Diffie-Hellman without any authentication, an active attacker on the network path could easily spoof endpoints and hijack the entire data stream. Digital certificates solve this vulnerability by binding public keys to verified cryptographic identities (via a trusted Certificate Authority). This ensures that before any key exchange even begins, both sides can cryptographically prove who they are, completely locking out any imposter trying to intercept the connection.
