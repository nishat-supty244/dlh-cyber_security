#!/usr/bin/python3
import sys, base64; print("".join([chr(b ^ 95) for b in base64.b64decode(sys.argv[1].replace("{xor}", ""))]))
