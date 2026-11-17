# Comando unico do simulador (PART-11). Argumentos sao repassados ao script.
# Uso: simulador/simular.ps1 --partidas=1000 --semente=1 [--config=res://...] [--set=campo=valor] [--saida=caminho]
$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "godot" }
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz
& $godot --headless --path . --import | Out-Null
& $godot --headless --path . -s res://simulador/simular.gd -- @args
exit $LASTEXITCODE
