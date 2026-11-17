# Roadmap: Cofre Mágico

## Overview

O roteiro leva o Cofre Mágico de um repositório sem código até as builds de Android e PC usadas na apresentação de dezembro de 2026, em quatro fases ordenadas por risco. Primeiro a equipe prova que o projeto roda em um aparelho Android real e fecha as regras com um núcleo sem tela e um simulador, porque a pesquisa mostrou que turnos sem jogada e partidas travadas são o maior risco do jogo. Em seguida vem a partida completa "feia" (retângulos e texto), que já entrega o Core Value: até quatro magos em um aparelho formam as quatro senhas e abrem o cofre. Só depois entram ilustrações de licença livre, créditos e efeitos sonoros, que são a parte elástica do prazo. A última fase confronta o jogo com adultos e valida as builds finais no aparelho e na máquina da apresentação.

**Regras que valem para todas as fases:**

- Exportar o APK e instalar no aparelho real ao fim de cada fase, não só na primeira e na última.
- O levantamento das 30 ilustrações e de suas licenças não depende de código e começa em paralelo já na Fase 1 (o resultado é entregue na Fase 3).
- Se o prazo apertar, o corte é feito de trás para a frente dentro da Fase 3 (primeiro áudio, depois arte final). As Fases 1, 2 e 4 não são cortáveis.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Fundação, regras e simulador** - Projeto rodando em Android real e PC; partida inteira jogada pelo núcleo de regras sem tela e medida por simulação
- [ ] **Phase 2: Partida completa jogável** - Até quatro magos jogam do menu à abertura do cofre em um único aparelho, com visual provisório
- [ ] **Phase 3: Arte, áudio e créditos** - Ilustrações de licença livre com créditos registrados e efeitos sonoros com mudo
- [ ] **Phase 4: Testes com adultos e entrega** - Protocolo de teste aplicado e builds finais validadas no aparelho e na máquina da apresentação

## Phase Details

### Phase 1: Fundação, regras e simulador

**Goal:** A equipe tem o projeto rodando em um aparelho Android real e no PC, e uma partida inteira (do sorteio das senhas à última sílaba) é jogada pelo núcleo de regras sem tela, com as regras medidas e ajustadas por simulação
**Mode:** mvp
**Depends on:** Nothing (first phase)
**Requirements:** FUND-01, FUND-02, FUND-03, FUND-04, CONT-01, CONT-02, PART-02, PART-03, PART-04, PART-05, PART-06, PART-07, PART-08, PART-09, PART-10, PART-11
**Success Criteria** (what must be TRUE):

  1. O APK do projeto é instalado e abre a cena inicial em um aparelho Android real, e o executável de PC abre a mesma cena (este é o primeiro entregável da fase, antes de qualquer regra)
  2. Um único comando roda os testes GUT e todos passam, cobrindo: as 30 palavras com sílabas explícitas, as 100 cartas em 22 sílabas, o sorteio de 4 senhas, o recorte do baralho da partida, a distribuição das mãos, a aceitação da sílaba apenas no espaço exato, a devolução da carta à mão sem punição, a compra/troca e a ordem dos turnos
  3. A equipe executa o simulador sem tela para 1, 2, 3 e 4 magos e recebe um relatório com turnos sem jogada, duração da partida e partidas em que um mago não pontua; 100% das partidas simuladas terminam
  4. A equipe muda um valor no arquivo de configuração (tamanho da mão, troca, número de senhas, tamanho do baralho da partida) e o relatório do simulador muda, sem nenhuma alteração de código
  5. Os valores iniciais das regras foram escolhidos com base nos números do simulador e estão registrados como decisão no PROJECT.md

**Plans:** 4/8 plans executed

Plans:
**Wave 1**

- [x] 01-01-PLAN.md — Esqueleto: Godot 4.7.2, projeto, ConfigRegras, cena inicial e executável de PC

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 01-02-PLAN.md — Android: SDK, keystore fora do Git, APK sem INTERNET instalado em aparelho real
- [x] 01-03-PLAN.md — GUT 9.7.1 e comando único de testes

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 01-04-PLAN.md — Dados: 30 palavras e 100 cartas com testes de integridade

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 01-05-PLAN.md — Núcleo: baralho da partida, sorteio das senhas e mãos

**Wave 5** *(blocked on Wave 4 completion)*

- [ ] 01-06-PLAN.md — Núcleo: turnos, validação por espaço exato, troca e conclusão

**Wave 6** *(blocked on Wave 5 completion)*

- [ ] 01-07-PLAN.md — Simulador sem tela com perfis, relatório e metas

**Wave 7** *(blocked on Wave 6 completion)*

- [ ] 01-08-PLAN.md — Varredura, decisão dos valores finais, PROJECT.md e builds finais

### Phase 2: Partida completa jogável

**Goal:** Até quatro jogadores, em um único aparelho, jogam uma partida completa do menu inicial à abertura do cofre, com visual provisório (retângulos, texto e imagens provisórias)
**Mode:** mvp
**Depends on:** Phase 1
**Requirements:** PART-01, MESA-01, MESA-02, MESA-03, MESA-04, MESA-05, MESA-06, MESA-07, MESA-08, MESA-09, COFR-01, COFR-02, COFR-03, COFR-04, COFR-05
**Success Criteria** (what must be TRUE):

  1. A partir do menu inicial, os jogadores tocam em jogar, escolhem de 1 a 4 magos tocando neles (sem digitar nomes) e veem a mesa com as 4 palavras-senha, cada uma com ilustração grande e um espaço por sílaba; a palavra escrita aparece ou não conforme a configuração
  2. O mago da vez é indicado com clareza e só a mão dele aparece; ele joga com dois toques (carta, depois espaço); a sílaba certa fica marcada com a cor e o símbolo dele e soma um ponto simbólico; a sílaba errada volta para a mão sem marcação de erro; o botão de comprar/trocar está sempre visível e ganha destaque quando a mão não tem jogada; depois da ação a vez passa
  3. Ao completar todas as senhas, o cofre se abre com uma celebração coletiva, a tela final mostra a contribuição de cada mago sem ordenar nem declarar vencedor, e os jogadores iniciam uma nova partida dali
  4. Pausar ou sair da partida pede confirmação, e o botão voltar do Android não encerra a partida sem perguntar
  5. Uma partida completa é jogada só com toque em um aparelho Android real, e a mesa aparece sem elementos cortados em 16:9, 20:9 e 4:3, com sílabas e palavras em maiúsculas grandes, sem serifa e com alto contraste

**Plans:** TBD
**UI hint**: yes

### Phase 3: Arte, áudio e créditos

**Goal:** O jogo usa ilustrações de licença livre com origem registrada para as 30 palavras e tem efeitos sonoros que podem ser silenciados
**Mode:** mvp
**Depends on:** Phase 2
**Requirements:** CONT-03, CONT-04, AUDI-01, AUDI-02
**Success Criteria** (what must be TRUE):

  1. Cada uma das 30 palavras-senha aparece na mesa com sua ilustração definitiva de licença livre, no lugar da imagem provisória
  2. O arquivo de créditos do repositório lista fonte, autor e licença de cada uma das 30 ilustrações
  3. O jogador abre a tela de créditos a partir do menu e lê as atribuições exigidas pelas licenças
  4. O jogo toca um efeito sonoro ao acertar uma sílaba, ao comprar cartas e ao abrir o cofre, e o botão de mudo liga e desliga o som durante a partida

**Plans:** TBD
**UI hint**: yes

### Phase 4: Testes com adultos e entrega

**Goal:** O jogo foi experimentado por adultos seguindo um protocolo, os resultados estão registrados e as builds finais funcionam no aparelho e na máquina da apresentação
**Mode:** mvp
**Depends on:** Phase 2 (a Phase 3 é desejável, mas não bloqueia)
**Requirements:** TEST-01, TEST-02
**Success Criteria** (what must be TRUE):

  1. A equipe aplicou o protocolo de teste em ao menos uma sessão com adultos e os resultados observados (compreensão, legibilidade, facilidade de toque, tempo de partida, cooperação) estão registrados no repositório
  2. Os ajustes de regra decididos a partir dos testes foram feitos no arquivo de configuração e o simulador continua terminando 100% das partidas com os valores finais
  3. O APK final é instalado no aparelho da apresentação e uma partida completa é jogada nele do menu ao cofre
  4. O executável final de PC é aberto na máquina da apresentação e uma partida completa é jogada nele do menu ao cofre

**Plans:** TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Fundação, regras e simulador | 4/8 | In Progress|  |
| 2. Partida completa jogável | 0/TBD | Not started | - |
| 3. Arte, áudio e créditos | 0/TBD | Not started | - |
| 4. Testes com adultos e entrega | 0/TBD | Not started | - |
