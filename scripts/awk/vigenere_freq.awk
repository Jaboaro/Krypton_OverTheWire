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
#   All input files are assumed to be encrypted with the SAME Vigenère
#   key and are automatically aligned per key length, allowing joint
#   frequency analysis without manual preprocessing.
#
#   For each column, ciphertext letters are ordered from most frequent
#   to least frequent. Assuming a given plaintext letter (by default
#   'E'), the script computes the corresponding candidate key letter
#   that would map each ciphertext letter to that assumed plaintext.
#
# Features:
#   - Column-wise separation of Vigenère ciphertext
#   - Joint frequency analysis across multiple ciphertext files
#   - Frequencies ordered from most to least common
#   - Direct mapping from ciphertext letters to candidate key letters
#   - Compact, human-readable output for manual cryptanalysis
#
# Usage:
#   awk -v key_len=6 [-v assumed=E] -f vigenere_freq.awk \
#       ciphertext1 ciphertext2 ...
#
# Notes:
#   - Only characters present in the alphabet (A–Z) are analyzed
#   - The assumed plaintext letter defaults to 'E' (English frequency)
#   - The script assumes a classical A–Z Vigenère cipher
#   - Intended for educational and cryptographic learning purposes
# ==================================================


BEGIN {
    A = ord("A")
    assumed = ord(assumed ? assumed : "E")
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if (!key_len || key_len<=0){
        print "Error: key_len must be provided (-v key_len=N)" > "/dev/stderr"
        exit 1
    }
}

{
    # Normalize input: uppercase and keep only alphabetic characters
    $0 = toupper($0)
    clean=""
    for (i = 1; i <= length($0); i++) {
        char = substr($0, i, 1)
        if (index(alphabet, char)) {
            clean = clean char
        }
    }

    # Concatenate the entire content of each file into a single string
    texts[FILENAME] = texts[FILENAME] clean
}

END {
    for (file in texts){
        lengths[file] = length(texts[file])
    }
    count_freq_by_col(key_len, texts, lengths, alphabet, freq, col_lengths)

    for (col = 1; col <= key_len; col++) {
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
                    maxch = substr(alphabet, idx[2], 1)
                }
            }

            if (maxfreq == 0)
                break


            keyshift = (ord(maxch) - assumed + 26) % 26
            keyletter = sprintf("%c", keyshift + A)

            ordered_chars[idx_out]=maxch
            ordered_keys[idx_out]=keyletter

            freq[col, index(alphabet,maxch)] = 0
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
function count_freq_by_col(key_len, texts, lengths, alphabet, freq, col_lengths,
                           col, file, usable_len, i, char, idx){

    delete freq
    delete col_lengths

    for (col = 1; col <= key_len; col++){

        for (file in texts){

            # Ignore trailing characters that do not complete a full key cycle
            usable_len = lengths[file] - (lengths[file] % key_len)

            for (i = col; i <= usable_len; i+=key_len){
                char = substr(texts[file], i, 1)
                idx = index(alphabet, char)
                if (idx > 0) {
                    freq[col,idx]++
                    col_lengths[col]++
                }
            }
        }
    }
}