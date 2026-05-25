# 🎨 Rofi Themes - Sistema Modular

## Estructura

Cada tema de Rofi debe estar en su propia carpeta dentro de `Configs-rofi/`:

```
Configs-rofi/
├── vaporwave/
│   ├── config.rasi          # Configuración y fuentes
│   └── style.rasi           # Estilos visuales (colores, bordes, etc.)
├── origami/
│   ├── config.rasi
│   └── style.rasi
└── [otros-temas]/
```

## Características

- **PyWal Integration**: Todos los temas importan `~/.cache/wal/colors-rofi-dark.rasi`
- **Colores Base**: `@foreground`, `@background`, `@color1`...`@color7`
- **Sincronización**: El script `theme_selector.sh` aplica automáticamente temas de Rofi + Waybar si comparten nombre

## Crear un Nuevo Tema

1. Crea una nueva carpeta: `mkdir Configs-rofi/mi-tema`
2. Copia los archivos de un tema existente como base
3. Personaliza `config.rasi` (fuentes, modi, etc.)
4. Personaliza `style.rasi` (colores, bordes, tamaños)
5. Si quieres que se aplique junto con Waybar, crea una carpeta con el **mismo nombre** en `Waybar/Configs-way/`

## Uso

```bash
~/.config/hypr/scripts/theme_selector.sh
```

El script:
- Muestra lista de temas Waybar disponibles
- Aplica tema de Waybar
- Si existe tema de Rofi con el mismo nombre, lo aplica también
- Reinicia Waybar
- Crea backups automáticos

## Notas

- Los temas pueden tener solo Waybar o solo Rofi (el script es flexible)
- PyWal colores base se aplican siempre, cada tema puede extender con sus propios colores
- Backups se guardan en `.theme-backups/` de cada aplicación
