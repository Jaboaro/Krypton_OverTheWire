# Nivel 1 - root13
## Descripción
En este nivel, la contraseña se encuentra en un archivo cifrado mediante una **rotación alfabética**, una forma simple de cifrado por sustitución conocida como **cifrado César**.

A diferencia del nivel anterior, aquí no basta con reconocer el formato: es necesario identificar el desplazamiento utilizado o probarlos sistemáticamente.


## Enunciado del problema
```text
Level Info
The password for level 2 is in the file ‘krypton2’. It is ‘encrypted’ using a simple rotation. It is also in non-standard ciphertext format. When using alpha characters for cipher text it is normal to group the letters into 5 letter clusters, regardless of word boundaries. This helps obfuscate any patterns. This file has kept the plain text word boundaries and carried them to the cipher text. Enjoy!
```

## Exploración inicial
Tras conectarnos al servidor:
```bash
ssh krypton1@krypton.labs.overthewire.org -p 2231
```
localizamos los archivos del juego dentro del directorio `/krypton`:

```bash
find / -name krypton* 2>/dev/null
```
El archivo relevante para este nivel es
```bash
/krypton/krypton1/krypton2
```
Y su contenido es
```bash
YRIRY GJB CNFFJBEQ EBGGRA
```
## Enfoque de resolución


El enunciado indica explícitamente que el texto está cifrado mediante una **rotación de letras**. Este tipo de cifrado pertenece a la familia del **cifrado César**, donde cada letra se desplaza un número fijo de posiciones en el alfabeto.

Dado que el alfabeto inglés tiene 26 letras, existen únicamente 26 desplazamientos posibles (25 si no contamos la identidad). Por tanto, una estrategia general consiste en:

-   probar todas las rotaciones posibles,
    
-   observar cuál produce un texto legible,
    
-   usar ese resultado como contraseña.
    

Además, uno de los casos más comunes es **ROT13**, donde el desplazamiento es 13. Este caso es especial porque cifrar y descifrar son exactamente la misma operación.

---

## Resolución directa (ROT13)

Podemos comprobar rápidamente si se trata de ROT13 usando `tr`:

```bash
cat /krypton/krypton1/krypton2 | tr 'A-Za-z' 'N-ZA-Mn-za-m'
```

Esto produce un texto legible, confirmando que el cifrado utilizado es ROT13.

---

## Resolución general mediante fuerza bruta

Aunque en este caso ROT13 funciona directamente, no siempre es razonable asumir el desplazamiento correcto. Por ello, resulta útil automatizar el proceso y probar **todas las rotaciones posibles**.

Para ello se ha implementado un script que:

-   soporta cifrado por desplazamiento arbitrario
    
-   permite descifrar aplicando desplazamientos negativos
    
-   incluye un modo de fuerza bruta que prueba todos los valores posibles
    

---

## Implementación

### Scripts utilizados

- [caesar_decoder_cli.sh](../scripts/bash/caesar_decoder_cli.sh)
- [caesar_decoder.py](../scripts/python/caesar_decoder.py)

---

### Ejemplo: fuerza bruta

```bash
./caesar_decoder_cli.sh -b "YRIRY GJB CNFFJBEQ EBGGRA"
```

Salida (extracto):

```text
...
offset 12: MFWFM UXP QBTTXPSE SPUUFO
offset 13: LEVEL TWO PASSWORD ROTTEN
offset 14: KDUDK SVN OZRRVNQC QNSSDM
...
```

Esto revela directamente la contraseña necesaria para acceder al siguiente nivel.
## Comentarios

Este nivel introduce conceptos fundamentales:

-   cifrados por sustitución monoalfabética
    
-   aritmética modular aplicada a alfabetos
    
-   ataques por fuerza bruta
    
-   automatización mediante scripting
    

Aunque el cifrado César no ofrece seguridad real, resulta excelente como ejemplo pedagógico para comprender cómo funcionan los cifrados clásicos y cómo pueden romperse de forma sistemática.

---

## Apéndices relacionados

- [Cifrado César, ROT13 y aritmética modular](../appendices/cifrado_cesar.md)
    
