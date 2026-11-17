---
phase: 01-funda-o-regras-e-simulador
plan: 06
subsystem: nucleo
tags: [godot, gdscript, partida, turnos]
requires: [01-05]
provides:
  - ResultadoJogada.Tipo (ACERTO, ERRO, TROCOU, INVALIDO)
  - Partida.jogar_silaba, trocar_mao, existe_jogada, concluida, invariantes_ok, cartas_colocadas e sinais
affects: [01-07, 01-08]
key-files:
  created: [nucleo/resultado_jogada.gd, testes/unit/test_partida_turnos.gd]
  modified: [nucleo/partida.gd]
key-decisions:
  - "Troca parcial escolhe indices por Baralho.misturar com o RNG injetado; troca sempre passa a vez"
requirements-completed: [PART-05, PART-06, PART-07, PART-08, PART-09, PART-10]
duration: 8min
completed: 2026-11-17
---

# Phase 1 Plan 06: Regras de turno da Partida Summary

Partida jogavel do inicio ao fim sem tela: acerto so no espaco exato, erro sem punicao, troca de mao sempre disponivel, vez circular, cofre aberto na ultima silaba; 400 partidas completas de bot (1 a 4 magos x 100 sementes) concluem com invariantes validos.

## Tasks
1. RED: ResultadoJogada e 16 testes. A suite falhou ao carregar o script (metodos ausentes). Commit c3af7a9.
2. GREEN: implementacao em nucleo/partida.gd. Suite completa: 6 scripts, 45 testes, exit 0; "partidas concluidas: 400". Commit a7c46cd.

## Deviations from Plan
None. Arquivos `.uid` do Godot versionados (convencao existente).

## Verificacoes
- grep em nucleo/ por `extends Node|await|shuffle()|randi()|randf()`: 0.
- Nenhum contador ou log de erro; ERRO apenas retornado.
- Alavancas lidas do ConfigRegras: erro_passa_a_vez, silabas_por_turno, cartas_por_troca, repor_mao_apos_acerto, tamanho_mao.

## Known Stubs
None.

## Self-Check: PASSED
