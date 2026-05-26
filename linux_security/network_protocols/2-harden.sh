#!/bin/bash
SEARCH_PATH="${1:-/}"
find "$SEARCH_PATH" -type d -perm -0002 -print -exec chmod o-w {} +
