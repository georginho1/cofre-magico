---
phase: 02-partida-completa-jog-vel
plan: 05
subsystem: validation
tags: [godot, gut, export, android, validacao]
requires: [02-03, 02-04]
provides:
  - Teste de fluxo completo com 1 a 4 magos
  - Exportacao APK (Android) e exe (Windows) validadas
  - Verificacao humana em aparelho Android real e em resolucoes de PC
affects: []
key-files:
  created: [testes/unit/test_partida_completa_ui.gd]
  modified: [dados/tipos/config_regras.gd]
key-decisions:
  - "APK exportado apenas para arm64-v8a, sem permissao de internet"
requirements-completed: [MESA-08, MESA-09, COFR-01, COFR-05]
duration: n/a
completed: 2026-11-17
---

# Phase 2 Plan 05: Validacao ponta a ponta Summary

Teste automatizado do fluxo menu-selecao-mesa-cofre-final com 1 a 4 magos, exportacao de APK e exe, e partida completa aprovada pelo usuario em Android real.

## Commits
- a719f4e: test(02-05) fluxo completo com 1 a 4 magos e comentario de mostrar_palavra_escrita

## Tasks
1. Teste de fluxo completo (1 a 4 magos): a719f4e.
2. Proporcoes e exportacao APK + exe: sem commit (build/ esta no .gitignore). Saidas em `build/android/CofreMagico.apk` e `build/windows/CofreMagico.exe`.
3. Verificacao humana (checkpoint): aprovada pelo usuario em 2026-11-17 ("aprovado"). Cobriu partida completa em Android real so com toque, botao voltar abrindo a pausa, cofre e tela final, legibilidade, e mesa sem cortes em 1280x720, 1600x720, 1280x960 e 960x540 no PC.

## Deviations from Plan
- Caminhos de exportacao em `build/android/` e `build/windows/` (gitignored).
- APK somente arm64-v8a (armeabi-v7a nao incluido), internet=false.
- `state.record-metric` falhava e foi ignorado.

## Known Stubs
Sem som (Fase 3, conforme plano).
