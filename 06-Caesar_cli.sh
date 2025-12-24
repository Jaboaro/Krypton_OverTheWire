#!/bin/bash
set -Eeuo pipefail

#solo alfabeto inglés
readonly ALPHABET_SIZE=26 
usage() {
    cat <<EOF
Uso:
  Encriptar:     $0 -e "texto" <desplazamiento>
  Desencriptar:  $0 -d "texto" <desplazamiento>
  Fuerza bruta:  $0 -b "texto_cifrado"
EOF
}


mod(){
    local a=$1 b=$2
    echo $(( (a % b + b) % b ))
}


encrypt() {
    local text=$1
    local offset=$2
    local result
    local char ascii base new

    #Permitimos offsets mayores a 26 (y negativos para desencriptar)
    offset=$(mod "$offset" "$ALPHABET_SIZE")

    for (( i = 0;i < ${#text}; i++)); do 
        char=${text:i:1}
        
        # Solo editamos si son letras
        if [[ $char =~ [[:alpha:]] ]]; then
            # Pasamos a número
            ascii=$(printf "%d" "'$char")
            
            if [[ $char =~ [[:upper:]] ]]; then
                # Empezamos a sumar en 65 si son mayúsculas (ya que A en ASCII es 65)
                base=65
            else
                # O en 97 si son minúsculas
                base=97
            fi
            new=$(( (ascii - base + offset) % ALPHABET_SIZE + base ))
            # Pasamos de decimal a octal y de octal a ASCII
            result+=$(printf "\\$(printf '%03o' "$new")")
        else
            result+="$char"
        fi
        done

    printf '%s\n' "$result"
}
bruteforce() {
    local text="$1"
    local offset

    for offset in $(seq 0 $((ALPHABET_SIZE - 1))); do
        printf 'offset %2d: %s\n' "$offset" "$(encrypt "$text" "$((-$offset))")"
    done
}

main() {
    [[ $# -lt 2 ]] && { usage; exit 1; }

    case "$1" in
        -e)
            [[ $# -ne 3 ]] && { usage; exit 1; }
            encrypt "$2" "$3"
            ;;
        -b)
            bruteforce "$2"
            ;;
        -d)
            [[ $# -ne 3 ]] && { usage; exit 1; }
            encrypt "$2" "$((-$3))"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
