#!/bin/sh
# Comando unico de testes (FUND-04). Argumentos extras sao repassados ao GUT.
cd "$(dirname "$0")/.." || exit 1
GODOT="${GODOT_BIN:-godot}"
"$GODOT" --headless --path . --import >/dev/null 2>&1
exec "$GODOT" --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://testes/unit -ginclude_subdirs -gexit "$@"
