#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# Project: Krypton Writeups
# Script: base64_decoder.sh
# ==================================================
# Author: Javier Laguna
#
# Purpose:
#   Encode or decode data using the Base64 representation.
#
# Description:
#   This script provides an educational implementation of the Base64
#   encoding and decoding process, operating at the bit level.
#
#   Base64 is not an encryption algorithm but a binary-to-text encoding
#   scheme commonly used to safely transmit binary data over text-based
#   channels.
#
#   The implementation illustrates how bytes are grouped, split into
#   6-bit values, mapped to the Base64 alphabet, and padded when needed.
#
# Features:
#   - Pure Bash implementation (no external encoders required)
#   - Bit-level processing of input data
#   - Manual Base64 alphabet mapping
#   - Support for encoding and decoding
#   - Optional verbose mode to visualize intermediate steps
#   - Designed for educational and learning purposes
#
# Usage:
#   See the usage() function or run the script without arguments.
#
# Notes:
#   - This implementation prioritizes clarity over performance
#   - Intended for learning how Base64 works internally
#   - This tool is intended for educational and cryptographic learning purposes only
# ==================================================

BASE64_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
VERBOSE=0

# -------------------------------------
# Error handler
# -------------------------------------
die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

verbose() {
    if (( VERBOSE )); then
        printf "$1"
        printf "\n"
    else
        :  # null command
    fi
}

# -------------------------------------
# Bit manipulation functions
# -------------------------------------

# int_to_bits <number> <bits_count>
# Convert an integer to a binary string with bits_count bits
int_to_bits() {
    local value=$1
    local bits_count=$2
    local bits=""
    for ((i=bits_count-1; i>=0; i--)); do
        bits+=$(( (value >> i) & 1 ))
    done
    printf "%s" "$bits"
}
# byte_to_bits <byte>
# Convert a byte (integer between 0-255) to 8-bit binary string
byte_to_bits() { int_to_bits $1 8; }

# int_to_bits6 <number>
# Convert integer (0-63) to 6-bit binary string
int_to_bits6() { int_to_bits $1 6; }

# bits_to_int <bitstring> <num_bits>
# Convert a binary string to integer
bits_to_int(){
local bits=$1
    local num_bits=$2
    local value=0
    for ((i=0; i<num_bits; i++)); do
        value=$(( (value << 1) | ${bits:i:1} ))
    done
    printf "%d" "$value"
}


bits_to_byte() { bits_to_int $1 8; }

bits6_to_int() { bits_to_int $1 6; }



# -------------------------------------
# Base64 encode
# -------------------------------------

base64_encode() {
    local input
    input="$1"
    local bits="" output=""
    local len=${#input}
    verbose "Encoding $len characters..."
    # Convert input to binary string
    for ((i=0; i<len; i++)); do
        local byte
        byte=$(printf "%d" "'${input:i:1}")
        local byte_bits
        byte_bits=$(byte_to_bits "$byte")
        verbose "$(printf "Char: '%s' -> byte: %3d -> bits: %s" "${input:i:1}" "$byte" "$byte_bits")"
        bits+="$byte_bits"
    done

    # Pad bits to multiple of 6
    local padding_bits=$(( (6 - (${#bits} % 6)) % 6 ))
    bits+=$(printf "%0${padding_bits}d" 0)
    verbose "Total bits (padded to multiple of 6):\n $bits"
    
    # Convert 6-bit chunks to Base64 characters
    for ((i=0; i<${#bits}; i+=6)); do
        local chunk=${bits:i:6}
        local index=$(bits6_to_int "$chunk")
        output+=${BASE64_ALPHABET:index:1}
        verbose "$(printf "Chunk: %s -> index: %2d-> char: %c" "$chunk" "$index" "${BASE64_ALPHABET:index:1}")"
    done

    

    # Add '=' padding to make output length multiple of 4
    case $((len % 3)) in
        1) output+="==";;
        2) output+="=";;
    esac
    printf "%s\n" "$output"
}

base64_decode() {
    local input
    local output=""
    input="$1"
    local bits="" clean="${input%%=*}"

    verbose "Decoding input: $input"

    for ((i=0; i<${#clean}; i++)); do
        local ch=${clean:i:1}
        local index
        index=$(expr index "$BASE64_ALPHABET" "$ch")
        [[ $index -eq 0 ]] && die "Invalid Base64 character: $ch"
        local chunk_bits
        chunk_bits=$(int_to_bits6 $((index - 1)))
        verbose "$(printf "Char: %s -> index: %2d -> bits: %s" "$ch" "$((index-1))" "$chunk_bits")"
        bits+="$chunk_bits"
    done

    for ((i=0; i+8<=${#bits}; i+=8)); do
        local byte_bits=${bits:i:8}
        local byte=$(bits_to_byte "$byte_bits")
        local decoded_ch=$(printf "%b" "$(printf '\\%03o' "$byte")")
        verbose "$(printf "bits: %s -> index %3d -> char: %s" "$byte_bits" "$byte" "$decoded_ch")"
        output+="$decoded_ch"
    done
    printf "%s\n" "$output"
}

# -------------------------------------
# Usage function
# -------------------------------------
usage() {
    cat <<EOF
Usage:
  $0 -e "string" or --encode <string> [-v]   Encode to Base64
  $0 -d "string" or --decode <string> [-v]   Decode from Base64
  -v                                              Enable verbose mode
EOF
    exit 1
}

# -------------------------------------
# Main
# -------------------------------------
main() {
    [[ $# -lt 2 ]] && usage

    local action source

    # parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e|--encode) action="encode"; shift; source="$1";;
            -d|--decode) action="decode"; shift; source="$1";;
            -v) VERBOSE=1;;
            *) usage;;
        esac
        shift
    done

    case "$action" in
        encode) base64_encode "$source";;
        decode) base64_decode "$source";;
        *) usage;;
    esac
}


main "$@"