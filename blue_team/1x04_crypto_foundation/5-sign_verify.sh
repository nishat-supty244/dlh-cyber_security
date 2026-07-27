#!/bin/bash

# Display usage instructions if arguments are incorrect
usage() {
    echo "Usage:"
    echo "  Sign Mode:   $0 sign <file_path> <private_key_path>"
    echo "  Verify Mode: $0 verify <file_path> <signature_path> <public_key_path>"
    exit 1
}

# Check if at least 2 arguments are provided
if [ "$#" -lt 2 ]; then
    usage
fi

MODE=$1

case "$MODE" in
    sign)
        if [ "$#" -ne 3 ]; then
            echo "Error: Sign mode requires a file path and a private key path."
            usage
        fi
        FILE=$2
        PRIV_KEY=$3
        SIG_FILE="${FILE}.sig"

        # Generate the signature file (.sig)
        openssl dgst -sha256 -sign "$PRIV_KEY" -out "$SIG_FILE" "$FILE"
        echo "Success: Signature written to $SIG_FILE"
        ;;

    verify)
        if [ "$#" -ne 4 ]; then
            echo "Error: Verify mode requires a file path, signature path, and public key path."
            usage
        fi
        FILE=$2
        SIG_FILE=$3
        PUB_KEY=$4

        # Verify the signature against the file
        openssl dgst -sha256 -verify "$PUB_KEY" -signature "$SIG_FILE" "$FILE"
        ;;

    *)
        echo "Error: Unknown mode '$MODE'."
        usage
        ;;
esac
