# Apéndice: Cifrado César, ROT13 y aritmética modular

Este apéndice desarrolla con más detalle los conceptos teóricos que aparecen en el **Nivel 1**, relacionados con los cifrados por rotación, su interpretación matemática y su implementación práctica.



## 1. El cifrado César

El **cifrado César** es uno de los sistemas criptográficos más antiguos conocidos. Se trata de un cifrado por **sustitución monoalfabética**, en el que cada letra del mensaje original se sustituye por otra obtenida desplazándola un número fijo de posiciones dentro del alfabeto.

Tradicionalmente se atribuye a Julio César, quien supuestamente utilizaba un desplazamiento de 3 posiciones para proteger mensajes militares.

### Funcionamiento básico

Dado un alfabeto ordenado:

```
ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

si elegimos un desplazamiento `k`, cada letra se sustituye por la que se encuentra `k` posiciones más adelante. Por ejemplo, con `k = 4`:

```
ABCDEFGHIJKLMNOPQRSTUVWXYZ
EFGHIJKLMNOPQRSTUVWXYZABCD
```

Así:
```text
A → E
B → F
H → L
O → S
L → P
A → E
```
La palabra **HOLA** quedaría cifrada como:

```
LSPE
```



## 2. Cifrado y descifrado

El cifrado César puede describirse como una función que actúa sobre cada letra de manera independiente:

* **Cifrado**: desplazar la letra hacia delante `k` posiciones.
* **Descifrado**: desplazar la letra hacia atrás `k` posiciones.

Esto implica que el mismo mecanismo sirve para ambos procesos, cambiando únicamente el signo del desplazamiento.

En pseudocódigo:

```
cifrar(letra)   = desplazar(letra, +k)
descifrar(letra) = desplazar(letra, -k)
```

El cifrado actúa únicamente sobre letras; otros caracteres (espacios, signos, números) suelen dejarse sin modificar.



## 3. ROT13: un caso especial

Un caso particularmente famoso del cifrado César es **ROT13**, donde el desplazamiento es:

```
k = 13
```

Dado que el alfabeto latino tiene 26 letras, ocurre una propiedad interesante:

```
13 + 13 = 26 ≡ 0 (mod 26)
```

Esto implica que **aplicar ROT13 dos veces devuelve el texto original**. Por tanto:

* cifrar y descifrar son exactamente la misma operación


Por ejemplo:

```
HELLO  → URYYB
URYYB  → HELLO
```
Por esta razón, ROT13 se ha usado tradicionalmente como un método simple para ocultar información sin necesidad de una clave adicional, por ejemplo en foros, acertijos o textos con spoilers. Aunque **no ofrece seguridad real**, es famoso por su simplicidad y por esa simetría que lo hace fácil de usar y de entender.


## 4. Aritmética modular aplicada al cifrado

El comportamiento del cifrado César puede describirse de forma precisa usando **aritmética modular**, una herramienta fundamental en criptografía.

### Representación numérica

Asignamos a cada letra un número:

```
A → 0
B → 1
...
Z → 25
```

Sea:

* `x` el valor numérico de una letra
* `k` el desplazamiento
* `n = 26` el tamaño del alfabeto

Entonces el cifrado se expresa como:

```
C = (x + k) mod n
```

Y el descifrado como:

```
x = (C - k) mod n
```

El uso del operador módulo garantiza que el resultado siempre permanezca dentro del rango `[0, 25]`, incluso cuando se sobrepasan los límites del alfabeto.



## 5. Relación con implementaciones prácticas

En implementaciones reales (como los scripts usados en este repositorio), este modelo matemático se traduce a operaciones sobre códigos ASCII:

* letras mayúsculas: rango `65–90`
* letras minúsculas: rango `97–122`

El procedimiento típico es:

1. Convertir el carácter a su valor ASCII
2. Restar el valor base (`'A'` o `'a'`)
3. Aplicar el desplazamiento usando aritmética modular
4. Volver a sumar la base
5. Convertir de nuevo a carácter

Esto permite implementar el cifrado de forma compacta y segura, incluso admitiendo desplazamientos negativos o mayores que 26.



## 6. Fuerza bruta y ruptura del cifrado

Dado que el cifrado César solo admite 26 claves posibles, puede romperse fácilmente mediante **fuerza bruta**:

1. Se prueban todos los valores de desplazamiento de 0 a 25
2. Se generan los posibles textos descifrados
3. Se identifica cuál tiene sentido lingüístico

Este enfoque no requiere conocer previamente la clave y es suficiente para romper cualquier texto cifrado con este método.

En los scripts asociados a este repositorio, este procedimiento se automatiza para mostrar todas las rotaciones posibles, facilitando su análisis.