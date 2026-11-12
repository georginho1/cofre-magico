---
phase: 01-funda-o-regras-e-simulador
plan: 03
subsystem: testing
tags: [gut, godot, tests]
requires: [01-01]
provides:
  - GUT 9.7.1 vendorizado e habilitado
  - testes/rodar.ps1 e rodar.sh (comando unico, exit code propagado)
  - Testes de ConfigRegras e da cena inicial
affects: [01-04, 01-05, 01-06, 01-07, 01-08]
key-files:
  created: [addons/gut/, .gutconfig.json, testes/rodar.ps1, testes/rodar.sh, testes/unit/test_config.gd, testes/unit/test_inicial.gd]
  modified: [project.godot, CREDITOS.md]
key-decisions:
  - "GUT 9.7.1 baixado da tag v9.7.1 de bitwes/Gut; LICENSE.md mantido em addons/gut"
  - "Sem doubles/mocks nos testes"
requirements-completed: [FUND-04, PART-10]
duration: 10min
completed: 2026-11-12
---

# Phase 1 Plan 03: Comando de testes GUT Summary

GUT 9.7.1 instalado e um unico comando (`testes/rodar.ps1`) roda 4 testes verdes (valores D-01..D-15, normalizar(), botao da cena inicial), com exit code 0 em sucesso e 1 em falha.

## Tasks
1. GUT vendorizado, plugin habilitado, .gutconfig.json, CREDITOS.md (MIT): commit chore(01-03).
2. Scripts de execucao e testes: commit test(01-03).

## Deviations from Plan
None. O `--import` previo resolveu `class_name ConfigRegras` em checkout limpo (Pitfall 1), sem alternativa necessaria. Falha forcada (assert_true(false)) deu exit 1; arquivo removido.

## Known Stubs
Nenhum.

## Self-Check: PASSED
