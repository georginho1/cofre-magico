# Phase 1: Fundação, regras e simulador - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-12
**Phase:** 1-Fundação, regras e simulador
**Areas discussed:** Regra do turno, Recorte do baralho, Sorteio das senhas, Metas do simulador

---

## Regra do turno

### Tamanho inicial da mão

| Option | Description | Selected |
|--------|-------------|----------|
| 5 cartas (Recomendado) | Cabe na tela do celular com cartas grandes; chance razoável de sílaba útil | ✓ |
| 4 cartas | Cartas maiores, mais turnos sem jogada | |
| 6 cartas | Menos turnos sem jogada, cartas menores | |
| Você decide | Simulador testa 4, 5 e 6 | |

**User's choice:** 5 cartas

### Sílabas por turno

| Option | Description | Selected |
|--------|-------------|----------|
| Uma por turno (Recomendado) | Um acerto encerra o turno; distribui as 8 a 10 jogadas entre os magos | ✓ |
| Quantas tiver | Reduz turnos sem jogada, mas um mago pode dominar | |
| Até duas | Meio-termo | |
| Você decide | Parâmetro comparado no simulador | |

**User's choice:** Uma por turno

### O que faz comprar/trocar

| Option | Description | Selected |
|--------|-------------|----------|
| Troca a mão inteira (Recomendado) | Cartas voltam ao baralho, reembaralha, compra 5; encerra o turno | ✓ |
| Troca cartas escolhidas | Mais decisão e mais toques | |
| Compra uma carta a mais | Mão cresce | |
| Você decide | Simulador compara | |

**User's choice:** Troca a mão inteira

### Tentativa errada: o turno continua?

| Option | Description | Selected |
|--------|-------------|----------|
| Continua, sem limite (Recomendado) | Tenta de novo até acertar ou trocar | |
| Passa a vez | A tentativa errada encerra o turno | ✓ |
| Continua, com limite | Após N erros a vez passa | |

**User's choice:** Passa a vez
**Notes:** Escolha contra a recomendação. Carta volta à mão sem marcação de erro; o efeito será medido pelo perfil aprendiz do simulador.

### Encerramento da área

**User's choice:** Próxima área
**Notes:** Suposições aceitas: repõe até 5 após acerto; a troca encerra o turno; troca permitida mesmo com jogada.

---

## Recorte do baralho

### Composição

| Option | Description | Selected |
|--------|-------------|----------|
| Úteis + distratoras (Recomendado) | Mantém o exercício de discriminar a sílaba certa | ✓ |
| Só sílabas das senhas | Quase zero turno sem jogada, menos desafio | |
| Você decide | Simulador varia a proporção | |

**User's choice:** Úteis + distratoras

### Proporção inicial de distratoras

| Option | Description | Selected |
|--------|-------------|----------|
| Cerca de metade (Recomendado) | Uma distratora por carta útil | ✓ |
| Cerca de um terço | Mais fácil e rápida | |
| Cerca de dois terços | Mais próximo do físico, mais trocas | |
| Você decide | Maior proporção que cumpra as metas | |

**User's choice:** Cerca de metade

### Como escolher as distratoras

| Option | Description | Selected |
|--------|-------------|----------|
| Sorteio entre as demais (Recomendado) | Respeita as cópias do baralho físico | ✓ |
| Parecidas com as úteis | Mesma consoante ou vogal; mais difícil | |
| Você decide | Começa pelo sorteio simples | |

**User's choice:** Sorteio entre as demais

### Cópias de cada sílaba útil

| Option | Description | Selected |
|--------|-------------|----------|
| Todas as do baralho físico (Recomendado) | Fiel ao protótipo; raras continuam raras | ✓ |
| Mínimo garantido | Completa as raras até um mínimo | |
| Quantidade fixa por sílaba | Mesmo número para todas | |
| Você decide | Simulador compara | |

**User's choice:** Todas as do baralho físico

### Garantia de jogada na distribuição

| Option | Description | Selected |
|--------|-------------|----------|
| Sorteio puro (Recomendado) | Embaralha e distribui | ✓ |
| Ao menos 1 útil na mão inicial | Evita primeiro turno frustrante | |
| Ao menos 1 útil em toda compra | Compra favorecida | |

**User's choice:** Sorteio puro

### Encerramento da área

**User's choice:** Próxima área
**Notes:** Suposições aceitas: carta colocada fica na senha; trocadas voltam e reembaralham; baralho vazio = mago fica com o que tem.

---

## Sorteio das senhas

### Pares quase idênticos (PATO+PATA, GATO+GATA)

| Option | Description | Selected |
|--------|-------------|----------|
| Não, evitar o par (Recomendado) | Ilustrações difíceis de distinguir | |
| Sim, sorteio puro | Qualquer combinação das 30 | ✓ |
| Evitar só sem palavra escrita | Restrição condicional | |

**User's choice:** Sim, sorteio puro

### Palavras difíceis (3 sílabas, sílabas raras)

| Option | Description | Selected |
|--------|-------------|----------|
| Nenhuma restrição (Recomendado) | Simulador reporta impacto por palavra | ✓ |
| No máximo uma difícil por partida | Partidas mais uniformes | |
| Parâmetro desligado | Opção na configuração | |

**User's choice:** Nenhuma restrição

### Número de senhas

| Option | Description | Selected |
|--------|-------------|----------|
| Sempre 4 (Recomendado) | Igual ao físico, para 1 a 4 magos | ✓ |
| Varia com os magos | Tabela na configuração | |
| Você decide | Começa em 4 | |

**User's choice:** Sempre 4

### Encerramento da área

**User's choice:** Próxima área
**Notes:** Suposições aceitas: sem repetição dentro da partida; semente reproduzível.

---

## Metas do simulador

### Teto de turnos sem ponto

| Option | Description | Selected |
|--------|-------------|----------|
| Até 35% (Recomendado) | Limite de alerta da pesquisa | ✓ |
| Até 25% | Mais exigente | |
| Até 50% | Mais tolerante | |
| Você decide | 35% como alvo | |

**User's choice:** Até 35%

### Comportamento do jogador simulado

| Option | Description | Selected |
|--------|-------------|----------|
| Dois perfis (Recomendado) | Perfeito e aprendiz com taxa de erro configurável | ✓ |
| Só perfeito | Mede só a regra | |
| Só aprendiz | Mais próximo de uma criança | |

**User's choice:** Dois perfis

### Tolerância para mago sem ponto (4 magos)

| Option | Description | Selected |
|--------|-------------|----------|
| Até 5% das partidas (Recomendado) | Pesquisa mediu 3% a 20% | ✓ |
| Até 10% | Mais tolerante | |
| Só medir, sem meta | Equipe decide depois | |

**User's choice:** Até 5% das partidas

### Primeira alavanca se as metas falharem

| Option | Description | Selected |
|--------|-------------|----------|
| Menos distratoras (Recomendado) | Não muda regra nem tamanho das cartas | ✓ |
| Mão maior | Sobe para 6 | |
| Rever "errou, passa a vez" | Muda regra já escolhida | |
| Você decide | Varredura de combinações | |

**User's choice:** Menos distratoras

---

## Claude's Discretion

- Idioma dos identificadores e convenção de pastas
- APK de depuração com debug keystore compartilhado; arquiteturas do preset Android
- Formato do relatório do simulador e do arquivo de configuração
- Número de partidas simuladas e taxa de erro padrão do perfil aprendiz
- Duração alvo da partida: apenas medir

## Deferred Ideas

- Evitar repetir palavras da partida anterior
- Distratoras escolhidas por semelhança com as sílabas úteis
- Restrições no sorteio das senhas
- Garantia de carta útil na mão inicial ou em toda compra
