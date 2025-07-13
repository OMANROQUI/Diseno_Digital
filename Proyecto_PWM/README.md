# Proyecto PWM

Este proyecto implementa un controlador PWM con interfaz de registro (`reg_if`) y núcleo PWM (`pwm_core`), integrado en el módulo `top_pwm`.

## Estructura del repositorio

```
Proyecto_PWM/
├── rtl/            # Módulos RTL Verilog-2001
│   ├── reg_if.v    # Interfaz de registros (CTRL, STATUS)
│   ├── pwm_core.v  # Núcleo PWM de 1 canal
│   └── top_pwm.v   # Módulo top-level que integra reg_if + pwm_core
├── tb/             # Testbenches (si los hubiera)
├── Makefile        # Scripts para síntesis y simulación
└── README.md       # Documentación de proyecto
```

## Módulos Verilog

* **reg\_if.v**: Interfaz de registro con parámetros `ADDR_WIDTH` y `DATA_WIDTH`. Mapea registros:

  * `CTRL` (offset `0x00`): R/W para configurar período y duty.
  * `STATUS` (offset `0x04`): R/O para leer flags de error.

* **pwm\_core.v**: Núcleo PWM de un canal. Parámetros:

  * `WIDTH_PERIOD`: bits de ancho para el contador de período.
  * `WIDTH_DUTY`: bits de ancho para valor de duty.

* **top\_pwm.v**: Top-level que conecta `reg_if` y `pwm_core`:

  * Extrae `period` y `duty` desde registro `CTRL`.
  * Detecta `error_flag` si `duty > period` y lo expone en `STATUS`.
  * Genera la señal `pwm_out`.

## Síntesis con Yosys

Para sintetizar el diseño y generar `top.json`:

```bash
make rtl
```

* Ejecuta: `read_verilog rtl/*.v; prep -top top_pwm; synth_ice40 -json top.json`
* Requiere **Yosys** instalado.

## Simulación con Icarus Verilog

Si dispones de testbenches en `tb/`, ejecuta:

```bash
make sim
```

* Compila y simula: `iverilog -g2012 -o sim.out rtl/*.v tb/*.v && vvp sim.out`
* Requiere **Icarus Verilog** instalado.

## Limpieza de artefactos

```bash
make clean
```

* Elimina `sim.out`, `top.json` y otros archivos generados.

---
