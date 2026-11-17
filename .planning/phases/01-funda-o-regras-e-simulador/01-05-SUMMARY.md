---
phase: 01-funda-o-regras-e-simulador
plan: 05
subsystem: nucleo
tags: [godot, gdscript, baralho, partida, sorteio]
requires: [01-04]
provides:
  - Baralho (montar, misturar Fisher-Yates com RNG injetado, comprar/devolver)
  - Jogador, PalavraSenha, Partida (construtor com sorteio das senhas e maos)
affects: [01-06, 01-07, 01-08]
key-files:
  created: [nucleo/baralho.gd, nucleo/jogador.gd, nucleo/palavra_senha.gd, nucleo/partida.gd, testes/unit/test_baralho.gd, testes/unit/test_partida_sorteio.gd]
key-decisions:
  - "Fisher-Yates unico em Baralho.misturar, reutilizado no sorteio das palavras; nenhum shuffle/randi global"
requirements-completed: [PART-02, PART-03, PART-04, PART-10]
duration: 10min
completed: 2026-11-17
---

# Phase 1 Plan 05: Baralho e construtor da Partida Summary

Partida sem tela que sorteia 4 senhas distintas, monta o baralho (todas as copias uteis + distratoras por proporcao, teto so corta distratoras) e distribui maos, tudo reproduzivel por semente via RNG injetado.

## Tasks
1. Baralho (TDD): RED confirmado (Baralho inexistente, script de teste nao carregava); GREEN 8/8 testes. Commit 68fb150.
2. Jogador, PalavraSenha, Partida (TDD): RED confirmado (tipo Partida nao encontrado); GREEN. Suite completa: 5 scripts, 29 testes, exit 0. Commit 19aeca0.

## Deviations from Plan
None. Arquivos `.uid` gerados pelo Godot foram versionados (convencao ja existente no repositorio).

## Verificacoes
- grep em nucleo/ por `extends Node|await|shuffle()|randi()|randf()`: 0 ocorrencias.
- Nenhum campo de erro em Jogador/Partida.
- Varredura de 3000 sementes encontrou PATO+PATA juntas e TOMATE/TAPETE (sem restricao D-13/D-14).

## Known Stubs
None.

## Self-Check: PASSED
