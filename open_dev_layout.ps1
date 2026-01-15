# open_dev_layout.ps1 - Abre Windows Terminal con layout de 3 paneles
# Layout: PowerShell + Ubuntu (izquierda), SSH Server (derecha)
#
# Uso:
#   .\open_dev_layout.ps1                   # Layout por defecto (2x2)
#   .\open_dev_layout.ps1 -Layout columns   # 3 columnas
#   .\open_dev_layout.ps1 -Layout rows      # 3 filas

param(
    [ValidateSet("default", "columns", "rows")]
    [string]$Layout = "default"
)

# Layout default:
# ┌─────────────────┬─────────────────┐
# │   Localhost     │                 │
# │  (PowerShell)   │ gsoda@servidor  │
# ├─────────────────┤     -casa       │
# │  Ubuntu@WSL     │                 │
# │                 │                 │
# └─────────────────┴─────────────────┘

switch ($Layout) {
    "default" {
        # 2x2: PowerShell arriba-izq, Ubuntu abajo-izq, SSH derecha completa
        wt new-tab -p "PowerShell" --title "Localhost" `; split-pane -H -s 0.5 -p "SSH Server" --title "Servidor-Casa" `; move-focus left `; split-pane -V -s 0.5 -p "Ubuntu" --title "Ubuntu-WSL"
    }
    "columns" {
        # 3 columnas horizontales
        wt new-tab -p "PowerShell" --title "Localhost" `; split-pane -H -p "SSH Server" --title "Server" `; split-pane -H -p "Ubuntu" --title "Ubuntu-WSL"
    }
    "rows" {
        # 3 filas verticales
        wt new-tab -p "PowerShell" --title "Localhost" `; split-pane -V -p "SSH Server" --title "Server" `; split-pane -V -p "Ubuntu" --title "Ubuntu-WSL"
    }
}
