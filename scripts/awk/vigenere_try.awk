# ==================================================
# Project: Krypton Writeups
# Script: vigenere_try.awk
# ==================================================
# Author: Javier Laguna
#
# Purpose:
#   Decode a Vigenère-encrypted ciphertext using a user-supplied key.
#
# Description:
#   This AWK script applies a given Vigenère key to a ciphertext in
#   order to recover the plaintext. The script assumes that the ciphertext 
#   consists only of uppercase letters A–Z.
#
#   The key is applied cyclically across the ciphertext, subtracting
#   the corresponding key letter shift from each character and
#   recomposing the plaintext in its original order.
#
#   This tool is intended to be used together with a frequency analysis
#   script (vigenere_freq.awk), allowing the user to manually test candidate
#   keys derived from statistical analysis.
#
# Features:
#   - Vigenère decryption with a known key
#   - Simple, direct recomposition of plaintext
#   - Designed for manual cryptanalysis workflows
#
# Usage:
#   awk -v key=SECRET -f vigenere_try.awk ciphertext.txt
#
# Notes:
#   - The key must be provided via the -v key=... argument
#   - Input text must be uppercase A–Z with no spaces or punctuation
#   - No validation is performed on key length or characters
#   - This tool is intended for educational and cryptographic learning
#     purposes only
# ==================================================

BEGIN {
    keylen = length(key)
    A = ord("A")
}

{
    for (i = 1; i <= length($0); i++) {
        cipher_char = substr($0, i, 1)
        col = (i - 1) % keylen
        key_char  = substr(key, col + 1, 1)

        shift = ord(key_char)

        plain_val = (ord(cipher_char) - shift + 26) % 26
        printf "%c", plain_val + A
    }
    print ""
}

function ord(c) {
    return index("ABCDEFGHIJKLMNOPQRSTUVWXYZ", c) - 1 + 65
}