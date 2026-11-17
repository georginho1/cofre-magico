# Phase 2: Partida completa jogável - Context

**Gathered:** 2026-11-17
**Status:** Ready for planning

<domain>
## Phase Boundary

A fase entrega a camada de apresentação sobre o núcleo da Fase 1: menu inicial → seleção de 1 a 4 magos → mesa (4 senhas, mão do mago da vez, botão comprar/trocar) → abertura do cofre → tela final de contribuições → nova partida. Inclui pausa/saída com confirmação e o botão voltar do Android. Visual provisório (retângulos, texto, placeholder), jogável só com toque em Android real e com mouse no PC, sem cortes em 16:9, 20:9 e 4:3.

Fora desta fase: ilustrações definitivas, tela de créditos e áudio (Fase 3); arrastar e soltar, "como jogar", dica, painel do adulto (v2). As regras e seus valores já estão fixados na Fase 1 e não são rediscutidos aqui.

Requisitos: PART-01, MESA-01 a MESA-09, COFR-01 a COFR-05.

</domain>

<decisions>
## Implementation Decisions

Regras herdadas da Fase 1 (não mudar): mão de 5, uma sílaba por turno, erro passa a vez (`erro_passa_a_vez=true`), troca da mão inteira encerra o turno e é permitida mesmo com jogada, sempre 4 senhas, valores em `dados/regras_padrao.tres`.

### Vez e jogada
- **D-01:** Passagem de vez com **faixa de tela "Vez do Mago X"** (cor + símbolo do mago) e **toque para começar**; a mão do novo mago só aparece depois desse toque. As senhas continuam visíveis atrás/ao redor da faixa. Não é tela de privacidade.
- **D-02:** Ao selecionar uma carta, **todos os espaços ainda abertos** ficam destacados, sem indicar qual é o certo.
- **D-03:** Sílaba errada: a carta **volta suavemente para a mão** (Tween), sem X, vermelho, tremida, som ou texto de erro; em seguida vem a mesma passagem de vez de D-01, idêntica à de um acerto ou de uma troca.
- **D-04:** Seleção livre: tocar em outra carta troca a seleção; tocar na carta selecionada desmarca. Nada conta como jogada até tocar num espaço aberto. Tocar num espaço sem carta selecionada não faz nada.

### Magos e seleção
- **D-05:** Identidade fixa dos magos (cor + símbolo, sempre juntos para quem não distingue cores): **vermelho = sol, azul = lua, verde = folha, amarelo = estrela**.
- **D-06:** Tela de seleção com **os 4 magos apagados; tocar acende/apaga**. O botão "Começar" só fica ativo com pelo menos 1 mago aceso. Sem digitar nomes.
- **D-07:** Ordem dos turnos **fixa pela ordem das cores** (vermelho → azul → verde → amarelo), pulando os magos inativos. O primeiro mago aceso nessa ordem começa.
- **D-08:** "Jogar de novo" na tela final inicia **nova partida com os mesmos magos** (novas senhas sorteadas), sem passar pela seleção.

### Mesa e pontos
- **D-09:** As 4 senhas em **linha única** na parte de cima, mão do mago da vez embaixo, botão comprar/trocar sempre visível. Em 4:3 as senhas encolhem; nada pode ser cortado.
- **D-10:** Pontos simbólicos aparecem **só para o mago da vez**, no indicador de turno. Não há painel com todos os magos lado a lado durante a partida.
- **D-11:** Ponto representado por **ícones repetidos** (um por sílaba, na cor do mago), **sem número**.
- **D-12:** Imagem provisória: **placeholder único** (`arte/provisoria/placeholder_palavra.svg`) com o **nome da palavra em texto dentro da área da ilustração**, para as senhas serem distinguíveis. Esse rótulo é parte do placeholder e é separado da "palavra escrita" do MESA-02, que continua obedecendo a `mostrar_palavra_escrita` do `ConfigRegras`. O rótulo sai quando as ilustrações da Fase 3 entrarem.
- **D-13:** Sílaba aceita fica no espaço com a **cor e o símbolo do mago autor** (MESA-05), até a tela final.

### Cofre, fim e pausa
- **D-14:** Ao completar a última senha: **transição para uma tela do cofre** (retângulo/porta) que abre com Tween, brilho/confete simples nas cores dos magos ativos e o texto "O cofre abriu!". Um toque leva à tela final.
- **D-15:** Tela final: as **4 senhas completas com cada sílaba na cor/símbolo do autor** e, abaixo, os magos ativos **na ordem fixa das cores**, cada um com seus ícones de ponto. Mago com 0 sílabas aparece igual aos demais. Mensagem coletiva ("Todos ajudaram!" ou equivalente), sem vencedor, sem ordenação por pontos. Botões: "Jogar de novo" (D-08) e voltar ao menu.
- **D-16:** **Botão de pausa** pequeno num canto da mesa abre um painel com "Continuar" e "Sair da partida"; sair pede **confirmação** e volta ao menu inicial. O **botão voltar do Android** (e Esc no PC) abre esse mesmo painel durante a partida. No menu inicial, voltar fecha o jogo; na seleção, volta ao menu.
- **D-17:** Menu inicial com um botão grande "Jogar" (COFR-04). Créditos e mudo ficam para a Fase 3.

### Claude's Discretion
- Forma do destaque do botão comprar/trocar quando `Partida.existe_jogada()` é falso (MESA-07): pulsar, brilho ou cor, desde que não pareça alerta de erro.
- Feedback do acerto (encaixe da carta com Tween, breve brilho) antes da faixa de passagem de vez.
- Estrutura de cenas, nomes de nós, autoload/gerente de cenas e como o índice de jogador do núcleo (0..n-1) é mapeado para o mago/cor.
- Detalhes visuais (paleta exata, fonte sem serifa de licença livre ou fonte padrão, tamanhos, espaçamentos) — a definir no `/gsd-ui-phase` dentro das restrições MESA-08/MESA-09 e alvos de toque ≥ ~96 px na base 1280x720.
- Desenho provisório dos símbolos (sol, lua, folha, estrela): formas simples desenhadas ou caracteres, desde que legíveis; a arte definitiva pode vir na Fase 3.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Escopo e requisitos
- `.planning/ROADMAP.md` §Phase 2 — objetivo e os 5 critérios de sucesso
- `.planning/REQUIREMENTS.md` — PART-01, MESA-01..09, COFR-01..05; v2 (APOI, JOGO-02) e Out of Scope (sem ranking, sem cronômetro)
- `.planning/PROJECT.md` — Key Decisions (só a mão do mago da vez, palavra escrita configurável, valores D-22) e restrições éticas (sem exposição pública de erro)
- `.planning/STATE.md` §Blockers/Concerns — decisões de Fase 2 (resolvidas aqui: D-01, D-02) e FUND-02 pendente (APK em aparelho físico)

### Decisões anteriores
- `.planning/phases/01-funda-o-regras-e-simulador/01-CONTEXT.md` — regras D-01..D-22 da Fase 1 que a interface precisa respeitar

### Pesquisa
- `.planning/research/FEATURES.md` — passagem de vez, toque-toque, alvos de toque, anti-features (sem tela de privacidade, sem cronômetro, sem X vermelho)
- `.planning/research/ARCHITECTURE.md` — camadas Dados → Núcleo → Apresentação; a Mesa consome a API da `Partida`
- `.planning/research/PITFALLS.md` — riscos de layout em proporções diferentes e de exportação Android
- `.planning/research/STACK.md` e `CLAUDE.md` — `canvas_items` + `expand`, containers/âncoras, Compatibility, sem addons de cartas

### Conceito
- `HCD_preenchido_cofre_magico.md` — core loop, experiência desejada, cuidados éticos
- `cofre_magico_todas_as_cartas_otimizado.pdf` — visual das cartas físicas (fundo azul-claro, sílaba centralizada) como referência para a carta provisória

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `nucleo/partida.gd` (`Partida`, RefCounted): `jogar_silaba(indice_carta, palavra, espaco)` → `ResultadoJogada.Tipo` (ACERTO/ERRO/TROCOU/INVALIDO), `trocar_mao()`, `existe_jogada()` (para MESA-07), `concluida()`, `jogador_atual`, `jogadores[i].mao/pontos`, `palavras[i].preenchido_por` (autoria por espaço). Sinais: `silaba_aceita`, `jogada_recusada`, `mao_trocada`, `turno_iniciado`, `cofre_aberto`.
- `Partida._init(cfg, bib, dist, n_magos, rng)` recebe só a quantidade de magos; os jogadores são índices 0..n-1. A apresentação precisa mapear índice → mago ativo (cor/símbolo) seguindo D-07.
- `dados/regras_padrao.tres` (`ConfigRegras`) com `mostrar_palavra_escrita`; `dados/biblioteca_palavras.tres` e `dados/distribuicao_baralho.tres`.
- `arte/provisoria/placeholder_palavra.svg` — placeholder da ilustração (D-12).
- `cenas/inicial/` — cena placeholder atual, `run/main_scene`; será substituída pelo menu inicial (atenção ao `testes/unit/test_inicial.gd`).

### Established Patterns
- Núcleo sem Node/await/Timer, RNG injetado; animações e esperas ficam só na apresentação.
- Valores de regra só em `ConfigRegras`, nunca no código da interface.
- Identificadores em português sem acento; arquivos em minúsculas com underscore; cenas em `cenas/`.
- Projeto já em 1280x720, `canvas_items`, `expand`, orientação sensor_landscape, Compatibility.

### Integration Points
- A mesa chama a mesma API usada pelos testes GUT e pelo simulador; nenhuma regra nova na interface.
- Após ERRO/TROCOU/ACERTO o núcleo já passou a vez (`turno_iniciado`); a interface só encena (D-03, D-01) antes de mostrar a nova mão.
- Botão voltar do Android: depende de desligar o "quit on go back" e tratar a notificação de go-back (a pesquisa deve confirmar o nome na 4.7).
- Ao fim da fase: exportar APK e jogar uma partida completa em aparelho Android real (regra do roadmap + critério 5).

</code_context>

<specifics>
## Specific Ideas

- O usuário escolheu a opção recomendada em todas as perguntas: o desenho segue as conclusões de `FEATURES.md` (faixa de passagem com toque, toque-toque com destaque neutro, erro sem sinal visual).
- Erro, acerto e troca terminam do mesmo jeito (faixa "Vez do Mago X"), para que ninguém perceba em público quem errou.
- Pontos nunca aparecem lado a lado durante a partida; só na tela final, em ordem fixa e sem número.

</specifics>

<deferred>
## Deferred Ideas

- Opção "Trocar magos" na tela final (hoje: só "Jogar de novo" com os mesmos magos e voltar ao menu).
- Emojis OpenMoji como imagens provisórias — fica para a Fase 3 com o registro de licenças.

</deferred>

---

*Phase: 2-Partida completa jogável*
*Context gathered: 2026-11-17*
