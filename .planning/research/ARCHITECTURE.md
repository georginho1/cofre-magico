# Architecture Research

**Domain:** jogo de cartas 2D cooperativo por turnos, pass-and-play em um único aparelho (Godot 4 / GDScript, Android + PC)
**Researched:** 2026-11-11
**Confidence:** MEDIUM-HIGH (configurações e APIs do Godot conferidas na documentação oficial 4.7; padrões de organização vêm de prática da comunidade; arrastar-e-soltar por toque no Android NÃO foi confirmado e está marcado como LOW)

> Convenção deste documento: nomes de classes, pastas e sinais estão em português sem acento (ex.: `Partida`, `silaba_aceita`). É uma sugestão; a equipe deve fixar o idioma dos identificadores na primeira fase e não misturar.
> Os trechos de GDScript são ilustrativos e não foram executados.

## Standard Architecture

### System Overview

Três camadas, com dependência em um único sentido: **Apresentação -> Núcleo -> Dados**. O núcleo nunca conhece cenas, nós ou `Control`.

```
┌──────────────────────────────────────────────────────────────────────┐
│ APRESENTACAO (cenas .tscn + scripts de Control)                       │
│                                                                       │
│  Menu ──> ConfiguracaoJogadores ──> Mesa ──────────────> Cofre        │
│                                      │                  (recompensa)  │
│              ┌───────────────────────┼──────────────────────┐         │
│              │           │           │            │         │         │
│        PainelPalavras  MaoView   BarraMagos   Passagem   Camada de    │
│        (4x PalavraView (CartaView) (placar)   de vez     animacao     │
│         com SlotView)                         (overlay)  (carta voa)  │
└───────────────┬──────────────────────────────────▲───────────────────┘
                │ chamadas de metodo (intencoes)    │ sinais (fatos)
                ▼                                   │
┌──────────────────────────────────────────────────┴───────────────────┐
│ NUCLEO DE REGRAS (RefCounted puro, sem Node, testavel com GUT)        │
│                                                                       │
│   Partida (fachada + maquina de estados do turno)                     │
│     ├── Baralho (compra, descarte, reembaralhar)                      │
│     ├── Jogador[] (cor, mao, pontos)                                  │
│     ├── PalavraSenha[4] (slots: silaba esperada, preenchido, autor)   │
│     └── Sorteio (RandomNumberGenerator injetado, semente fixa p/teste)│
└───────────────┬──────────────────────────────────────────────────────┘
                │ le (somente leitura)
                ▼
┌──────────────────────────────────────────────────────────────────────┐
│ DADOS (Resources .tres editaveis no Inspector)                        │
│   BibliotecaPalavras (30x DadosPalavra)   DistribuicaoBaralho (22->100)│
│   ConfigRegras (mao, compra, troca...)    PaletaMagos (4 cores)       │
└──────────────────────────────────────────────────────────────────────┘

  Autoload unico: Sessao (jogadores escolhidos, ConfigRegras ativa, resultado)
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `DadosPalavra` | Uma palavra-senha: texto, sílabas explícitas, ilustração | `class_name DadosPalavra extends Resource` com `@export` (`texto: String`, `silabas: PackedStringArray`, `imagem: Texture2D`) |
| `BibliotecaPalavras` | As 30 palavras | Um único `.tres` com `Array[DadosPalavra]` |
| `DistribuicaoBaralho` | Sílaba -> número de cópias (22 sílabas, 100 cartas) | Um `.tres` com `Dictionary[String, int]` |
| `ConfigRegras` | Todos os parâmetros "em teste" | Um `.tres` com `@export` e `@export_range`; variantes (`regras_padrao.tres`, `regras_teste_a.tres`) |
| `Baralho` | Pilha de compra + descarte, embaralhar, reembaralhar descarte | `RefCounted`; guarda só `Array[String]` de sílabas |
| `Jogador` | Cor/identidade do mago, mão, pontos | `RefCounted` |
| `PalavraSenha` | Estado de uma senha na partida: slots, autor por slot, completa? | `RefCounted` criado a partir de `DadosPalavra` |
| `Partida` | Única porta de entrada das regras: turno, validação, pontuação, vitória; emite sinais | `RefCounted` com `signal`; recebe `ConfigRegras`, dados e RNG no construtor |
| `Sessao` (autoload) | Carrega dados entre cenas: quantos jogadores, cores, config ativa, resultado final | `Node` autoload mínimo, sem regra de jogo |
| `Mesa` | Cena da partida: cria a `Partida`, traduz toques em chamadas, traduz sinais em visual | `Control` raiz + script "controlador" |
| `CartaView`, `SlotView`, `PalavraView`, `MaoView` | Peças visuais reutilizáveis; só exibem e emitem "fui tocado" | Cenas `Control` pequenas, sem acesso à `Partida` |
| `PassagemDeVez` | "Vez do Mago Azul" entre turnos | Overlay `Control` dentro da `Mesa` (não é cena separada) |
| `Cofre` | Animação de abertura, recompensa, placar por mago, jogar de novo | Cena própria; lê o resultado em `Sessao` |

## Recommended Project Structure

```
res://
├── nucleo/                      # REGRAS PURAS - proibido Node/Control/get_tree aqui
│   ├── partida.gd               # fachada + estados do turno + sinais
│   ├── baralho.gd
│   ├── jogador.gd
│   ├── palavra_senha.gd
│   └── resultado_jogada.gd      # enum/objeto de retorno (ACEITA, SILABA_ERRADA, ...)
├── dados/
│   ├── tipos/                   # scripts de Resource (um arquivo por classe)
│   │   ├── dados_palavra.gd
│   │   ├── biblioteca_palavras.gd
│   │   ├── distribuicao_baralho.gd
│   │   └── config_regras.gd
│   ├── biblioteca_palavras.tres # 30 palavras
│   ├── baralho_padrao.tres      # 100 cartas
│   └── regras_padrao.tres       # parametros ajustaveis
├── cenas/
│   ├── menu/menu.tscn (+ .gd)
│   ├── configuracao/configuracao_jogadores.tscn
│   ├── mesa/
│   │   ├── mesa.tscn / mesa.gd          # controlador da partida
│   │   ├── painel_palavras.tscn
│   │   ├── mao_view.tscn
│   │   ├── barra_magos.tscn
│   │   └── passagem_de_vez.tscn
│   └── cofre/cofre.tscn
├── componentes/                 # pecas reutilizaveis
│   ├── carta_view.tscn / .gd
│   ├── slot_view.tscn / .gd
│   └── palavra_view.tscn / .gd
├── autoload/sessao.gd
├── tema/                        # Theme unico (fontes grandes, cores, StyleBox)
│   └── tema_infantil.tres
├── arte/                        # imagens, com LICENCAS.md ao lado
│   ├── palavras/  cartas/  magos/  cofre/
├── audio/
├── testes/                      # GUT
│   ├── unit/                    # test_baralho.gd, test_partida.gd, test_conteudo.gd
│   └── simulacao/simular_partidas.gd   # joga N partidas sem tela (balanceamento)
└── addons/gut/
```

### Structure Rationale

- **`nucleo/` separado de `cenas/`:** a fronteira vira regra de revisão simples ("nada em `nucleo/` pode estender `Node`"). É o que permite testar validação, pontuação e fim de jogo sem abrir uma cena, e permite a simulação de balanceamento que o plano de testes do projeto pede (equilíbrio da distribuição, tempo de partida).
- **`dados/tipos/` com um arquivo por Resource:** a documentação do Godot avisa que classes internas não serializam propriedades corretamente; cada Resource precisa do próprio arquivo com `class_name`.
- **`componentes/` vs `cenas/`:** telas inteiras em `cenas/`, peças instanciadas várias vezes em `componentes/`. Cada cena fica com seu script na mesma pasta (convenção comum em projetos Godot).
- **`tema/` único:** tamanho de letra e contraste para crianças de 7 a 9 anos se ajustam em um só lugar, não em cada nó.
- **`arte/LICENCAS.md`:** a restrição de registrar licenças (Kenney, OpenMoji) vira parte da estrutura.

## Architectural Patterns

### Pattern 1: Modelo puro em `RefCounted` + cena como controlador fino

**What:** todo o estado e todas as regras vivem em objetos `RefCounted` sem dependência de cena. A cena `Mesa` cria uma `Partida`, chama métodos quando o jogador toca algo e reage a sinais.
**When to use:** sempre neste projeto. Regras ainda estão "em teste" no HCD; mudá-las não pode exigir mexer em interface.
**Trade-offs:** um pouco mais de código de ligação (a view precisa refletir o modelo). Em troca: testes unitários rápidos, simulação sem tela e dois integrantes trabalhando em paralelo (um nas regras, outro nas telas) sem conflito de cena.

```gdscript
# nucleo/partida.gd
class_name Partida
extends RefCounted

signal turno_iniciado(indice_jogador: int)
signal silaba_aceita(indice_jogador: int, indice_palavra: int, indice_slot: int, silaba: String)
signal jogada_recusada(indice_jogador: int, indice_carta: int)   # feedback discreto, sem registro de erro
signal mao_alterada(indice_jogador: int)
signal palavra_completada(indice_palavra: int)
signal cofre_aberto()

enum Fase { AGUARDANDO_JOGADOR, EM_TURNO, ENCERRADA }

var fase: Fase = Fase.AGUARDANDO_JOGADOR
var jogadores: Array[Jogador] = []
var palavras: Array[PalavraSenha] = []
var jogador_atual: int = 0

func _init(config: ConfigRegras, biblioteca: BibliotecaPalavras,
		distribuicao: DistribuicaoBaralho, num_jogadores: int,
		rng: RandomNumberGenerator) -> void:
	pass  # sorteia 4 palavras, monta e embaralha o baralho, distribui as maos

func jogar_silaba(indice_carta: int, indice_palavra: int, indice_slot: int) -> ResultadoJogada.Tipo:
	return ResultadoJogada.Tipo.ACEITA  # valida, aplica, pontua, emite sinais

func comprar_carta() -> ResultadoJogada.Tipo:
	return ResultadoJogada.Tipo.ACEITA

func trocar_carta(indice_carta: int) -> ResultadoJogada.Tipo:
	return ResultadoJogada.Tipo.ACEITA

func confirmar_inicio_do_turno() -> void:
	pass  # chamado quando o proximo mago toca "Estou pronto"
```

Pontos que tornam o modelo testável:
- **RNG injetado** (`RandomNumberGenerator` com `seed` fixa nos testes); nunca `randi()` global nem `Array.shuffle()` direto dentro das regras.
- **Sem `await`, sem timers, sem tweens** no núcleo. Animação é problema da view.
- **Cartas são só `String`** (a sílaba). Não existe "objeto carta" no modelo; a `CartaView` é criada a partir da string.
- Métodos devolvem um resultado **e** emitem sinais: o teste confere o retorno, a view ouve o sinal.

### Pattern 2: "Chamada desce, sinal sobe"

**What:** pai chama método do filho; filho avisa o pai por sinal. `CartaView` emite `tocada(indice)`; `MaoView` repassa; `Mesa` decide o que isso significa e chama a `Partida`. Os componentes visuais nunca fazem `get_parent()` nem acessam a `Partida`.
**When to use:** em toda a árvore da `Mesa`.
**Trade-offs:** alguns sinais de repasse. Em troca, `CartaView` e `PalavraView` podem ser abertas e testadas sozinhas no editor (F6).

```gdscript
# cenas/mesa/mesa.gd (controlador)
var _partida: Partida
var _carta_selecionada: int = -1

func _ready() -> void:
	_partida = Sessao.criar_partida()
	_partida.silaba_aceita.connect(_ao_silaba_aceita)
	_partida.jogada_recusada.connect(_ao_jogada_recusada)
	_partida.turno_iniciado.connect(_ao_turno_iniciado)
	_partida.cofre_aberto.connect(_ao_cofre_aberto)
	%MaoView.carta_tocada.connect(_ao_carta_tocada)
	%PainelPalavras.slot_tocado.connect(_ao_slot_tocado)
	_sincronizar_tudo()

func _ao_carta_tocada(indice: int) -> void:
	_carta_selecionada = indice
	%MaoView.destacar(indice)

func _ao_slot_tocado(indice_palavra: int, indice_slot: int) -> void:
	if _carta_selecionada < 0:
		return
	_partida.jogar_silaba(_carta_selecionada, indice_palavra, indice_slot)
	_carta_selecionada = -1
```

### Pattern 3: Sinais finos para animar + `_sincronizar_tudo()` como rede de segurança

**What:** a view reage a sinais específicos (`silaba_aceita`, `palavra_completada`) para animar, mas também tem uma função que reconstrói a tela inteira a partir do estado da `Partida`. Ela é chamada no `_ready()` e a cada `turno_iniciado`.
**When to use:** na `Mesa`. Em pass-and-play a troca de turno já redesenha a mão inteira, então o custo é zero.
**Trade-offs:** dois caminhos de atualização; em compensação, um sinal esquecido não deixa a tela dessincronizada por mais de um turno.

### Pattern 4: Conteúdo e regras como `Resource` (não JSON)

**What:** palavras, distribuição do baralho e parâmetros de regra são Resources `.tres` com `@export`.
**When to use:** todo o conteúdo fixo do protótipo.
**Por que Resource e não JSON:** a ilustração entra como `Texture2D` (referência real: renomear o arquivo no editor atualiza o `.tres`, e um caminho quebrado aparece no editor em vez de em tempo de execução); os valores são tipados e editáveis no Inspector sem escrever parser; `.tres` é texto e versiona bem no Git. JSON só valeria se alguém de fora da equipe fosse editar conteúdo sem o Godot, o que não é o caso (vocabulário fechado de 30 palavras).
**Trade-offs:** `load()` devolve sempre a **mesma instância** em cache; o núcleo deve tratar esses Resources como somente leitura e copiar o que for mutável (por isso `PalavraSenha` é um objeto separado de `DadosPalavra`).

```gdscript
# dados/tipos/config_regras.gd
class_name ConfigRegras
extends Resource

@export_group("Mao")
@export_range(1, 10) var tamanho_mao: int = 5
@export var repor_mao_apos_jogada: bool = true

@export_group("Turno")
@export var pode_comprar_em_vez_de_jogar: bool = true
@export var pode_trocar_carta: bool = true
@export_range(1, 5) var cartas_por_troca: int = 1
@export var jogada_errada_encerra_turno: bool = false
@export var reembaralhar_descarte: bool = true

@export_group("Partida")
@export_range(1, 6) var quantidade_palavras: int = 4
@export_range(0, 5) var pontos_por_silaba: int = 1

@export_group("Apresentacao")
@export var mostrar_tela_de_passagem: bool = true
@export var destacar_slots_validos: bool = false
```

Os valores acima são pontos de partida, não regras decididas; o HCD deixa mão/compra/troca em aberto. **As sílabas ficam explícitas em `DadosPalavra.silabas`** (ex.: `["TA","PE","TE"]`), nunca calculadas cortando a string de dois em dois, para não amarrar o código à restrição "só CV".

### Pattern 5: Um autoload só (`Sessao`), sem EventBus global

**What:** `Sessao` guarda o que precisa sobreviver à troca de cena: número de jogadores e cores, `ConfigRegras` ativa, resultado da última partida. Também expõe `criar_partida()`.
**When to use:** passagem de dados Menu -> Configuração -> Mesa -> Cofre.
**Trade-offs:** a documentação oficial alerta que autoloads criam estado e acesso globais difíceis de depurar e recomenda usá-los para sistemas de escopo amplo que gerenciam os próprios dados. Um barramento global de eventos é exagero aqui: a própria `Partida` já é o emissor de eventos da mesa e vive apenas enquanto a cena `Mesa` existe. Se houver áudio, um segundo autoload `Audio` é aceitável. A `Partida` **não** deve ser autoload (ver Anti-Pattern 2).

### Pattern 6: Troca de cena simples entre telas, overlays dentro da mesa

**What:** quatro cenas de tela trocadas com `get_tree().change_scene_to_file()`; dentro da `Mesa`, passagem de vez e avisos são overlays `Control` mostrados/escondidos.
**When to use:** fluxo linear com poucas telas, como este.
**Trade-offs:** sem transições elaboradas entre telas (um fade pode ser adicionado depois em `Sessao`). Gerenciador de telas com pilha é desnecessário para quatro telas.

Árvore sugerida da `Mesa`:

```
Mesa (Control, Full Rect, script mesa.gd)
├── Fundo (TextureRect)
├── AreaSegura (MarginContainer, Full Rect; margens ajustadas pela safe area)
│   └── VBoxContainer
│       ├── BarraMagos (HBoxContainer)       # 1-4 magos, cor, pontos, destaque do atual
│       ├── PainelPalavras (HBox/GridContainer, expande)
│       │   └── PalavraView x4               # ilustracao em cima, SlotView x2..3 embaixo
│       └── Rodape (HBoxContainer)
│           ├── MaoView (HBoxContainer)      # CartaView x tamanho_mao
│           └── Acoes                        # botoes Comprar / Trocar (icone + texto curto)
├── CamadaAnimacao (Control, mouse_filter = IGNORE)   # carta "fantasma" que voa
└── PassagemDeVez (Control, Full Rect, oculto)        # bloqueia toques enquanto visivel
```

## Card UI: decisões

### Control, não Node2D

Use **`Control`** para cartas, slots, palavras e todo o resto. O jogo é uma interface: não há física, câmera nem mundo. `Control` dá de graça containers, âncoras, `custom_minimum_size`, `Theme`, `mouse_filter` e entrada por toque/clique sem `Area2D`. `Node2D` + `Area2D` só se justificaria para cartas livres sobre uma mesa com rotação e sobreposição, o que este jogo não tem. (Confidence: MEDIUM-HIGH; é a recomendação recorrente na comunidade para jogos de cartas "de interface" e é coerente com a documentação de múltiplas resoluções, que orienta usar âncoras e containers.)

`CartaView` pode ser uma cena com raiz `Button` (ou `PanelContainer` + `gui_input`): raiz `Button` já entrega estados pressionado/desabilitado, foco e sinal `pressed`, que funciona igual com mouse e dedo.

### Tocar-para-selecionar como interação principal; arrastar é opcional e posterior

**Recomendação: toque na carta (ela sobe e ganha contorno) -> toque no espaço da palavra.** Motivos:

1. **Público:** arrastar com precisão é mais difícil para crianças de 7 a 9 anos em tela pequena e com vários dedos em volta do aparelho; o dedo cobre o alvo. Dois toques não exigem manter pressão.
2. **Mesmo código em Android e PC:** um toque e um clique chegam como `pressed` no `Button`.
3. **Risco técnico:** o sistema nativo de drag-and-drop de `Control` (`_get_drag_data`, `_can_drop_data`, `_drop_data`, `set_drag_preview`) é documentado em termos de ponteiro do mouse; a documentação não menciona toque nesses métodos e há relatos em fórum de arrasto por toque que não funciona em alguns alvos. **Não foi verificado em aparelho Android real (LOW confidence).** Não construa o loop principal sobre isso.
4. **Erro discreto:** uma jogada recusada vira apenas a carta voltando para a mão com um balanço suave, sem som de erro, sem contador e sem mensagem pública.

Se sobrar tempo, arrastar pode ser acrescentado como **segundo caminho para a mesma chamada** (`Partida.jogar_silaba`), sem mudar o núcleo. Antes disso, fazer um teste de 30 minutos em um Android real.

### Animação de carta voando

Containers reposicionam os filhos a cada reordenação, então animar `position` de uma `CartaView` dentro de um `HBoxContainer` não funciona de forma confiável. Padrão: ao receber `silaba_aceita`, criar uma carta "fantasma" em `CamadaAnimacao`, animar com `Tween` de `global_position` da carta até `global_position` do slot, e ao final revelar o slot preenchido e liberar o fantasma. O modelo já mudou antes da animação; a view apenas bloqueia toques (`mouse_filter`/flag) enquanto anima. (Confidence: MEDIUM.)

### Autoria e pontos

`SlotView` recebe `silaba` e `cor_autor` e pinta borda/fundo com a cor do mago. Como a restrição é alto contraste e acessibilidade, a cor não deve ser o único indicador: acrescentar um pequeno ícone do mago (chapéu/estrela na cor) no canto do slot. A cor vem de `PaletaMagos`/`Jogador`, nunca fixa na cena.

## Data Flow

### Fluxo de uma jogada

```
Crianca toca carta na mao
    ↓ sinal carta_tocada(indice)
Mesa guarda selecao, MaoView destaca
    ↓
Crianca toca slot de uma palavra
    ↓ sinal slot_tocado(palavra, slot)
Mesa ──chamada──> Partida.jogar_silaba(carta, palavra, slot)
                      │ valida: fase, slot vazio, silaba == esperada
        ┌─────────────┴──────────────┐
     correta                      incorreta
        │                            │
  preenche slot, marca autor,   (estado nao muda, ou turno passa
  soma ponto, repoe mao,         conforme ConfigRegras)
  verifica palavra/vitoria           │
        │                            │
  sinais: silaba_aceita,        sinal: jogada_recusada
  mao_alterada,                      │
  [palavra_completada],              ▼
  [cofre_aberto] ou             Mesa: carta balanca e volta
  turno_iniciado(proximo)
        ▼
  Mesa: anima carta -> slot, pinta cor do mago, atualiza placar,
        mostra PassagemDeVez ou troca para a cena Cofre
```

### Máquina de estados do turno (dentro de `Partida`)

```
            confirmar_inicio_do_turno()
AGUARDANDO_JOGADOR ───────────────────────> EM_TURNO
        ▲                                      │ jogar_silaba / comprar / trocar
        │ proximo jogador                      ▼
        └────────────── turno encerrado ── (todas completas?) ── sim ──> ENCERRADA
```

Com 1 jogador ou `mostrar_tela_de_passagem = false`, a `Mesa` chama `confirmar_inicio_do_turno()` automaticamente e não mostra o overlay. A decisão de **mostrar** é da view; o **estado** é do núcleo.

### Fluxo entre telas

```
Menu ──> ConfiguracaoJogadores ──(Sessao.jogadores = [...])──> Mesa
                                                                │ cofre_aberto
                                                                ▼
Menu <──────────── "Jogar de novo" / "Sair" ──────────── Cofre (le Sessao.resultado)
```

### Key Data Flows

1. **Carga de conteúdo:** `Sessao` carrega `biblioteca_palavras.tres`, `baralho_padrao.tres` e a `ConfigRegras` ativa uma vez; passa por referência para `Partida`, que copia o necessário para o próprio estado.
2. **Intenção (desce):** View -> `Mesa` -> método da `Partida`. Nunca View -> estado diretamente.
3. **Fato (sobe):** `Partida` -> sinal -> `Mesa` -> métodos dos componentes visuais.
4. **Resultado final:** ao `cofre_aberto`, `Mesa` grava em `Sessao.resultado` (pontos por mago, autoria por sílaba) e troca de cena; `Cofre` só lê.
5. **Nada é persistido em disco.** Sem save, sem coleta de dados (restrição ética do projeto).

## Layout responsivo (celular, tablet, desktop)

Configuração conferida na documentação oficial "Multiple resolutions" (Godot 4.7):

| Configuração | Valor | Motivo |
|--------------|-------|--------|
| `display/window/size/viewport_width` x `viewport_height` | 1280 x 720 | Base recomendada pela documentação para jogos mobile em paisagem |
| `display/window/stretch/mode` | `canvas_items` | 2D renderizado na resolução do aparelho; texto das sílabas nítido |
| `display/window/stretch/aspect` | `expand` | Suporta de 4:3 (tablet) a 19,5:9 (celular) sem barras pretas |
| Orientação (`display/window/handheld/orientation`) | paisagem (sensor landscape) | Quatro palavras lado a lado + mão embaixo; grupo em volta do aparelho |

Regras de layout:

- **Só containers e âncoras** (`VBoxContainer`, `HBoxContainer`, `GridContainer`, `MarginContainer`, `AspectRatioContainer`). Nenhuma posição absoluta em tela.
- **Carta com proporção fixa 3:4** (como a carta física 6 x 8 cm) via `AspectRatioContainer` ou `custom_minimum_size`; tamanho mínimo generoso para dedos pequenos (ordem de 110 x 150 px na base 1280 x 720; ajustar em teste com aparelho real).
- **Com `expand`, o espaço extra aparece nas laterais (celular alto) ou em cima/embaixo (tablet 4:3).** O painel de palavras deve ter `size_flags` de expansão para absorver a sobra; a mão fica ancorada embaixo.
- **Área segura:** `DisplayServer.get_display_safe_area()` (implementado em Android e iOS; nos demais devolve a área útil da tela) define as margens do `MarginContainer` raiz, para furo de câmera e cantos arredondados. A documentação não informa as unidades; a conversão para coordenadas do viewport precisa ser validada em aparelho (MEDIUM).
- **Um `Theme` único** com fonte grande e de formas simples; tamanhos definidos no tema, não por nó.
- **Testar cedo em três proporções** redimensionando a janela no PC: 16:9, 4:3 e ~20:9.
- A partida com TAPETE/TOMATE tem 3 slots em vez de 2: `PalavraView` deve gerar os `SlotView` a partir de `silabas.size()`, nunca fixar dois.

## Suggested Build Order

Dependências: **Dados -> Núcleo -> Mesa mínima -> Multi-jogador -> Fluxo de telas -> Polimento**. Cada etapa termina com algo verificável.

| # | Etapa | Entrega verificável | Depende de |
|---|-------|---------------------|------------|
| 1 | **Fundação do projeto** | Projeto Godot 4.7.x criado, pastas, configurações de stretch/orientação, GUT instalado com 1 teste passando, **APK "tela vazia" rodando em um Android real** | - |
| 2 | **Dados** | Scripts de Resource + `.tres` das 30 palavras, 100 cartas e regras; teste de integridade passando (soma = 100; toda sílaba de toda palavra existe no baralho; toda palavra tem imagem) | 1 |
| 3 | **Núcleo de regras** | `Baralho`, `Jogador`, `PalavraSenha`, `Partida` com testes GUT: sorteio, distribuição, jogada certa/errada, pontuação, autoria, compra/troca, ordem de turno 1-4 jogadores, vitória | 2 |
| 4 | **Simulação sem tela** | Script que joga N partidas automáticas e imprime duração média em turnos e partidas travadas; confirma que nenhuma configuração de regras gera partida impossível | 3 |
| 5 | **Mesa mínima (1 jogador, sem arte)** | Partida completa jogável com tocar-carta -> tocar-slot, retângulos e texto; rodando em PC e Android | 3 |
| 6 | **Multi-jogador pass-and-play** | Configuração de 1-4 magos, overlay de passagem de vez, cor de autoria nos slots, placar por mago | 5 |
| 7 | **Fluxo completo de telas** | Menu -> Configuração -> Mesa -> Cofre (abertura + recompensa + placar) -> jogar de novo | 6 |
| 8 | **Apresentação infantil e responsividade** | Tema, ilustrações, cartas, animações de carta, áudio, área segura, verificação em 16:9 / 4:3 / 20:9 | 7 |
| 9 | **Ajuste de regras e builds finais** | Variantes de `ConfigRegras` testadas com adultos; APK e executável de PC finais; registro de licenças | 8 |

Implicações para o roteiro:

- **Etapas 2-4 não dependem de nenhuma tela**; uma pessoa pode fazê-las enquanto a outra adianta `CartaView`/`PalavraView`/tema com dados falsos. As duas frentes se encontram na etapa 5.
- **Exportação Android na etapa 1, não no fim.** Configurar SDK/keystore e descobrir problemas de toque e de tela costuma consumir tempo imprevisível; o prazo é dezembro.
- **Etapa 4 antes da interface** porque o risco de regra é real: há sete sílabas com apenas 2 cópias (CO, PE, PI, PO, SI, SO, TU). Dependendo de como descarte e troca funcionarem, uma cópia pode ficar inacessível e a senha ficar impossível. O núcleo precisa garantir (e a simulação comprovar) que toda sílaba necessária continua alcançável, por exemplo reembaralhando o descarte.
- **Etapa 5 é o marco do "Core Value"**: a partir dela existe partida completa; tudo depois é incremento.
- A etapa 8 é a mais elástica; se o prazo apertar, é onde cortar (animações e áudio antes de legibilidade e área segura).

## Scaling Considerations

Não há usuários simultâneos nem servidor. O que "escala" aqui é conteúdo e variedade de aparelho.

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Protótipo (30 palavras, 4 senhas, 1-4 jogadores) | Arquitetura acima sem alterações; tudo em memória |
| Mais conteúdo (100+ palavras, sílabas CVC/dígrafos) | Só dados: novas entradas em `BibliotecaPalavras` e `DistribuicaoBaralho`. Funciona porque as sílabas são explícitas. Com muitas imagens, carregar só as 4 ilustrações sorteadas |
| Evoluções futuras (habilidades por mago, rede) | Habilidades entram como dados em `Jogador` + ganchos na `Partida`. Rede exigiria trocar chamadas diretas por comandos serializáveis; o núcleo puro facilita, mas está fora de escopo |

### Scaling Priorities

1. **Primeiro gargalo: espaço de tela em celulares pequenos.** Quatro palavras ilustradas + mão + placar em ~6 polegadas. Mitigar com layout por containers, ilustrações que encolhem antes do texto e tamanho de mão parametrizado.
2. **Segundo gargalo: tamanho do APK e memória de texturas** se as ilustrações forem grandes. Padronizar resolução das imagens (ex.: 512 px) ao importar.

## Anti-Patterns

### Anti-Pattern 1: Regras dentro dos scripts das cartas

**What people do:** `carta.gd` verifica no `_gui_input` se a sílaba combina com o slot, soma ponto e troca o turno.
**Why it's wrong:** a regra fica espalhada por nós visuais, não dá para testar sem montar a cena e cada ajuste de regra (que o projeto prevê fazer durante os testes) vira mudança de interface.
**Do this instead:** `CartaView` só emite `tocada`. Toda decisão passa por `Partida`.

### Anti-Pattern 2: `Partida` (estado do jogo) como autoload global

**What people do:** um singleton `GameManager` com baralho, mãos e turno, acessado de qualquer script.
**Why it's wrong:** estado sobrevive entre partidas ("jogar de novo" começa sujo), qualquer nó pode alterar qualquer coisa, e os testes passam a depender de ordem. A documentação oficial lista exatamente esses problemas de estado e acesso globais.
**Do this instead:** `Partida` é criada pela cena `Mesa` e descartada com ela. O autoload `Sessao` guarda apenas a configuração e o resultado.

### Anti-Pattern 3: A árvore de cena como fonte da verdade

**What people do:** descobrir a mão do jogador com `mao_container.get_children()` ou saber se a palavra está completa lendo `Label.text`.
**Why it's wrong:** durante animações a árvore está em estado intermediário; a lógica passa a depender do tempo da animação.
**Do this instead:** o modelo muda de forma instantânea e síncrona; a view anima depois e pode ser reconstruída do zero com `_sincronizar_tudo()`.

### Anti-Pattern 4: Posições absolutas e tamanho fixo de tela

**What people do:** montar a mesa em 1280 x 720 arrastando nós para posições fixas.
**Why it's wrong:** quebra em tablet 4:3 e em celular 20:9; com `expand` sobram áreas vazias ou elementos cortados.
**Do this instead:** containers + âncoras desde a primeira versão da `Mesa`, mesmo na fase de retângulos cinza.

### Anti-Pattern 5: Parâmetros de regra como constantes no código

**What people do:** `const TAMANHO_MAO = 5` dentro de `partida.gd`.
**Why it's wrong:** o requisito pede regras ajustáveis durante os testes; cada ajuste exigiria editar código e comparar variantes seria difícil.
**Do this instead:** `ConfigRegras` como Resource, passada no construtor da `Partida`; variantes em arquivos `.tres` separados, e os testes unitários rodam com configs diferentes.

### Anti-Pattern 6: Modificar Resources carregados

**What people do:** marcar `dados_palavra.preenchida = true` no próprio Resource.
**Why it's wrong:** `load()` devolve a mesma instância em cache; a alteração vaza para a próxima partida (e, no editor, pode ser salva no arquivo).
**Do this instead:** Resources são somente leitura; estado mutável vive em `PalavraSenha`, `Jogador`, `Baralho`.

### Anti-Pattern 7: Registrar ou exibir erros

**What people do:** contador de erros por jogador, som de buzina, "X" vermelho.
**Why it's wrong:** viola a restrição do projeto (sem exposição pública de erro, sem coleta de dados de crianças).
**Do this instead:** `jogada_recusada` não altera nenhuma estatística; a view dá um retorno neutro e breve.

## Integration Points

### External Services

Nenhum serviço externo: sem rede, sem contas, sem analytics, sem persistência.

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Exportação Android | Preset de exportação + SDK/keystore | Fazer na etapa 1; validar toque, orientação e área segura em aparelho real |
| Exportação PC | Preset desktop | Janela redimensionável serve de bancada para testar proporções |
| GUT (testes) | Addon em `addons/gut`, testes em `testes/` | GUT 9.7.1 é a versão indicada pelo repositório para Godot 4.7.x; versões do GUT acompanham a versão menor do Godot, então fixar a versão do motor primeiro |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Componentes visuais <-> `Mesa` | Sinais para cima, métodos para baixo | Componentes não conhecem `Partida` |
| `Mesa` <-> `Partida` | Métodos (intenções) e sinais (fatos) | Única fronteira entre apresentação e regras |
| `Partida` <-> Dados | Leitura de Resources recebidos no construtor | Nunca `load()` dentro do núcleo; facilita testes com dados pequenos |
| Cenas de tela <-> `Sessao` | Propriedades simples | Só configuração e resultado; nenhuma regra |
| Testes/simulação <-> `Partida` | Mesma API pública que a `Mesa` usa | Se o teste precisa de algo que a API não oferece, a API está incompleta |

## Open Questions (para pesquisa de fase)

- **Arrastar por toque no Android com o drag-and-drop nativo de `Control`:** não confirmado. Só importa se a equipe quiser arrastar; verificar em aparelho antes de planejar.
- **Unidades de `get_display_safe_area()`** e conversão para o viewport com `canvas_items` + `expand`: validar em aparelho com furo de câmera.
- **Regras de mão/compra/troca e garantia de partida sempre solucionável:** decisão de design, não de arquitetura; a simulação da etapa 4 é a ferramenta para decidir.
- **A mão dos outros magos fica visível?** O jogo é cooperativo; mostrar só a mão do mago da vez economiza tela, mas mostrar todas pode favorecer a cooperação. A arquitetura suporta ambos (é decisão da view).
- **Botão "voltar" do Android e pausa do app durante a partida:** comportamento a definir na etapa 7.

## Sources

- Godot Docs 4.7, Multiple resolutions (base 1280x720, `canvas_items`, `expand`, âncoras/containers): https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html — HIGH
- Godot Docs 4.7, Autoloads versus regular nodes (riscos de estado global; alternativas com Resource e `static`): https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_regular_nodes.html — HIGH
- Godot Docs 4.7, Resources (Resource customizado, `.tres`, cache de `load()`, limitação de classes internas): https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html — HIGH
- Godot Docs 4.7, classe Control (`_get_drag_data`, `_can_drop_data`, `_drop_data`, `set_drag_preview`, `mouse_filter`, `custom_minimum_size`): https://docs.godotengine.org/en/stable/classes/class_control.html — HIGH para a API; a página não trata de toque
- Godot Docs 4.7, classe DisplayServer (`get_display_safe_area`, `get_display_cutouts`): https://docs.godotengine.org/en/stable/classes/class_displayserver.html — HIGH para existência/plataformas; unidades não documentadas
- Godot Docs 4.7, InputEvent (ordem de propagação; GUI antes de `_unhandled_input`): https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html — HIGH
- Página de download do Godot (4.7.2 estável, 18/08/2026): https://godotengine.org/download/windows/ — HIGH
- GUT, tabela de compatibilidade (9.7.1 para Godot 4.7.x): https://github.com/bitwes/Gut — HIGH
- Fórum Godot, organização de jogo de cartas 2D e mão de cartas com Control: https://forum.godotengine.org/t/2d-card-game-setup-question/104131 e https://forum.godotengine.org/t/how-do-i-design-a-hand-of-cards-a-row-of-cards-where-cards-can-be-clicked-dragged-and-reordered-includes-video-and-demo-project/62716 — MEDIUM (comunidade)
- Tutorial comunitário sobre lógica de baralho em `RefCounted` separada da interface: https://bjamba.github.io/teach-me-engineering/learn-godot/module-04-card-word-puzzle/lesson-01-deck-mechanics.html — LOW-MEDIUM (fonte única, coerente com a prática geral)
- Relatos de fórum sobre arrasto por toque e drag ligado ao botão do mouse: https://forum.godotengine.org/t/trying-to-get-touch-working-on-android-mobile-chrome-with-standard-desktop-html5-build-function-qr-code-provided/136354 e https://forum.godotengine.org/t/clicking-and-dragging-a-control-node/75511 — LOW (não reproduzido)

---
*Architecture research for: jogo de cartas cooperativo 2D em Godot (Cofre Mágico)*
*Researched: 2026-11-11*
