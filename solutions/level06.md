# Nivel 6 - Cifrado de flujo con generador pseudoaleatorio débil
## Descripción
El objetivo del nivel es **explotar la debilidad de ese generador pseudoaleatorio**, realizando un ataque de known-plaintext, para recuperar la contraseña necesaria para acceder al siguiente nivel.

La seguridad de un cifrado de flujo depende casi por completo de la calidad del **generador de números pseudoaleatorios (PRNG)** que produce el *keystream*. Si este generador es predecible o entra en ciclos, el cifrado colapsa.

El objetivo del nivel es **explotar la debilidad de ese generador pseudoaleatorio**, realizando un ataque de **texto escogido (chosen-plaintext)**, para recuperar la contraseña necesaria para acceder al siguiente nivel.

## Enunciado del problema
```text
Hopefully by now its obvious that encryption using repeating keys is a bad idea. Frequency analysis can destroy repeating/fixed key substitution crypto.

A feature of good crypto is random ciphertext. A good cipher must not reveal any clues about the plaintext. Since natural language plaintext (in this case, English) contains patterns, it is left up to the encryption key or the encryption algorithm to add the ‘randomness’.

[...]

Its time to employ a stream cipher. A stream cipher attempts to create an on-the-fly ‘random’ keystream to encrypt the incoming plaintext one byte at a time. Typically, the ‘random’ key byte is xor’d with the plaintext to produce the ciphertext. If the random keystream can be replicated at the recieving end, then a further xor will produce the plaintext once again.

[...]

In this example, the keyfile is in your directory, however it is not readable by you. The binary ‘encrypt6’ is also available. It will read the keyfile and encrypt any message you desire, using the key AND a ‘random’ number. You get to perform a ‘known ciphertext’ attack by introducing plaintext of your choice. The challenge here is not simple, but the ‘random’ number generator is weak.

As stated, it is now that we suggest you begin to use public tools, like cryptool, to help in your analysis. You will most likely need a hint to get going. See ‘HINT1’ if you need a kicktstart.

If you have further difficulty, there is a hint in ‘HINT2’.

The password for level 7 (krypton7) is encrypted with ‘encrypt6’.

Good Luck!
```
## Enfoque de la solución
En el enunciado indican que el método de generación de números pseudoaleatorios es muy débil. Uno de los principales problemas a los que se enfrenta este tipo de algoritmos es que, tras un número suficiente de iteraciones, **entran en bucles**, produciendo secuencias periódicas.

### Uso de ataque de texto escogido
El binario `encrypt6` nos permite cifrar **textos elegidos por nosotros**, lo que habilita directamente un ataque de *chosen-plaintext*. Esto nos permite intentar reconstruir el *keystream* generado por el cifrador.

El primer paso consiste en cifrar un texto simple, por ejemplo una cadena larga de caracteres idénticos (`A` repetidas). Si el texto en claro es constante, el texto cifrado reflejará **directamente el comportamiento del flujo de claves**, salvo una transformación trivial.

Si el texto es lo suficientemente largo y el PRNG entra en un ciclo, deberíamos observar un **patrón repetitivo** en el texto cifrado.

Para confirmar el ataque, ciframos el mismo texto una segunda vez y comparamos ambos resultados. Si el cifrado es idéntico byte a byte, el generador se está inicializando **siempre con la misma semilla**, lo que implica que el *keystream* es completamente reproducible.

En este escenario, el cifrado de flujo empleado se degrada a un **cifrado de Vigenère por bytes**, donde la “clave” es simplemente el bloque del *keystream* hasta que comienza a repetirse. La clave puede obtenerse directamente como la diferencia (XOR o resta modular, según el caso) entre el texto cifrado y el texto plano conocido.


### Preparación de datos y resolución

Nos conectamos a la máquina:

```bash
ssh krypton6@krypton.labs.overthewire.org -p 2231
```
Preparamos el entorno:
```bash
mktemp -d
/tmp/tmp.XokOox1MaY
cd /tmp/tmp.XokOox1MaY
ln -s /krypton/krypton6/keyfile.dat
chmod 777 .
```

Generamos el texto plano:
```bash
python -c "print('A'*100)">plain_text
```
Lo ciframos: 
```bash
/krypton/krypton6/encrypt6  plain_text cipher_text
```
Observamos el contenido del archivo generado:
```bash
cat cipher_text
```
Salida:
```bash
EICTDGYIYZKTHNSIRFXYCPFUEOCKRNEICTDGYIYZKTHNSIRFXYCPFUEOCKRNEICTDGYIYZKTHNSIRFXYCPFUEOCKRNEICTDGYIYZ
```

Como puede observarse, el mismo patrón se repite cada 30 caracteres:
```bash
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
EICTDGYIYZKTHNSIRFXYCPFUEOCKRN
```
Para obtener el keystream basta con restar el texto cifrado al texto plano:

```bash
awk -f stream_keystream_extract.awk -v plain_text="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" -v cipher_text="EICTDGYIYZKTHNSIRFXYCPFUEOCKRN"
```
Salida:
```bash
Shists:
5 9 3 20 4 7 25 9 25 26 11 20 8 14 19 9 18 6 24 25 3 16 6 21 5 15 3 11 18 14
Equivalent Vigenere Password:
EICTDGYIYZKTHNSIRFXYCPFUEOCKRN
```

Finalmente, desciframos el archivo objetivo:
```bash
awk -f vigenere_try.awk -v key="EICTDGYIYZKTHNSIRFXYCPFUEOCKRN" krypton7
```
Salida:
```
XXXXXXXXXXXXXXX
```
obteniendo la contraseña para el siguiente nivel.

## Comentarios
Este nivel introduce conceptos fundamentales de la criptografía moderna:

- cifrados de flujo (*stream ciphers*),
- ataques de texto escogido (*chosen-plaintext*),
- importancia crítica de la semilla y del estado interno de un PRNG.

El ejercicio demuestra que **un cifrado moderno con una fuente de aleatoriedad débil puede ser tan inseguro como un cifrado clásico mal diseñado**, e incluso degradarse a esquemas equivalentes a Vigenère o XOR con clave repetida.

En el directorio de scripts se incluye además un script AWK adicional que realiza el mismo tipo de análisis para **cifrados XOR**, ya que por el enunciado del ejercicio parecía razonable asumir inicialmente que el archivo objetivo estaría cifrado mediante XOR. Finalmente no fue necesario, pero se mantiene como referencia, ya que el ataque y el razonamiento son conceptualmente idénticos.

Este nivel refuerza una lección clave: **la seguridad criptográfica no reside únicamente en el algoritmo**, sino en todos los componentes que lo rodean, especialmente en la calidad de la aleatoriedad empleada. Un PRNG débil convierte cualquier cifrado, por sofisticado que sea en apariencia, en un sistema completamente vulnerable.