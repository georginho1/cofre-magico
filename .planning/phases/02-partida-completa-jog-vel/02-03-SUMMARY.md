---
phase: 02-partida-completa-jog-vel
plan: 03
subsystem: ui
tags: [godot, gdscript, mesa, pausa, tween]
requires: [02-02]
provides:
  - PainelPausa (pausa com confirmacao de saida)
  - Mesa.ao_voltar() (Esc / voltar do Android)
  - Indicador com pontos simbolicos do mago da vez
  - Botao Trocar violeta pulsante sem jogada
affects: [02-04]
tech-stack:
  added: []
  patterns: [pausa por overlay mouse_filter STOP sem get_tree().paused, pulso de escala por Tween em loop]
key-files:
  created: [cenas/mesa/painel_pausa.gd, cenas/mesa/painel_pausa.tscn]
  modified: [cenas/mesa/mesa.gd, cenas/mesa/mesa.tscn, testes/unit/test_mesa.gd]
key-decisions:
  - "Pontos exibidos so apos a faixa de vez (junto da mao) e atualizados tambem apos acerto sem troca de vez"
  - "IconesPonto ja expunha qtd; nenhuma alteracao em icones_ponto.gd foi necessaria"
requirements-completed: [MESA-03, MESA-06, MESA-07, COFR-05]
duration: 15min
completed: 2026-11-17
---

# Phase 2 Plan 03: Pontos, destaque do Trocar e pausa Summary

Indicador mostra so o mago da vez com pontos como icones, botao Trocar fica violeta e pulsa quando nao ha jogada, e pausa/saida com confirmacao responde ao botao, Esc e voltar do Android.

## Commits
- 4e8d6ce: feat(02-03) pontos, pulso e pausa, com testes (tarefas 1 a 3 em um commit)

## Deviations from Plan
Tarefas 1, 2 e 3 foram commitadas juntas porque mesa.gd e mesa.tscn sao compartilhados. IconesPonto ja tinha `qtd`, entao nao foi alterado.

## Verification
Suite GUT completa: 79 testes passam (4 novos em test_mesa: pontos, pulso, voltar, sair). Verificacao visual nao feita (headless).

## Known Stubs
Cenas COFRE/FINAL (plano 02-04) ainda nao existem.

## Self-Check: PASSED
