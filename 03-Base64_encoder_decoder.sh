#!/bin/bash
set -euo pipefail

# =====================================
# Base64 encoder / decoder
# =====================================

BASE64_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

# -------------------------------------
# Bit
# -------------------------------------

# Convertimos un número entero que se puede representar 
# con $2 bits ($2= segundo argumento de la función)
# En una cadena con los $2 bits que lo componen
int_to_bits(){
    local byte=$1
    local bits=""
    for ((i=$2-1; i>=0; i--)); do
        bits+=$(( (byte >> i) & 1 ))
    done
    printf "%s" "$bits"
}
# Convertimos un byte (0-255) en una cadena con los 8 bits que lo componen
byte_to_bits() {
    int_to_bits $1 8
}

# Misma lógica. Pasamos de entero (0-63) a una cadena con los 6 bits que lo componen
int_to_bits6() {
    int_to_bits $1 6
}
# Proceso inverso a las funciones anteriores. Pasamos de un string de bits a un entero
# Simplemente hacemos 10100_2 =1\cdot 2^4+0\cdot 2^3+1\cdot 2^2+0\cdot 2^1+0\cdot 2^0
# Con notación bit shift
bits_to_int(){
    local bits=$1
    local value=0
    for ((i=0; i<$2; i++)); do
        value=$(( ( value << 1 ) | ${bits:i:1} ))
    done
    printf "%d" "$value"
}


bits_to_byte() {
    bits_to_int $1 8
}

bits6_to_int() {
    bits_to_int $1 6
}



# -------------------------------------
# Base64 encode
# -------------------------------------

base64_encode() {
    local input=$1
    local bits=""
    local output=""
    local len=${#input}

    # Read input byte by byte
    for ((i=0; i<len; i++)); do
        byte=$(printf "%d" "'${input:i:1}")
        bits+=$(byte_to_bits "$byte")
    done

    # Pad bits to multiple of 6
    local padding_bits=$(( (6 - ${#bits} % 6) ))
    pad=$(printf "%*s" "$padding_bits" "")
    pad=${pad// /0}
    bits+="$pad"
    # Convert 6-bit groups to Base64 chars
    for ((i=0; i<${#bits}; i+=6)); do
        chunk=${bits:i:6}
        index=$(bits6_to_int "$chunk")
        output+=${BASE64_ALPHABET:index:1}
    done

    # Add '=' padding
    case $((len % 3)) in
        1) output+="==" ;;
        2) output+="=" ;;
    esac

    printf "%s\n" "$output"
}

# -------------------------------------
# Base64 decode
# -------------------------------------

base64_decode() {
    local input=$1
    local bits=""
    local clean=${input%=*}        # Quitar '=' al final temporalmente

    # Convertimos caracteres de base64 a bits
    for ((i=0; i<${#clean}; i++)); do
        local ch=${clean:i:1}
        local index=$(expr index "$BASE64_ALPHABET" "$ch")
        [[ $index -eq 0 ]] && die "Invalid Base64 character: $ch"
        bits+=$(int_to_bits6 $((index - 1)))
    done

    # convertimos bits a bytes, solo bloques completos
    for ((i=0; i+8<=${#bits}; i+=8)); do
        byte_bits=${bits:i:8}
        byte=$(bits_to_byte "$byte_bits")
        printf "%b" "$(printf '\\%03o' "$byte")"
    done
    printf "\n"
}


usage() {
    cat <<EOF
Usage:
  $0 -e "string"   Encode
  $0 -d "string"   Decode
EOF
    exit 1
}

main() {
    [[ $# -ne 2 ]] && usage

    case "$1" in
        -e) base64_encode "$2" ;;
        -d) base64_decode "$2" ;;
        *) usage ;;
    esac
}

main "$@"