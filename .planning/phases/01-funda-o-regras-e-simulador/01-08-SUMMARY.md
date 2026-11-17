---
phase: 01-funda-o-regras-e-simulador
plan: 08
subsystem: simulador
tags: [godot, simulador, calibracao, exportacao, decisao]
requires: [01-02, 01-07]
provides:
  - Decisao D-22 registrada em 01-SIMULACAO.md
  - proporcao_distratoras=0.40 em dados/regras_padrao.tres
  - Relatorio.avaliar_metas com D-18 exigida para 2 a 4 magos
affects: [Phase 2]
key-files:
  created: [.planning/phases/01-funda-o-regras-e-simulador/01-SIMULACAO.md]
  modified: [dados/regras_padrao.tres, simulador/relatorio.gd, testes/unit/test_simulacao.gd]
key-decisions:
  - "Opcao exigir-2-a-4: proporcao_distratoras=0.40; D-18 exigida para 2 a 4 magos e apenas relatada para 1 mago (36.4% com 5000 partidas). Aprovada por georginho1 em 2026-11-17."
  - "D-04 erro_passa_a_vez=true mantido; demais valores de regra inalterados."
requirements-completed: [PART-09, PART-10, PART-11]
duration: n/a
completed: 2026-11-17
---

# Phase 1 Plan 08: Calibracao final e decisao D-22 Summary

Varredura de proporcao_distratoras no simulador, escolha de 0.40 com D-18 exigida para 2 a 4 magos, reexportacao Windows e Android, e relatorio final registrado em 01-SIMULACAO.md.

## Tasks
1. Varredura de proporcao_distratoras e comparacao de D-04 (d48d71d).
2. proporcao_distratoras=0.40 e D-18 exigida para 2 a 4 magos (381e039): `simulador/relatorio.gd` ganhou `MAGOS_D18_EXIGIDOS=[2,3,4]` e parametro opcional em `avaliar_metas`; testes 54 -> 56, todos passam.
3. Decisao D-22 e relatorio final (05dab16).
4. Checkpoint human-verify: aprovado por georginho1 em 2026-11-17, com a verificacao em aparelho fisico dispensada por ora. O build/windows/CofreMagico.exe abriu no PC e a cena abriu como antes.

## Relatorio final (5000 partidas, semente 2026)
| magos | turnos sem ponto | D-18 |
|---|---|---|
| 1 | 36.4% | RELATADO (falha, nao exigido) |
| 2 | 33.1% | PASS |
| 3 | 30.2% | PASS |
| 4 | 28.0% | PASS |

Media D-18 em 2 a 4 magos: 30.4% PASS. D-19 (mago zerado): 0.7% PASS. D-20: PASS.

A divergencia em relacao a pesquisa tem explicacao: a tabela da pesquisa corresponde a proporcao 0.5, nao a 1.0.

## Exportacoes
Windows e Android reexportados. Sem permissao INTERNET (verificado com aapt2). Nenhum apk/keystore versionado.

## Nota para leitores futuros
A cena inicial atual (titulo, "Mao: 5 cartas", botao TOCAR, contador de toques) e o placeholder do walking skeleton do 01-01. A interface real do jogo vem na Fase 2.

## Deviations from Plan
None - plan executed as written; a verificacao em aparelho fisico foi dispensada pelo usuario no checkpoint.

## Itens em aberto
- Verificacao em aparelho fisico arm64 pendente (tambem FUND-02): o APK do preset e so arm64 e o emulador disponivel e x86_64 sem traducao ARM.
- Palavras lentas D-14 (TAPETE, SOPA, SACO, SAPO, PIPA, SINO, TATU): decisao da equipe pendente.
- Decisao sobre armeabi-v7a pendente.

## Self-Check: PASSED
Commits d48d71d, 381e039 e 05dab16 existem.
