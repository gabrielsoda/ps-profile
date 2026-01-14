# setup_scoop.ps1 - Versión con GUI de checkboxes
$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "Iniciando configuración de entorno Scoop..." -ForegroundColor Cyan

# 1. Instalar Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
}

# 2. Cargar configuración
$JsonPath = Join-Path $ScriptDir "scoop_apps.json"
if (-not (Test-Path $JsonPath)) { Write-Error "No se encontró scoop_apps.json" }
$Config = Get-Content $JsonPath -Raw | ConvertFrom-Json

# 3. Restaurar Buckets
Write-Host "Configurando buckets..." -ForegroundColor Yellow
$CurrentBuckets = scoop bucket list
foreach ($bucket in $Config.buckets) {
    if ($CurrentBuckets -notmatch $bucket.Name) {
        scoop bucket add $bucket.Name $bucket.Source
    }
}
scoop update

# 4. Crear GUI de selección
Write-Host "Abriendo selector de aplicaciones..." -ForegroundColor Yellow

# Crear formulario
$form = New-Object System.Windows.Forms.Form
$form.Text = "Scoop - Selector de Aplicaciones"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $false

# Label de instrucciones
$label = New-Object System.Windows.Forms.Label
$label.Text = "Selecciona las aplicaciones que deseas instalar:"
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(560, 20)
$form.Controls.Add($label)

# CheckedListBox para las apps
$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Location = New-Object System.Drawing.Point(10, 40)
$checkedListBox.Size = New-Object System.Drawing.Size(560, 320)
$checkedListBox.CheckOnClick = $true

# Agregar apps a la lista (TODAS SELECCIONADAS por defecto)
foreach ($app in $Config.apps) {
    $displayText = "$($app.Name) - v$($app.Version) [$($app.Source)]"
    $index = $checkedListBox.Items.Add($displayText)
    $checkedListBox.SetItemChecked($index, $true)  # ← TODAS TILDADAS
}

$form.Controls.Add($checkedListBox)

# Label con contador
$countLabel = New-Object System.Windows.Forms.Label
$countLabel.Location = New-Object System.Drawing.Point(10, 370)
$countLabel.Size = New-Object System.Drawing.Size(560, 20)
$countLabel.Text = "Seleccionadas: $($checkedListBox.CheckedItems.Count) de $($checkedListBox.Items.Count)"
$form.Controls.Add($countLabel)

# Actualizar contador cuando cambia la selección
$checkedListBox.add_ItemCheck({
    # El evento se dispara ANTES del cambio, entonces necesitamos usar BeginInvoke
    $form.BeginInvoke([Action]{
        $countLabel.Text = "Seleccionadas: $($checkedListBox.CheckedItems.Count) de $($checkedListBox.Items.Count)"
    })
})

# Botones de control
$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Location = New-Object System.Drawing.Point(10, 400)
$btnSelectAll.Size = New-Object System.Drawing.Size(120, 30)
$btnSelectAll.Text = "Seleccionar Todo"
$btnSelectAll.Add_Click({
    for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
        $checkedListBox.SetItemChecked($i, $true)
    }
})
$form.Controls.Add($btnSelectAll)

$btnDeselectAll = New-Object System.Windows.Forms.Button
$btnDeselectAll.Location = New-Object System.Drawing.Point(140, 400)
$btnDeselectAll.Size = New-Object System.Drawing.Size(120, 30)
$btnDeselectAll.Text = "Deseleccionar Todo"
$btnDeselectAll.Add_Click({
    for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
        $checkedListBox.SetItemChecked($i, $false)
    }
})
$form.Controls.Add($btnDeselectAll)

$btnInvert = New-Object System.Windows.Forms.Button
$btnInvert.Location = New-Object System.Drawing.Point(270, 400)
$btnInvert.Size = New-Object System.Drawing.Size(120, 30)
$btnInvert.Text = "Invertir Selección"
$btnInvert.Add_Click({
    for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
        $checkedListBox.SetItemChecked($i, -not $checkedListBox.GetItemChecked($i))
    }
})
$form.Controls.Add($btnInvert)

# Botón de instalación
$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Location = New-Object System.Drawing.Point(450, 400)
$btnInstall.Size = New-Object System.Drawing.Size(120, 30)
$btnInstall.Text = "Instalar"
$btnInstall.DialogResult = [System.Windows.Forms.DialogResult]::OK
$btnInstall.BackColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($btnInstall)
$form.AcceptButton = $btnInstall

# Botón de cancelar
$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Location = New-Object System.Drawing.Point(450, 435)
$btnCancel.Size = New-Object System.Drawing.Size(120, 25)
$btnCancel.Text = "Cancelar"
$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.Controls.Add($btnCancel)
$form.CancelButton = $btnCancel

# Mostrar formulario
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    if ($checkedListBox.CheckedItems.Count -eq 0) {
        Write-Warning "No has seleccionado ninguna aplicación. Cancelando instalación."
        exit
    }

    # 5. Instalación
    Write-Host "`nInstalando $($checkedListBox.CheckedItems.Count) aplicaciones seleccionadas..." -ForegroundColor Cyan
    
    # Extraer nombres de apps seleccionadas
    $selectedApps = @()
    foreach ($checkedItem in $checkedListBox.CheckedItems) {
        # El formato es "NombreApp - vVersion [Bucket]"
        $appName = $checkedItem -replace ' - .*$'
        $selectedApps += $appName
    }

    # Instalar cada app
    $installedCount = 0
    $failedApps = @()
    
    foreach ($appName in $selectedApps) {
        try {
            Write-Host "Instalando $appName..." -ForegroundColor Yellow
            scoop install $appName -u
            $installedCount++
        } catch {
            Write-Warning "Error al instalar $appName : $_"
            $failedApps += $appName
        }
    }

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Proceso finalizado." -ForegroundColor Green
    Write-Host "Apps instaladas: $installedCount de $($selectedApps.Count)" -ForegroundColor Green
    
    if ($failedApps.Count -gt 0) {
        Write-Warning "Apps que fallaron: $($failedApps -join ', ')"
    }
} else {
    Write-Host "Instalación cancelada por el usuario." -ForegroundColor Yellow
}