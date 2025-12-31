#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# Project: Krypton Writeups
# Script: caesar_decoder_cli.sh
# ==================================================
# Author: Javier Laguna
# Purpose:
#   Encrypt or decrypt text using the classical Caesar cipher.
#
# Description:
#   This script implements a Caesar shift over the English alphabet
#   (A–Z, a–z). Alphabetic characters are rotated by a given offset,
#   while non-alphabetic characters are preserved unchanged.
#
# Features:
#   - Self-contained Bash implementation
#   - Supports encryption and decryption
#   - Handles negative and large shifts using modular arithmetic
#   - Preserves letter case (uppercase / lowercase)
#   - Includes brute-force mode for cryptanalysis
#
# Usage:
#   See the usage() function or run the script without arguments.
#
# Notes:
#   - The alphabet size is fixed to 26 characters
#   - Decryption is implemented as encryption with a negative shift
#   - This tool is intended for educational and cryptographic learning purposes only
# ==================================================

# Caesar cipher implementation (English alphabet only)
readonly ALPHABET_SIZE=26 
usage() {
    cat <<EOF
Usage:
  Encrypt:      $0 -e "text" <shift>
  Decrypt:      $0 -d "text" <shift>
  Brute-force:  $0 -b "ciphertext"

Notes:
  - The alphabet used is A–Z / a–z
  - Non-alphabetic characters are preserved
  - Shifts may be negative or greater than 26
EOF
}

# Safe modulo operation (handles negative values correctly)
mod(){
    local a=$1 b=$2
    echo $(( (a % b + b) % b ))
}

# Encrypt or decrypt using a Caesar shift
# A negative shift performs decryption
encrypt() {
    local text=$1
    local offset=$2
    local result
    local char ascii base new

    # Normalize shift to range [0, 25]
    offset=$(mod "$offset" "$ALPHABET_SIZE")

    for (( i = 0;i < ${#text}; i++)); do 
        char=${text:i:1}
        
        # Only transform alphabetic characters
        if [[ $char =~ [[A-Za-z]] ]]; then
            ascii=$(printf "%d" "'$char")
            
            if [[ $char =~ [[A-Z]] ]]; then
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

# Try all possible Caesar shifts (brute force)
bruteforce() {
    local text="$1"
    local offset

    for offset in $(seq 0 $((ALPHABET_SIZE - 1))); do
        printf 'offset %2d: %s\n' "$offset" "$(encrypt "$text" "$((-$offset))")"
    done
}

main() {
    [[ $# -lt 2 ]] && { usage; exit 1; }

    case "$1" in
        -e)
            [[ $# -ne 3 ]] && { usage; exit 1; }
            encrypt "$2" "$3"
            ;;
        -b)
            bruteforce "$2"
            ;;
        -d)
            [[ $# -ne 3 ]] && { usage; exit 1; }
            encrypt "$2" "$((-$3))"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
