#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# Project: Krypton Writeups
# Script: caesar_decoder_cli.sh
# ==================================================
# Author: Javier Laguna
#
# Purpose:
#   Encrypt or decrypt text using the classical Caesar cipher.
#
# Description:
#   This script implements a Caesar shift over the English alphabet
#   (A–Z, a–z). Alphabetic characters are rotated by a given offset,
#   while non-alphabetic characters are preserved unchanged.
#
#   The program is designed to work with standard input and output,
#   making it suitable for use with pipes and redirections.
#
# Features:
#   - Self-contained Bash implementation
#   - Supports encryption and decryption
#   - Handles negative and large shifts using modular arithmetic
#   - Preserves letter case (uppercase / lowercase)
#   - Supports brute-force attacks over all possible shifts
#   - Works with stdin/stdout for easy composition with Unix tools
#
# Usage:
#   See the usage() function or run the script without arguments.
#
# Notes:
#   - The alphabet size is fixed to 26 characters (English alphabet)
#   - Decryption is implemented as encryption with a negative shift
#   - This tool is intended for educational and cryptographic learning
#     purposes only.
# ==================================================



# Caesar cipher implementation (English alphabet only)
readonly ALPHABET_SIZE=26

usage() {
    cat <<EOF
Uso:
  Cifrar:
    $0 -e OFFSET < archivo

  Descifrar:
    $0 -d OFFSET < archivo

  Fuerza bruta:
    $0 -b < archivo
EOF
}

# Safe modulo operation (handles negative values correctly)
mod() {
    local a=$1 b=$2
    echo $(( (a % b + b) % b ))
}

# Encrypt or decrypt using a Caesar shift
# A negative shift performs decryption
encrypt_line() {
    local text=$1
    local offset=$2
    local result=""
    local char ascii base new

    # Normalize shift to range [0, 25]
    offset=$(mod "$offset" "$ALPHABET_SIZE")

    for ((i=0; i<${#text}; i++)); do
        char=${text:i:1}

        # Only transform alphabetic characters
        if [[ $char =~ [A-Za-z] ]]; then
            ascii=$(printf '%d' "'$char")

            if [[ $char =~ [A-Z] ]]; then
                base=65 # 'A'
            else
                base=97 # 'a'
            fi

            # Apply Caesar offset using modular arithmetic
            new=$(( (ascii - base + offset) % ALPHABET_SIZE + base ))
            # Convert ASCII code back to character
            result+=$(printf "\\$(printf '%03o' "$new")")
        else
            result+="$char"
        fi
    done

    printf '%s\n' "$result"
}
# Process input from stdin and encrypt/decrypt each line
process_stream_encrypt() {
    local offset=$1
    local line

    while IFS= read -r line || [[ -n $line ]]; do
        encrypt_line "$line" "$offset"
    done
}
# Try all possible Caesar shifts (brute-force attack)
process_stream_bruteforce() {
    local line offset

    while IFS= read -r line || [[ -n $line ]]; do
        for ((offset=0; offset<ALPHABET_SIZE; offset++)); do
            printf 'offset %2d: ' "$offset"
            encrypt_line "$line" "$((-offset))"
        done
        printf '\n'
    done
}

main() {
    [[ $# -lt 1 ]] && { usage; exit 1; }

    case "$1" in
        -e)
            [[ $# -ne 2 ]] && { usage; exit 1; }
            process_stream_encrypt "$2"
            ;;
        -d)
            [[ $# -ne 2 ]] && { usage; exit 1; }
            process_stream_encrypt "$((- $2))"
            ;;
        -b)
            [[ $# -ne 1 ]] && { usage; exit 1; }
            process_stream_bruteforce
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"