#!/usr/bin/env bash

SWIFTFORMAT=$(command -v swiftformat)
if [ -z "$SWIFTFORMAT" ]; then
    echo "swiftformat not found, please install it to use this hook."
    exit 1
fi

$SWIFTFORMAT . --lint
