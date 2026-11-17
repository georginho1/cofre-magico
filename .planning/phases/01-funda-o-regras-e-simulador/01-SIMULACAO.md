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

## Decisão da equipe (Task 2)

Aprovada pelo usuário (git user georginho1) em 2026-11-17: opção `exigir-2-a-4`.

- proporcao_distratoras = 0.40.
- D-18 (<= 35% turnos sem ponto, perfil perfeito) EXIGIDA com 2, 3 e 4 magos; com 1 mago apenas RELATADA (medido 36.2% com 3000 partidas e 36.4% com 5000; falha, aceito).
- D-04 erro_passa_a_vez = true (inalterado). D-01 tamanho_mao=5, D-02 silabas_por_turno=1, D-03 cartas_por_troca=0, D-05 repor_mao_apos_acerto=true, D-15 quantidade_senhas=4 inalterados.
- Pendência (D-14), para decisão futura da equipe: palavras mais lentas TAPETE, depois SOPA, SACO, SAPO, PIPA, SINO, TATU.
- Implementação: simulador/relatorio.gd ganhou MAGOS_D18_EXIGIDOS = [2, 3, 4]; metas não exigidas aparecem como "RELATADO (passa|falha)".

## Relatório final

Comando: `simulador/simular.ps1 --partidas=5000 --semente=2026` com dados/regras_padrao.tres final (código de saída 0).

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

### Saída do simulador

Semente: 2026 | Partidas por linha: 5000

### Configuração (ConfigRegras)

- tamanho_mao = 5
- silabas_por_turno = 1
- cartas_por_troca = 0
- erro_passa_a_vez = true
- repor_mao_apos_acerto = true
- quantidade_senhas = 4
- proporcao_distratoras = 0.4
- tamanho_baralho_partida = 0
- mostrar_palavra_escrita = false
- taxa_erro_aprendiz = 0.3
- limite_turnos_partida = 5000
- semente = 0

### Resultados por magos x perfil

| Magos | Perfil | Terminadas | Turnos (média/mediana/p95) | Turnos por mago | Sem ponto | Troca | Erro | Partidas com mago sem sílaba | Pontos médios por mago |
|---|---|---|---|---|---|---|---|---|---|
| 1 | perfeito | 100.0% | 13.0 / 12.0 / 20.0 | 13.0 | 36.4% | 36.4% | 0.0% | 0.0% | 8.27 |
| 1 | aprendiz | 100.0% | 16.1 / 15.0 / 25.0 | 16.1 | 48.6% | 29.6% | 19.0% | 0.0% | 8.27 |
| 2 | perfeito | 100.0% | 12.4 / 11.0 / 19.0 | 6.2 | 33.1% | 33.1% | 0.0% | 0.0% | 4.14 |
| 2 | aprendiz | 100.0% | 15.4 / 15.0 / 24.0 | 7.7 | 46.4% | 26.6% | 19.8% | 0.0% | 4.14 |
| 3 | perfeito | 100.0% | 11.8 / 11.0 / 18.0 | 3.9 | 30.2% | 30.2% | 0.0% | 0.0% | 2.76 |
| 3 | aprendiz | 100.0% | 15.1 / 14.0 / 23.0 | 5.0 | 45.1% | 24.3% | 20.8% | 0.7% | 2.76 |
| 4 | perfeito | 100.0% | 11.5 / 11.0 / 18.0 | 2.9 | 28.0% | 28.0% | 0.0% | 0.7% | 2.07 |
| 4 | aprendiz | 100.0% | 14.7 / 14.0 / 22.0 | 3.7 | 43.7% | 22.9% | 20.8% | 7.4% | 2.07 |

### Metas

- RELATADO (falha) D-18: turnos sem ponto <= 35% com 1 mago(s), perfeito (36.4%)
- PASS D-18: turnos sem ponto <= 35% com 2 mago(s), perfeito (33.1%)
- PASS D-18: turnos sem ponto <= 35% com 3 mago(s), perfeito (30.2%)
- PASS D-18: turnos sem ponto <= 35% com 4 mago(s), perfeito (28.0%)
- PASS D-18: media de turnos sem ponto nos magos exigidos <= 35% (30.4%)
- PASS D-19: partidas com mago sem silaba <= 5% com 4 magos, perfeito (0.7%)
- PASS D-20: 100% das partidas terminam, todas as linhas

### Comparação perfeito x aprendiz

Regra em vigor (D-04): erro_passa_a_vez = true; taxa_erro_aprendiz = 0.3

| Magos | Dif. turnos médios (aprendiz - perfeito) | Erro (aprendiz) | Mago sem sílaba (perfeito) | Mago sem sílaba (aprendiz) |
|---|---|---|---|---|
| 1 | +3.08 | 19.0% | 0.0% | 0.0% |
| 2 | +3.07 | 19.8% | 0.0% | 0.0% |
| 3 | +3.20 | 20.8% | 0.0% | 0.7% |
| 4 | +3.20 | 20.8% | 0.7% | 7.4% |

### Impacto por palavra

Perfil perfeito, ordenado por turnos até completar (decrescente). [3 síl.] = palavra de 3 sílabas; [2 cópias] = contém sílaba com 2 cópias no baralho.

#### 1 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 697 | 12.53 | 337 | [3 síl.] [2 cópias] |
| SINO | 650 | 10.68 | 294 | [2 cópias] |
| TATU | 696 | 10.53 | 291 | [2 cópias] |
| SAPO | 642 | 10.43 | 277 | [2 cópias] |
| SOPA | 615 | 10.40 | 284 | [2 cópias] |
| SACO | 693 | 10.09 | 278 | [2 cópias] |
| PIPA | 652 | 9.97 | 252 | [2 cópias] |
| TOMATE | 668 | 9.53 | 172 | [3 síl.] |
| BOLO | 623 | 8.18 | 172 |  |
| GALO | 708 | 8.17 | 167 |  |
| MOLA | 670 | 8.08 | 171 |  |
| MOTO | 637 | 8.00 | 152 |  |
| GOTA | 673 | 7.92 | 147 |  |
| GOLA | 700 | 7.83 | 168 |  |
| GATO | 643 | 7.66 | 138 |  |
| RATO | 679 | 7.65 | 139 |  |
| CARA | 679 | 7.51 | 150 |  |
| PANO | 685 | 7.48 | 130 |  |
| GATA | 665 | 7.32 | 111 |  |
| MALA | 653 | 7.19 | 119 |  |
| BOTA | 635 | 7.15 | 113 |  |
| SALA | 686 | 7.11 | 121 |  |
| BOLA | 706 | 7.10 | 117 |  |
| CANO | 657 | 7.06 | 94 |  |
| MATO | 674 | 6.97 | 114 |  |
| BOCA | 672 | 6.92 | 88 |  |
| CASA | 597 | 6.91 | 88 |  |
| CAMA | 678 | 6.86 | 118 |  |
| PATA | 675 | 6.77 | 94 |  |
| PATO | 692 | 6.77 | 104 |  |

#### 2 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 674 | 11.75 | 325 | [3 síl.] [2 cópias] |
| SOPA | 721 | 9.94 | 303 | [2 cópias] |
| SINO | 708 | 9.86 | 315 | [2 cópias] |
| SAPO | 658 | 9.81 | 286 | [2 cópias] |
| PIPA | 613 | 9.76 | 262 | [2 cópias] |
| TATU | 644 | 9.63 | 261 | [2 cópias] |
| SACO | 715 | 9.38 | 275 | [2 cópias] |
| TOMATE | 690 | 9.16 | 185 | [3 síl.] |
| GALO | 669 | 8.00 | 194 |  |
| BOLO | 715 | 7.83 | 183 |  |
| MOTO | 658 | 7.72 | 168 |  |
| GOTA | 632 | 7.66 | 144 |  |
| MOLA | 661 | 7.61 | 172 |  |
| GOLA | 684 | 7.44 | 141 |  |
| RATO | 669 | 7.40 | 142 |  |
| CARA | 660 | 7.29 | 145 |  |
| GATO | 667 | 7.24 | 121 |  |
| PANO | 616 | 7.16 | 117 |  |
| MALA | 684 | 7.05 | 126 |  |
| GATA | 687 | 7.01 | 121 |  |
| BOTA | 673 | 6.91 | 106 |  |
| SALA | 679 | 6.88 | 113 |  |
| BOLA | 618 | 6.83 | 99 |  |
| CANO | 660 | 6.80 | 111 |  |
| BOCA | 693 | 6.77 | 112 |  |
| CAMA | 632 | 6.76 | 103 |  |
| MATO | 657 | 6.71 | 104 |  |
| CASA | 672 | 6.53 | 98 |  |
| PATA | 629 | 6.44 | 78 |  |
| PATO | 662 | 6.34 | 90 |  |

#### 3 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 694 | 11.21 | 326 | [3 síl.] [2 cópias] |
| SINO | 682 | 9.52 | 322 | [2 cópias] |
| SACO | 680 | 9.35 | 276 | [2 cópias] |
| TATU | 637 | 9.30 | 269 | [2 cópias] |
| PIPA | 701 | 9.28 | 290 | [2 cópias] |
| SAPO | 669 | 9.24 | 261 | [2 cópias] |
| SOPA | 634 | 9.19 | 254 | [2 cópias] |
| TOMATE | 647 | 9.13 | 204 | [3 síl.] |
| GALO | 627 | 7.63 | 162 |  |
| BOLO | 695 | 7.55 | 173 |  |
| GOLA | 655 | 7.41 | 158 |  |
| RATO | 633 | 7.36 | 130 |  |
| CARA | 649 | 7.31 | 159 |  |
| MOTO | 685 | 7.26 | 154 |  |
| MOLA | 722 | 7.23 | 160 |  |
| GOTA | 692 | 7.00 | 133 |  |
| PANO | 645 | 6.91 | 130 |  |
| CANO | 655 | 6.89 | 126 |  |
| SALA | 655 | 6.84 | 129 |  |
| BOLA | 651 | 6.84 | 116 |  |
| BOCA | 680 | 6.81 | 130 |  |
| GATO | 673 | 6.77 | 119 |  |
| GATA | 661 | 6.74 | 108 |  |
| MALA | 709 | 6.68 | 118 |  |
| CASA | 674 | 6.66 | 116 |  |
| MATO | 650 | 6.64 | 114 |  |
| BOTA | 604 | 6.57 | 87 |  |
| CAMA | 685 | 6.51 | 107 |  |
| PATO | 715 | 6.44 | 95 |  |
| PATA | 641 | 6.29 | 74 |  |

#### 4 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 717 | 10.94 | 358 | [3 síl.] [2 cópias] |
| SAPO | 680 | 9.33 | 313 | [2 cópias] |
| PIPA | 658 | 9.29 | 279 | [2 cópias] |
| TATU | 680 | 9.25 | 265 | [2 cópias] |
| SINO | 664 | 9.18 | 293 | [2 cópias] |
| SACO | 635 | 9.08 | 271 | [2 cópias] |
| SOPA | 660 | 9.07 | 262 | [2 cópias] |
| TOMATE | 661 | 8.84 | 179 | [3 síl.] |
| BOLO | 659 | 7.53 | 187 |  |
| GALO | 675 | 7.52 | 190 |  |
| MOTO | 628 | 7.29 | 157 |  |
| MOLA | 629 | 7.29 | 135 |  |
| GOLA | 652 | 7.12 | 157 |  |
| GOTA | 676 | 7.07 | 149 |  |
| CARA | 685 | 7.04 | 142 |  |
| RATO | 665 | 6.95 | 144 |  |
| PANO | 653 | 6.89 | 137 |  |
| GATO | 645 | 6.70 | 116 |  |
| MALA | 728 | 6.69 | 126 |  |
| BOLA | 658 | 6.68 | 112 |  |
| CANO | 682 | 6.66 | 128 |  |
| GATA | 665 | 6.62 | 114 |  |
| BOTA | 667 | 6.44 | 124 |  |
| SALA | 707 | 6.41 | 112 |  |
| MATO | 679 | 6.30 | 104 |  |
| BOCA | 663 | 6.28 | 97 |  |
| PATO | 657 | 6.28 | 79 |  |
| CASA | 672 | 6.25 | 90 |  |
| PATA | 656 | 6.19 | 105 |  |
| CAMA | 644 | 6.16 | 75 |  |

## Atualização após revisão de código (2026-11-17)

A revisão de código da fase (01-REVIEW.md) mudou o simulador e uma regra do núcleo. Os números acima desta seção são anteriores a essas correções e ficam como registro histórico. `dados/regras_padrao.tres` NÃO foi alterado (proporcao_distratoras = 0.40, erro_passa_a_vez = true, demais valores iguais).

O que mudou:

- CR-01 (métrica): a coluna "Erro" contava só turnos que terminavam em ERRO. Com erro_passa_a_vez = false o turno nunca termina em ERRO, então o aprendiz aparecia com 0.0% de erro. Agora o relatório mostra "Turnos com erro" (turnos com pelo menos uma jogada errada, qualquer que seja o fim do turno) e "Erros por turno" (jogadas erradas / turnos). A comparação D-04 da seção (c) usava a métrica antiga e está substituída pela tabela abaixo.
- WR-02 (regra do núcleo, efeito na jogabilidade): `trocar_mao` agora compra as cartas novas antes de devolver as descartadas ao baralho, como no jogo físico. Antes o jogador podia receber de volta as próprias cartas. Isso reduz os turnos sem ponto. Precisa de confirmação da equipe.
- WR-05: D-18 e D-19 não passam mais por vacuidade quando nenhuma partida termina. WR-06: o impacto por palavra conta só partidas terminadas. IN-06: pontos médios por mago dividem pelo número real de magos. Nenhuma das três muda os números desta execução (todas as partidas terminam e n_magos está entre 1 e 4).

### Antes e depois (relatório final, 5000 partidas, semente 2026, perfil perfeito)

| Medida | Antes | Depois |
|---|---|---|
| Turnos sem ponto, 1 / 2 / 3 / 4 magos | 36.4 / 33.1 / 30.2 / 28.0% | 33.8 / 31.2 / 28.3 / 26.6% |
| Média D-18 (2 a 4 magos) | 30.4% | 28.7% |
| Turnos por partida (média), 1 / 4 magos | 13.0 / 11.5 | 12.5 / 11.3 |
| D-19 (4 magos) | 0.7% | 0.5% |
| D-18 com 1 mago (só relatada) | falha (36.4%) | passa (33.8%) |
| Erro do aprendiz, 1 a 4 magos (true) | 19.0 / 19.8 / 20.8 / 20.8% (turnos que terminaram em erro) | 19.8 / 20.2 / 21.1 / 21.1% (turnos com erro) |

Metas com as regras atuais: D-18 (2, 3 e 4 magos e média) PASS, D-19 PASS, D-20 PASS. D-18 com 1 mago continua só relatada e agora passa. A queda de cerca de 2 pontos nos turnos sem ponto vem do WR-02. As palavras mais lentas continuam as mesmas (TAPETE primeiro em todas as contagens de magos, depois palavras com sílaba de 2 cópias), mas completam em menos turnos (TAPETE 11.98 com 1 mago, antes 14.98 com proporção 1.0).

### Comparação D-04 refeita (erro_passa_a_vez true x false)

Comandos: `simulador/simular.ps1 --partidas=3000 --semente=2026 --set=proporcao_distratoras=1.0` com e sem `--set=erro_passa_a_vez=false` (mesma proporção da seção (c)); e os mesmos comandos sem `--set=proporcao_distratoras` (regras atuais, 0.40). Todos saíram com código 0 e 100% das partidas terminadas.

Proporção 1.0, aprendiz (taxa_erro_aprendiz = 0.3), 3000 partidas, semente 2026:

| magos | true: turnos / sem ponto / turnos com erro / erros por turno | false: turnos / sem ponto / turnos com erro / erros por turno | dif. aprendiz - perfeito (true -> false) | mago sem sílaba (true -> false) |
|---|---|---|---|---|
| 1 | 18.8 / 56.1% / 15.9% / 0.159 | 15.8 / 47.7% / 13.3% / 0.189 | +3.08 -> +0.08 | 0.0% -> 0.0% |
| 2 | 18.3 / 54.7% / 16.6% / 0.166 | 15.2 / 45.5% / 14.0% / 0.201 | +2.97 -> -0.12 | 0.0% -> 0.0% |
| 3 | 17.8 / 53.5% / 17.4% / 0.174 | 14.8 / 44.2% / 14.7% / 0.210 | +2.98 -> +0.03 | 0.8% -> 0.2% |
| 4 | 17.5 / 52.7% / 17.8% / 0.178 | 14.3 / 42.0% / 15.1% / 0.216 | +3.17 -> -0.04 | 7.2% -> 2.3% |

Proporção 0.40 (regras atuais), aprendiz (taxa_erro_aprendiz = 0.3), 3000 partidas, semente 2026:

| magos | true: turnos / sem ponto / turnos com erro / erros por turno | false: turnos / sem ponto / turnos com erro / erros por turno | dif. aprendiz - perfeito (true -> false) | mago sem sílaba (true -> false) |
|---|---|---|---|---|
| 1 | 15.5 / 46.6% / 19.7% / 0.197 | 12.4 / 33.5% / 17.2% / 0.246 | +3.06 -> +0.00 | 0.0% -> 0.0% |
| 2 | 15.1 / 45.3% / 20.3% / 0.203 | 12.0 / 31.3% / 17.8% / 0.255 | +3.08 -> -0.00 | 0.0% -> 0.0% |
| 3 | 14.8 / 44.0% / 21.1% / 0.211 | 11.6 / 29.0% / 18.5% / 0.270 | +3.25 -> +0.12 | 1.0% -> 0.0% |
| 4 | 14.5 / 43.0% / 21.0% / 0.210 | 11.3 / 26.7% / 19.1% / 0.275 | +3.18 -> -0.05 | 7.4% -> 0.6% |

Leitura: com erro_passa_a_vez = false o aprendiz erra tanto quanto antes (cerca de 13 a 19% dos turnos têm erro, e há mais erros por turno do que com true, porque ele tenta de novo no mesmo turno), mas o erro não custa turno: a partida dura o mesmo que a do perfeito. Com true, cada erro vira um turno perdido, cerca de 3 turnos a mais por partida, e o mago sem sílaba com 4 magos sobe para 7.2% (1.0) ou 7.4% (0.40), contra 2.3% e 0.6% com false. O 0.0% de erro da seção (c) era artefato da métrica; a conclusão qualitativa sobre turnos e mago sem sílaba se mantém. D-04 continua true; a escolha segue com a equipe.

### Relatório final atualizado

Comando: `simulador/simular.ps1 --partidas=5000 --semente=2026` com dados/regras_padrao.tres (código de saída 0).

Semente: 2026 | Partidas por linha: 5000

#### Configuração (ConfigRegras)

- tamanho_mao = 5
- silabas_por_turno = 1
- cartas_por_troca = 0
- erro_passa_a_vez = true
- repor_mao_apos_acerto = true
- quantidade_senhas = 4
- proporcao_distratoras = 0.4
- tamanho_baralho_partida = 0
- mostrar_palavra_escrita = false
- taxa_erro_aprendiz = 0.3
- limite_turnos_partida = 5000
- semente = 0

#### Resultados por magos x perfil

| Magos | Perfil | Terminadas | Turnos (média/mediana/p95) | Turnos por mago | Sem ponto | Troca | Turnos com erro | Partidas com mago sem sílaba | Pontos médios por mago |
|---|---|---|---|---|---|---|---|---|---|
| 1 | perfeito | 100.0% | 12.5 / 12.0 / 19.0 | 12.5 | 33.8% | 33.8% | 0.0% | 0.0% | 8.27 |
| 1 | aprendiz | 100.0% | 15.6 / 15.0 / 23.0 | 15.6 | 46.8% | 27.0% | 19.8% | 0.0% | 8.27 |
| 2 | perfeito | 100.0% | 12.0 / 11.0 / 18.0 | 6.0 | 31.2% | 31.2% | 0.0% | 0.0% | 4.14 |
| 2 | aprendiz | 100.0% | 15.1 / 14.0 / 22.0 | 7.6 | 45.4% | 25.2% | 20.2% | 0.0% | 4.14 |
| 3 | perfeito | 100.0% | 11.5 / 11.0 / 17.0 | 3.8 | 28.3% | 28.3% | 0.0% | 0.0% | 2.76 |
| 3 | aprendiz | 100.0% | 14.8 / 14.0 / 22.0 | 4.9 | 44.1% | 23.1% | 21.1% | 0.8% | 2.76 |
| 4 | perfeito | 100.0% | 11.3 / 11.0 / 16.0 | 2.8 | 26.6% | 26.6% | 0.0% | 0.5% | 2.07 |
| 4 | aprendiz | 100.0% | 14.5 / 14.0 / 21.0 | 3.6 | 43.0% | 21.9% | 21.1% | 7.5% | 2.07 |

#### Metas

- RELATADO (passa) D-18: turnos sem ponto <= 35% com 1 mago(s), perfeito (33.8%)
- PASS D-18: turnos sem ponto <= 35% com 2 mago(s), perfeito (31.2%)
- PASS D-18: turnos sem ponto <= 35% com 3 mago(s), perfeito (28.3%)
- PASS D-18: turnos sem ponto <= 35% com 4 mago(s), perfeito (26.6%)
- PASS D-18: media de turnos sem ponto nos magos exigidos <= 35% (28.7%)
- PASS D-19: partidas com mago sem silaba <= 5% com 4 magos, perfeito (0.5%)
- PASS D-20: 100% das partidas terminam, todas as linhas

#### Comparação perfeito x aprendiz

Regra em vigor (D-04): erro_passa_a_vez = true; taxa_erro_aprendiz = 0.3

Turnos com erro = turnos com pelo menos uma jogada errada, qualquer que seja o fim do turno. Erros por turno = jogadas erradas / turnos.

| Magos | Dif. turnos médios (aprendiz - perfeito) | Turnos com erro (aprendiz) | Erros por turno (aprendiz) | Mago sem sílaba (perfeito) | Mago sem sílaba (aprendiz) |
|---|---|---|---|---|---|
| 1 | +3.05 | 19.8% | 0.198 | 0.0% | 0.0% |
| 2 | +3.13 | 20.2% | 0.202 | 0.0% | 0.0% |
| 3 | +3.27 | 21.1% | 0.211 | 0.0% | 0.8% |
| 4 | +3.24 | 21.1% | 0.211 | 0.5% | 7.5% |

#### Impacto por palavra

Perfil perfeito, ordenado por turnos até completar (decrescente). [3 síl.] = palavra de 3 sílabas; [2 cópias] = contém sílaba com 2 cópias no baralho.

##### 1 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 697 | 11.98 | 338 | [3 síl.] [2 cópias] |
| SAPO | 642 | 10.32 | 283 | [2 cópias] |
| SACO | 693 | 10.03 | 298 | [2 cópias] |
| SOPA | 615 | 9.93 | 252 | [2 cópias] |
| SINO | 650 | 9.91 | 273 | [2 cópias] |
| PIPA | 652 | 9.83 | 272 | [2 cópias] |
| TATU | 696 | 9.66 | 268 | [2 cópias] |
| TOMATE | 668 | 9.32 | 180 | [3 síl.] |
| BOLO | 623 | 8.18 | 167 |  |
| GALO | 708 | 8.16 | 190 |  |
| MOTO | 637 | 7.88 | 140 |  |
| GOLA | 700 | 7.82 | 178 |  |
| MOLA | 670 | 7.72 | 163 |  |
| GOTA | 673 | 7.68 | 150 |  |
| CARA | 679 | 7.54 | 158 |  |
| RATO | 679 | 7.53 | 153 |  |
| PANO | 685 | 7.48 | 140 |  |
| GATO | 643 | 7.30 | 117 |  |
| GATA | 665 | 7.23 | 125 |  |
| MALA | 653 | 7.04 | 114 |  |
| SALA | 686 | 7.04 | 126 |  |
| BOTA | 635 | 7.03 | 111 |  |
| CANO | 657 | 6.95 | 98 |  |
| CASA | 597 | 6.92 | 96 |  |
| BOLA | 706 | 6.91 | 102 |  |
| BOCA | 672 | 6.89 | 95 |  |
| MATO | 674 | 6.86 | 98 |  |
| PATA | 675 | 6.83 | 102 |  |
| CAMA | 678 | 6.75 | 106 |  |
| PATO | 692 | 6.71 | 107 |  |

##### 2 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 674 | 11.53 | 316 | [3 síl.] [2 cópias] |
| SINO | 708 | 9.79 | 322 | [2 cópias] |
| PIPA | 613 | 9.54 | 257 | [2 cópias] |
| SAPO | 658 | 9.48 | 291 | [2 cópias] |
| SOPA | 721 | 9.41 | 295 | [2 cópias] |
| TATU | 644 | 9.27 | 250 | [2 cópias] |
| SACO | 715 | 9.11 | 281 | [2 cópias] |
| TOMATE | 690 | 8.98 | 163 | [3 síl.] |
| GALO | 669 | 7.95 | 194 |  |
| BOLO | 715 | 7.65 | 174 |  |
| MOLA | 661 | 7.57 | 165 |  |
| MOTO | 658 | 7.56 | 172 |  |
| GOTA | 632 | 7.50 | 140 |  |
| GOLA | 684 | 7.47 | 145 |  |
| CARA | 660 | 7.29 | 149 |  |
| RATO | 669 | 7.25 | 135 |  |
| GATO | 667 | 7.21 | 131 |  |
| PANO | 616 | 7.00 | 118 |  |
| MALA | 684 | 6.97 | 127 |  |
| GATA | 687 | 6.91 | 118 |  |
| SALA | 679 | 6.86 | 121 |  |
| BOTA | 673 | 6.80 | 107 |  |
| CANO | 660 | 6.76 | 110 |  |
| BOCA | 693 | 6.72 | 113 |  |
| BOLA | 618 | 6.71 | 103 |  |
| MATO | 657 | 6.70 | 109 |  |
| CAMA | 632 | 6.64 | 100 |  |
| CASA | 672 | 6.55 | 108 |  |
| PATA | 629 | 6.44 | 93 |  |
| PATO | 662 | 6.35 | 93 |  |

##### 3 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 694 | 10.88 | 327 | [3 síl.] [2 cópias] |
| SACO | 680 | 9.22 | 276 | [2 cópias] |
| PIPA | 701 | 9.18 | 310 | [2 cópias] |
| TATU | 637 | 9.12 | 266 | [2 cópias] |
| SINO | 682 | 9.08 | 301 | [2 cópias] |
| TOMATE | 647 | 9.05 | 192 | [3 síl.] |
| SOPA | 634 | 9.00 | 254 | [2 cópias] |
| SAPO | 669 | 8.97 | 266 | [2 cópias] |
| GALO | 627 | 7.51 | 155 |  |
| BOLO | 695 | 7.49 | 171 |  |
| GOLA | 655 | 7.31 | 151 |  |
| RATO | 633 | 7.24 | 132 |  |
| CARA | 649 | 7.18 | 151 |  |
| MOLA | 722 | 7.17 | 155 |  |
| MOTO | 685 | 7.14 | 145 |  |
| GOTA | 692 | 6.97 | 140 |  |
| CANO | 655 | 6.85 | 131 |  |
| SALA | 655 | 6.84 | 131 |  |
| PANO | 645 | 6.82 | 127 |  |
| BOLA | 651 | 6.80 | 124 |  |
| BOCA | 680 | 6.76 | 132 |  |
| GATO | 673 | 6.71 | 124 |  |
| MALA | 709 | 6.69 | 118 |  |
| GATA | 661 | 6.69 | 112 |  |
| CASA | 674 | 6.64 | 111 |  |
| MATO | 650 | 6.61 | 122 |  |
| BOTA | 604 | 6.58 | 91 |  |
| CAMA | 685 | 6.47 | 100 |  |
| PATO | 715 | 6.46 | 105 |  |
| PATA | 641 | 6.32 | 80 |  |

##### 4 mago(s)

| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |
|---|---|---|---|---|
| TAPETE | 717 | 10.77 | 366 | [3 síl.] [2 cópias] |
| PIPA | 658 | 9.12 | 280 | [2 cópias] |
| SAPO | 680 | 9.11 | 305 | [2 cópias] |
| SINO | 664 | 9.01 | 296 | [2 cópias] |
| TATU | 680 | 8.96 | 267 | [2 cópias] |
| SACO | 635 | 8.95 | 271 | [2 cópias] |
| SOPA | 660 | 8.91 | 264 | [2 cópias] |
| TOMATE | 661 | 8.83 | 182 | [3 síl.] |
| BOLO | 659 | 7.49 | 180 |  |
| GALO | 675 | 7.47 | 193 |  |
| MOTO | 628 | 7.27 | 158 |  |
| MOLA | 629 | 7.27 | 132 |  |
| GOLA | 652 | 7.04 | 157 |  |
| GOTA | 676 | 7.02 | 142 |  |
| PANO | 653 | 6.94 | 144 |  |
| CARA | 685 | 6.92 | 138 |  |
| RATO | 665 | 6.91 | 145 |  |
| GATO | 645 | 6.71 | 119 |  |
| BOLA | 658 | 6.67 | 112 |  |
| MALA | 728 | 6.67 | 120 |  |
| CANO | 682 | 6.63 | 126 |  |
| GATA | 665 | 6.61 | 112 |  |
| SALA | 707 | 6.45 | 115 |  |
| BOTA | 667 | 6.41 | 121 |  |
| MATO | 679 | 6.30 | 104 |  |
| PATO | 657 | 6.29 | 86 |  |
| BOCA | 663 | 6.24 | 95 |  |
| CASA | 672 | 6.23 | 87 |  |
| CAMA | 644 | 6.18 | 78 |  |
| PATA | 656 | 6.17 | 105 |  |
