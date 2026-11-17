# Cofre Mágico

## What This Is

Cofre Mágico é um serious game educativo cooperativo de cartas, em versão digital 2D, no qual até quatro crianças em alfabetização (7 a 9 anos) assumem o papel de magos e combinam cartas de sílabas para completar quatro palavras-senha ilustradas. Quando todas as senhas são completadas, o grupo abre um cofre mágico e compartilha a recompensa. É um projeto acadêmico da disciplina Tópicos em Desenvolvimento de Jogos (UFRPE – UAST), desenvolvido em Godot/GDScript por George Lucas do Santos e Lucas Eduardo de Oliveira Mariz.

## Core Value

Um grupo de até quatro jogadores, em um único aparelho, consegue jogar uma partida completa: formar as quatro palavras-senha colocando sílabas corretas, ver quem contribuiu com cada sílaba e abrir o cofre juntos.

## Requirements

### Validated

- ✓ Sorteio automático de 4 palavras-senha entre as 30 palavras a cada partida (núcleo de regras) — Validated in Phase 1: Fundação, regras e simulador
- ✓ Baralho de 100 cartas de sílabas (22 sílabas CV distintas) com a distribuição do protótipo físico; recorte por partida parametrizado — Validated in Phase 1
- ✓ Regras de mão/compra/troca parametrizadas em `ConfigRegras` (`dados/regras_padrao.tres`) e ajustadas por simulação — Validated in Phase 1
- ✓ Partida para 1 a 4 jogadores no mesmo aparelho, em turnos (pass-and-play), cada um como um mago de cor (vermelho, azul, verde, amarelo) — Validated in Phase 2: Partida completa jogável
- ✓ Palavra escrita junto da ilustração configurável (ligada ou desligada) — Validated in Phase 2: Partida completa jogável
- ✓ Mesa mostra apenas a mão do mago da vez — Validated in Phase 2: Partida completa jogável
- ✓ Cada mago tem uma mão de cartas; no turno joga uma sílaba em uma palavra-senha ou compra/troca do baralho — Validated in Phase 2: Partida completa jogável
- ✓ O jogo valida sozinho se a sílaba está correta para a posição escolhida (sem exposição pública de erro) — Validated in Phase 2: Partida completa jogável
- ✓ Cada sílaba correta é marcada com a cor do mago autor e rende um ponto simbólico — Validated in Phase 2: Partida completa jogável
- ✓ Progresso visível pelo preenchimento das palavras-senha — Validated in Phase 2: Partida completa jogável
- ✓ Ao completar as quatro senhas, o cofre se abre com uma recompensa coletiva — Validated in Phase 2: Partida completa jogável
- ✓ Builds exportadas para Android (APK) e PC (desktop) para a apresentação — Validated in Phase 2: Partida completa jogável

### Active

- [ ] Efeitos sonoros básicos com botão de mudo
- [ ] Interface adequada ao público infantil: instruções curtas, letras grandes, alto contraste, imagens de apoio

### Out of Scope

- Multiplayer em rede (um aparelho por criança) — complexidade incompatível com o prazo; o jogo é presencial em um aparelho compartilhado
- Habilidades únicas por mago — decidido manter os magos iguais, diferenciados apenas pela cor; ideia registrada para o futuro
- Papel de Mestre dentro do app (aprovar jogadas, escolher palavras) — a validação é automática e as senhas são sorteadas
- Testes com crianças — exigem aprovação do comitê de ética, o que extrapola o prazo; os testes serão feitos com adultos
- Sílabas não canônicas (CVC, CCV, dígrafos etc.) — o protótipo usa apenas sílabas CV e vocabulário fechado de 30 palavras
- Validação empírica da efetividade pedagógica — fora do alcance do protótipo
- Arte original produzida pela equipe — serão usados recursos de licença livre da internet

## Context

**Origem:** o jogo foi concebido como jogo de cartas analógico (cartas de 6 × 8 cm, fundo azul-claro, bordas discretas, sílabas centralizadas, cartas de palavras com ilustração acima do texto). O protótipo da disciplina é a tradução digital dessa experiência. Documentos de referência na raiz do repositório:

- `HCD_preenchido_cofre_magico.md` — High-Concept Document v1.0 (27/10/2026)
- `cofre_magico_todas_as_cartas_otimizado.pdf` — todas as cartas do protótipo físico

**Problema:** oferecer uma atividade lúdica, acessível e de baixo custo para praticar identificação e combinação de sílabas na alfabetização, acrescentando narrativa, colaboração e motivação a exercícios de formação de palavras.

**Narrativa:** quatro magos encontram um cofre fechado; para liberar sua magia precisam reconstruir quatro palavras-senha com cartas de sílabas. Com todas completas, o cofre abre e a recompensa é compartilhada.

**Core loop:** observar as palavras-senha e as cartas da mão → identificar uma sílaba útil → escolher onde colocá-la → o jogo confere → a sílaba fica marcada com a cor do mago e ele recebe um ponto simbólico → passa a vez → repetir até completar as quatro palavras e abrir o cofre.

**Experiência desejada:** curiosidade diante das senhas, fantasia de magia, satisfação ao completar palavras, cooperação, senso de contribuição individual e expectativa pela abertura do cofre.

**Contexto de uso:** sala de aula, oficinas ou atividades pedagógicas mediadas, e também em casa; pequenos grupos presenciais em volta de um aparelho, com um adulto acompanhando. O jogo não substitui a mediação docente.

**Conteúdo (extraído do PDF das cartas):**

30 palavras-senha (28 de duas sílabas, 2 de três):
CASA, CAMA, CANO, CARA, BOCA, BOLA, BOLO, BOTA, PATO, PATA, PANO, PIPA, GATO, GATA, GALO, GOLA, GOTA, MALA, MATO, MOTO, MOLA, RATO, SAPO, SACO, SALA, SINO, SOPA, TATU, TAPETE, TOMATE

100 cartas de sílabas, 22 distintas (sílaba × cópias):
CA×8, TA×8, TO×8, LA×7, PA×7, BO×6, MA×6, SA×6, GA×5, NO×5, GO×4, LO×4, MO×4, RA×4, TE×4, CO×2, PE×2, PI×2, PO×2, SI×2, SO×2, TU×2

4 cartas de mago: vermelho, azul, verde, amarelo.

**Testes previstos:** testes funcionais e de usabilidade com a equipe e outros adultos, observando compreensão das instruções, facilidade de interação com as cartas, legibilidade, reconhecimento das imagens, funcionamento da formação de palavras, equilíbrio da distribuição de sílabas, tempo de partida, cooperação e motivação.

**Base pedagógica:** consciência fonológica/silábica e jogos didáticos (Gerheim, Nogueira e Rocha, 2026, "Da concepção à produção"). Escolhas de palavras e regras ainda não validadas empiricamente.

## Constraints

- **Tech stack**: Godot com GDScript, jogo 2D — definido no HCD pela equipe
- **Timeline**: protótipo jogável até dezembro de 2026 (fim do semestre) — entrega da disciplina
- **Plataforma**: Android (APK) e PC desktop — aparelho móvel pelo alcance; PC para demonstrar na apresentação
- **Público**: crianças de 7 a 9 anos em alfabetização — exige letras grandes, contraste, instruções curtas e imagens de apoio
- **Conteúdo**: somente sílabas CV e as 30 palavras do protótipo físico — vocabulário fechado definido pela equipe
- **Arte**: recursos de licença livre (ex.: Kenney, OpenMoji) — sem tempo nem orçamento para arte original; licenças precisam ser registradas
- **Ética**: sem exposição pública de erros; sem coleta de dados de crianças; testes apenas com adultos
- **Equipe**: duas pessoas — escopo precisa ser enxuto

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Um aparelho compartilhado (pass-and-play) | Mais simples e mais próximo do jogo de mesa presencial | — Pending |
| Validação automática das jogadas | Dispensa o Mestre dentro do app; o adulto só acompanha | — Pending |
| Sorteio automático das 4 palavras-senha | Início de partida imediato, sem tela de preparação | — Pending |
| Mão por mago + compra do baralho | Ponto de partida para as regras ainda "em teste" no HCD; valores ajustáveis | — Pending |
| Magos iguais, sem habilidades | Mantém o escopo viável para dezembro | — Pending |
| Arte de licença livre | Equipe pequena e prazo curto | — Pending |
| Exportar para Android e PC | Mobile é a plataforma-alvo; PC facilita a demonstração | — Pending |
| Baralho reduzido por partida | A simulação da pesquisa indicou 41% a 80% de turnos sem jogada com as 100 cartas; diverge do jogo físico | — Pending |
| Palavra escrita configurável | Funciona como nível de dificuldade e reduz a dependência da qualidade das ilustrações | — Pending |
| Só a mão do mago da vez na tela | Cartas maiores no celular; quem está ao lado vê e pode ajudar | — Pending |
| Áudio só com efeitos sonoros | Palavras e sílabas faladas exigem gravação; ficam para v2 | — Pending |
| Valores iniciais das regras (D-22): proporcao_distratoras=0.40, tamanho_mao=5, silabas_por_turno=1, cartas_por_troca=0, erro_passa_a_vez=true, quantidade_senhas=4, baralho de partida=100 cartas (tamanho_baralho_partida=0) | Simulador, 5000 partidas, semente 2026, perfil perfeito: turnos sem ponto 36.4/33.1/30.2/28.0% (1 a 4 magos); D-18 (<=35%) exigida com 2 a 4 magos, so relatada com 1 mago (falha aceita); D-19 mago sem silaba com 4 magos 0.7% (<=5%); D-20 100% terminam. Aprovado por georginho1 em 2026-11-17. Pendente (D-14): palavras mais lentas TAPETE, SOPA, SACO, SAPO, PIPA, SINO, TATU. Evidencia: .planning/phases/01-funda-o-regras-e-simulador/01-SIMULACAO.md | Decidido |
| Troca de mão compra antes de devolver os descartes (WR-02 da revisão de código) | Evita receber a mesma mão de volta com o baralho quase vazio; após a mudança, turnos sem ponto 33.8/31.2/28.3/26.6% (1 a 4 magos), D-18/D-19/D-20 continuam PASS. Aprovado em 2026-11-17 | Decidido |

## Current State

Phase 2 concluída em 2026-11-17: partida completa jogável de ponta a ponta — menu, seleção de 1 a 4 magos, mesa com faixa de vez, mão só do mago da vez, jogada por dois toques, acerto com cor/símbolo do autor, erro sem punição visível, troca de cartas, pontos simbólicos, pausa com confirmação (Esc/voltar do Android), cofre que abre e tela final de contribuições sem ranking. 89 testes GUT passando; APK e exe exportados e partida completa conferida em Android real e em 4 proporções no PC (aprovado pelo usuário). Revisão de código (02-REVIEW.md) deixou 4 avisos abertos (WR-01..04) para correção. Arte final, áudio e créditos vêm na Phase 3.

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-11-17 after Phase 2 completion*
