---
phase: 01-funda-o-regras-e-simulador
plan: 04
subsystem: dados
tags: [godot, resources, conteudo]
requires: [01-03]
provides:
  - DadosPalavra, BibliotecaPalavras, DistribuicaoBaralho
  - dados/biblioteca_palavras.tres (30 palavras) e dados/distribuicao_baralho.tres (100 cartas, 22 silabas)
affects: [01-05, 01-06, 01-07, 01-08]
key-files:
  created: [dados/tipos/dados_palavra.gd, dados/tipos/biblioteca_palavras.gd, dados/tipos/distribuicao_baralho.gd, dados/biblioteca_palavras.tres, dados/distribuicao_baralho.tres, arte/provisoria/placeholder_palavra.svg, testes/unit/test_conteudo.gd]
  modified: [CREDITOS.md]
key-decisions:
  - "Dados sao Resources somente leitura; sem restricao de sorteio (D-13/D-14)"
requirements-completed: [CONT-01, CONT-02]
duration: 8min
completed: 2026-11-17
---

# Phase 1 Plan 04: Conteudo do prototipo fisico Summary

30 palavras com silabas explicitas e 100 cartas em 22 silabas como Resources, provados por 8 testes de integridade, incluindo as 27405 combinacoes de 4 palavras (nenhuma senha impossivel).

## Verificacao contra o PDF
`pdftotext -layout cofre_magico_todas_as_cartas_otimizado.pdf - | grep -oE '\b[A-Z]{2}\b' | sort | uniq -c` deu 100 tokens e contagens identicas a distribuicao gravada (CA8 TA8 TO8 LA7 PA7 BO6 MA6 SA6 GA5 NO5 GO4 LO4 MO4 RA4 TE4 CO2 PE2 PI2 PO2 SI2 SO2 TU2). A lista de 30 palavras do PROJECT.md coincide com a do plano; sem divergencia.

## Tasks
1. Tipos, .tres, SVG provisorio, CREDITOS.md: commit 95d48a8.
2. test_conteudo.gd (8 testes): commit seguinte (test(01-04)). Teste de demanda imprimiu "combinacoes verificadas: 27405", zero violacoes. rodar.ps1: 12/12 testes, exit 0, ~7 s.

## Deviations from Plan
None. (Os metodos de buscar/silabas_distintas/copias_de/total foram criados completos na Task 1.)

## Known Stubs
placeholder_palavra.svg e imagem provisoria intencional de todas as palavras (arte real em fase posterior).

## Self-Check: PASSED
