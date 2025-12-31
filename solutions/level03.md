# Nivel 3 – Sustitución monoalfabética
## Descripción
En este nivel se abandona el cifrado César y se introduce un **cifrado por sustitución monoalfabética**, un esquema considerablemente más fuerte.

A diferencia del cifrado por rotación, aquí no existe un desplazamiento fijo: cada letra del alfabeto se sustituye por otra distinta, formando una permutación completa del alfabeto. La clave, por tanto, no es un número, sino una correspondencia entre letras.

El reto proporciona varios textos cifrados con **la misma clave**, y se indica que los textos originales están escritos en **inglés americano**, lo cual será fundamental para poder romper el cifrado.
## Enunciado del problema
```text
Well done. You’ve moved past an easy substitution cipher.

The main weakness of a simple substitution cipher is repeated use of a simple key
[...]

The password to the next level is found in the file ‘krypton4’. You have also found 3 other files. (found1, found2, found3)

You know the following important details:

The message plaintexts are in American English (*** very important) - They were produced from the same key (*** even better!)
Enjoy.
```
## Enfoque de resolución
A diferencia de los niveles anteriores, ya **no es viable probar todas las claves posibles**, ya que un cifrado por sustitución monoalfabética tiene:


$$26!=26\cdot25\cdots 2\cdot1\approx 4\cdot 10^{26}$$

posibles claves distintas. Incluso [imponiendo restricciones adicionales](../appendices/num_monoalphabetic_pass.md), el espacio de búsqueda sigue siendo astronómico, por lo que la fuerza bruta no es una opción.

En su lugar, este tipo de cifrado se ataca mediante **criptoanálisis clásico**, combinando:

-   análisis estadístico,
    
-   conocimiento del idioma original,
    
-   patrones lingüísticos,
    
-   y refinamiento progresivo de hipótesis.
    

Esto permite aplicar **análisis de frecuencias**, ya que al combinar varios textos cifrados obtenemos una muestra suficientemente grande para que las frecuencias de letras se aproximen a las del inglés real. La frecuencia con la que aparece cada letra es diferente y particular de cada idioma. Por ejemplo, en inglés la `E` aparece unas 200 vececes más que la `Z`.

El procedimiento general es el siguiente:

1.  **Unir todos los textos cifrados disponibles** para aumentar el tamaño de la muestra.
    
2.  **Contar la frecuencia de aparición de cada letra cifrada**.
    
3.  Comparar esas frecuencias con las frecuencias típicas del inglés.
    
4.  Proponer una correspondencia inicial entre letras cifradas y letras reales.
    
5.  Aplicar la sustitución parcial al texto objetivo (`krypton4`).
    
6.  Refinar manualmente el mapeo observando patrones reconocibles:
    
    -   palabras frecuentes (`THE`, `AND`, `OF`, `TO`, …)
        
    -   terminaciones comunes (`-ED`, `-ING`)
        
    -   estructuras típicas (`THE _____`)
        
7.  Ajustar iterativamente la sustitución hasta obtener un texto coherente.
    

Este proceso no es automático: combina estadística con razonamiento lingüístico.



## Preparación y análisis de frecuencias

Para facilitar el análisis, desde local se copian los archivos del servidor y se combinan en uno solo:
```bash
scp -P 2231 krypton3@krypton.labs.overthewire.org:"/krypton/krypton3/*" .
cat found1 found2 found3 > found.txt
```
A continuación, se calcula la frecuencia de aparición de cada letra:

```bash
cat found.txt | tr '[:lower:]' '[:upper:]' |grep -o '[A-Z]' | sort | uniq -c | sort -nr
```
Este pipeline:

- extrae únicamente letras,

- las normaliza a mayúsculas,

- cuenta apariciones,

- y ordena por frecuencia descendente.

Para facilitar su uso posterior, puede obtenerse la lista compacta de letras ordenadas por frecuencia:

```bash
... | awk '{print $2}' | paste -sd ''
```
Esto produciría una cadena como
```text
SQJUBNGCDZVWMYTXKELAFIORHP
```
### Comparamos con la frecuencia del inglés
La [frecuencia de aparición](https://en.wikipedia.org/wiki/Letter_frequency) de las letras en inglés es aproximadamente:
```bash
ETAOINSHRDLCUMWFGYPBVKJXQZ
```
Comparando ambas listas, se puede construir una primera hipótesis de sustitución:
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
Esta correspondencia no tiene por qué ser perfecta, pero sirve como punto de partida.
### Sustitución progresiva y refinamiento
Al realizar esta primera sustitución
```bash
cat krypton4 | tr [SQJUBNGCDZVWMYTXKELAFIORHP] [ETAOINSHRDLCUMWFGYPBVKJXQZ]
```
Obtenemos como salida:
```bash
GELLC ISEAR ELEKE LFIUN MTOOG INCHO XXXXX
```
Y observamos patrones típicos del inglés. 
- La primera palabra `GELL` podría ser `WELL`
- `LEKEL` probablemente sea `LEVEL`.
- Si comienza por `WELL` probablemente las siguientes cuatro letras sean `DONE`.
A partir de ahí, se refinan las sustituciones manualmente, ajustando el mapeo letra a letra hasta obtener un texto completamente coherente.

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
# Comentarios
Este enfoque requiere una cantidad considerable de prueba y error, ya que la sustitución se va refinando progresivamente a partir de hipótesis sobre palabras frecuentes y patrones del idioma. En este caso concreto, el contexto del reto y la estructura predecible del mensaje final permitieron deducir directamente el contenido de `krypton4` y ajustar la sustitución hasta obtener el texto en claro.

No obstante, en un escenario más general resulta más práctico aplicar estas sustituciones sobre `found.txt`, ya que contiene una mayor cantidad de texto. Un corpus más grande incrementa la probabilidad de encontrar patrones reconocibles (como palabras comunes, terminaciones o secuencias repetidas), lo que facilita validar y corregir el mapeo entre letras cifradas y letras reales.

Aunque aquí el descifrado se ha realizado manualmente, existen métodos para **automatizar total o parcialmente** este proceso. Por ejemplo, mediante el uso de análisis de frecuencias automatizado comparado con distribuciones estadísticas del inglés y  y scripts que evalúan automáticamente hipótesis de sustitución usando diccionarios o modelos de lenguaje.
    

Profundizaremos en estos métodos en un futuro apéndice.
## Apéndices relacionados
- [Número de contraseñas en cifrado monoalfabético con restricciones](../appendices/cifrado_cesar.md)







