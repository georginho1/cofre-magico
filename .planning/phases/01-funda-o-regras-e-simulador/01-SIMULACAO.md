# Fase 1: Simulação e escolha dos valores das regras

Gerado pelo plano 01-08, tarefa 1. Simulador: `simulador/simular.ps1 --partidas=3000 --semente=2026 --set=proporcao_distratoras=X`. Demais valores de `dados/regras_padrao.tres` inalterados (tamanho_mao=5, silabas_por_turno=1, cartas_por_troca=0, erro_passa_a_vez=true, quantidade_senhas=4, taxa_erro_aprendiz=0.3). Todas as execuções terminaram com código 0 (100% das partidas terminam). `regras_padrao.tres` NÃO foi alterado.

## (a) Varredura de proporcao_distratoras, perfil perfeito (3000 partidas por célula)

Percentual de turnos sem ponto (meta D-18: <= 35%):

| proporcao | 1 mago | 2 magos | 3 magos | 4 magos | média 1-4 |
|---|---|---|---|---|---|
| 1.0  | 49.4% | 47.5% | 45.2% | 43.3% | 46.4% |
| 0.75 | 44.7% | 43.2% | 40.1% | 37.6% | 41.4% |
| 0.5  | 39.0% | 36.4% | 33.1% | 30.9% | 34.9% |
| 0.25 | 31.7% | 29.2% | 25.4% | 22.7% | 27.2% |
| 0.0  | 23.5% | 19.8% | 16.1% | 13.9% | 18.3% |

Valores intermediários (varredura extra para localizar o limite da meta):

| proporcao | 1 mago | 2 magos | 3 magos | 4 magos |
|---|---|---|---|---|
| 0.45 | 37.4% | 35.0% | 32.2% | 29.2% |
| 0.40 | 36.2% | 33.1% | 30.4% | 27.9% |
| 0.35 | 34.6% | 32.1% | 28.9% | 26.1% |
| 0.30 | 34.2% | 29.9% | 27.4% | 24.7% |

Mago sem sílaba (D-19, 4 magos, perfeito, meta <= 5%) e turnos por partida (média; mago único / 4 magos):

| proporcao | D-19 (4 magos) | turnos 1 mago | turnos 4 magos | terminadas |
|---|---|---|---|---|
| 1.0  | 2.3% | 16.3 | 14.6 | 100% |
| 0.75 | 2.2% | 15.0 | 13.3 | 100% |
| 0.5  | 0.7% | 13.6 | 12.0 | 100% |
| 0.45 | 0.9% | 13.2 | 11.7 | 100% |
| 0.4  | 0.6% | 13.0 | 11.5 | 100% |
| 0.35 | 0.6% | 12.6 | 11.2 | 100% |
| 0.25 | 0.4% | 12.1 | 10.7 | 100% |
| 0.0  | 0.1% | 10.8 | 9.6 | 100% |

Pontos médios por mago são independentes da proporção (8.27 / 4.14 / 2.75 / 2.07 para 1 a 4 magos).

## (b) PASS/FAIL por proporção

D-19 e D-20 são PASS em todas as proporções testadas (todas as partidas terminam; mago sem sílaba com 4 magos <= 2.3%).

| proporcao | D-18 1 mago | D-18 2 magos | D-18 3 magos | D-18 4 magos | D-19 | D-20 |
|---|---|---|---|---|---|---|
| 1.0  | FAIL | FAIL | FAIL | FAIL | PASS | PASS |
| 0.75 | FAIL | FAIL | FAIL | FAIL | PASS | PASS |
| 0.5  | FAIL (39.0) | FAIL (36.4) | PASS | PASS | PASS | PASS |
| 0.45 | FAIL (37.4) | PASS (35.0, no limite) | PASS | PASS | PASS | PASS |
| 0.40 | FAIL (36.2) | PASS | PASS | PASS | PASS | PASS |
| 0.35 | PASS (34.6) | PASS | PASS | PASS | PASS | PASS |
| 0.30 | PASS | PASS | PASS | PASS | PASS | PASS |
| 0.25 | PASS | PASS | PASS | PASS | PASS | PASS |
| 0.0  | PASS | PASS | PASS | PASS | PASS | PASS |

## (c) Perfeito x aprendiz e erro_passa_a_vez (D-04)

Aprendiz com taxa_erro_aprendiz = 0.3 (proporcao 1.0, erro_passa_a_vez = true): turnos médios +2.96 / +2.80 / +3.06 / +3.16 sobre o perfeito (1 a 4 magos); mago sem sílaba com 4 magos: 7.6% (perfeito 2.3%). Em proporção 0.5: +3.08 a +3.29 turnos; 4 magos mago sem sílaba 6.7% (perfeito 0.7%). Em 0.25: 7.4% (perfeito 0.4%). Ou seja, o aprendiz com 4 magos supera 5% em qualquer proporção até 0.0 (7.5%); D-19 só é meta do perfil perfeito.

Efeito de erro_passa_a_vez (proporção 1.0, aprendiz, 3000 partidas):

| magos | true: turnos / sem ponto / erro | false: turnos / sem ponto / erro | mago sem sílaba (true -> false) |
|---|---|---|---|
| 1 | 19.3 / 57.1% / 15.5% | 16.3 / 49.3% / 0.0% | 0.0% -> 0.0% |
| 2 | 18.6 / 55.5% / 16.3% | 15.7 / 47.2% / 0.0% | 0.0% -> 0.0% |
| 3 | 18.1 / 54.5% / 17.0% | 15.0 / 45.0% / 0.0% | 1.0% -> 0.2% |
| 4 | 17.8 / 53.4% / 17.2% | 14.5 / 43.0% / 0.0% | 7.6% -> 2.9% |

Com erro_passa_a_vez=false o erro não custa turno: o aprendiz fica praticamente igual ao perfeito (diferença de -0.04 a -0.12 turnos) e a partida dura cerca de 3 turnos a menos. Com true, o erro vira um turno perdido (cerca de 3 turnos por partida), e o risco de mago sem sílaba com 4 magos cai de 7.6% para 2.9% sem o custo do erro. D-04 NÃO foi alterado; é decisão da equipe (D-21).

## (d) Impacto por palavra (D-14), perfil perfeito, proporção 1.0 (turnos até completar)

As mesmas palavras lideram em todas as contagens de magos. As 5 mais lentas:

| 1 mago | 2 magos | 3 magos | 4 magos |
|---|---|---|---|
| TAPETE 14.98 | TAPETE 15.29 | TAPETE 13.76 | TAPETE 13.88 |
| SOPA 13.27 | SINO 13.00 | SACO 12.63 | SOPA 11.82 |
| SACO 13.27 | SOPA 12.71 | PIPA 12.15 | SACO 11.54 |
| SAPO 13.26 | TATU 12.65 | SINO 12.13 | SAPO 11.48 |
| PIPA 13.11 | SACO 12.10 | SOPA 11.80 | TATU 11.38 |

Todas as 7 palavras mais lentas contêm sílaba com 2 cópias no baralho (TAPETE, SOPA, SACO, SAPO, PIPA, SINO, TATU; TAPETE também tem 3 sílabas e é a última a completar em cerca de metade das partidas). As demais palavras de 2 sílabas completam em 7 a 10 turnos. Pendência para decisão futura (D-14): palavras de sílabas com 2 cópias e TAPETE puxam o fim da partida; não alterado.

## (e) Comparação com a tabela da pesquisa

Tabela da pesquisa (turnos sem ponto): 39 / 36 / 33 / 31% para 1 a 4 magos. Os números desta varredura com proporcao_distratoras = 0.5 são 39.0 / 36.4 / 33.1 / 30.9% (turnos por partida 13.6 / 13.0 / 12.3 / 12.0, igual aos 13.6 / 13.0 / 12.3 / 11.9 da pesquisa). Conclusão: a tabela da pesquisa descreve a proporção 0.5, não 1.0. O plano 01-07 viu divergência de cerca de 10 pontos percentuais com 1.0 porque a pesquisa havia sido gerada com metade das distratoras; não há bug no núcleo nem no simulador (a reimplementação independente em Python do plano 01-07 também confere com 1.0). Com 0.5 a divergência em relação à pesquisa é de no máximo 0.4 ponto percentual.

## (f) Recomendação NÃO vinculante

- D-18 para 1, 2, 3 e 4 magos: maior valor testado que cumpre = 0.35 (34.6 / 32.1 / 28.9 / 26.1%). A margem de 1 mago é pequena (0.4 pp); 0.30 dá mais folga (34.2%, praticamente igual) e está entre 0.25 e 0.35. Recomendação: 0.35.
- D-18 só para 2 a 4 magos: maior valor testado que cumpre = 0.45 (35.0% com 2 magos, exatamente no limite); mais seguro: 0.40 (33.1 / 30.4 / 27.9%). Recomendação: 0.40.
- Manter 1.0 (D-09 literal) falha D-18 em todos os números de magos (43.3 a 49.4%); 0.5 (a "cerca de metade" de D-09 lido como metade das úteis) falha apenas com 1 e 2 magos (39.0 e 36.4%).
- Nenhuma das opções precisa mexer em tamanho_mao nem em D-04.
