# Apéndice: Base64 – fundamentos y funcionamiento

Este apéndice desarrolla los conceptos teóricos y matemáticos detrás de la codificación **Base64**, explicando su relación con sistemas de numeración posicional y su implementación práctica.

## 1. Sistemas de numeración y Base64

Un **sistema de numeración** es un conjunto de reglas que permite representar números mediante símbolos. Base64 es un **sistema posicional**, lo que significa que el valor de cada símbolo depende de su posición, al igual que ocurre en el sistema decimal que usamos habitualmente: no representa lo mismo el número 23 que el 32, ya que el valor del símbolo ‘3’ cambia según su posición.

Esto contrasta con sistemas no posicionales, como el sistema romano, donde el valor de cada símbolo es fijo y los números se forman mediante sumas y restas de símbolos adyacentes.


### 1.1 Ejemplos de sistemas posicionales

En el **sistema decimal** utilizamos **10 símbolos** (0–9). Cada símbolo representa un valor entre cero y nueve, y cuando se agotan los símbolos, se pasa a la siguiente posición. Por ejemplo, el número 10 se representa como un 1 seguido de un 0, y este patrón se repite para números mayores.

Desde un punto de vista matemático, cada posición representa una potencia de la base. Por ejemplo:

$$2301 = 2\cdot10^4+3\cdot 10^3 + 0\cdot 10^1 + 1\cdot 10^0$$

No hay nada especial en usar la base 10: se suele atribuir su origen a que tenemos diez dedos, pero podrían emplearse otras bases sin ningún problema
Uno de los sistemas más importantes es el sistema binario, que utiliza únicamente dos símbolos: 0 y 1. Por ejemplo:

$$10100_2 =1\cdot 2^4+0\cdot 2^3+1\cdot 2^2+0\cdot 2^1+0\cdot 2^0$$

El uso del binario en computación se debe principalmente a dos motivos. En primer lugar, es mucho más sencillo y fiable distinguir entre dos estados físicos (hay corriente o no la hay) que entre múltiples niveles de voltaje. En segundo lugar, la lógica booleana demuestra que cualquier proceso lógico y computacional puede representarse utilizando únicamente dos valores: verdadero y falso.
### 1.2 Base64 como sistema posicional
Base64 no es más que otro sistema de numeración posicional de este tipo, pero con **64 símbolos** en lugar de 10 o 2. Habitualmente, estos símbolos son:

- Letras mayúsculas: A–Z

- Letras minúsculas: a–z

- Dígitos: 0–9

- Dos símbolos adicionales: + y /

#### 1.2.1 ¿Por qué 64 dígitos?
Porque 64 es la potencia de dos ($2^6=64$) más grande que se puede representar con los caracteres imprimibles ASCII. Los caracteres imprimibles son aquellos que se pueden representar visualmente. Hay 95 caracteres imprimibles y la siguiente potenica de dos es $2^7=128$. Nos interesa que sea una potencia de dos porque le da propiedades interesantes para luego traducirlo a binario internamente (sabemos que los ordenadores emplean internamente exclusivamente 0's y 1's).

## 2. Representación de texto en Base64

Hasta ahora hemos aprendido a representar números mediante base64. Pero nuestro objetivo es representar textos.

En el cómo se logar se aprecia una de las ventajas de que **64 es una potencia de 2**: cada símbolo de Base64 tiene asociado un número entre 0 y 63, y estos números pueden representarse internamente en binario usando exactamente **6 bits**.

En los sistemas informáticos, los caracteres de texto no se almacenan como letras, sino como **números**. Por ejemplo, en ASCII:

- `'a'` → 97  
- `'A'` → 65  

Base64 no trabaja directamente con caracteres, sino con los **bytes binarios** que los representan.

### 2.1 División en bloques

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
### 2.2 Ejemplo de codificación
Para la cadena `"aaa"`:
1. Cada carácter se convierte a su valor ASCII:
```text
a → 97
```
1. Se expresa cada valor en binario (8 bits):

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
### 2.3 Padding
se rellenan los bits con ceros y se añaden `=` al final para indicar padding. Por ejemplo, la letra "a" se codifica como:

```text
[ 01100001 ][ 00000000 ][ 0000000 ] 
↓
[  011000  ][  010000  ][  000000 ][  000000  ]
↓
[    24    ][    22    ][    00   ][    00    ]
↓
     Y           Q           =          =
```
## 3. Implementación práctica

Con esta comprensión, podemos implementar scripts que codifiquen y decodifiquen Base64. Los ejemplos incluidos en este repositorio son:

* [`base64_decoder.sh`](../scripts/bash/base64_decoder.sh)
* [`base64_decoder.py`](../scripts/python/base64_decoder.py)

Estos scripts reflejan la división en bloques, la conversión entre binario y decimal, y el uso de la tabla Base64 para traducir bytes a caracteres.
