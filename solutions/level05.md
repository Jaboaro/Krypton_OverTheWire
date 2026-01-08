# Nivel 5 - Cifrado de Vigenère con longitud de clave desconocida
## Descripción
En este nivel se continúa con el **cifrado de Vigenère**, pero eliminando una de las ayudas clave del nivel anterior: **la longitud de la clave ya no es conocida**.

El reto consiste ahora en **romper completamente un cifrado Vigenère**, sabiendo que el idioma origianl es **inglés americano**.

## Enunciado del problema

```text
FA can break a known key length as well. Lets try one last polyalphabetic cipher, but this time the key length is unknown. 
Note: the text is writen in American English

Enjoy.
```
## Enfoque de la solución
La solución del problema se divide en dos fases claramente diferenciadas:
1. Estimación de la longitud de la clave
2. Recuperación de la clave una vez conocida la longitud

Ambas fases se apoyan en propiedades estadísticas del lenguaje y del propio cifrado de Vigenère.

### Estimación de la longitud de la clave

Cuando se desconoce la longitud de la clave, el primer paso es detectar la periodicidad introducida por la reutilización de la clave a lo laro del texto cifrado.

Una de las técnicas clásicas para ello es el **Índice de Coincidencia (IC)**.

El IC mide **la probabilidad de que dos letras tomadas al azar** de un texto **sean iguales**. 
Para textos largos:

- Texto aleatorio → IC = $\frac{1}{26}\approx$ 0.038

- Texto en inglés → IC $\approx$ 0.066

Como esta probabilidad no cambia al desplazar todas las letras del texto una misma distancia, al aplicar este concepto a un cifrado de Vigenère se obtiene lo siguiente:

- si el texto se divide usando la **longitud correcta** de la clave, cada columna corresponde a un texto cifrado con un único desplazamiento, por lo que su **IC es similar al característico del inglés**.

- si se divide con una **longitud incorrecta**, las columnas mezclan alfabetos desplazados y su **IC se aproxima al aleatorio**.

La longitud de la clave se estima, por tanto, separando el texto en $n$ columnas, con $n=1, 2...$ posibles longitudes de la clave, y calculando el IC medio de las columnas. Cuando el valor obtenido se aproxima suficientemente al IC del idioma, ese valor de $n$ se considera un **candidato plausible** para la longitud de la clave.

> NOTA: Esta aproximación mediante IC detecta como longitudes plausibles no solo la longitud real de la clave, sino también sus múltiplos. Por ello, es recomendable probar en primer lugar el menor de los valores candidatos (por ejemplo, si aparecen 6, 12 y 18, con alta probabilidad la longitud real será 6).
Para una explicación más detallada de este fenómeno, véase el apéndice correspondiente referenciado al final de este texto.

### Estimación de la clave
Una vez conocida la longitud de la clave, el problema puede abordarse de forma similar al nivel anterior. Sin embargo, cuando no se dispone de grandes cantidades de texto, el análisis de frecuencias columna a columna puede resultar poco fiable.

Para estos casos se emplea un método estadístico más robusto: el **índice de coincidencias múltiples (ICM)**.

El ICM mide **la probabilidad de que dos letras tomadas al azar sean iguales en dos textos diferentes**. Así pues, en lugar de atacar cada columna de forma aislada, es posible explotar **la relación estadística entre columnas**. Dado que todas proceden del mismo idioma original, las distribuciones de frecuencias de las letras en distintas columnas son similares entre sí, aunque estén desplazadas en el alfabeto por distintos valores. 

Comparando estas distribuciones entre columnas bajo distintos desplazamientos relativos y midiendo su coincidencia mediante el (ICM), se puede determinar el desplazamiento que mejor alinea estadísticamente cada columna con una columna de referencia. Este proceso permite recuperar **la clave relativa**, es decir, cuál es el desplazamiento de cada letra de la contraseña respecto a la primera.

Esto ya es una mejora sustancial: el espacio de búsqueda se reduce de forma drástica quedando únicamente $26$ posibles desplazamientos absolutos.Para fijar este desplazamiento final de manera automática se emplea el **test de chi-cuadrado**, que compara la distribución de frecuencias del texto resultante con un modelo conocido del inglés americano. El desplazamiento que minimiza el valor de chi-cuadrado corresponde al texto cuya distribución se asemeja más a la del idioma natural, permitiendo así recuperar la clave completa sin intervención manual.
### Implementación
Para automatizar este proceso se ha empleado el siguiente script:
- [vigenere_key_length.awk](../scripts/awk/vigenere_key_length.awk): estima la **longitud** de la clave empleando el Índice de Coincidencia.
- [vigenere_recover_key_ic.awk](../scripts/awk/vigenere_recover_key_ic.awk): recupera la **clave completa** a partir de su longitud utilizando ICM y chi-cuadrado.

## Preparación de los datos y resolución
Descargamos los archivos del servidor:

```bash
scp -P 2231 krypton5@krypton.labs.overthewire.org:"/krypton/krypton5/*" .
```
Y calculamos la longitud de la clave con la que se han cifrado los textos
```bash
awk -f vigenere_key_length.awk found1 found2 found3
```
Salida:
```text
Possible key length: 9
Possible key length: 18
```
Como se ha comentado anteriormente, además de la longitud real aparecen también sus múltiplos, por lo que tomamos 9 como longitud de la clave. Con este valor, recuperamos la contraseña:

```bash
awk -f vigenere_recover_key.awk -v key_len=9 found1 found2 found3
```
Salida:
```text
Recovered key: KEYLENGTH
```

Conocida la contraseña del cifrado, solamente queda descifrar `krypton6`:

```bash
awk -f vigenere_try.awk -v key="KEYLENGTH" krypton6
```
Salida
```text
XXXXXX
```
## Comentarios
Este nivel consolida varios conceptos fundamentales del criptoanálisis clásico:

- ruptura de cifrados polialfabéticos

- estimación automática de la longitud de la clave

- uso del Índice de Coincidencia

- comparación estadística mediante chi-cuadrado

A diferencia de los niveles anteriores, todo el proceso puede automatizarse completamente, sin necesidad de intuición lingüística ni prueba y error manual. No obstante, en este writeup se ha optado  por mantener los pasos separados (estimación de la longitud de la clave, recuperación de desplazamientos relativos, fijación del desplazamiento absoluto y descifrado), ya que esto:

- permite inspeccionar resultados intermedios y validar hipótesis,

- facilita la reutilización de los scripts en otros retos o textos,

- y hace explícito qué parte del proceso está explotando cada propiedad estadística del lenguaje.

Los scripts desarrollados en este repositorio están diseñados de forma modular precisamente para permitir dicha automatización cuando sea conveniente. En [vigenere_breaker.sh](../scripts/bash/vigenere_breaker.sh) se puede encontrar un ejemplo de cómo integrar todas las fases en un único flujo automatizado.