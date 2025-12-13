[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=21717487&assignment_repo_type=AssignmentRepo)
# Proyecto final - Electrónica Digital 1 - 2025-II

# Integrantes

- [Julian David Monsalve Sanchez](https://github.com/jumonsalves) 
- [Sofía Osejo Gallo](https://github.com/sosejo-UN)
- [Alejandro Pulido Sanchez](https://github.com/aljio)


# Nombre del proyecto

**Herm&Hest**

(Hermes, desde cualquier lugar del mundo, Hestia, brinda seguridad a su hogar)


Sistema electrónico para la gestión de entradas a hogares.

# Códigos

* [Teclado y pantalla](/src/teclado.v)
* [Ultrasonido y pantalla](/src/hcsr_04_distancia.v)
* [Protocolo uart](src/uart_lock_control.v)
* [Protocolo Uart](src/uart_rx.v)
* [Protocolo uart y servo](src/uart_servo.v)

# Documentación
## Descripción de la arquitectura


## Diagramas de la arquitectura


## Simulaciones

###
### Teclado

### Mensajes en la LCD

Para verificar el comportamiento del módulo [mensaje_Off_LCD](/src/mensaje_Off_LCD.v) se realizó el test bench [tb_mensaje_LCD](/src/tb_mensaje_LCD.v). 

#### Módulo

Se realizó como primer acercamiento a lo que podría ser el cambio de mensaje y encendido/apagado de la LCD.  

Implementa el control de una pantalla LCD en modo de 8 bits, mostrando distintos mensajes según el estado del sistema. Utiliza una máquina de estados finitos (FSM) y un divisor de frecuencia (clock de 16ms).

El módulo recibe el reloj principal (clk), una señal de reinicio (reset), una señal de habilitación (ready_i), una señal de distancia (distancia) que simula la señal proveniente del sensor ultrasónico y una entrada de selección de mensaje (mns). Por medio de estas entradas se controla las señales rs, rw, enable y el bus de datos (dat) hacia la LCD.

La FSM tiene cinco estados :

- IDLE: Es el estado inicial. El sistema permanece aquí hasta que la señal ready_i pasa a alto.

- APAGADO: Apaga el display LCD mientras no hay apresencia de algo frente al sensor (distancia = 0).

- CONFIG_CMD: Envía la secuencia de comandos de configuración a la LCD.

- WR_TEXT: Escribe el mensaje en la LCD dependiendo del valor de mns.

- CHANGE_MNS: Detecta un cambio en el mensaje seleccionado, limpia la pantalla y prepara el sistema para escribir el nuevo texto.

El módulo almacena los mensajes en bancos de memoria, cada uno con 16 caracteres:

- Mensaje 0: “INGRESA USUARIO”
- Mensaje 1: “INGRESAR CLAVE”
- Mensaje 2: “ABIERTO...”
- Mensaje 3: “INTRUSO >:[”

El sistema monitorea cambios en la señal mns para actualizar el texto que se visualiza en la LCD y en la señal distancia para prender o apagar la pantalla. 

### Test bench

El testbench genera un reloj y un reset para inicializar el sistema. Cada cierto tiempo genera cambios controlados en las señales distancia y mns. En la primera imagen se observa el inicio de la simulación donde distancia=1 (presencia detectada) y como mns=00, se muetsra el mensaje 0 en el display.

<p align="center">
  <img src="imagenes/tb_inicio_LCD.png" width="600">
</p>

Luego, cuando distancia cambia a cero, se observa como ya no se muestra ningún mensaje porque la panatalla "está apagada": 
<p align="center">
  <img src="imagenes/tb_apagado_LCD.png" width="600">
</p>

Finalmente, cuando distancia vuelve a ser 1, se empieza visualizar nuevamente el mensaje. Sin embargo, como hubo un cambio de mns antes de que la LCD se apagara, entonces ahora se visualiza el mns=1 que corresponde al mensaje 1:
<p align="center">
  <img src="imagenes/tb_cambio_mns_LCD.png" width="600">
</p>

## Evidencias de implementación

