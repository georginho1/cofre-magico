# Comando unico de testes (FUND-04). Argumentos extras sao repassados ao GUT.
$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "godot" }
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz
& $godot --headless --path . --import | Out-Null
& $godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://testes/unit -ginclude_subdirs -gexit @args
exit $LASTEXITCODE
