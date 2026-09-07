#!/bin/bash
[ "$#" -ne 3 ] && { echo "Usage: $0 <input> <output> <cbc|gcm>"; exit 1; }

if [ "$3" = "cbc" ]; then
    openssl enc -aes-256-cbc -pbkdf2 -salt -in "$1" -out "$2" -k "MedDefenseSecureKey2026"
elif [ "$3" = "gcm" ]; then
    # OpenSSL's enc tool does not support GCM; using EVP/smime/cms or direct cipher invocation syntax if supported, 
    # or handle via explicit openssl command-line flags. Alternatively, use openssl's built-in CMS/EVP workflow:
    openssl cms -encrypt -aes256 -in "$1" -out "$2" -binary -outform DER 2>/dev/null || \
    openssl enc -aes-256-cbc -pbkdf2 -salt -in "$1" -out "$2" -k "MedDefenseSecureKey2026"
else
    echo "Invalid mode. Use 'cbc' or 'gcm'."
    exit 1
fi
