---
phase: 02-partida-completa-jog-vel
plan: 04
subsystem: ui
tags: [godot, gdscript, cofre, tela-final, tween]
requires: [02-02]
provides:
  - Cena do cofre (porta por Tween 1,2 s, confete nas cores dos magos, toque tardio)
  - Tela final de contribuicoes sem ranking
  - Jogar de novo com os mesmos magos
affects: []
tech-stack:
  added: []
  patterns: [flags _pode_avancar/_indo contra toque duplo, CPUParticles2D com Gradient das cores ativas]
key-files:
  created: [cenas/cofre/cofre.gd, cenas/cofre/cofre.tscn, cenas/final/final.gd, cenas/final/final.tscn, testes/unit/test_cofre_final.gd]
  modified: []
key-decisions:
  - "Voltar durante a animacao do cofre e ignorado; depois equivale ao toque"
  - "Tela final nao ordena magos por pontos nem mostra numeros"
requirements-completed: [COFR-01, COFR-02, COFR-03]
duration: 15min
completed: 2026-11-17
---

# Phase 2 Plan 04: Cofre e tela final Summary

Cofre com porta que abre por Tween e confete colorido, seguido de tela final com as quatro senhas coloridas pelo autor, pontos como icones por mago e botoes Jogar de novo e Voltar ao menu.

## Commits
- 6bbdbe1: feat(02-04) cofre, tela final e testes (tarefas 1 a 3 em um commit)

## Deviations from Plan
Tarefas 1 a 3 foram commitadas juntas. Nenhuma correcao de regra necessaria.

## Verification
Suite GUT completa: 82 testes passam (3 novos em test_cofre_final). Grep de sort/vencedor/ranking em final.gd retorna 0. Verificacao visual nao feita (headless). `state.record-metric` nao foi usado/precisou ser contornado, ver nota do orquestrador.

## Known Stubs
Sem som no cofre (Fase 3, conforme plano).

## Self-Check: PASSED
