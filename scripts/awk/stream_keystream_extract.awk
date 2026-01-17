# ==================================================
# Project: Krypton Writeups
# Script: stream_keystream_extract.awk
# ==================================================
# Author: Javier Laguna
#
# Purpose:
#   Extract the keystream (equivalent Vigenère key) from a stream cipher
#   or Vigenère-encrypted ciphertext using a known/chosen plaintext.
#
# Description:
#   This AWK script performs a known-plaintext attack against a stream
#   cipher or a Vigenère-style cipher by computing the keystream as the
#   difference between the ciphertext and the corresponding plaintext.
#
#   When the underlying keystream is periodic (e.g., due to a weak PRNG),
#   the extracted sequence represents the effective encryption key.
#
#   Although implemented using modular subtraction over an alphabet,
#   the same logic applies conceptually to XOR-based stream ciphers.
#
# Features:
#   - Keystream extraction from plaintext and ciphertext
#   - Equivalent Vigenère key reconstruction
#   - Useful for stream ciphers degraded to repeating-key schemes
#
# Usage:
#   awk -f stream_keystream_extract.awk \
#       -v plain_text="AAAA..." \
#       -v cipher_text="EICT..."
#
# Notes:
#   - plain_text and cipher_text must be aligned and of equal length
#   - Only characters present in the defined alphabet are supported
#   - Intended for educational and cryptographic learning purposes
# ==================================================
BEGIN{
    ALPHABET = ? ALPHABET : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    alphabet_len = length(ALPHABET)

    if (!(plain_text && cipher_text)){
        print "Error: plain_text and cipher_text must be specified" > "/dev/stderr"
        exit 1
    }

    if (length(plain_text) != length(cipher_text)) {
        print "Error: plain_text and cipher_text must have the same length" > "/dev/stderr"
        exit 1
    }

    n = length(cipher_text)

    print "Shists:"
    for (i = 1; i <= n; i++){
        a = index(ALPHABET, substr(plain_text,i,1))
        b = index(ALPHABET, substr(cipher_text,i,1))
        key[i] = ((b - a) + alphabet_len) % alphabet_len +1
        printf "%d ", key[i]
    }
    print ""
    
    key_len = length(key)
    print ("Equivalent Vigenere Password:")
    for (i=1 ; i<=key_len;i++){
        printf "%s", substr(ALPHABET, key[i],1)
    }
    print ""
}