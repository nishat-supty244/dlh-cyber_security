#!/bin/bash
# 3-hash_verify.sh - File Integrity Verification Tool

FILE_PATH="$1"
EXPECTED_HASH="$2"

# Validate arguments
if [ -z "$FILE_PATH" ] || [ -z "$EXPECTED_HASH" ]; then
    echo "Usage: $0 <file_path> <expected_sha256_hash>"
    exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' not found."
    exit 1
fi

# Compute SHA-256 hash
ACTUAL_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')

# Compare hashes
if [ "$ACTUAL_HASH" = "$EXPECTED_HASH" ]; then
    echo "INTEGRITY OK"
    exit 0
else
    echo "INTEGRITY FAILED - expected $EXPECTED_HASH got $ACTUAL_HASH"
    exit 1
fi
