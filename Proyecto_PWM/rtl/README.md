# Documentación RTL — Controlador PWM

## Propósito de la carpeta `rtl/`

Esta carpeta contiene **todo el código RTL (Register Transfer Level) en Verilog-2001** correspondiente a un controlador PWM de un canal con interfaz de configuración y estado.  
El diseño es integrable, reutilizable y compatible tanto con síntesis como simulación.

---

## Estructura de módulos

rtl/
├── reg_if.v # Interfaz de registro de configuración y estado
├── pwm_core.v # Núcleo generador de señal PWM
└── top_pwm.v # Módulo top-level que conecta los anteriores


---

## 1. Módulo `reg_if.v` — Interfaz de registro

### Función

Gestiona el acceso del procesador o bus de control a dos registros:
- **CTRL**: para configurar el valor del periodo y el ciclo de trabajo (duty cycle).
- **STATUS**: para reportar errores y el estado del módulo.

### Puertos principales

| Señal        | Dirección | Ancho                | Descripción                             |
|--------------|-----------|----------------------|-----------------------------------------|
| `clk`        | in        | 1                    | Reloj                                   |
| `reset_n`    | in        | 1                    | Reset activo bajo                       |
| `addr`       | in        | `ADDR_WIDTH`         | Dirección de acceso a registro          |
| `wdata`      | in        | `DATA_WIDTH`         | Datos de escritura                      |
| `rdata`      | out       | `DATA_WIDTH`         | Datos de lectura                        |
| `wen`        | in        | 1                    | Habilitación de escritura               |
| `ren`        | in        | 1                    | Habilitación de lectura                 |
| `ctrl`       | out       | `DATA_WIDTH`         | Valor actual del registro CTRL          |
| `status_in`  | in        | `DATA_WIDTH`         | Flags de error generados internamente   |
| `status`     | out       | `DATA_WIDTH`         | Valor actual de STATUS                  |

### Mapeo de registros

- **CTRL** (offset `0x00`):  
  - `[31:16]` → Período del PWM  
  - `[15:0]`  → Duty cycle (ancho de pulso)
- **STATUS** (offset `0x04`):  
  - `[0]`     → Flag de error (`duty > period`)  
  - `[31:1]`  → Reservado (0)

### Motivación

El uso de CTRL y STATUS separados facilita el control desde software y simplifica la depuración.  
El mapeo permite modificar y consultar fácilmente los parámetros esenciales del PWM.

---

## 2. Módulo `pwm_core.v` — Núcleo PWM

### Función

Genera la señal PWM a partir de:
- **Periodo:** Valor máximo del contador antes de reiniciar el ciclo PWM.
- **Duty cycle:** Ancho del pulso alto en cada periodo.

### Puertos principales

| Señal      | Dirección | Ancho           | Descripción                       |
|------------|-----------|-----------------|-----------------------------------|
| `clk`      | in        | 1               | Reloj                             |
| `reset_n`  | in        | 1               | Reset activo bajo                 |
| `period`   | in        | `WIDTH_PERIOD`  | Período del PWM                   |
| `duty`     | in        | `WIDTH_DUTY`    | Duty cycle (ancho de pulso alto)  |
| `pwm_out`  | out       | 1               | Salida digital PWM                |

### Descripción funcional

- El módulo contiene un contador que avanza con cada flanco de reloj.
- Cuando el contador llega a `period-1`, se reinicia a 0.
- La salida `pwm_out` está en alto (`1`) mientras `counter < duty`, y en bajo (`0`) el resto del periodo.

### Motivación

Este método es eficiente y ampliamente usado en hardware digital, y permite parametrizar la resolución de periodo y duty con facilidad.

---

## 3. Módulo `top_pwm.v` — Integración top-level

### Función

- Conecta la interfaz de registro y el núcleo PWM.
- Extrae de `CTRL` los valores de periodo y duty.
- Genera un flag de error si `duty > period`.
- Expone todo a través de una interfaz estándar.

### Descripción interna

- Instancia `reg_if` y `pwm_core`.
- Mapea el registro `CTRL` para dividirlo en `period` y `duty`.
- Evalúa la condición de error en hardware y la reporta a `STATUS`.

### Razón de la estructura

Separar el diseño en tres módulos (registro, núcleo y top) ofrece:
- **Reutilización:** El núcleo PWM puede usarse en otros proyectos.
- **Escalabilidad:** Fácil de extender a más canales o agregar funciones.
- **Claridad:** El flujo de datos y control es explícito y modular.
- **Depuración sencilla:** Cada bloque puede simularse y probarse por separado.

---

## Parámetros y convenciones

- **`ADDR_WIDTH`**: ancho del bus de direcciones (por defecto 8 bits).
- **`DATA_WIDTH`**: ancho de los registros de datos (por defecto 32 bits).
- **`WIDTH_PERIOD` / `WIDTH_DUTY`**: resolución del periodo y duty (por defecto 16 bits).
- Buses usan **little endian** (bits menos significativos a la derecha).

---

## Ejemplo de acceso (pseudo-código)

```c
// Configurar periodo=1000, duty=400
uint32_t ctrl = (1000 << 16) | 400;
write_reg(CTRL_ADDR, ctrl);

// Leer estado
uint32_t status = read_reg(STATUS_ADDR);
if (status & 0x1) {
  // Error: duty > period
}
