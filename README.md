
# PowerShell Profile

Configuración personal de perfil de PowerShell (`$PROFILE`). Incluye configuración de entorno (Oh My Posh, autocompletado) y funciones de automatización para manipulación de audio/video.

## Dependencias

Se asume la instalación y configuración de las siguientes herramientas en el `PATH`:

* **PowerShell 7+**
* **Gestores de paquetes/entorno:** `uv`, `scoop` (para instalar binarios o portables).
* **Módulos PS:** `Terminal-Icons`, `PSReadLine`, `oh-my-posh`.
* **Binarios externos:** `ffmpeg`, `ffprobe`, `yt-dlp`.
* **Python:** Entorno virtual con `whisperx` instalado.

> **Nota:** La ruta del entorno virtual está hardcodeada en `C:\Users\Gabi\whisperx-env`. Modificar la variable `$envPath` en la función `WhisperTxt` según corresponda.

## Instalación

1. Copiar el contenido de `Microsoft.PowerShell_profile.ps1` al perfil actual.
2. Se verifica la ruta con: `echo $PROFILE`.
3. de la misma manera se puede directamente abrir con VSCode: `code $PROFILE`

## Funciones Disponibles

### Transcripción (WhisperX)

#### `wtxt` (Alias de `WhisperTxt`)
Activa el entorno virtual, transcribe archivos de audio usando el modelo `large-v3` (idioma español) y genera un `.txt`. Desactiva el entorno al finalizar.

```powershell
wtxt archivo1.mp3 archivo2.wav

```

### Descarga y Procesamiento (YouTube)

#### `wyt`

Descarga el audio de enlaces de YouTube (formato m4a), obtiene el título original y lo transcribe automáticamente con `wtxt`. Elimina el audio tras la transcripción.

```powershell
wyt "[https://youtube.com/watch?v=](https://youtube.com/watch?v=)..."

```

#### `wyt2`

Variante de `wyt`. Fuerza nombres de archivo temporales (`temp_audio_X`) para evitar errores con caracteres especiales en títulos de video.

```powershell
wyt2 "[https://youtube.com/watch?v=](https://youtube.com/watch?v=)..."

```

#### `ytd`

Descarga videos de YouTube en la mejor calidad disponible, fusionando video y audio en un contenedor MP4.

```powershell
ytd "[https://youtube.com/watch?v=](https://youtube.com/watch?v=)..."

```

### Manipulación de Video (FFmpeg)

#### `subs` (Alias de `MuxSubs`)

Integra (mux) un archivo de subtítulos en un archivo de video sin recodificar (`-c copy`). Asigna metadatos de idioma (spa).

**Sintaxis:**
`subs <VideoInput> <SubtitleInput> [Output] [Lang] [Title]`

```powershell
# Uso básico (genera nombre automático)
subs video.mp4 subtitulo.srt

# Uso explícito
subs video.mkv subs.ass final.mkv

```

## Configuración de Shell

* **Prompt:** Inicializa Oh My Posh.
* **Completions:** Genera autocompletado para `uv` y `uvx`.
* **Keybindings:** `Tab` para autocompletado estilo menú (`ListView`).