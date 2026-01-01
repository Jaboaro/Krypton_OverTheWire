# Nivel 4 - Cifrado de Vigenère
## Descripción
En este nivel se abandona definitivamente el cifrado por sustitución **monoalfabética** y se introduce un cifrado **polialfabético**, concretamente el **cifrado de Vigenère**.

A diferencia de los niveles anteriores, donde cada letra del texto en claro se sustituía siempre por la misma letra cifrada, en este caso **una misma letra puede cifrarse de distintas formas** dependiendo de su posición dentro del texto. Esto incrementa significativamente la resistencia frente al análisis de frecuencias simple.

El objetivo sigue siendo el mismo: recuperar la contraseña necesaria para acceder al siguiente nivel.

## Enunciado del problema

```text
Good job!

You more than likely used some form of FA and some common sense to solve that one.

So far we have worked with simple substitution ciphers. They have also been
‘monoalphabetic’, meaning using a fixed key, and giving a one to one mapping
of plaintext (P) to ciphertext (C). Another type of substitution cipher is
referred to as ‘polyalphabetic’, where one character of P may map to many,
or all, possible ciphertext characters.

An example of a polyalphabetic cipher is called a Vigenère Cipher. It works
like this:

If we use the key (K) ‘GOLD’, and P = PROCEED MEETING AS AGREED, then “add” P
to K, we get C. When adding, if we exceed 25, then we roll to 0 (modulo 26).

P P R O C E E D M E E T I N G A S A G R E E D
K G O L D G O L D G O L D G O L D G O L D G O
becomes:

P 15 17 14  2  4  4  3 12  4  4 19  8 13  6  0 18  0  6 17  4  4  3
K  6 14 11  3  6 14 11  3  6 14 11  3  6 14 11  3  6 14 11  3  6 14
C 21  5 25  5 10 18 14 15 10 18  4 11 19 20 11 21  6 20  2  8 10 17

So, we get a ciphertext of:

VFZFK SOPKS ELTUL VGUCH KR

This level is a Vigenère Cipher. You have intercepted two longer,
english language messages (American English). You also have a key piece of
information. You know the key length!

For this exercise, the key length is 6. The password to level five is in the
usual place, encrypted with the 6 letter key.

Have fun!
```

## Enfoque de la solución
Para resolver este problema el enunciado nos proporciona una información crítica: **la longitud de la clave es conocida** y vale 6. Esto reduce drásticamente la complejidad del problema y permite transformar el cifrado de Vigenère en varios problemas mucho más simples.

### Reducción del problema a cifrados César
En un cifrado de Vigenère con clave de longitud $k$, el texto cifrado puede dividirse en $k$ subtextos independientes:

-   el primer subtexto contiene los caracteres cifrados con la primera letra de la clave,
    
-   el segundo subtexto contiene los caracteres cifrados con la segunda letra de la clave,
    
-   y así sucesivamente, repitiéndose el patrón de forma cíclica.
    

Como la clave se reutiliza periódicamente, **cada uno de estos subtextos está cifrado con un único desplazamiento fijo**, es decir, con un **cifrado César clásico**.

Cada columna puede analizarse de forma completamente independiente.

### Análisis de frecuencias por columna

Una vez separados los subtextos, se aplica **análisis de frecuencias** a cada uno de ellos. Dado que los textos originales están en **inglés americano** y son suficientemente largos, la distribución de letras en cada columna se aproxima razonablemente a la distribución real del inglés.

Para cada columna:

-   se cuentan las frecuencias de aparición de las letras A–Z,
    
-   se ordenan de mayor a menor frecuencia,
    
-   se asume inicialmente que la letra más frecuente corresponde a una letra común del inglés (por defecto, **E**),
    
-   y se deduce el desplazamiento César necesario para que esa correspondencia sea válida.
    

Este proceso produce **candidatos plausibles para cada letra de la clave**, uno por columna.

Por último, probamos los distintos candidatos hasta dar con la solución esperada.

## Implementación
### Scripts utilizados
- [vigenere_freq.awk](../scripts/awk/vigenere_freq.awk): Análisis de frecuencia para cada caracter de la contraseña.
- [vigenere_try.awk](../scripts/awk/vigenere_try.awk): Decodificador para contraseña dada.
### Preparación de los datos y resolución

Descargamos los archivos del servidor:
```bash
scp -P 2231 krypton4@krypton.labs.overthewire.org:"/krypton/krypton3/*" .
```
Comprobamos la longitud del primer archivo encontrado:
```bash
cat found1 | tr -d " " | awk '{ total+=length($0) } END {printf "%d mod 6 = %d", total, total%6}'
```
Salida:
```bash
1450 mod 6 = 4
```
Consta de 1450 caracteres, que no es multiplo de 6, es necesario eliminar 4 caracteres antes de concatenar el segundo archivo a fin de evitar un desajuste en la contraseña.

Como la codificación del texto es ASCII, cada letra ocupa un byte y podemos eliminarla con el siguiente comando.
```bash
cat found1 | tr -d " "| head -c -4 > found1
```
Para el segundo no necesitamos preocuparnos por el padding
```bash
cat found1 found2 |tr -d " " > found.txt
```
Comenzamos con el análisis de frecuencia
```bash
awk -f vigenere_freq.awk -v keylen=6 found.txt
```
Salida:
```text
=========== Columna 0 ===========
CHARS: JTYSFMNWIXKBZQHRDULPGAO
       ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
 KEYS: FPUOBIJSETGXVMDNZQHLCWK

=========== Columna 1 ===========
CHARS: VKRUFYEIZJCNWPLTXGDBSM
       ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
 KEYS: RGNQBUAEVFYJSLHPTCZXOI

=========== Columna 2 ===========
CHARS: IXSVLEMHRWPAGQCKYOTJFZBN
       ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
 KEYS: ETORHAIDNSLWCMYGUKPFBVXJ

=========== Columna 3 ===========
CHARS: ODKBCRNYSXVGEIMLPQWZUTFAH
       ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
 KEYS: KZGXYNJUOTRCAEIHLMSVQPBWD

=========== Columna 4 ===========
CHARS: IXSLWEMVRPYHAGJQKCTOFZ
       ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
 KEYS: ETOHSAIRNLUDWCFMGYPKBV

=========== Columna 5 ===========
CHARS: CRMFYLPBQGJSWUDKIENAZTH
       ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
 KEYS: YNIBUHLXMCFOSQZGEAJWVPD
```
Lo que nos proporciona nuestra primera posible contraseña (la más plausible tomando la primera letra de cada lista)
```bash
awk -f vigenere_try.awk -v key="FREKEY" found.txt
```
Que resulta ser la correcta. Si no hubiera sido el caso hubieramos procedido por prueba y error analizando el texto de la misma manera que hicimos en el nivel anterior. Decodificamos el archivo objetivo
```bash
awk -f vigenere_try.awk -v key="FREKEY" krypton5
```
obteniendo la contraseña para el siguiente nivel.

## Comentarios

Este nivel introduce conceptos fundamentales de la criptografía clásica:

- cifrados por sustitución **polialfabética**
- reducción del cifrado de Vigenère a múltiples cifrados César independientes
- análisis de frecuencias condicionado por posición
- aprovechamiento de información parcial (longitud de la clave) para reducir el espacio de búsqueda

Aunque en este reto la **longitud de la clave es proporcionada explícitamente**, este no es un requisito indispensable en un escenario real. Existen técnicas bien conocidas que permiten **estimar la longitud de la clave directamente a partir del texto cifrado**, como el índice de coincidencia o el análisis de repeticiones periódicas (método de Kasiski).

Del mismo modo, el proceso de selección de la clave que aquí se ha realizado de forma **manual y guiada por contexto lingüístico** puede automatizarse casi por completo. Para cada columna, es posible evaluar sistemáticamente todos los desplazamientos posibles y seleccionar el más probable comparando la distribución de frecuencias resultante con la del inglés mediante pruebas estadísticas, como el **test de chi-cuadrado (χ²)**.

Estos métodos permiten romper cifrados de Vigenère de forma eficiente siempre que se disponga de suficiente texto cifrado, incluso cuando **ni la clave ni su longitud son conocidas previamente**.

En un apéndice posterior se desarrollan estos ataques de manera más formal y automatizada, mostrando cómo pasar de un análisis manual a una ruptura completamente estadística del cifrado.
