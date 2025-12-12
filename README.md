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

Para verificar el comportamiento del módulo [mensaje_Off_LCD](/src/mensaje_Off_LCD.v) se realizó el test bench [tb_mensaje_LCD](/src/tb_mensaje)

<p align="center">
  <img src="imagenes/tb_mens.png" width="600">
</p>

<p align="center">
  <img src="imagenes/tb_mnsapagar.png" width="600">
</p>

<p align="center">
  <img src="imagenes/tb_cambiomns.png" width="600">
</p>

## Evidencias de implementación

