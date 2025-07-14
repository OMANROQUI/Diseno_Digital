#!/usr/bin/env python3
"""
driver_stub.py — Mock de driver para reg_if + PWM Top
Escribe en ADDR_CTRL para configurar periodo/duty, lee ADDR_STATUS,
y muestra logs de lo que sucedería en hardware.
"""

import time

# Offsets de registros
ADDR_CTRL   = 0x00
ADDR_STATUS = 0x04

# Mock de memoria-mapeo de registros
_registers = {
    ADDR_CTRL:   0x00000000,
    ADDR_STATUS: 0x00000000,
}

def write_reg(addr, val):
    """Simula una escritura a un registro."""
    print(f"[WRITE]  Addr=0x{addr:02X} ← 0x{val:08X}")
    _registers[addr] = val

def read_reg(addr):
    """Simula una lectura de un registro."""
    val = _registers.get(addr, 0)
    print(f"[READ ]  Addr=0x{addr:02X} → 0x{val:08X}")
    return val

def main():
    print("=== Demo Driver Stub ===\n")

    # 1) Ciclo de 0→100% duty, periodo fijo en 100
    for duty in range(0, 101, 10):
        # Empaqueta periodo=100 (alto 16 bits) y duty (bajo 16 bits)
        ctrl_val = (100 << 16) | duty
        write_reg(ADDR_CTRL, ctrl_val)

        # Leemos status
        # El bit [0] de status indica error_flag (duty > periodo)
        status = read_reg(ADDR_STATUS)
        error_flag = status & 0x1

        print(f"  → Configurado duty={duty}%   error_flag={error_flag}\n")
        time.sleep(0.1)

    # 2) Caso de error: duty=150 > periodo=100
    print("--- Probando condición de error ---")
    ctrl_val = (100 << 16) | 150
    write_reg(ADDR_CTRL, ctrl_val)
    status = read_reg(ADDR_STATUS)
    error_flag = status & 0x1
    print(f"  → duty=150%, error_flag={error_flag}\n")

    print("=== Demo completado ===")

if __name__ == "__main__":
    main()
