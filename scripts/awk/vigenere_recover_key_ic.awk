# ============================================================
# Project: Krypton Writeups
# Script: vigenere_recover_key_ic_multiple.awk
# Author: Javier Laguna
#
# Description:
#   Recover the key of a Vigenère cipher assuming the key
#   length is known. The script uses the Multiple Index of
#   Coincidence (MIC) method to recover relative key shifts,
#   and fixes the absolute key shift using chi-square
#   statistics against English letter frequencies.
#
# Methodology:
#   1. Normalize ciphertext(s) and remove non-alphabet chars
#   2. Split ciphertexts into key-length columns
#   3. Compute relative key shifts using cross-IC
#   4. Fix absolute key shift via chi-square minimization
#
# Usage:
#   awk -v key_len=5 \
#       [-v alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ] \
#       [-v shift_mode=chi_square|all] \
#       -f vigenere_recover_key_ic.awk ciphertext
#
# Options:
#   shift_mode:
#     - chi_square (default): output best recovered key
#     - all: output all possible keys (one per base shift)
#
# Notes:
#   - Supports multiple ciphertext files encrypted with
#     the same Vigenère key
#   - English language frequency model
#   - Intended for educational / portfolio purposes
# ============================================================

BEGIN {
    alphabet     = alphabet     ? alphabet     : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    shift_mode   = shift_mode   ? shift_mode   : "chi_square"
    freq_file    = freq_file    ? freq_file    : "../../data/freq/en.txt"

    if (!key_len || key_len<=0) {
        print "Error: key_len must be specified and >0" > "/dev/stderr"
        exit 1
    }
    validators["chi_square"]
    validators["all"]

    if (!(shift_mode in validators)) {
        print "Error: invalid shift_mode \"" shift_mode "\". Use 'chi_square' or 'all'." > "/dev/stderr"
        exit 1
    }
    if (!load_frequencies(freq_file)) {
        print "Error: could not load frequency file: " freq_file > "/dev/stderr"
        exit 1
    }
    
    alphabet_len = length(alphabet)

    if (alphabet_len != freq_len) {
        print "Warning: alphabet and frequency model size differ" > "/dev/stderr"
    }
}

{
    # Input normalization: uppercase and alphabet filtering
    $0 = toupper($0)
    clean = ""
    for (i = 1; i <= length($0); i++) {
        c = substr($0, i, 1)
        if (index(alphabet, c)) {
            clean = clean c
        }
    }
    texts[FILENAME] = texts[FILENAME] clean
}

# Main analysis
END {
    

    # Split ciphertext(s) into key columns
    split_columns(key_len, texts, cols, col_lengths)

    # Recover relative key shifts using column 1 as reference
    key_diff[1] = 0

    for (j = 2; j <= key_len; j++) {
        best_mic = 0
        best_shift = 0

        for (shift = 0; shift < alphabet_len; shift++) {
            mic = cross_ic(1, j, shift, alphabet_len)
            if (mic > best_mic) {
                best_mic = mic
                best_shift = shift
            }
        }
        key_diff[j] = best_shift
    }

    # Output handling
    if (shift_mode == "all") {
        printf("Recovered keys:\n\n")
        for (shift = 0; shift < alphabet_len; shift++){
            for (j = 1; j <= key_len; j++) {
                k = (shift + key_diff[j] + alphabet_len) % alphabet_len
                printf("%s", substr(alphabet, k + 1, 1))
            }
            printf("\n")

        }
    } else if (shift_mode == "chi_square") {
        best_shift = find_base_shift_chi(key_len, alphabet_len)
        printf("Recovered key: ")
         for (j = 1; j <= key_len; j++) {
                k = (best_shift + key_diff[j] + alphabet_len) % alphabet_len
                printf("%s", substr(alphabet, k + 1, 1))
            }
            printf("\n")
    }
    
    
}

# ============================================================
# Functions
# ============================================================

# Split ciphertext(s) into key-length columns

function split_columns(key_len, texts, cols, col_lengths,
                       file, i, col, c, idx) {

    delete cols
    delete col_lengths

    for (file in texts) {
        for (i = 1; i <= length(texts[file]); i++) {
            col = ((i - 1) % key_len) + 1
            char = substr(texts[file], i, 1)
            idx = index(alphabet, char)
            if (idx) {
                cols[col, col_lengths[col]++] = idx - 1
            }
        }
    }
    
}

# Cross Index of Coincidence between two columns
function cross_ic(col_idx1, col_idx2, shift, alphabet_len,
                  freq1, freq2, i, sum) {

    delete freq1
    delete freq2

    for (i = 0; i < col_lengths[col_idx1]; i++){
        freq1[cols[col_idx1, i]]++
    }

    for (i = 0; i < col_lengths[col_idx2]; i++){
        freq2[(cols[col_idx2, i] - shift + alphabet_len) % alphabet_len]++
    }

    sum = 0
    for (i = 0; i < alphabet_len; i++){
        sum += freq1[i] * freq2[i]
    }
        
    return sum / (col_lengths[col_idx1] * col_lengths[col_idx2])
}

function load_frequencies(file, line, letter, value, idx) {
    while ((getline line < file) > 0) {
        split(line, a, /[[:space:]]+/)
        letter = toupper(a[1])
        value  = a[2]
        idx = index(alphabet, letter)
        if (idx){
            expected_freq[idx - 1] = value
        }
        freq_len++
    }
    close(file)
    return freq_len > 0
}

# Chi-square statistic against English frequencies
function chi_square(freq, len,
                    i, obs, expected_count, chi) {

    chi = 0
    for (i = 0; i < alphabet_len; i++) {
        obs = freq[i]
        expected_count = expected_freq[i] * len
        if (expected_count > 0)
            chi += (obs - expected_count)^2 / expected_count
    }
    return chi
}

# Determine absolute key shift using chi-square minimization
function find_base_shift_chi(key_len, alphabet_len,
                             base, j, i, shift,
                             freq, total_len,
                             chi, best_chi, best_base) {

    best_chi = 1e9
    best_base = 0

    for (base = 0; base < alphabet_len; base++) {
        delete freq
        total_len = 0

        for (j = 1; j <= key_len; j++) {
            shift = (base + key_diff[j]) % alphabet_len
            for (i = 0; i < col_lengths[j]; i++) {
                freq[(cols[j, i] - shift + alphabet_len) % alphabet_len]++
                total_len++
            }
        }

        chi = chi_square(freq, total_len)
        if (chi < best_chi) {
            best_chi = chi
            best_base = base
        }
    }
    return best_base
}