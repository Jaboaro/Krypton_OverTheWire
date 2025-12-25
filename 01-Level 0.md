# Krypton Level 0 → Level 1
```
Welcome to Krypton! The first level is easy. The following string encodes the password using Base64:

S1JZUFRPTklTR1JFQVQ=

Use this password to log in to krypton.labs.overthewire.org with username krypton1 using SSH on port 2231. You can find the files for other levels in /krypton/
```

La resolución de este nivel es muy sencilla ya que nos indica cómo se ha "encriptado" el mensaje. 
```bash
echo "S1JZUFRPTklTR1JFQVQ=" | base64 --decode
```

Como la solución de este reto ha sido muy corta, vamos a aprovechar para profundizar un poco más en cómo funciona este "método de cifrado" internamente.
## Sistemas de numeración y `base64`
Un **sistema de numeración** es un conjunto de reglas que permite representar números mediante símbolos. **Base64 es un sistema de numeración posicional**, es decir, un sistema en el que el valor de cada símbolo depende de la posición que ocupa. Aunque pueda parecer algo abstracto, nuestro sistema de numeración habitual también es posicional: no representa lo mismo el número 23 que el 32, ya que el valor del símbolo ‘3’ cambia según su posición.

Esto contrasta con sistemas no posicionales, como el sistema romano, donde el valor de cada símbolo es fijo y los números se forman mediante sumas y restas de símbolos adyacentes.

Los sistemas más comunes son los **sistemas posicionales de base aritmética**, entre los que se encuentra el sistema decimal. En el sistema decimal utilizamos **10 símbolos** (0–9). Cada símbolo representa un valor entre cero y nueve, y cuando se agotan los símbolos, se pasa a la siguiente posición. Por ejemplo, el número 10 se representa como un 1 seguido de un 0, y este patrón se repite para números mayores.

Desde un punto de vista matemático, un número se expresa como una combinación de potencias de la base. Por ejemplo:

$$2301 = 2\cdot10^4+3\cdot 10^3 + 0\cdot 10^1 + 1\cdot 10^0$$

No hay nada especial en usar la base 10: se suele atribuir su origen a que tenemos diez dedos, pero podrían emplearse otras bases sin ningún problema.

Uno de los sistemas más importantes es el sistema binario, que utiliza únicamente dos símbolos: 0 y 1. Por ejemplo:

$$10100_2 =1\cdot 2^4+0\cdot 2^3+1\cdot 2^2+0\cdot 2^1+0\cdot 2^0$$

El uso del binario en los ordenadores se debe principalmente a dos motivos. En primer lugar, es mucho más sencillo y fiable distinguir entre dos estados físicos (hay corriente o no la hay) que entre múltiples niveles de voltaje. En segundo lugar, la lógica booleana demuestra que cualquier proceso lógico y computacional puede representarse utilizando únicamente dos valores: verdadero y falso.

Base64 no es más que otro sistema de numeración posicional de este tipo, pero con **64 símbolos** en lugar de 10 o 2. Habitualmente, estos símbolos son:

- Letras mayúsculas: A–Z

- Letras minúsculas: a–z

- Dígitos: 0–9

- Dos símbolos adicionales: + y /

### ¿Por qué 64 dígitos?
Es la potencia de dos ($2^6=64$) más grande que se puede representar con los caracteres imprimibles ASCII. Los caracteres imprimibles son aquellos que se pueden representar visualmente. Hay 95 caracteres imprimibles y la siguiente potenica de dos es $2^7=128$. Nos interesa que sea una potencia de dos porque le da propiedades interesantes para luego traducirlo a binario internamente (sabemos que los ordenadores emplean internamente exclusivamente 0's y 1's).

### ¿Pero si es un sistema para representar números, cómo nos permite  codigicar texto?


En este método se aprecia una de las ventajas de que **64 es una potencia de 2**. Cada símbolo de Base64 tiene asociado un número entre 0 y 63, y estos números pueden representarse internamente en binario usando exactamente **6 bits**.

En los sistemas informáticos, los caracteres de texto no se almacenan como letras, sino como **números**. Por ejemplo, en ASCII:

- `'a'` → 97  
- `'A'` → 65  

Base64 no trabaja directamente con caracteres, sino con los **bytes binarios** que los representan.

---

#### División en bloques

Base64 procesa la entrada en bloques de **24 bits**, es decir, **3 bytes**:

```text
[ 8 bits ][ 8 bits ][ 8 bits ]  → 24 bits
```
Estos 24 bits se dividen en 4 grupos de 6 bits, lo que produce 4 valores entre 0 y 63:
```text
[ 6 bits ][ 6 bits ][ 6 bits ][ 6 bits ] → 4 valores entre 0 y 63
```
Cada uno de estos valores se mapea a un símbolo de la tabla Base64.

```text
A-Z → 0–25
a-z → 26–51
0–9 → 52–61
+   → 62
/   → 63
```
Por ejemplo, la cadena `"aaa"` se codifica así:
1. Cada carácter se convierte a su valor ASCII:
```text
a → 97
```
2. Se expresa cada valor en binario (8 bits):

```text
[ 01100001 ][ 01100001 ][ 01100001 ] 
```
3. Se agrupan los 24 bits en bloques de 6:
```text
[ 011000 ][ 010110 ][ 000101 ][ 100001 ]
(en decimal)
↓                                           
[   24   ][   22   ][   05   ][   33   ]
```
4. Se sustituyen por símbolos Base64
```text
[   24   ][   22   ][   05   ][   33   ]
↓
    Y          V        F         h
```
#### ¿Qué ocurre si la entrada no es múltiplo de 3 bytes?
Si la entrada no completa un bloque de 24 bits, Base64 rellena con bits a cero y añade el carácter = para indicar que se ha aplicado padding.
Por ejemplo, para `"a"`:

```text
[ 01100001 ][ 00000000 ][ 0000000 ] 
↓
[ 011000 ][ 010000 ][ 000000 ][ 000000 ]
↓
[   24   ][   22   ][   00   ][   00   ]
↓
    Y           Q       =           =
```

Con esta información somos capaces de crear nuestro propio script de bash emulando `base64`

```bash
#!/bin/bash
set -euo pipefail

# ============================
# Base64 encoder
# ============================

BASE64_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

# Convertimos bites a cadena de bits
byte_to_bits() {
    local byte=$1
    local bits=""
    for ((i=7; i>=0; i--)); do
        bits+=$(( (byte >> i) & 1 ))
    done
    printf "%s" "$bits"
}

# Convertimos cadena de 6 bits a byte
bits6_to_int() {
    local bits=$1
    local value=0
    for ((i=0; i<6; i++)); do
        value=$(( (value << 1) | ${bits:i:1} ))
    done
    printf "%d" "$value"
}

base64_encode() {
    local input=$1
    local bits=""
    local output=""
    local len=${#input}

    # Leemos input byte a byte
    for ((i=0; i<len; i++)); do
        byte=$(printf "%d" "'${input:i:1}")
        bits+=$(byte_to_bits "$byte")
    done

    # Añadimos padding de tantos 0's como haga falta
    local padding_bits=$(( (6 - ${#bits} % 6) ))
    pad=$(printf "%*s" "$padding_bits" "")
    pad=${pad// /0}
    bits+="$pad"

    # Convertimos cada grupo de 6 bits en su caracter base64 asociado
    for ((i=0; i<${#bits}; i+=6)); do
        chunk=${bits:i:6}
        index=$(bits6_to_int "$chunk")
        output+=${BASE64_ALPHABET:index:1}
    done

    # Añadimos los "=" necesarios para el padding
    case $((len % 3)) in
        1) output+="==" ;;
        2) output+="=" ;;
    esac

    printf "%s\n" "$output"
}

main() {
    if [[ $# -ne 1 ]]; then
        die "Usage: $0 <string>"
    fi

    base64_encode "$1"
}

main "$@"
```

El decoder se realiza de manera muy similar. Se puede encontrar el programa completo con comentarios en `01-tool-base64.sh`.

