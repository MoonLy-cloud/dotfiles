#!/usr/bin/env python

import subprocess
import json
import sys
import os

# --- ICONOS ---
ICON_CPU = ""
ICON_RAM = ""
ICON_GPU = "󰢮"  # O usar 󰢮 (icono de Nvidia)
ICON_DISK = ""
ICON_LAPTOP = ""

def get_cpu_usage():
    """Obtiene uso de CPU usando top (rápido y sin dependencias)"""
    try:
        # Ejecuta top una vez en modo batch
        cmd = "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"
        output = subprocess.check_output(cmd, shell=True).decode("utf-8").strip()
        return int(float(output))
    except:
        return 0

def get_gpu_info():
    """Obtiene uso y nombre de la GPU NVIDIA"""
    try:
        # Consulta uso y nombre
        cmd = "nvidia-smi --query-gpu=utilization.gpu,name --format=csv,noheader,nounits"
        output = subprocess.check_output(cmd, shell=True).decode("utf-8").strip()
        usage_str, name = output.split(',', 1)
        
        usage = int(usage_str)
        name = name.strip()
        
        # Determinar etiqueta corta (RTX, GTX, AMD, ATI)
        short_name = "GPU"
        if "RTX" in name: short_name = "RTX"
        elif "GTX" in name: short_name = "GTX"
        elif "Radeon" in name or "AMD" in name: short_name = "AMD"
        
        return usage, short_name, name
    except:
        return 0, "GPU", "No NVIDIA detected"

def get_ram_usage():
    """Obtiene uso de RAM desde /proc/meminfo"""
    try:
        meminfo = {}
        with open("/proc/meminfo", "r") as f:
            for line in f:
                key, value = line.split(":", 1)
                meminfo[key] = int(value.strip().split()[0])

        total_kb = meminfo.get("MemTotal", 0)
        available_kb = meminfo.get("MemAvailable", 0)

        if total_kb <= 0:
            return 0, "0.0/0.0 GiB"

        used_kb = total_kb - available_kb
        usage_percent = int((used_kb / total_kb) * 100)

        used_gib = used_kb / (1024 * 1024)
        total_gib = total_kb / (1024 * 1024)
        usage_text = f"{used_gib:.1f}/{total_gib:.1f} GiB"

        return usage_percent, usage_text
    except:
        return 0, "0.0/0.0 GiB"

def get_system_details():
    """Recopila info para el tooltip con fuente bonita y pequeña"""
    details = []
    
    # 1. Modelo de Laptop
    try:
        with open("/sys/class/dmi/id/product_name", "r") as f:
            model = f.read().strip()
        details.append(f"{ICON_LAPTOP} <b>Modelo:</b> {model}")
    except:
        pass

    # 2. Modelo de CPU
    try:
        cpu_model = subprocess.check_output("lscpu | grep 'Model name' | cut -f 2 -d ':' | awk '{$1=$1}1'", shell=True).decode("utf-8").strip()
        details.append(f"{ICON_CPU} <b>CPU:</b> {cpu_model}")
    except:
        pass

    # 3. Discos Duros (LETRA PEQUEÑA AQUI)
    try:
        cmd = "df -h --output=target,size,pcent -x tmpfs -x devtmpfs | grep -v '/snap'"
        df_output = subprocess.check_output(cmd, shell=True).decode("utf-8").strip()
        
        lines = df_output.split('\n')
        # Ajusté un poco los espacios del header para que cuadre con la letra pequeña
        header = f"<b>{'MONTAJE':<15} {'TOTAL':<8} {'USO':<5}</b>"
        body = "\n".join([f"{line[:15]:<15} {line[15:23]:<8} {line[23:]:<5}" for line in lines[1:]])
        
        formatted_disk = f"<span font_family='JetBrainsMono Nerd Font Mono' size='small'>{header}\n{body}</span>"
        
        details.append(f"\n{ICON_DISK} <b>Almacenamiento:</b>\n{formatted_disk}")
    except Exception as e:
        details.append(f"\n{ICON_DISK} Error discos: {e}")
        pass
        
    return "\n".join(details)

# --- EJECUCIÓN PRINCIPAL ---
cpu_usage = get_cpu_usage()
ram_usage, ram_usage_text = get_ram_usage()
gpu_usage, gpu_label, gpu_full_name = get_gpu_info()
sys_details = get_system_details()

# Tooltip final
tooltip_text = (
    f"{sys_details}\n\n"
    f"{ICON_RAM} <b>RAM:</b> {ram_usage_text} ({ram_usage}%)\n"
    f"{ICON_GPU} <b>GPU:</b> {gpu_full_name} ({gpu_usage}%)"
)

# Salida JSON para Waybar
output = {
    "text": f"{ICON_CPU} {cpu_usage}%  {ICON_RAM} {ram_usage}%  {gpu_label} {gpu_usage}%",
    "tooltip": tooltip_text,
    "class": "sys_info"
}

print(json.dumps(output))