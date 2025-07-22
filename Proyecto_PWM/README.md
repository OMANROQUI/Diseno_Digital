# Proyecto PWM Programable

Este proyecto implementa un **controlador PWM programable** en Verilog, pensado para sistemas digitales y FPGA, incluyendo banco de pruebas automatizados y demo de software para validación.

---

## Índice

- [Diagrama de bloques](#diagrama-de-bloques)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Descripción de los módulos](#descripción-de-los-módulos)
  - [Interfaz de registros (`reg_if`)](#1-interfaz-de-registros-reg_if)
  - [Núcleo PWM (`pwm_core`)](#2-núcleo-pwm-pwm_core)
  - [Módulo top-level (`top_pwm`)](#3-módulo-top-level-top_pwm)
- [Testbenches y verificación](#testbenches-y-verificación)
- [Demo de software](#demo-de-software)
- [Simulación y visualización de resultados](#simulación-y-visualización-de-resultados)
- [Autores y créditos](#autores-y-créditos)

---

## Diagrama de bloques

*Inserta aquí tu diagrama de bloques (formato PNG/JPG):*

![Diagrama de bloques](doc/DiagramaBloques.png)

---

## Estructura del proyecto

Proyecto_PWM/
├── rtl/ # Código fuente RTL en Verilog
├── tb/ # Testbenches de los módulos
├── sim/ # Scripts de simulación y Makefile
├── demo/ # Demo de software (driver_stub)
├── README.md # (Este archivo)


**¿Por qué esta estructura?**  
- Permite separar claramente el diseño RTL, los bancos de pruebas, los scripts de automatización y las herramientas de demo.
- Facilita la escalabilidad, mantenimiento y trazabilidad del proyecto a medida que crece.
- Cada carpeta tiene un README específico para mayor claridad.

---

## Descripción de los módulos

### 1. Interfaz de registros (`reg_if`)

**Función:**  
Gestiona el acceso por bus a los registros de control (`CTRL`) y de estado (`STATUS`).  
Permite la configuración de los parámetros del PWM (periodo, duty) y la lectura del estado del sistema.

**Detalles clave:**
- Protocolo de acceso simple (dirección, dato, señales de enable de lectura/escritura).
- Actualización de registros en flanco de reloj, con reset asíncrono.
- Facilita la comunicación con software y periféricos externos.

---

### 2. Núcleo PWM (`pwm_core`)

**Función:**  
Genera la señal PWM según los parámetros de periodo y ciclo de trabajo recibidos desde el módulo de control.

**Detalles clave:**
- Diseño parametrizable en ancho de periodo y duty.
- Salida síncrona a reloj, con contador interno.
- Muy eficiente y fácil de escalar a varios canales si se desea.

---

### 3. Módulo top-level (`top_pwm`)

**Función:**  
Integra la interfaz de registros y el núcleo PWM, formando el sistema completo.

**Detalles clave:**
- Mapea el registro de control a los parámetros del PWM (extracto de bits).
- Genera la señal de error si duty > periodo.
- Conecta todos los buses internos y salidas externas.

---

## Testbenches y verificación

**¿Por qué esta batería de testbenches?**  
- Permite validar cada módulo de manera aislada (unit testing).
- Facilita la depuración y asegura que los módulos funcionen correctamente antes de la integración.
- El testbench top-level asegura que la integración sea correcta y funcional.

**Cobertura de los testbenches:**
- **reg_if_tb.v:** Verifica lecturas y escrituras por bus, actualizaciones de registros y estado.
- **pwm_core_tb.v:** Verifica la generación PWM en distintos duty cycles, validando que la señal resultante es la esperada.
- **top_pwm_tb.v:** Verifica el funcionamiento del sistema completo, desde el acceso por bus hasta la salida PWM y el manejo de errores.

---

## Demo de software

Incluye un **driver stub** en Python para validar la lógica de acceso a registros desde software, emulando el comportamiento de un microcontrolador o CPU.

- Permite escribir en el registro de control y leer el de estado, mostrando flags y valores por consola.
- Útil para validar la comunicación hardware-software antes de la implementación real.

---

## Simulación y visualización de resultados

**Simulación:**

Desde la raíz del proyecto puedes ejecutar:

```bash
./sim/runsim.sh all

o

make all

Visualización:
Abre los archivos VCD generados con GTKWave para analizar en detalle las señales de cada testbench:

gtkwave sim/top_pwm_tb.vcd

Autores y créditos
  Diseño y verificación:
    Oscar David Guerrero Hernandez
    Omar Andres Rodriguez Quiceno