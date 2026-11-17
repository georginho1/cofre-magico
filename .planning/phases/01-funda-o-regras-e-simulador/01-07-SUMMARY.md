---
phase: 01-funda-o-regras-e-simulador
plan: 07
subsystem: simulador
tags: [godot, gdscript, simulador, relatorio, headless]
requires: [01-06]
provides:
  - Perfil, PerfilPerfeito, PerfilAprendiz (simulador/)
  - Simulacao.rodar, Relatorio.montar/metas_ok/avaliar_metas
  - simulador/simular.ps1 (CLI) e dados/variantes/regras_mao3_senhas3.tres
affects: [01-08]
key-files:
  created: [simulador/perfis.gd, simulador/perfil_perfeito.gd, simulador/perfil_aprendiz.gd, simulador/simulacao.gd, simulador/relatorio.gd, simulador/simular.gd, simulador/simular.ps1, dados/variantes/regras_mao3_senhas3.tres, testes/unit/test_simulacao.gd]
key-decisions:
  - "Perfis em arquivos separados (class_name Perfil, PerfilPerfeito, PerfilAprendiz) em vez de classes internas, para evitar referencia ciclica"
  - "Simulacao.rodar chama cfg.normalizar() e conta turnos proprios (o ultimo turno da partida concluida conta como com ponto)"
requirements-completed: [PART-10, PART-11]
duration: 25min
completed: 2026-11-17
---

# Phase 1 Plan 07: Simulador headless Summary

Simulador sem tela que joga N partidas de 1 a 4 magos (perfeito e aprendiz) pela API publica da Partida e imprime relatorio com metas D-18/D-19/D-20 em PASS/FAIL; reproduzivel por semente e configuravel por arquivo ou --set.

## Tasks
1. RED (8ecd576) e GREEN (1b3cd62): perfis e motor, 9 testes em test_simulacao.gd. Suite completa: 7 scripts, 54 testes, exit 0.
2. CLI, relatorio, comando unico e variante (5849d3f).

## Resultado importante: divergencia da pesquisa
pct_turnos_sem_ponto do perfeito (1.0 de distratoras), 200 partidas, semente 1 na CLI (1000 partidas, semente 1 no debug: 49.0/47.4/45.7/43.4):

| magos | GDScript (CLI, 200) | Pesquisa |
|---|---|---|
| 1 | 49.2% | 39% |
| 2 | 46.8% | 36% |
| 3 | 46.4% | 33% |
| 4 | 43.7% | 31% |

Divergencia > 5 pp, entao investiguei: escrevi uma simulacao Python independente (descartavel, no scratchpad) seguindo D-01..D-12 literalmente (3000 partidas/celula): 49.9 / 47.7 / 45.0 / 43.3% e turnos/partida 16.5 / 15.8 / 15.0 / 14.6 (pesquisa: 13.6 / 13.0 / 12.3 / 11.9). O port GDScript concorda com a reimplementacao independente; a tabela preliminar da pesquisa parece subestimar os turnos sem ponto (provavel diferenca de modelagem naquela simulacao). Nao encontrei bug no nucleo ou no simulador. Mago zerado com 4 magos: 1.5% a 4.0% (pesquisa 1.1%), dentro da meta D-19 (<= 5%).

Consequencia para o plano 08: com a configuracao inicial D-18 falha em todos os numeros de magos (PASS apenas D-19 e D-20). Pela D-21 a primeira alavanca e reduzir proporcao_distratoras. O teste de sanidade foi alargado para 0.20 a 0.55 por esse motivo.

## Verificacoes de aceitacao
- `simular.ps1 --partidas=200 --semente=1`: exit 0; secoes Metas, Comparacao perfeito x aprendiz, Impacto por palavra; 8 linhas (1 a 4 magos x 2 perfis); duas execucoes com saida identica (cmp).
- Variante mao3/senhas3 (mesma semente): cabecalho mostra tamanho_mao = 3 e quantidade_senhas = 3; 1 mago perfeito vai de 16.3 para 15.4 turnos e de 49.2% para 59.5% sem ponto; 4 magos com mago zerado de 4.0% para 21.5%.
- `--set=campo_inexistente=1`, `--set=tamanho_mao=abc`, `--config=res://nada.tres`: exit 2.
- `--set=limite_turnos_partida=100` e `=3`: sem excecao; relatorio mostra limite efetivo 100.
- Teste com PerfilSoTroca e limite 100: partidas nao terminadas contam, terminadas = 0.
- grep por `extends Node|shuffle()|randi()|randf()` em simulador/: 0. 9 funcoes test_.
- Relatorio gravado em user:// por padrao; dados/variantes versionado.

## Deviations from Plan
**1. [Rule 3] Perfis em arquivos separados.** O plano permitia classes internas ou arquivos; classes internas que estendem a propria classe externa sao ciclicas em GDScript. Os testes usam PerfilPerfeito.new() / PerfilAprendiz.new().
**2. [Rule 2] Relatorio.montar ganhou parametros opcionais bib e dist** (para marcar palavras de 3 silabas e silabas de 2 copias, D-14); a assinatura de tres argumentos continua valida.
**3. Faixa do teste de sanidade** alargada de 0.20-0.45 para 0.20-0.55 (ver divergencia acima).

## Known Stubs
None.

## Self-Check: PASSED
