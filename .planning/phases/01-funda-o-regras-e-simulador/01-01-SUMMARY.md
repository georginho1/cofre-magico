---
phase: 01-funda-o-regras-e-simulador
plan: 01
subsystem: infra
tags: [godot, gdscript, export, config]
requires: []
provides:
  - Godot 4.7.2 instalado, GODOT_BIN definido
  - Projeto Godot Compatibility 1280x720 com cena inicial
  - ConfigRegras (Resource) com todas as alavancas e normalizar()
  - Preset Windows Desktop e executável exportado
affects: [01-02, 01-03]
tech-stack:
  added: [Godot 4.7.2-stable]
  patterns: [regras como Resource editável, identificadores em português sem acento]
key-files:
  created: [project.godot, .gitignore, icon.svg, CREDITOS.md, dados/tipos/config_regras.gd, dados/regras_padrao.tres, cenas/inicial/inicial.tscn, cenas/inicial/inicial.gd, export_presets.cfg]
  modified: [CLAUDE.md]
key-decisions:
  - "GODOT_BIN (usuário) = C:\\Tools\\Godot\\4.7.2\\Godot_v4.7.2-stable_win64_console.exe"
  - "Templates instalados via leitura parcial (HTTP Range) do .tpz oficial, só Windows x86_64"
requirements-completed: [FUND-01, FUND-03]
duration: 20min
completed: 2026-11-12
---

# Phase 1 Plan 01: Walking Skeleton Summary

Projeto Godot 4.7.2 (Compatibility, 1280x720, canvas_items/expand, sensor_landscape) com ConfigRegras de 12 alavancas lidas de regras_padrao.tres, e executável Windows exportado (Embed PCK) que imprime `COFRE_MAGICO_INICIAL tamanho_mao=5`.

## Tasks
1. Instalação Godot 4.7.2 + templates (sem commit; fora do repositório).
2. Projeto, ConfigRegras, cena inicial, convenções no CLAUDE.md: d7ff3dd.
3. Preset Windows e exportação: ee406c1.

## Deviations from Plan

**1. [Rule 3 - Blocking] Templates baixados parcialmente.** O download do .tpz completo (1,28 GB) rodava a ~140 KB/s. Foram extraídos por HTTP Range, a partir do mesmo asset oficial do release 4.7.2-stable, apenas `windows_{debug,release}_x86_64[_console].exe` e `version.txt`. **Pendência para o plano 01-02:** faltam `android_debug.apk`, `android_release.apk` e `android_source.zip` (e os demais alvos) em `%APPDATA%\Godot\export_templates\4.7.2.stable\`; o script `rangezip.py` usado ficou no scratchpad (não versionado) e o mesmo método serve (ou instalar pelo editor).
**2. [Rule 3] icon.svg.import** commitado junto (convenção Godot, necessário ao export).

## Notas
- A equipe (colega) deve repetir a instalação da 4.7.2 e dos templates.
- Executável testado: build/windows/CofreMagico.console.exe --quit-after 5, saída 0, sem .pck separado, sem segredos no preset, build/ ignorado.
- Cena exportada rodou em OpenGL 3.3 Compatibility.

## Known Stubs
Nenhum.

## Self-Check: PASSED
