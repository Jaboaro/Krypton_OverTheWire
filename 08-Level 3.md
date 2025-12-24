# Krypton Level 1 → Level 2
```text
ROT13 is a simple substitution cipher.

Substitution ciphers are a simple replacement algorithm. In this example of a substitution cipher, we will explore a ‘monoalphebetic’ cipher. Monoalphebetic means, literally, “one alphabet” and you will see why.

This level contains an old form of cipher called a ‘Caesar Cipher’. A Caesar cipher shifts the alphabet by a set number. For example:

plain:  a b c d e f g h i j k ...
cipher: G H I J K L M N O P Q ...
In this example, the letter ‘a’ in plaintext is replaced by a ‘G’ in the ciphertext so, for example, the plaintext ‘bad’ becomes ‘HGJ’ in ciphertext.

The password for level 3 is in the file krypton3. It is in 5 letter group ciphertext. It is encrypted with a Caesar Cipher. Without any further information, this cipher text may be difficult to break. You do not have direct access to the key, however you do have access to a program that will encrypt anything you wish to give it using the key. If you think logically, this is completely easy.

One shot can solve it!

Have fun.
```

En este reto se nos indica que la contraseña del nivel 3 se encuentra en el archivo krypton3, cifrada mediante un cifrado César. No conocemos el desplazamiento utilizado, pero sí sabemos algo muy importante: tenemos acceso al programa que se utiliza para cifrar textos con esa clave.

Esto significa que, aunque no conozcamos directamente la contraseña, podemos aprovechar el propio programa de cifrado para deducirla. Si recordamos la explicación del nivel anterior sobre el funcionamiento de este método de encriptación, ya se nos puede estar ocurriendo cómo proceder a continuación. Sin embargo, antes de empezar y por simple curiosidad, vamos a intentar echar un vistazo a este programa para ver si podemos rescatar algo de información.

```bash
strings encrypt
```
El resultado no aporta mucho, salvo una línea orientativa:
`usage: encrypt foo  - where foo is the file containing the plaintext`


Como no tenemos permisos de escritura en el directorio del reto (y para no ensuciar el entorno para futuros jugadpres), trabajaremos en un directorio temporal:

```bash
mktemp -d
/tmp/tmp.XokOox1MaY
cd /tmp/tmp.XokOox1MaY
ln -s /krypton/krypton2/keyfile.dat
```
### Obtención del desplazamiento

Con todo preparado, vamos a resolver este reto. La idea es sencilla: si conseguimos saber a qué letra se transforma otra conocida, podremos deducir el desplazamiento del cifrado. Para ello, basta con cifrar una sola letra y observar el resultado. Sin embargo, ya que tenemos la posibilidad, vamos a codificar al alfabeto completo para tener un diccionario.

Creamos un archivo con el abecedario
```bash
echo "ABCDEFGHIJKLMNOPQRSTUVWXYZ" > texto_plano.txt
```
Lo ciframos
```bash
/krypton/krypton2/encrypt texto_plano.txt
```
Ahora listamos los archivos generados:
```bash
ls
ciphertext  keyfile.dat  texto_plano.txt
```
Añadimos un salto de línea al final del fichero cifrado para visualizarlo correctamente:
```bash
echo "" >> ciphertext
```
Y mostramos ambos contenidos:
```bash
cat texto_plano.txt ciphertext
ABCDEFGHIJKLMNOPQRSTUVWXYZ
MNOPQRSTUVWXYZABCDEFGHIJKL
```

Esto indica claramente que el cifrado aplica un desplazamiento de $12$ posiciones.
### Descifrado del mensaje

Con esta información, ya podemos descifrar el contenido de `krypton3`. Una forma directa es usar `tr`:
```bash
cat /krypton/krypton2/krypton3 | tr [M-ZA-Lm-za-l] [A-Za-z]
```
También podemos usar el script que desarrollamos en el ejercicio anterior:
```bash
./06-Caesar_BruteForce.sh -d "OMQEMDUEQMEK" 12
```
O (aunque no sea el método de resolución intencionado) podemos obtenerla mediante fuerza bruta
```bash
./06-Caesar_BruteForce.sh -b "OMQEMDUEQMEK"
```
### Mejora del script anterior
Este ejercicio nos da una idea clara de cómo mejorar el programa del nivel anterior. En lugar de exigir que el texto se pase como argumento, resulta mucho más flexible permitir que el programa:

- lea el texto desde stdin

- escriba el resultado por stdout

- pueda usarse con redirecciones y pipes

```bash
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
```