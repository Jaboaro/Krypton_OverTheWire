# Krypton Level 3 → Level 4
```text
Well done. You’ve moved past an easy substitution cipher.

The main weakness of a simple substitution cipher is repeated use of a simple key. In the previous exercise you were able to introduce arbitrary plaintext to expose the key. In this example, the cipher mechanism is not available to you, the attacker.

However, you have been lucky. You have intercepted more than one message. The password to the next level is found in the file ‘krypton4’. You have also found 3 other files. (found1, found2, found3)

You know the following important details:

The message plaintexts are in American English (*** very important) - They were produced from the same key (*** even better!)
Enjoy.
```
El nivel introduce un **cifrado por sustitución monoalfabética**, mucho más fuerte que el cifrado César visto anteriormente.

Recordemos el enunciado clave:

-   Tenemos **varios textos cifrados con la misma clave**.
    
-   Los textos originales están en **inglés americano**.
    
-   El objetivo es obtener la contraseña contenida en `krypton4`.
## Cifrado por sustitución monoalfabética
El nuevo tipo de cifrado que se presenta es más complejo que el anterior. En este caso, cada letra del alfabeto se corresponde de manera unívoca con otra, pero la regla de asociación es desconocida. Es decir,

-   Cada letra del alfabeto se sustituye siempre por **la misma letra cifrada**.
    
-   La sustitución es biyectiva: no hay dos letras que se cifren igual.
    
-   La clave es una permutación del alfabeto.
    
Se puede representar como una lista en la que cada letra se asocia con otra

```css
A → Q
B → M
C → T
...
```
Esto implica que todas las apariciones de una letra del texto original se transforman siempre en la misma letra cifrada.


En este contexto, el método de fuerza bruta no es efectivo, ya que el número de posibles cifrados es aproximadamente $26!$ (veintiseis factorial), es decir:

$$26!=26\cdot25\cdots 2\cdot1\sim10^{26}$$

Este número es extremadamente grande, lo que hace inviable probar todas las claves posibles. Incluso si exigimos que **ninguna letra se cifre como ella misma**, el número sigue siendo enorme:

$$
!26 \approx \frac{26!}{e}
$$

Por tanto, necesitamos otro enfoque.

> En [el primer apéndice a este nivel](<04-Level 3-appendix.md>) se puede encontrar una explicación matemática más profunda de este punto. No es necesaria para comprender la resolución del reto pero puede ser de interés para aquellos que quieran conocer de dónde salen estas expresiones.




## Análisis de frencuencias
En inglés, las letras **no aparecen con la misma frecuencia**. Por ejemplo:

-   E es la más común
    
-   luego T, A, O, I, N…
    
-   letras como Q, Z, X aparecen muy poco (E es más de 200 veces más frecuente que Z)

Si contamos cuántas veces aparece cada letra cifrada, podemos **sospechar a qué letra real corresponde** cada una.

Como además tenemos **tres textos distintos cifrados con la misma clave**, la muestra es suficientemente grande para que las frecuencias sean representativas de la estadística real.

Esto convierte el problema en uno de:

> “Ajustar una permutación razonable usando estadística + contexto lingüístico”.

## Preparación de los archivos y análisis

Copiamos los ficheros de la máquina al local mediante `scp` (se puede trabajar en directorios temporales en la máquina objetivo pero personalmente me resulta más comodo descargarlos).
```bash
scp -P 2231 krypton3@krypton.labs.overthewire.org:"/krypton/krypton3/*" <directorio local>
```
Unimos los tres textos interceptados:
```bash
cat found1 found2 found3 > found.txt
```
Y contamos cuántas veces aparece cada letra:s.

```bash
cat found.txt | tr '[:lower:]' '[:upper:]' |grep -o '[A-Z]' | sort | uniq -c | sort -nr
```
Obteniendo la siguiente tabla de frecuencias
```text
    456 S
    340 Q
    301 J
    257 U
    246 B
    240 N
    227 G
    227 C
    210 D
    132 Z
    130 V
    129 W
     86 M
     84 Y
     75 T
     71 X
     67 K
     64 E
     60 L
     55 A
     28 F
     19 I
     12 O
      4 R
      4 H
      2 P
```

En este punto merece la pena pararnos a explicar el comando empleado:
- `cat found.txt`: leemos el archivo y lo pasamos a salida estándar.
- `tr '[:lower:]' '[:upper:]'`: pasamos letras minúsculas a mayúsculas (en este caso todas son mayúsculas con lo que no es estríctamente necesario).
- `grep -o '[A-Z]'` buscamos e imprimimos todas las letras del alfabeto inglés, cada una en una linea. `-o` imprime solamente las cadenas que coinciden con la expresión regular y las separa por línea.
- `sort`: junta todas las letras iguales (necesario para emplear `uniq`).
- `uniq -c`: toma las distintas letras *adyacentes* y cuenta cuántas hay de cada una de ellas.
- `sort -nr`: las ordena de nuevo de acuerdo al valor numérico (`-n`) y de mayor a menor (`-r`).

Y para poder copiar y pegar la lista de letras de manera sencilla podemos *pipear* al final de la expresión:

- `awk '{print $2}'`: para tomar la segunda columna (las letras).
- `paste -sd ''`: pegamos de una en una y en orden (`-s`) cada una de las letras sin separarlas (`-d ''`).

La [frecuencia de aparición](https://en.wikipedia.org/wiki/Letter_frequency) de las letras en inglés es:
```bash
ETAOINSHRDLCUMWFGYPBVKJXQZ
```
Si ordenamos nuestras letras cifradas por frecuencia, obtenemos

```bash
SQJUBNGCDZVWMYTXKELAFIORHP
```
Esto sugiere una primera correspondencia aproximada
```bash
S → E
Q → T
J → A
U → O
B → I
N → N
G → S
C → H
D → R
...
```
Que no tiene por qué ser exacta, pero sirve como punto de partida.
## Sustituciones y prueba guiada por contexto
Al realizar esta primera sustitución
```bash
cat krypton4 | tr [SQJUBNGCDZVWMYTXKELAFIORHP] [ETAOINSHRDLCUMWFGYPBVKJXQZ]
```
Obtenemos como salida
```bash
GELLC ISEAR ELEKE LFIUN MTOOG INCHO XXXXX
```
Y observamos patrones típicos del inglés. 
- La primera palabra `GELL` podría ser `WELL`
- `LEKEL` probablemente sea `LEVEL`.
- Si comienza por `WELL` probablemente las siguientes cuatro letras sean `DONE`.

Entrada:
```bash
cat krypton4 | tr [SQJUBNGCDZVWMYTXKELAFIORHP] [ETAIOSNRHULDCMFYWGPBVKXQJZ]
```
Salida:
```bash
WELLD ONEAH ELEKE LYOCS MTIIW OSDRI XXXXX
```
Entrada:
```bash
cat krypton4 | tr [SQJUBNGCDZVWMYTXKELAFIORHP] [EATIOSNRHULDCMFYWGPBKVXQJZ]
```
Salida:
```bash
WELLD ONETH ELEVE LYOCS MAIIW OSDRI XXXXX
```

Es de esperar que la siguiente palabra sea `FOUR`:

```bash
cat krypton4 | tr [SQJUBNGCDZVWMYTXKELAFIORHP] [EATIORNSHCLDUMYFWGPBKVXQJZ]
```
Salida:
```
WELLD ONETH ELEVE LFOUR MAIIW ORDSI XXXX
```
Y, por último, `MAIIW ORDSI→PASSWORDIS`

```bash
cat krypton4 | tr [SQJUBNGCDZVWMYTXKELAFIORHP] [EATSORNIHCLDUPYFWGPBKVXQJZ]
```
```bash
WELLD ONETH ELEVE LFOUR PASSW ORDIS XXXXX
```
Este enfoque requiere una cantidad considerable de prueba y error, ya que la sustitución se va refinando progresivamente a partir de hipótesis sobre palabras frecuentes y patrones del idioma. En este caso concreto, el contexto del reto y la estructura predecible del mensaje final permitieron deducir directamente el contenido de `krypton4` y ajustar la sustitución hasta obtener el texto en claro.

No obstante, en un escenario más general resulta más práctico aplicar estas sustituciones sobre `found.txt`, ya que contiene una mayor cantidad de texto. Un corpus más grande incrementa la probabilidad de encontrar patrones reconocibles (como palabras comunes, terminaciones o secuencias repetidas), lo que facilita validar y corregir el mapeo entre letras cifradas y letras reales.

Aunque aquí el descifrado se ha realizado manualmente, existen métodos para **automatizar total o parcialmente** este proceso. Por ejemplo, mediante el uso de análisis de frecuencias automatizado comparado con distribuciones estadísticas del inglés y  y scripts que evalúan automáticamente hipótesis de sustitución usando diccionarios o modelos de lenguaje.
    

Profundizaremos en estos métodos en un futuro apéndice.






