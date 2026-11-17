---
phase: 2
slug: partida-completa-jogavel
status: draft
shadcn_initialized: false
preset: none
created: 2026-11-17
---

# Fase 2 — Contrato de Design de Interface

> Contrato visual e de interação da Fase 2 (Partida completa jogável). Gerado pelo gsd-ui-researcher, verificado pelo gsd-ui-checker. Projeto Godot 4.7.2 / GDScript 2D: não há CSS, React nem shadcn. O "sistema de design" é um `Theme` do Godot + containers `Control`. Unidade "px" = pixel da base 1280x720 (stretch `canvas_items`, aspect `expand`).

Fontes das decisões: D-xx = `02-CONTEXT.md`; MESA/COFR/PART = `REQUIREMENTS.md`; "padrão" = escolhido aqui por falta de decisão upstream.

---

## Design System

| Propriedade | Valor |
|-------------|-------|
| Ferramenta | none (shadcn não se aplica: projeto Godot) |
| Preset | não se aplica |
| Biblioteca de componentes | nenhuma; `Control` + containers nativos do Godot, `Tween` para animação; sem addons de cartas (CLAUDE.md) |
| Tema | um único `Theme` em `res://tema/tema_cofre.tres`, aplicado na raiz de cada cena; nenhum `theme_override` solto fora de exceções documentadas aqui |
| Biblioteca de ícones | provisória: símbolos dos magos desenhados como formas simples (`Polygon2D`/`_draw`/`TextureRect` com SVG próprio em `arte/provisoria/`); sem pacote de ícones nesta fase. Arte definitiva fica para a Fase 3 |
| Fonte | **Andika** (SIL OFL 1.1, feita para alfabetização), arquivos Regular e Bold em `res://fontes/`, com `OFL.txt` ao lado; registrar em `CREDITOS.md` no momento em que entrar no repositório. Fallback do Godot só se a Andika não puder ser baixada (registrar a exceção) |
| Estilo | alfabeto em **MAIÚSCULAS** para sílabas e palavras (MESA-09); sem serifa; alto contraste |
| Resolução / escala | base 1280x720, `canvas_items`, `expand`; área segura de 1280x720 centralizada (ver Layout) |

---

## Spacing Scale

Valores declarados (múltiplos de 4):

| Token | Valor | Uso |
|-------|-------|-----|
| xs | 4px | folga entre ícone de ponto e vizinho, contorno interno |
| sm | 8px | espaço entre espaços de sílaba de uma mesma senha |
| md | 16px | espaço entre cartas da mão; padding interno de painéis |
| lg | 24px | separação entre mão e botão comprar/trocar |
| xl | 32px | margem externa da área segura; espaço entre blocos |
| 2xl | 48px | separação entre blocos principais nas telas de menu, seleção, cofre e final |
| 3xl | 64px | altura da barra superior da mesa; folga de título |

Implementação: `MarginContainer` com `theme_override_constants` vindo do Theme; `HBoxContainer`/`VBoxContainer`/`GridContainer` com `separation` nesses tokens. Nenhum posicionamento absoluto de nós de interface (CLAUDE.md).

Exceções (todas intencionais):
- **Alvo de toque mínimo 96px** (diretriz CLAUDE.md, base 1280x720): botões, cartas, magos na seleção e espaços de sílaba têm lado mínimo 96px, exceto o botão de pausa (abaixo).
- Espaço de sílaba: **92 x 96px** (largura reduzida para 3 espaços caberem na largura de uma senha de 296px; ainda dentro do "~96px"). Validar em aparelho real.
- Botão de pausa: **72 x 72px** no canto superior direito, de propósito menor e longe da mão para evitar toque acidental (D-16); cercado por 16px de área morta.
- Valores de tamanho de componente (96, 92, 144, 160, 296, 72) são dimensões de controles, não tokens de espaçamento.

---

## Typography

Quatro tamanhos e dois pesos (Regular 400 e Bold 700). Tamanhos em px na base 1280x720.

| Papel | Tamanho | Peso | Altura de linha | Uso |
|-------|---------|------|-----------------|-----|
| Body | 24px | Regular 400 | 1.5 | frases curtas de apoio ("Toque para começar"), rótulo placeholder da palavra (D-12), rótulo da palavra escrita (MESA-02) |
| Label | 32px | Bold 700 | 1.2 | texto de botões, "Vez do Mago X" no indicador de turno, mensagens do painel de pausa |
| Heading | 48px | Bold 700 | 1.2 | títulos de tela ("Quem vai jogar?"), "O cofre abriu!", "Todos ajudaram!", faixa de passagem de vez |
| Display | 72px | Bold 700 | 1.0 | sílaba na carta da mão e sílaba aceita nos espaços; título "Cofre Mágico" no menu |

Regras:
- Sílabas e palavras sempre em maiúsculas (`text.to_upper()` na apresentação; os dados permanecem como estão).
- Sílaba na carta: 72px Bold centralizada; nos espaços aceitos reduzida para 56px **não permitida** (apenas 4 tamanhos): manter 72px e dimensionar o espaço para caber 2 letras (cabe em 92px com Andika Bold; conferir com a fonte instalada, se não couber trocar o espaço para 96px e a senha para 3 x 96 + 2 x 8 = 304px, reduzindo a margem lateral de xl para md).
- Nenhum texto abaixo de 24px.
- Rótulo de palavra (D-12 / MESA-02): Body 24px Regular em maiúsculas.

---

## Color

Tema escuro "noite mágica" para destacar cartas claras e cores dos magos.

| Papel | Valor | Uso |
|-------|-------|-----|
| Dominante (60%) | `#14213D` (azul-noite) | fundo de todas as telas |
| Secundária (30%) | `#DCEBFA` (azul-claro das cartas físicas) | cartas da mão, espaços vazios das senhas, área da ilustração; texto escuro `#14213D` sobre ela (contraste >= 12:1) |
| Superfície auxiliar | `#22335C` | painéis (barra superior, pausa, faixa de vez), botões secundários; texto `#FFFFFF` |
| Acento (10%) | `#B388FF` (violeta claro) | ver lista abaixo |
| Destrutivo | não usado | não há ação destrutiva com dados; "Sair da partida" usa botão secundário com confirmação, sem vermelho (vermelho pertence ao mago) |
| Texto sobre fundo escuro | `#FFFFFF` | títulos, rótulos |

Cores dos magos (D-05, sempre acompanhadas do símbolo; nunca só cor):

| Mago | Cor | Símbolo | Cor do símbolo/texto sobre ela |
|------|-----|---------|--------------------------------|
| 1 | vermelho `#E03C3C` | sol | `#FFFFFF` |
| 2 | azul `#2F7BFF` | lua | `#FFFFFF` |
| 3 | verde `#2EAD5E` | folha | `#FFFFFF` |
| 4 | amarelo `#F2C200` | estrela | `#14213D` |

Mapeamento: índice do núcleo 0..n-1 -> n-ésimo mago **ativo** na ordem fixa vermelho -> azul -> verde -> amarelo (D-07). Um único recurso `dados/tipos`-like ou dicionário na apresentação guarda cor+símbolo; nenhuma cor de mago em código de regra.

O acento violeta é reservado a:
1. contorno da carta selecionada (D-02/D-04);
2. destaque de **todos** os espaços ainda abertos quando há carta selecionada (D-02), contorno violeta de 4px, sem indicar o correto;
3. destaque do botão comprar/trocar quando `Partida.existe_jogada()` é falso (MESA-07): pulsar de escala 1.0 -> 1.06 em 0,8 s em loop e preenchimento violeta; nunca vermelho nem tremida;
4. botão primário de cada tela ("Jogar", "Começar", "Continuar", "Jogar de novo");
5. brilho do cofre ao abrir (junto das cores dos magos ativos).

Fora dessa lista o acento não é usado. Estados desabilitados: `#22335C` com texto `#8FA0C4`. Mago apagado na seleção: fundo `#22335C`, símbolo e contorno em cinza `#5C6C91` (D-06); aceso: cor plena do mago + símbolo branco.

Regra ética: nenhum vermelho, X, tremida ou som associado a erro (D-03; PROJECT.md). O vermelho só aparece como identidade do mago 1.

---

## Layout e telas

Ancoragem: raiz `Control` em `FULL_RECT`; conteúdo dentro de `MarginContainer` (xl = 32px) e containers. Com `expand`, a janela nunca é menor que 1280x720: 20:9 acrescenta largura (conteúdo centralizado, fundo estendido), 4:3 acrescenta altura (conteúdo centralizado verticalmente, fundo estendido). **O conteúdo funcional cabe sempre em 1280x720** (MESA-08). Se a janela de PC for menor que a base, a escala do `canvas_items` reduz tudo proporcionalmente (D-09: "encolhe", nada cortado).

### Fluxo de cenas (cada uma em `cenas/<nome>/`)
`menu` -> `selecao` -> `mesa` (com sobreposições `faixa_vez` e `pausa`) -> `cofre` -> `final` -> (`mesa` com os mesmos magos | `menu`).

### 1. Menu inicial (COFR-04, D-17)
- Título "COFRE MÁGICO" (Display 72px, centralizado) com retângulo/ícone provisório de cofre acima.
- Botão "Jogar" 360 x 120px, primário (acento), Label 32px, centralizado, 48px abaixo do título.
- Sem créditos, sem mudo (Fase 3). Voltar do Android fecha o jogo.

### 2. Seleção de magos (PART-01, D-06, D-07)
- Título "Quem vai jogar?" (Heading 48px).
- 4 botões-mago em linha (HBox, separação 24px), cada **200 x 200px**: bloco com a cor do mago e seu símbolo grande (96px) quando aceso; cinza apagado quando não. Toque acende/apaga. Sem nome nem texto de número.
- Botão "Começar" 360 x 96px abaixo (48px), desabilitado com 0 acesos, ativo com >= 1 (acento).
- Voltar do Android/Esc volta ao menu.
- Estado inicial: todos apagados.

### 3. Mesa (MESA-01 a MESA-09, D-09)
Três faixas verticais dentro da área segura 1280x720 (margem 32px):

| Faixa | Altura | Conteúdo |
|-------|--------|----------|
| Barra superior | 64px | esquerda: indicador de turno (D-10); direita: botão de pausa 72px |
| Senhas | 320px | 4 senhas em linha única, cada **296px** de largura, separação 8px (total 1208px; margem lateral 36px) |
| Mão | 200px | 5 cartas à esquerda + botão comprar/trocar à direita |

Soma: 64 + 16 + 320 + 16 + 200 = 616px mais margens de 32px = 680px, cabendo em 720px.

**Indicador de turno (D-10/D-11/MESA-03/MESA-06):** painel `#22335C` com o círculo do mago (cor + símbolo, 48px), texto "Vez do Mago X" (Label 32px; X = nome da cor: "Vermelho", "Azul", "Verde", "Amarelo") e, à direita, **ícones de ponto repetidos** (um por sílaba posta pelo mago, 24px, na cor do mago, sem número, quebrando linha se necessário; máximo previsto cabe em 8 ícones por linha). Só mostra o mago da vez; nunca os pontos de outros.

**Senha (MESA-01/02):** cartão vertical 296px:
- área da ilustração 296 x 160px, fundo `#DCEBFA`, placeholder `arte/provisoria/placeholder_palavra.svg` com o **nome da palavra em Body 24px maiúsculo** sobreposto (D-12; rótulo removido na Fase 3);
- linha de espaços (2 ou 3), cada 92 x 96px, separação 8px (sm), alinhada ao centro; espaço vazio: `#DCEBFA` com contorno cinza `#5C6C91` 2px;
- se `mostrar_palavra_escrita` for verdadeiro: palavra escrita (Body 24px) sob a ilustração, entre a ilustração e os espaços, 32px de altura; se falso, o espaço some e a senha apenas fica mais compacta (não deixar buraco). Valor lido de `ConfigRegras`, nunca fixo;
- espaço preenchido (D-13/MESA-05): fundo na **cor do mago autor**, sílaba em Display 72px (cor do texto conforme tabela de magos) e pequeno símbolo do mago (24px) no canto superior esquerdo do espaço; permanece até a tela final;
- senha completa: contorno de 4px na cor `#FFFFFF` ao redor do cartão e leve pulso de escala 1.0 -> 1.04 (sem som nem texto).

**Mão (MESA-03/04/09):** 5 cartas 144 x 176px (HBox, separação 16px = 5*144 + 4*16 = 784px). Carta: fundo `#DCEBFA`, borda 4px `#14213D`, cantos arredondados 16px, sílaba Display 72px Bold `#14213D` centralizada, em maiúsculas. Carta selecionada: sobe 16px, contorno 4px acento violeta (D-04). Mão do mago da vez só aparece depois do toque na faixa de vez.

**Botão comprar/trocar (MESA-07):** 360 x 120px à direita da mão (24px de separação), sempre visível, Label 32px: texto "Trocar cartas". Estilo normal: superfície `#22335C` com contorno branco 2px. Quando `existe_jogada()` é falso: preenchimento violeta + pulsar (item 3 do acento). Habilitado em qualquer turno (regra herdada: troca permitida mesmo com jogada).

**Pausa (D-16):** botão 72px com ícone de duas barras, canto superior direito. Abre painel modal 560 x 400px centralizado sobre fundo escurecido (`#14213D` a 80%): título "Pausa" (Heading 48px), botões "Continuar" (primário, 360 x 96px) e "Sair da partida" (secundário, 360 x 96px), separação 16px. "Sair da partida" abre confirmação no mesmo painel: "Sair da partida?" (Heading), texto "A partida atual será perdida." (Body), botões "Sair" (secundário) e "Continuar jogando" (primário). Esc e botão voltar do Android abrem o mesmo painel; com o painel aberto, voltar equivale a "Continuar". O painel congela a interação com a mesa.

### 4. Faixa de passagem de vez (D-01, D-03)
Sobreposição de tela cheia horizontal (faixa 1280 x 240px centralizada vertical, fundo `#22335C` 95%, borda superior e inferior de 8px na cor do próximo mago): círculo do mago (cor + símbolo 96px), "Vez do Mago X" (Heading 48px) e "Toque para começar" (Body 24px). As 4 senhas permanecem visíveis acima e abaixo da faixa (a mão fica oculta). **Toque em qualquer lugar da faixa** dispensa e revela a mão (fade 0,2 s). Idêntica após acerto, erro ou troca (sem pista de quem errou). Não mostra pontos. Na partida de 1 mago, a faixa aparece igualmente (consistência, mesmo comportamento após cada jogada). Primeira vez: aparece também no início da partida.

### 5. Cofre (COFR-01, D-14)
Tela cheia fundo `#14213D`: retângulo do cofre (320 x 320px) com porta que abre por `Tween` em 1,2 s (porta desliza/gira, interior `#B388FF` brilhante), partículas/confete simples (`CPUParticles2D` ou retângulos animados, sem shader pesado, compatível com Compatibility) nas cores dos **magos ativos**, texto "O cofre abriu!" (Heading 48px) aparecendo após a abertura, e "Toque para continuar" (Body 24px). Toque só é aceito depois da animação (>= 1,5 s) para não pulá-la; depois leva à tela final.

### 6. Tela final (COFR-02, COFR-03, D-15, D-08)
- Título "Todos ajudaram!" (Heading 48px).
- Bloco superior: as 4 senhas completas na mesma anatomia da mesa, sílabas na cor/símbolo do autor, tamanho reduzido (cartão 296px sem ilustração grande: ilustração 96px de altura).
- Bloco inferior: magos ativos em linha, **ordem fixa das cores**, cada um com círculo (48px, cor + símbolo) e seus ícones de ponto (24px, sem número). Mago com 0 sílabas: aparece igual, com o círculo e nenhum ícone, sem destaque nem rótulo. Sem ordenação por pontos, sem "vencedor", sem troféu.
- Botões lado a lado (separação lg 24px), cada 320 x 96px: "Jogar de novo" (primário; mesmos magos, novas senhas) e "Voltar ao menu" (secundário). Voltar do Android aqui leva ao menu.
- Altura: título 64 + 16 + senhas ~232 + 24 + magos ~96 + 24 + botões 96 = ~552px, cabendo em 720px.

---

## Interação

- **Dois toques (MESA-04, D-04):** tocar carta -> seleciona (qualquer outra seleção anterior é trocada; tocar de novo na mesma desmarca). Com carta selecionada, todos os espaços abertos recebem contorno violeta (D-02). Tocar em espaço aberto -> chama `jogar_silaba(indice_carta, palavra, espaco)`. Tocar em espaço sem carta selecionada, ou em espaço já preenchido: nada acontece.
- **Acerto:** carta voa até o espaço por `Tween` (0,25 s), espaço assume cor do mago e pulsa de escala 1.0 -> 1.1 -> 1.0 (0,2 s), sem som (Fase 3). Em seguida, se `concluida()`, vai ao cofre; senão, faixa de vez.
- **Erro:** a carta volta suavemente à posição na mão por `Tween` (0,3 s, `TRANS_SINE`); **nenhum** X, cor de erro, tremida, texto ou som; em seguida faixa de vez (D-03).
- **Troca:** toque em "Trocar cartas" -> mão atual desliza para fora e novas entram (0,3 s); depois a faixa de vez (D-01).
- Entrada bloqueada durante animações e faixa (evita toques duplos); toque simples com mouse no PC equivale ao toque no Android (`emulate_mouse_from_touch` padrão; usar `pressed` de `Button`/`gui_input`, sem depender de arrastar).
- Sem arrastar e soltar nesta fase (v2), sem cronômetro, sem dica.
- Estados por mago: contagem de 1 a 4 magos todos tratados; com 1 mago a ordem de turno repete o mesmo mago.

---

## Copywriting Contract

Tom: frases curtas, sem pontuação de erro, vocabulário para crianças de 7 a 9 anos (pt-BR). Maiúsculas apenas em sílabas, palavras-senha e título do jogo.

| Elemento | Texto |
|----------|-------|
| CTA primário (menu) | Jogar |
| CTA da seleção | Começar |
| Título da seleção | Quem vai jogar? |
| Dica da seleção (Body, aparece com 0 magos acesos) | Toque nos magos para acender |
| Indicador / faixa de vez | Vez do Mago {Vermelho/Azul/Verde/Amarelo} |
| Subtexto da faixa | Toque para começar |
| Botão comprar/trocar | Trocar cartas |
| Botão de pausa (nome acessível) | Pausa |
| Painel de pausa | Pausa / Continuar / Sair da partida |
| Confirmação de saída (destrutiva) | Sair da partida?: "A partida atual será perdida." Botões: "Sair" e "Continuar jogando" (o primário é "Continuar jogando") |
| Cofre | O cofre abriu! / Toque para continuar |
| Tela final | Todos ajudaram! |
| Botões finais | Jogar de novo / Voltar ao menu |
| Estado vazio | não há listas vazias nesta fase; o único "vazio" é a seleção sem magos acesos: botão "Começar" desabilitado + dica acima |
| Estado de erro | não existe texto de erro de jogada (regra ética). Erro técnico inesperado: "Algo deu errado. Toque para voltar ao menu." (Body, tela cheia) |
| Ação destrutiva | única: "Sair da partida", com confirmação (painel acima). "Jogar de novo" e "Voltar ao menu" na tela final não pedem confirmação (a partida já terminou) |

---

## Acessibilidade e conformidade com requisitos

| Requisito | Como o contrato atende |
|-----------|------------------------|
| MESA-01 | 4 senhas com ilustração (placeholder) 296 x 160px e 2 ou 3 espaços |
| MESA-02 | palavra escrita Body 24px condicionada a `ConfigRegras.mostrar_palavra_escrita`; rótulo do placeholder (D-12) é separado |
| MESA-03 | só a mão do mago da vez; indicador de turno com cor + símbolo + nome da cor |
| MESA-04 | dois toques; alvo >= 96px |
| MESA-05 | sílaba aceita com cor + símbolo do mago |
| MESA-06 | ícones de ponto só do mago da vez, sem número, sem ranking |
| MESA-07 | botão sempre visível; destaque violeta pulsante |
| MESA-08 | conteúdo cabe em 1280x720; 16:9, 20:9 e 4:3 só aumentam o fundo; testar também janela pequena de PC |
| MESA-09 | Andika Bold maiúscula 72px, `#14213D` sobre `#DCEBFA` |
| COFR-01..05 | telas 4, 5, 6, pausa e voltar descritos acima |
| Daltonismo | cor sempre acompanhada de símbolo (D-05) |
| Contraste | texto principal >= 12:1; violeta sobre azul-noite >= 6:1; texto escuro sobre amarelo e violeta |

---

## Registry Safety

| Registro | Blocos usados | Safety Gate |
|----------|---------------|-------------|
| shadcn oficial | nenhum | não se aplica (projeto Godot) |
| Terceiros | nenhum | não se aplica |

Recursos externos desta fase: apenas a fonte Andika (OFL 1.1), a registrar em `CREDITOS.md` com URL, data e licença, e `OFL.txt` em `fontes/`. Arte provisória e símbolos são desenhados no projeto, sem recurso de terceiros.

---

## Checker Sign-Off

- [ ] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: PASS
- [ ] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: PASS
- [ ] Dimension 5 Spacing: PASS
- [ ] Dimension 6 Registry Safety: PASS

**Aprovação:** pendente
