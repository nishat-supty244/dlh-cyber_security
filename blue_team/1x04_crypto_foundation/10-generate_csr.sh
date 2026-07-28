#!/usr/bin/env bash
set -e

echo "[+] Step 1: Generating ECC P-256 Private Key..."
openssl ecparam -genkey -name secp256r1 -out portal_key.pem
chmod 600 portal_key.pem

echo "[+] Step 2: Generating CSR with SANs..."
openssl req -new -key portal_key.pem -out portal.csr \
  -subj "/C=US/ST=Massachusetts/L=Boston/O=MedDefense Health Systems/OU=Information Technology/CN=portal.meddefense.local" \
  -addext "subjectAltName = DNS:portal.meddefense.local, DNS:meddefense.local, DNS:portal.meddefense.com"

echo "[+] Step 3: Verifying CSR..."
openssl req -text -noout -in portal.csr

echo "[+] Success: Done!"
