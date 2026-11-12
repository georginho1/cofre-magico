# Phase 1: Fundação, regras e simulador - Context

**Gathered:** 2026-11-12
**Status:** Ready for planning

<domain>
## Phase Boundary

A fase entrega o projeto Godot 4.7.2 rodando em um aparelho Android real e no PC (cena inicial), e o núcleo de regras sem tela: dados das 30 palavras e das 100 cartas, sorteio das senhas, recorte do baralho da partida, distribuição das mãos, validação da sílaba pelo espaço exato, troca de mão e ordem dos turnos. As regras são cobertas por testes GUT executados com um único comando e medidas por um simulador sem interface, e todos os parâmetros ficam em um arquivo de configuração.

Fora desta fase: qualquer tela de jogo (mesa, seleção de magos, cofre, menu), ilustrações definitivas, créditos e áudio.

Requisitos: FUND-01 a FUND-04, CONT-01, CONT-02, PART-02 a PART-11.

</domain>

<decisions>
## Implementation Decisions

Todos os valores numéricos abaixo são valores **iniciais** e devem existir como parâmetros no arquivo de configuração (PART-10), não como constantes no código.

### Regra do turno
- **D-01:** Cada mago tem mão de **5 cartas**.
- **D-02:** O mago coloca **no máximo uma sílaba por turno**. Um acerto encerra o turno.
- **D-03:** O botão comprar/trocar **troca a mão inteira**: as 5 cartas voltam ao baralho da partida, o baralho é reembaralhado e o mago compra 5 novas. Não há seleção de cartas individuais.
- **D-04:** Tentativa em espaço errado: a carta **volta para a mão e a vez passa** para o próximo mago. Não há marcação de erro, contador nem perda de carta.
- **D-05 (suposição, aceita ao avançar de área):** Após um acerto, o mago compra até voltar ao tamanho da mão (5).
- **D-06 (suposição, aceita ao avançar de área):** A troca de mão encerra o turno e é permitida mesmo quando o mago tem jogada.

**Atenção para o planejador:** D-04 foi escolha explícita do usuário contra a opção recomendada ("continua, sem limite"). O PART-06 diz "sem punição nem marcação de erro"; a leitura adotada é que perder a vez não conta como punição visível, mas o efeito deve aparecer no relatório do simulador (perfil aprendiz, D-17) para a equipe reavaliar. Deixar o comportamento parametrizado (`erro_passa_a_vez` ou equivalente) para permitir a comparação.

### Recorte do baralho da partida
- **D-07:** O baralho da partida contém **sílabas úteis e distratoras**.
- **D-08:** Sílabas úteis entram com **todas as cópias do baralho físico** (ex.: senha com CA leva as 8 cartas CA; senha com TU leva as 2 TU).
- **D-09:** Proporção inicial de distratoras: **cerca de metade** do baralho da partida (uma distratora para cada carta útil).
- **D-10:** As distratoras são **sorteadas entre as cartas das demais sílabas** do baralho de 100, respeitando a quantidade de cópias de cada uma.
- **D-11:** A distribuição das mãos e as compras são **sorteio puro**, sem garantia de carta útil.
- **D-12 (suposição, aceita ao avançar de área):** A carta colocada em uma senha permanece nela e sai de circulação; as cartas trocadas voltam ao baralho e são reembaralhadas; se o baralho esvaziar, o mago fica com as cartas que tem. Nenhuma carta necessária pode ficar inalcançável (PART-09).

### Sorteio das senhas
- **D-13:** **Sorteio puro** entre as 30 palavras. Pares quase idênticos (PATO+PATA, GATO+GATA) podem sair na mesma partida.
- **D-14:** **Nenhuma restrição** para palavras de 3 sílabas (TAPETE, TOMATE) nem para palavras com sílabas de 2 cópias (CO, PE, PI, PO, SI, SO, TU). O simulador deve reportar o impacto por palavra para a equipe decidir com números.
- **D-15:** **Sempre 4 senhas**, para 1 a 4 magos (valor parametrizado).
- **D-16 (suposição, aceita ao avançar de área):** Sem palavra repetida dentro da partida; sorteio com semente para ser reproduzível nos testes.

### Metas do simulador
- **D-17:** Dois perfis de jogador simulado: **perfeito** (joga a sílaba certa sempre que tem; senão troca a mão) e **aprendiz** (erra o espaço com probabilidade configurável). O relatório mostra os dois.
- **D-18:** Meta de **turnos sem ponto ≤ 35%** (turnos que terminam em troca de mão ou em tentativa errada), medida com o perfil perfeito.
- **D-19:** Meta de **partidas em que um mago termina sem nenhuma sílaba ≤ 5%**, com 4 magos e perfil perfeito.
- **D-20:** 100% das partidas simuladas terminam (critério do roadmap), para 1, 2, 3 e 4 magos.
- **D-21:** Se a configuração inicial não cumprir as metas, a primeira alavanca é **reduzir a proporção de distratoras**. Tamanho da mão e a regra D-04 só são revistos depois, com aprovação da equipe.
- **D-22:** Os valores finais escolhidos com base no simulador são registrados como decisão no PROJECT.md (critério 5 do roadmap).

### Claude's Discretion
- Idioma dos identificadores (sugestão: português sem acento, nomes de arquivo em minúsculas) e convenção de pastas (pasta de testes, arquivo de créditos); fixar uma convenção e registrá-la no CLAUDE.md.
- APK de depuração com um debug keystore compartilhado fora do repositório; keystore de release só se sobrar tempo.
- Arquiteturas do preset Android (`arm64-v8a`, e `armeabi-v7a` conforme o aparelho de teste).
- Formato do relatório do simulador e do arquivo de configuração (`.tres` de `ConfigRegras` conforme a pesquisa de arquitetura).
- Número de partidas por configuração no simulador e taxa de erro padrão do perfil aprendiz.
- Duração alvo da partida não foi definida como meta: apenas medir e reportar.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Conceito e conteúdo do jogo
- `HCD_preenchido_cofre_magico.md` — High-Concept Document v1.0; core loop, público, cuidados éticos; §7 declara as regras de mão/compra/troca como "em teste"
- `cofre_magico_todas_as_cartas_otimizado.pdf` — todas as cartas do protótipo físico (fonte das 30 palavras e da distribuição das 100 cartas)
- `.planning/PROJECT.md` — lista das 30 palavras, distribuição das 22 sílabas (sílaba × cópias), restrições e decisões-chave

### Escopo da fase
- `.planning/ROADMAP.md` §Phase 1 — objetivo, requisitos e os 5 critérios de sucesso
- `.planning/REQUIREMENTS.md` — FUND-01..04, CONT-01..02, PART-02..11
- `.planning/STATE.md` §Blockers/Concerns — itens do Godot a conferir no editor; simulador da pesquisa está fora do repositório

### Pesquisa
- `.planning/research/SUMMARY.md` — síntese; divergências entre pesquisas (keystore, armeabi-v7a, nomes de pastas)
- `.planning/research/PITFALLS.md` — turnos mortos (41% a 80%), estados sem saída, sílabas com 2 cópias, exportação Android tardia
- `.planning/research/ARCHITECTURE.md` — camadas Dados → Núcleo → Apresentação; `Partida`, `Baralho`, `Jogador`, `PalavraSenha` como `RefCounted`; `ConfigRegras`; RNG injetado
- `.planning/research/STACK.md` — versões, configurações de projeto, exportação Android e desktop, GUT
- `CLAUDE.md` — pilha prescrita e o que não usar

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Nenhum. O repositório ainda não tem projeto Godot nem código; só documentos de planejamento, o HCD e o PDF das cartas.

### Established Patterns
- Nenhum padrão de código estabelecido. As regras de estrutura da pesquisa valem como ponto de partida: nada do núcleo estende `Node`; sílabas explícitas por palavra (nunca cortar a string); validação por índice de espaço; nomes de arquivo em minúsculas sem acento.

### Integration Points
- A API pública da `Partida` criada nesta fase é a mesma que a `Mesa` da Fase 2 vai usar; os testes GUT e o simulador devem exercitar essa mesma API.
- CONT-01 é atendido aqui com imagens provisórias; as ilustrações definitivas entram na Fase 3.

</code_context>

<specifics>
## Specific Ideas

- O usuário preferiu fidelidade ao jogo físico sempre que houve escolha: todas as cópias físicas das sílabas úteis, sorteio puro das senhas e das mãos, sempre 4 senhas.
- A única escolha contra a recomendação foi D-04 (errou, passa a vez).
- O relatório do simulador deve trazer, além das métricas do PART-11, o impacto por palavra (D-14) e a comparação entre os perfis perfeito e aprendiz (D-17).

</specifics>

<deferred>
## Deferred Ideas

- Evitar repetir palavras da partida anterior em partidas seguidas.
- Escolher distratoras por semelhança com as sílabas úteis (mesma consoante ou vogal).
- Restrições no sorteio (pares quase idênticos, limite de palavras difíceis) — reavaliar só se o simulador ou os testes da Fase 4 indicarem problema.
- Garantia de carta útil na mão inicial ou em toda compra — reavaliar só se as metas não forem cumpridas reduzindo distratoras.

</deferred>

---

*Phase: 1-Fundação, regras e simulador*
*Context gathered: 2026-11-12*
