#!/bin/bash
set -Eeuo pipefail

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

mod() {
    local a=$1 b=$2
    echo $(( (a % b + b) % b ))
}

encrypt_line() {
    local text=$1
    local offset=$2
    local result=""
    local char ascii base new

    offset=$(mod "$offset" "$ALPHABET_SIZE")

    for ((i=0; i<${#text}; i++)); do
        char=${text:i:1}

        if [[ $char =~ [A-Za-z] ]]; then
            ascii=$(printf '%d' "'$char")

            if [[ $char =~ [A-Z] ]]; then
                base=65
            else
                base=97
            fi

            new=$(( (ascii - base + offset) % ALPHABET_SIZE + base ))
            result+=$(printf "\\$(printf '%03o' "$new")")
        else
            result+="$char"
        fi
    done

    printf '%s\n' "$result"
}

process_stream_encrypt() {
    local offset=$1
    local line

    while IFS= read -r line || [[ -n $line ]]; do
        encrypt_line "$line" "$offset"
    done
}

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