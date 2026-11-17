---
phase: 02-partida-completa-jog-vel
plan: 01
subsystem: ui
tags: [godot, gdscript, theme, autoload, andika]
requires: []
provides:
  - Autoload Sessao (magos_ativos, partida, nova_partida, ir_para, voltar)
  - Theme global tema_cofre.tres com type variations
  - Magos, SimboloMago, IconesPonto
  - Cenas menu e selecao (menu e a cena principal)
affects: [02-02, 02-03, 02-04]
tech-stack:
  added: [Andika (OFL)]
  patterns: [Theme gerado por script, autoload sem class_name, ao_voltar() por cena]
key-files:
  created: [sessao.gd, tema/tema_cofre.tres, ferramentas/gerar_tema.gd, cenas/comum/magos.gd, cenas/comum/simbolo_mago.gd, cenas/comum/icones_ponto.gd, cenas/menu/menu.tscn, cenas/selecao/selecao.tscn, testes/unit/test_magos.gd, testes/unit/test_sessao.gd]
  modified: [project.godot, CREDITOS.md]
key-decisions:
  - "Cor de fundo dos botoes de mago via StyleBox override (excecao ao Theme)"
requirements-completed: [PART-01, COFR-04, COFR-05, MESA-09]
duration: 20min
completed: 2026-11-17
---

# Phase 2 Plan 01: Menu e selecao de magos Summary

Menu inicial e selecao de 1 a 4 magos com fonte Andika, Theme global, autoload Sessao e botao voltar (quit_on_go_back=false).

## Commits
- fe1fbb7: fonte, Theme, Sessao, project.godot
- 0f2bc61: Magos, SimboloMago, IconesPonto, testes
- 7e36835: cenas menu/selecao, remocao da cena inicial

## Deviations from Plan
None - plan executed as written. Godot em C:\Tools\Godot\4.7.2 (GODOT_BIN). Suite GUT: todos os testes passam.

## Known Stubs
Cofre do menu e um ColorRect provisorio (previsto no plano). CENA_MESA/COFRE/FINAL ainda nao existem (planos 02-02 a 02-04).

## Self-Check: PASSED
