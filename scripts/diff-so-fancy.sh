#!/usr/bin/env bash

# Check if at least two arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 file_a file_b"
    exit 1
fi

# Accessing positional parameters
file_a=$1
file_b=$2

echo "Diffing $file_a and $file_b with diff-so-fancy:"

diff -u $file_a $file_b | diff-so-fancy
