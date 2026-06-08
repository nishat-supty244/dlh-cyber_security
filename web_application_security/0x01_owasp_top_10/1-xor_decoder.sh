#!/usr/bin/python3
import sys
import base64

# Get the argument from the command line
hash_arg = sys.argv[1]

# Strip the {xor} prefix
if hash_arg.startswith("{xor}"):
    encoded_data = hash_arg[5:]
else:
    encoded_data = hash_arg

# Decode base64 and XOR each byte with 95
decoded_bytes = base64.b64decode(encoded_data)
result = "".join([chr(b ^ 95) for b in decoded_bytes])

# Print the result
print(result)
