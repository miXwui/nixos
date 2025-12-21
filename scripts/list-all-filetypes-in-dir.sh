#!/usr/bin/env bash

# Finds all distinct file extensions in a directory.
# https://stackoverflow.com/a/1842270

find . -type f | perl -ne 'print $1 if m/\.([^.\/]+)$/' | sort -u
