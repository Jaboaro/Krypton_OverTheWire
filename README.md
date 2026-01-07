# OverTheWire Krypton — Writeup y Solución

Este repositorio contiene mi **solución al wargame Krypton** de OverTheWire y una explicación de cómo abordar cada nivel paso a paso con comandos de Bash, awk y conceptos de criptografía práctica.


## ¿Qué es Krypton?

**Krypton** es uno de los wargames educativos de la plataforma [OverTheWire](https://overthewire.org/), orientado a practicar conceptos básicos de **criptografía clásica y análisis de texto** en entornos Linux.

Cada nivel presenta un problema que requiere analizar datos cifrados y aplicar distintas técnicas para recuperar información, como por ejemplo:

- codificación Base64  
- cifrado César  
- análisis de frecuencia  
- manipulación de archivos y texto  

Aunque los retos están pensados para resolverse manualmente o con herramientas del sistema, en este repositorio se abordan mediante **scripts en Bash**, con el objetivo de automatizar los procesos y demostrar habilidades prácticas de scripting.



> En este repositorio **no publico contraseñas reales** para respetar las reglas de OverTheWire. Aquí explico *cómo se resuelve cada nivel, los comandos usados y los aprendizajes obtenidos*.


## Objetivo del proyecto

- Practicar scripting en Bash aplicado a problemas reales
- Automatizar tareas relacionadas con:
  - manipulación de archivos
  - procesamiento de texto
  - cifrados clásicos
  - uso de herramientas estándar de Unix

## Motivación adicional: matemáticas y fundamentos teóricos

Además del interés por el scripting y la automatización, este proyecto sirve como una forma de mantener contacto activo con las **matemáticas subyacentes a la criptografía clásica**.

Por ese motivo, el repositorio incluye una serie de *apéndices teóricos* donde se desarrollan con mayor profundidad:

- los fundamentos matemáticos de los cifrados utilizados
- su formulación algebraica
- las ideas computacionales necesarias para implementarlos
- la relación entre teoría y práctica

Estos apéndices están separados de las resoluciones para mantener una clara distinción entre:

- **qué hay que hacer para resolver un nivel**
- **por qué funciona matemáticamente**
- **cómo se implementa de forma computacional**
---

## Estructura del repositorio
```graphql
Krypton_OverTheWire/
│
├── README.md
│
├── solutions/                 # Resoluciones de los niveles
│   ├── level00.md
│   ├── level01.md
│   └── ...
│
├── appendices/                # Apéndices teóricos
│   ├──base64.md
|   ├──num_monoalphabetic_pass.md
│   └── ...
│
├── data/                 
│   └── frec
│       ├── en.txt
│       └── ...
│
└── scripts/
    ├── bash/
    │   ├── base64_decoder.sh
    │   ├── caesar_decoder_cli.sh
    │   └── ...
    ├── python/
    │   ├── base64_decoder.py
    │   ├── caesar_decoder.py
    │   └── ...
    │
    └── awk/
        ├── vigenere_freq.awk
        └── ...

```
## Modelos de frecuencia
Algunos scripts se basan en modelos de frecuencia lingüística para el criptoanálisis estadístico (p. ej., la puntuación de chi-cuadrado). Estos modelos se almacenan por separado en `data/frec`. Este diseño mantiene la lógica criptográfica independiente de las suposiciones lingüísticas y permite experimentar fácilmente con diferentes alfabetos o idiomas sin modificar el código de análisis. Se utiliza el modelo inglés de manera predeterminada a menos que se sobrescriba mediante el parámetro `freq_file`. Para mayor comodidad o para realizar pruebas rápidas, las frecuencias se pueden incorporar directamente al script si se requiere portabilidad.
## Estado del proyecto
En progreso. Algunos de los niveles están pendientes de completar.
## Referencias
-   [https://overthewire.org/wargames/krypton/](https://overthewire.org/wargames/krypton/)

