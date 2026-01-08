# ============================================================
# Project: Krypton Writeups
# Script: vigenere_try.awk
# Author: Javier Laguna
#
# Description:
#   Decrypt a Vigenère-encrypted ciphertext using a known key.
#   The script automatically normalizes input, ignores
#   non-alphabet characters, and supports multiple input files.
#
#   Alphabet and key are treated consistently as index-based
#   symbols, allowing easy adaptation to different languages
#   or custom alphabets.
#
# Features:
#   - Vigenère decryption with known key
#   - No manual preprocessing required
#   - Supports multiple input files
#   - Configurable alphabet
#
# Usage:
#   awk -v key=SECRET \
#       [-v alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ] \
#       -f vigenere_try.awk ciphertext1 [ciphertext2 ...]
#
# Notes:
#   - Only characters present in the alphabet are decrypted
#   - Other characters are preserved as-is
#   - Intended for educational purposes only
# ============================================================

BEGIN {
    alphabet     = alphabet ? alphabet : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    alphabet_len = length(alphabet)

    if (!key || length(key) == 0) {
        print "Error: key must be provided via -v key=..." > "/dev/stderr"
        exit 1
    }

    key = toupper(key)
    key_len = length(key)
    pos = 0
}

{
    $0 = toupper($0)

    for (i = 1; i <= length($0); i++) {
        char = substr($0, i, 1)
        char_idx = index(alphabet, char)

        if (char_idx) {
            key_char = substr(key, (pos % key_len) + 1, 1)
            key_idx  = index(alphabet, key_char)

            plain_idx = (char_idx - key_idx + alphabet_len) % alphabet_len
            plain_char = substr(alphabet, plain_idx + 1, 1)

            printf "%s", plain_char
            pos++
        } else {
            # Preserve non-alphabet characters
            printf "%s", char
        }
    }
    print ""
}