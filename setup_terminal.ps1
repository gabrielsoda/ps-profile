# setup_terminal.ps1 - Restaura la configuración de Windows Terminal
$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot

Write-Host "Configurando Windows Terminal..." -ForegroundColor Cyan

# Buscar settings.json de Windows Terminal
$PossiblePaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
)

$SettingsPath = $null
foreach ($path in $PossiblePaths) {
    if (Test-Path $path) {
        $SettingsPath = $path
        break
    }
}

if (-not $SettingsPath) {
    Write-Error "No se encontró Windows Terminal instalado. Instálalo desde Microsoft Store primero."
    exit 1
}

Write-Host "Destino: $SettingsPath" -ForegroundColor Gray

# Verificar que existe el archivo fuente
$SourcePath = Join-Path $ScriptDir "settings.json"
if (-not (Test-Path $SourcePath)) {
    Write-Error "No se encontró settings.json en el repositorio."
    exit 1
}

# Backup del archivo actual
$BackupPath = "$SettingsPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $SettingsPath $BackupPath
Write-Host "Backup creado: $BackupPath" -ForegroundColor Yellow

# Copiar configuración
Copy-Item $SourcePath $SettingsPath -Force
Write-Host "✓ Configuración restaurada" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Windows Terminal configurado." -ForegroundColor Green
Write-Host ""
Write-Host "Perfiles disponibles:" -ForegroundColor Yellow
Write-Host "  • PowerShell (default)"
Write-Host "  • Windows PowerShell"
Write-Host "  • Ubuntu (WSL)"
Write-Host "  • SSH Server (gsoda@192.168.1.38)"
Write-Host "  • WSL Home (Ubuntu ~)"
Write-Host ""
Write-Host "Para abrir el layout de 3 paneles:" -ForegroundColor Yellow
Write-Host "  .\open_dev_layout.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Reinicia Windows Terminal para aplicar los cambios." -ForegroundColor Cyan
