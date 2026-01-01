# ==================================================
# Project: Krypton Writeups
# Script: vigenere_freq.awk
# ==================================================
# Author: Javier Laguna
#
# Purpose:
#   Assist in the cryptanalysis of the Vigenère cipher by performing
#   per-column frequency analysis when the key length is known.
#
# Description:
#   This AWK script splits a Vigenère-encrypted ciphertext into N
#   independent streams (one per key position) and computes the
#   frequency distribution of letters for each stream.
#
#   For each column, the letters are ordered from most frequent to
#   least frequent. Additionally, assuming a given plaintext letter
#   (by default 'E'), the script computes the corresponding key letter
#   that would map each ciphertext letter to that assumed plaintext.
#
#   The output is designed to be compact and human-readable, allowing
#   the user to manually test key hypotheses based on frequency order.
#
# Features:
#   - Column-wise separation of Vigenère ciphertext
#   - Frequency analysis per key position
#   - Frequencies sorted from most to least common
#   - Direct mapping from ciphertext letters to candidate key letters
#   - Minimal, compact output for manual cryptanalysis
#
# Usage:
#   awk -v keylen=6 [-v assumed=E] -f vigenere_freq.awk ciphertext.txt
#
# Notes:
#   - Input text should be uppercase A–Z with no spaces or punctuation
#   - The assumed plaintext letter defaults to 'E' (English frequency)
#   - This tool is intended for educational and cryptographic learning
#     purposes only
# ==================================================

BEGIN {
    A = ord("A")
    assumed = ord(assumed ? assumed : "E")
}

{
    for (i = 1; i <= length($0); i++) {
        ch = substr($0, i, 1)
        col = (i - 1) % keylen
        freq[col, ch]++
    }
}

END {
    for (col = 0; col < keylen; col++) {
        print "=========== Columna", col, "==========="

        # reset arrays for this column
        delete ordered_chars
        delete ordered_keys

        idx_out = 0

        # selection-sort–like ordering by frequency

        while (1) {
            maxfreq = 0
            maxch = ""

            for (k in freq) {
                split(k, idx, SUBSEP)
                if (idx[1] == col && freq[k] > maxfreq) {
                    maxfreq = freq[k]
                    maxch = idx[2]
                }
            }

            if (maxfreq == 0)
                break


            keyshift = (ord(maxch) - assumed + 26) % 26
            keyletter = sprintf("%c", keyshift + A)

            ordered_chars[idx_out]=maxch
            ordered_keys[idx_out]=keyletter

            freq[col, maxch] = 0
            idx_out++
        }

        # compact visual output
        printf "CHARS: "
        for (i=0;i<idx_out;i++){
            printf "%s", ordered_chars[i]
        }
        printf "\n       "
        for (i=0;i<idx_out;i++){
            printf "↓"
        }
        printf "\n KEYS: "
        for (i=0;i<idx_out;i++){
            printf "%s", ordered_keys[i]
        }
        print "\n"   
    }
}

function ord(c) {
    return index("ABCDEFGHIJKLMNOPQRSTUVWXYZ", c) - 1 + 65
}