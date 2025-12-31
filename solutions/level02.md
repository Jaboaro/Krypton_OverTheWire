# Nivel 2 – Cifrado César con oráculo conocido
## Descripción

En este nivel se nos proporciona un texto cifrado mediante un **cifrado César**, pero a diferencia del nivel anterior, **no conocemos el desplazamiento utilizado**.

Sin embargo, el reto introduce una nueva característica clave: disponemos de un programa que cifra texto usando *exactamente la misma clave* que se ha usado para generar el mensaje objetivo. Esto convierte el problema en uno de **criptoanálisis por texto elegido**, donde podemos explotar el comportamiento del cifrador para deducir el desplazamiento.
## Enunciado del problema
```text
ROT13 is a simple substitution cipher.

Substitution ciphers are a simple replacement algorithm. 
[...]

The password for level 3 is in the file krypton3. It is in 5 letter group ciphertext. It is encrypted with a Caesar Cipher. Without any further information, this cipher text may be difficult to break. You do not have direct access to the key, however you do have access to a program that will encrypt anything you wish to give it using the key. If you think logically, this is completely easy.

One shot can solve it!

Have fun.
```
## Exploración inicial
Tras conectarnos al servidor:
```bash
ssh krypton2@krypton.labs.overthewire.org -p 2231
```
localizamos los archivos del nivel. En el nivel anterior ya vimos que se encuentran en `/krypton/krypton2`. Entre ellos encontramos
```bash
/krypton/krypton2/encrypt
/krypton/krypton2/keyfile.dat
/krypton/krypton2/krypton3
```
Respectivamente, el programa empleado para encriptar los archivos, la contraseña mediante la que se encriptar (no tenemos permisos de lectura sobre ella) y el texto que debemos descifrar.
Si inspeccionamos el contenido cifrado:
```bash
cat /krypton/krypton2/krypton3
```
Obtenemos
```text
OMQEMDUEQMEK
```
Claramente se trata de texto alfabético en mayúsculas, consistente con un cifrado César.

En primer lugar, vamos a intentar obtener información del propio programa para encriptar

```bash
strings encrypt
```
El resultado no aporta mucho, salvo una línea orientativa:
```text
usage: encrypt foo  - where foo is the file containing the plaintext
```
Era de esperar, pues sabemos que la contraseña no está *hardcodeada*.

## Preparación del entorno
Como no tenemos permisos de escritura en el directorio del reto (y para no modificar el entorno global para futuros jugadpres), trabajaremos en un directorio temporal:

```bash
mktemp -d
/tmp/tmp.XokOox1MaY
cd /tmp/tmp.XokOox1MaY
ln -s /krypton/krypton2/keyfile.dat
```
## Enfoque de resolución
Aunque no conocemos el desplazamiento, sí tenemos acceso a un binario (`encrypt`) que cifra cualquier texto usando la misma clave secreta.

Esto nos permite realizar un ataque muy sencillo:

> Si ciframos un texto cuyo contenido conocemos, podemos observar cómo se transforma cada letra y deducir el desplazamiento.

En particular, basta con cifrar una sola letra.

La estrategia será la siguiente:

1.  **Cifrar un texto conocido**, por ejemplo el alfabeto completo.
    
2.  **Comparar texto plano y texto cifrado** para observar cómo se desplazan las letras.
    
3.  **Deducir el desplazamiento** observando cuántas posiciones se ha movido cada carácter.
    
4.  Aplicar ese mismo desplazamiento, en sentido inverso, al archivo `krypton3` para recuperar la contraseña.
    
# Implementación
Creamos un archivo con el abecedario
```bash
echo "ABCDEFGHIJKLMNOPQRSTUVWXYZ" > texto_plano.txt
```
Lo ciframos
```bash
/krypton/krypton2/encrypt texto_plano.txt
```
Esto genera un archivo llamado `ciphertext`. Para visualizarlo correctamente, añadimos un salto de línea:
```bash
echo "" >> ciphertext
```
Y mostramos ambos contenidos:
```bash
cat texto_plano.txt ciphertext
```
Salida:
```text
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
./caesar_decoder_cli -d "OMQEMDUEQMEK" 12
```
O (aunque no sea el método de resolución intencionado) podemos obtenerla mediante fuerza bruta
```bash
./caesar_decoder_cli -b "OMQEMDUEQMEK"
```
### Mejora del script anterior
Este ejercicio nos da una idea clara de cómo mejorar el programa del nivel anterior. En lugar de exigir que el texto se pase como argumento, resulta mucho más flexible permitir que el programa:

- lea el texto desde stdin

- escriba el resultado por stdout

- pueda usarse con redirecciones y pipes

Estas mejoras se implementan en [caesar_decoder_filter.py](../scripts/bash/caesar_decoder_filter.sh)
### Scripts utilizados
- [caesar_decoder_cli.sh](../scripts/bash/caesar_decoder_cli.sh)
- [caesar_decoder_filter.py](../scripts/bash/caesar_decoder_filter.sh)
## Apéndices relacionados

- [Cifrado César, ROT13 y aritmética modular](../appendices/cifrado_cesar.md)

