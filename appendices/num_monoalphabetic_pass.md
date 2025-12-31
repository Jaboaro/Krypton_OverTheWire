# Apéndice: Número de contraseñas en cifrado monoalfabético con restricciones
En este apéndice vamos a calcular el número de contraseñas (permutaciones del alfabeto) posibles de un cifrado monoalfabético general. Además, dado que una permutación en la que solo unas pocas letras cambian de posición no oculta el contenido del mensaje, vamos a hacer una estimación de cuántas de estas son adecuadas para la criptografía.
## Calculo del número total de permutaciones del alfabeto

En el cifrado César (con el alfabeto inglés) restringimos el número de contraseñas a $25$  porque podemos hacer $25$ desplazamientos distintos antes de volver a la identidad, es decir, antes de que a cada letra se le asocie ella misma. 

En un cifrado monoalfabético general, el número de contraseñas se puede calcular de la siguiente manera:

Imaginemos que tenemos 26 “huecos”, uno por cada letra del alfabeto, y que en cada hueco colocamos la letra a la que se asocia en el cifrado.

- En el primer hueco hay $26$ opciones posibles.
- Una vez elegida una, en el segundo hueco quedan $25$.
- En el siguiente, $24$, y así sucesivamente,
- hasta que en el último hueco solo queda una letra disponible.
Por tanto, el número total de maneras de asignar letras a los huecos es

$$26\cdot25\cdots 2\cdot1=26!.$$

## Introducción de restricciones
No todas estas permutaciones pueden considerarse cifrados “válidos”. Por ejemplo:
- Si en cada hueco colocamos la misma letra que le corresponde, no estamos cifrando nada: obtenemos el texto en claro.
- También pueden darse permutaciones en las que algunas letras permanecen fijas y solo unas pocas cambian de lugar permitiendo leer el texto sin complicaciones. Por ejemplo, si se quedan todas en su lugar salvo dos de ellas.

No tiene mucho sentido fijar un número mínimo de letras que deban cambiar para considerar que una permutación sea un cifrado:
claramente, **$0$ letras trasladadas** no es aceptable, mientras que **$26$ letras trasladadas** sí lo es. Entre ambos extremos hay muchas posibilidades intermedias. 


Se puede demostrar que para el alfabeto de $26$ letras, el número de cifrados en los que **ninguna letra se cifra como ella misma** es:

$$
!26 = 26! \sum_{k=0}^{26} \frac{(-1)^k}{k!}
\approx \frac{26!}{e}.
$$

Esto muestra que, aunque imponer la condición de que ninguna letra permanezca fija reduce el número total de claves, dicho número sigue siendo del orden de $26!$, y por tanto resulta completamente inabordable para un ataque por fuerza bruta.


## Demostración de la fórmula para el número de contraseñas con restricción


Llamaremos desarreglo a una permutación de $n$ elementos en la que ninguno queda en su posición original. Denotaremos por $!n$ el número de desarreglos de $n$ elementos.

Para calcularlo, necesitamos emplear **principio de inclusión–exclusión**. Así que vamos a explicar en qué consiste.

### Principio de Inclusión–Exclusión

El **principio de inclusión–exclusión** es una herramienta combinatoria que permite contar elementos que cumplen al menos una de varias propiedades, evitando el **sobreconteo** que ocurre al sumar simplemente los tamaños de los conjuntos.

Supongamos que queremos contar los elementos que pertenecen a al menos uno de varios conjuntos $A_1, A_2, \dots, A_n$.

- Si solo sumamos $|A_1| + |A_2| + \dots + |A_n|$, los elementos que pertenecen a más de un conjunto se cuentan varias veces.  
- Para corregir esto, vamos restando y sumando las intersecciones de los diferentes conjuntos para evitar sumar cada uno más de una vez.


### Enunciado formal del principio de inclusión–exclusión

Para conjuntos finitos $A_1, \dots, A_n$, se cumple:

$$
\left| \bigcup_{i=1}^n A_i \right| = \sum_{k=1}^{n} (-1)^{k+1} \sum_{1 \le i_1 < \cdots < i_k \le n} \left| A_{i_1} \cap \cdots \cap A_{i_k} \right|.
$$



### Demostración  de la fórmula

Daremos una demostración basada en conteo punto a punto.

#### Paso 1: fijar un elemento arbitrario

Sea $x$ un elemento del universo. Supongamos que pertenece exactamente a $r$ de los conjuntos $A_1, \dots, A_n$.

Es decir, existen exactamente $r$ índices tales que:

$$
x \in A_{i_1}, A_{i_2}, \dots, A_{i_r}, \quad \text{y} \quad x \notin A_j \text{ para los demás}.
$$



#### Paso 2: cuántas veces aparece $x$ en la fórmula

Analicemos cuántas veces contribuye $x$ al valor total del lado derecho de la fórmula.

-   En la suma $\sum |A_i|$, el elemento $x$ aparece exactamente $r$ veces.
    
-   En la suma de intersecciones dobles, aparece una vez por cada par de conjuntos entre esos $r$, es decir:
    
    $$
    \binom{r}{2}
    $$
    
    veces, y con signo negativo.
    
-   En las intersecciones triples aparece
    
    $$
    \binom{r}{3}
    $$
    
    veces, con signo positivo.
    
-   Y así sucesivamente.
    
-   Finalmente, aparece una vez en la intersección de los $r$ conjuntos que lo contienen, con signo $(-1)^{r+1}$.
    

Por tanto, la contribución total de $x$ a la suma es:

$$
\sum_{k=1}^{r} (-1)^{k+1} \binom{r}{k}.
$$


#### Paso 3: evaluación de la suma

Recordemos la identidad binomial:

$$
(1 - 1)^r = \sum_{k=0}^{r} \binom{r}{k} (-1)^k = 0.
$$

Separando el término $k=0$:

$$
\sum_{k=1}^{r} \binom{r}{k} (-1)^k = -1.
$$

Multiplicando por $-1$:

$$
\sum_{k=1}^{r} (-1)^{k+1} \binom{r}{k} = 1.
$$

Esto demuestra que **cada elemento que pertenece al menos a uno de los conjuntos contribuye exactamente una vez** a la suma total.



#### Paso 4: conclusión

-   Si un elemento pertenece a al menos uno de los conjuntos, contribuye exactamente con 1.
    
-   Si no pertenece a ninguno, no aparece en ninguna intersección y contribuye 0.
    

Por lo tanto, el valor total de la expresión es exactamente el número de elementos de la unión:

$$
\left| \bigcup_{i=1}^n A_i \right|.
$$

Esto completa la demostración.

## Número de desarreglos
Con esto claro, estamos en disposición de calcular el número de desarreglos
### Paso 1: planteamiento del problema


Sea $S_n$ el conjunto de todas las permutaciones de $\{1,2,\dots,n\}$, que tiene cardinal $|S_n| = n!$.

Para cada $i \in \{1,\dots,n\}$, definimos el conjunto:

$$
A_i = \{\text{permutaciones que dejan fijo al elemento } i\}.
$$

Nuestro objetivo es contar las permutaciones que **no pertenecen a ninguno de los conjuntos $ A_i $**, es decir,

$$
!n = \left| S_n \setminus \bigcup_{i=1}^n A_i \right|.
$$



### Paso 2: tamaños de las intersecciones

- Si fijamos una letra concreta $i$, el número de permutaciones que la dejan fija es:
  $$
  |A_i| = (n-1)!
  $$

- Si fijamos dos letras concretas $i,j$, el número de permutaciones que dejan ambas fijas es:
  $$
  |A_i \cap A_j| = (n-2)!
  $$

- En general, si fijamos $k$ letras concretas, el número de permutaciones que las dejan fijas es:
  $$
  (n-k)!
  $$

Además, hay $\binom{n}{k}$ maneras de elegir qué $k$ letras quedan fijas.



### Paso 3: aplicación del principio de inclusión–exclusión

El principio de inclusión–exclusión nos dice:

$$
\left| \bigcup_{i=1}^n A_i \right|=\sum_{k=1}^{n} (-1)^{k+1}\sum_{1 \le i_1 < \cdots < i_k \le n}|A_{i_1} \cap \cdots \cap A_{i_k}|.
$$

Sustituyendo los valores obtenidos:

$$
\left| \bigcup_{i=1}^n A_i \right|=\sum_{k=1}^{n} (-1)^{k+1} \binom{n}{k}(n-k)!.
$$

Por tanto, el número de desarreglos es

$$
!n
= n! - \sum_{k=1}^{n} (-1)^{k+1} \binom{n}{k}(n-k)!.
$$

Sacando factor común $n!$:

$$
!n
= n!\left( 1 - \sum_{k=1}^{n} (-1)^{k+1} \frac{1}{k!} \right)
= n! \sum_{k=0}^{n} \frac{(-1)^k}{k!}.
$$

Esta es la **fórmula exacta del número de desarreglos**.



### Paso 4: aproximación asintótica

La serie de Taylor de $ e^{-1} $ es:

$$
e^{-1} = \sum_{k=0}^{\infty} \frac{(-1)^k}{k!}.
$$

Comparándola con la expresión anterior, obtenemos:

$$
!n = n! \sum_{k=0}^{n} \frac{(-1)^k}{k!}
\;\longrightarrow\;
\frac{n!}{e}
\quad \text{cuando } n \to \infty.
$$

En particular,

$$
!n \approx \frac{n!}{e},
$$

y el error relativo es muy pequeño incluso para valores moderados de $n$.
