# Nivel 0 - Base64
## Descripción
En este nivel se proporciona una cadena codificada en **Base64** que contiene la contraseña necesaria para acceder al siguiente nivel.

Base64 no es un cifrado, sino un método de codificación binaria–texto, por lo que no requiere clave para recuperar el contenido original.

## Enunciado del problema
```
Welcome to Krypton! The first level is easy. The following string encodes the password using Base64:

S1JZUFRPTklTR1JFQVQ=

Use this password to log in to krypton.labs.overthewire.org with username krypton1 using SSH on port 2231. You can find the files for other levels in /krypton/
```
## Enfoque de resolución

Dado que el texto está codificado en Base64, basta con aplicar el proceso inverso (decodificación) para obtener el mensaje original.

No se trata de un problema criptográfico en sentido estricto, sino de reconocer el formato de codificación utilizado y aplicar la herramienta adecuada.
## Implementación
### Scripts utilizados
- [base64_decoder.sh](../scripts/bash/base64_decoder.sh)
- [base64_decoder.py](../scripts/python/base64_decoder.py)
### Resolución  
La resolución de este nivel es muy sencilla ya que nos indica cómo se ha "encriptado" el mensaje. 
```bash
echo "S1JZUFRPTklTR1JFQVQ=" | base64 --decode
```
Esto devuelve directamente la contraseña necesaria para acceder al siguiente nivel.

## Comentarios
Este nivel sirve como introducción al uso de herramientas de codificación y decodificación en entornos Unix, y como recordatorio de la diferencia entre:

- **codificación**, cuyo objetivo es representar datos de forma segura o transportable

- **cifrado**, cuyo objetivo es ocultar información mediante una clave

Para una explicación más detallada sobre el funcionamiento interno de Base64, puede consultarse el apéndice correspondiente. Además, en [base64_decoder.sh](../scripts/bash/base64_decoder.sh) y [base64_decoder.py](../scripts/python/base64_decoder.py) se presentan dos posibles implementaciones. 

## Apendices relacionados
- [Base64: fundamentos y funcionamiento](../appendices/base64.md)

