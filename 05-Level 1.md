# Krypton Level 1 → Level 2
```text
Level Info
The password for level 2 is in the file ‘krypton2’. It is ‘encrypted’ using a simple rotation. It is also in non-standard ciphertext format. When using alpha characters for cipher text it is normal to group the letters into 5 letter clusters, regardless of word boundaries. This helps obfuscate any patterns. This file has kept the plain text word boundaries and carried them to the cipher text. Enjoy!
```

En primer lugar, nos conectamos a la máquina objetivo mediante servicio ssh:
```bash
ssh krypton1@krypton.labs.overthewire.org -p 2231
                      _                     _
                     | | ___ __ _   _ _ __ | |_ ___  _ __
                     | |/ / '__| | | | '_ \| __/ _ \| '_ \
                     |   <| |  | |_| | |_) | || (_) | | | |
                     |_|\_\_|   \__, | .__/ \__\___/|_| |_|
                                |___/|_|

                      This is an OverTheWire game server.
            More information on http://www.overthewire.org/wargames

backend: gibson-0
```
Los archivos de los siguientes niveles no estarán en el "home" de cada usuario al que te conectes. Vamos a buscar donde se encuentran los archivos mencionados.

```bash
find / -name krypton* 2>/dev/null
/krypton
/krypton/krypton1
/krypton/krypton1/krypton2
/krypton/krypton7
/krypton/krypton3
/krypton/krypton3/krypton4
/krypton/krypton6
/krypton/krypton6/krypton7
/krypton/krypton5
/krypton/krypton5/krypton6
/krypton/krypton4
/krypton/krypton4/krypton5
/krypton/krypton2
/krypton/krypton2/krypton3
...
```
Con esto hemos "descubierto" que los enunciados de los problemas se encuentran en subcarpetas de `/krypton` (no era complicado de encontrar).

Vamos a ver el contenido de `/krypton/krypton1/krypton2`:
```bash
cat /krypton/krypton1/krypton2
YRIRY GJB CNFFJBEQ EBGGRA
```
El enunciado indica que el método de encriptación consiste en rotar las letras de un texto un número fijo de posiciones en el alfabeto. Este método se conoce como **cifrado César**.
Por tanto, la “contraseña” para desencriptar el mensaje es precisamente ese número de posiciones de rotación. Una vez conocido, basta con rotar las letras la misma cantidad, pero en sentido contrario.

Por ejemplo, la palabra **“HOLA”** cifrada con un desplazamiento de 4 posiciones se obtiene de la siguiente manera.
A la letra 'A' le corresponde la 'E', ya que es la cuarta letra que aparece después en el alfabeto. En general, la correspondencia es:
```text
ABCDEFGHIJKLMNOPQRSTUVWXYZ
EFGHIJKLMNOPQRSTUVWXYZABCD
```
Para **encriptar**, se sustituye cada letra de la fila superior por la letra que tiene debajo:
```text
HOLA
LSPE
```
Para **desencriptar**, se hace el proceso inverso: se toma cada letra cifrada (fila inferior) y se sustituye por la correspondiente de la fila superior. Por ejemplo:
```text
QYRHS
MUNDO
```
Para desencriptar un texto cifrado con el método César, la forma más sencilla consiste en probar todas las posibles rotaciones del alfabeto: **25 en el caso del alfabeto inglés y 26 en el español**. En cada intento, basta con desplazar las letras y comprobar si el resultado tiene sentido.

No obstante, con mucha frecuencia el cifrado utilizado es **César 13**, también conocido como **ROT13**. Este caso es especialmente popular porque tiene una propiedad muy particular: **encriptar y desencriptar son exactamente el mismo proceso.**
Esto se debe a que el alfabeto tiene 26 letras y, al rotar 13 posiciones, cada letra se transforma en su opuesta; aplicar de nuevo la misma rotación devuelve el texto original.

Por esta razón, ROT13 se ha usado tradicionalmente como un método simple para ocultar información sin necesidad de una clave adicional, por ejemplo en foros, acertijos o textos con spoilers. Aunque no ofrece seguridad real, es famoso por su simplicidad y por esa simetría que lo hace fácil de usar y de entender.

Al comprobar esta hipótesis, observamos que efectivamente el texto está codificado usando ROT13.

```bash
cat krypton2 | tr [A-Za-z] [N-ZA-Mn-za-m]
```

Con este comando hemos resuelto el acertijo y podemos avanzar al siguiente nivel. Sin embargo, este éxito se debe en parte a la suerte y al conocimiento previo de que ROT13 es el cifrado César más utilizado. En un escenario real, no siempre podemos asumir cuál es el desplazamiento correcto.

Además, desencriptar el texto manualmente con tr resulta poco práctico, ya que es necesario calcular a mano la correspondencia entre letras para cada posible rotación. Por este motivo, vamos a mejorar la solución desarrollando un script en Bash que rompa este tipo de encriptación de forma automática, probando todas las rotaciones posibles mediante fuerza bruta y mostrando los resultados para su análisis.

```bash
#!/bin/bash
set -Eeuo pipefail

#solo alfabeto inglés
readonly ALPHABET_SIZE=26 
usage() {
    cat <<EOF
Uso:
  Encriptar:     $0 -e "texto" <desplazamiento>
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
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
```