# ==================================================
# Project: Krypton Writeups
# Script: vigenere_key_length.awk
# ==================================================
# Author: Javier Laguna
#
# Purpose:
#   Estimate the key length of a Vigenère-encrypted ciphertext using
#   the Index of Coincidence (IC) method.
#
# Description:
#   This AWK script tests a range of candidate key lengths and computes
#   the Index of Coincidence for each key column obtained by splitting
#   the ciphertext according to the assumed key length.
#
#   For the correct key length, each column behaves like a monoalphabetic
#   substitution cipher and its IC approaches the expected IC of the
#   plaintext language. The script identifies candidate key lengths by
#   comparing the computed ICs against a configurable expected value
#   within a given error margin.
#
#   Multiple input files encrypted with the SAME Vigenère key are
#   supported and processed jointly, with proper column alignment.
#
# Features:
#   - Index of Coincidence computation per key column
#   - Support for multiple ciphertext files
#   - Configurable alphabet and language IC
#   - Mean or strict (all-columns) error validation modes
#   - Fully parameterized via command-line variables
#
# Usage:
#   awk [-v min_key_len=2] [-v max_key_len=20] \
#       [-v expected_ic=0.0661] [-v error_margin=0.015] \
#       [-v error_mode=mean] [-v alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ] \
#       -f vigenere_key_length.awk ciphertext1 ciphertext2 ...
#
# Notes:
#   - Only characters present in the specified alphabet are analyzed
#   - Default parameters assume English plaintext (IC apprx 0.066)
#   - Intended for educational and cryptographic learning purposes
# ==================================================

BEGIN {
    alphabet        = alphabet      ? alphabet      : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    expected_ic     = expected_ic   ? expected_ic   : 0.0661
    error_margin    = error_margin  ? error_margin  : 0.015
    error_mode      = error_mode    ? error_mode    : "mean"
    min_key_len     = min_key_len   ? min_key_len   : 2
    max_key_len     = max_key_len   ? max_key_len   : 20


    validators["mean"] = 1
    validators["all"]  = 2

    if (!(error_mode in validators)) {
        print "Error: invalid error_mode \"" error_mode "\". Use 'mean' or 'all'." > "/dev/stderr"
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
    alphabet_len = length(alphabet)

    # Precompute text lengths per file
    for (file in texts){
        lengths[file] = length(texts[file])
    }
    
    # Test each candidate key length
    for (key_len = min_key_len; key_len <= max_key_len; key_len++){
        
        # Compute frequency tables per column
        count_freq_by_col(key_len, texts, lengths, alphabet, freq, col_lengths)

        delete ics

        # Compute IC for each column
        for (col = 1; col <= key_len; col++){
            delete freq_col

            for (idx=1; idx <=alphabet_len; idx++){
                freq_col[idx] = freq[col,idx]
            }

            ics[col] = index_of_coincidence(col_lengths[col], freq_col, alphabet_len)
        }
        
        
        # Validate ICs according to the selected error mode
        if (is_valid_ic(ics, error_mode)){
            printf("Possible key length: %d\n", key_len)
        }
    }
}

# Absolute value
function abs(x){
    return x >= 0 ? x : -x
}

# Count character frequencies per key column
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

# Compute the Index of Coincidence for a given frequency distribution
function index_of_coincidence(text_len, freq, alphabet_len,
                              sum, i, ic){

    if (text_len < 2) {
        return 0
    } 

    sum = 0
    for (i = 1; i<= alphabet_len; i++) {
        sum += freq[i] * (freq[i]-1)
    }
    ic = sum / (text_len * (text_len-1))
    return ic
}

# Validate ICs using the mean absolute error
function is_valid_mean_error(IC,
                             total_err,col,num_cols,mean_err){

    total_err = 0
    num_cols = 0

    for (col in IC){
        total_err += abs(IC[col] - expected_ic)
        num_cols++
    }
    mean_err=total_err/num_cols
    return (mean_err < error_margin)
}

# Validate ICs requiring all columns to be within the error margin
function is_valid_all_error(IC,
                            col){
    for (col in IC){
        if (abs(IC[col] - expected_ic) > error_margin){
            return 0
        }
    }

    return 1
}

# Dispatch validation according to error mode
function is_valid_ic(IC, error_mode) {

    if (error_mode == "all") {
        return is_valid_all_error(IC)
    } else if (error_mode == "mean") {
        return is_valid_mean_error(IC)
    }
}