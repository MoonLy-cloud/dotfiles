#!/usr/bin/env python

import requests
import json
import sys

# --- CONFIGURACIÓN ---
API_KEY = "7b55ef2469f8d633230bdbaa68d847f5"
UNITS = "metric"
LANG = "es"

# Iconos (Nerd Fonts)
WEATHER_ICONS = {
    "01d": "", "01n": "", "02d": "", "02n": "",
    "03d": "", "03n": "", "04d": "", "04n": "",
    "09d": "", "09n": "", "10d": "", "10n": "",
    "11d": "", "11n": "", "13d": "", "13n": "",
    "50d": "", "50n": ""
}

def get_coords():
    """Detecta la ubicación actual por IP"""
    try:
        # Usamos ip-api.com que es gratis y rápido
        res = requests.get("http://ip-api.com/json/", timeout=3)
        data = res.json()
        if data['status'] == 'success':
            return data['lat'], data['lon'], data['city']
    except:
        pass
    return None, None, None

try:
    # 1. Obtener coordenadas
    lat, lon, city_ip = get_coords()

    if lat is None:
        # Fallback si no hay internet o falla la geolocalización
        print(json.dumps({"text": " GPS Error", "tooltip": "No se pudo detectar ubicación"}))
        sys.exit()

    # 2. Pedir clima EXACTO para esas coordenadas
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units={UNITS}&lang={LANG}"
    res = requests.get(url)
    data = res.json()

    if res.status_code == 200:
        # Datos
        temp = int(data['main']['temp'])
        desc = data['weather'][0]['description'].capitalize()
        icon_code = data['weather'][0]['icon']
        icon = WEATHER_ICONS.get(icon_code, "")
        
        # Detalles
        feels_like = int(data['main']['feels_like'])
        humidity = data['main']['humidity']
        wind = data['wind']['speed']
        
        # Nombre de la ciudad (A veces OWM es más preciso que la IP)
        place_name = data['name'] 

        # Salida JSON
        out_data = {
            "text": f"{icon} {temp}°C",
            "tooltip": f"<b>📍 {place_name}</b>\n{desc}\n Sensación: {feels_like}°C\n Humedad: {humidity}%\n Viento: {wind} m/s",
            "class": "weather",
            "alt": desc
        }
        print(json.dumps(out_data))
    else:
        print(json.dumps({"text": " API Error", "tooltip": "Revisa tu API Key"}))

except Exception as e:
    print(json.dumps({"text": " Offline", "tooltip": str(e)}))