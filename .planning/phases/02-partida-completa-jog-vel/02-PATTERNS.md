# Fase 2: Partida completa jogável - Mapa de padrões

**Mapeado em:** 2026-11-17
**Arquivos analisados:** 27 (novos/modificados)
**Análogos encontrados:** 14 / 27 (os demais são de apresentação sem precedente: ver "Sem análogo")

Observação: o repositório só tem uma cena (`cenas/inicial/`) e código de núcleo/dados/testes. Para cenas e scripts de UI o único análogo direto é `cenas/inicial/`; para classes puras (`Magos`, fluxo) o análogo é o núcleo (`nucleo/*.gd`); para testes, `testes/unit/*`. Código de Tween, container responsivo, Theme, autoload e `_draw()` não existe no repositório: usar RESEARCH.md (Padrões 1-9), referenciado abaixo.

## Classificação dos arquivos

| Arquivo novo/modificado | Papel | Fluxo de dados | Análogo mais próximo | Qualidade |
|-------------------------|-------|----------------|----------------------|-----------|
| `sessao.gd` (autoload `Sessao`) | provider/store | request-response (estado entre cenas) | `simulador/simulacao.gd` (carrega `.tres`, monta `Partida`) + RESEARCH Padrão 1 | parcial |
| `cenas/comum/magos.gd` | utilitário (dados estáticos) | transform | `nucleo/resultado_jogada.gd` (enum) + `nucleo/jogador.gd` (RefCounted) | papel |
| `cenas/comum/simbolo_mago.gd` | componente | `_draw()` | nenhum | sem análogo |
| `cenas/comum/icones_ponto.gd` | componente | `_draw()`/filhos | nenhum | sem análogo |
| `cenas/comum/senha_visual.gd/.tscn` | componente | request-response | `cenas/inicial/inicial.gd/.tscn` (script + `@onready`) | papel |
| `cenas/menu/menu.gd/.tscn` | cena | request-response | `cenas/inicial/inicial.gd/.tscn` | exato |
| `cenas/selecao/selecao.gd/.tscn` | cena | request-response | `cenas/inicial/inicial.gd/.tscn` | exato |
| `cenas/mesa/mesa.gd/.tscn` | cena | event-driven + CRUD sobre `Partida` | `cenas/inicial/inicial.gd` (botão → ação → atualizar rótulo) + `testes/unit/test_partida_turnos.gd` (uso da API) | papel |
| `cenas/mesa/faixa_vez.tscn` | componente | event-driven | `cenas/inicial/inicial.tscn` | papel |
| `cenas/mesa/painel_pausa.tscn` | componente | event-driven | `cenas/inicial/inicial.tscn` | papel |
| `cenas/cofre/cofre.gd/.tscn` | cena | event-driven (Tween) | `cenas/inicial/inicial.gd` | papel |
| `cenas/final/final.gd/.tscn` | cena | request-response | `cenas/inicial/inicial.gd` | papel |
| lógica de fluxo `RefCounted` (próxima etapa após `ResultadoJogada`) | utilitário | transform | `nucleo/resultado_jogada.gd`, `nucleo/palavra_senha.gd` | papel |
| `tema/tema_cofre.tres` + `ferramentas/gerar_tema.gd` | config | transform | nenhum (`dados/*.tres` é só estilo de arquivo `.tres`) | sem análogo |
| `fontes/*.ttf`, `fontes/OFL.txt`, `CREDITOS.md` (modificar) | config/asset | file-I/O | linha existente em `CREDITOS.md` | exato |
| `project.godot` (modificar) | config | — | o próprio arquivo | exato |
| `testes/unit/test_magos.gd` | teste | request-response | `testes/unit/test_partida_turnos.gd` | exato |
| `testes/unit/test_sessao.gd` | teste | request-response | `testes/unit/test_partida_turnos.gd` | exato |
| `testes/unit/test_fluxo_cenas.gd` (fumaça de cenas) | teste | request-response | `testes/unit/test_inicial.gd` | exato |
| remover `cenas/inicial/*` e `testes/unit/test_inicial.gd` | — | — | — | — |

## Atribuição de padrões

### `cenas/menu/menu.gd`, `selecao.gd`, `final.gd`, `cofre.gd`, `mesa.gd` (cenas)

**Análogo:** `cenas/inicial/inicial.gd` e `inicial.tscn`

**Estilo do script** (inicial.gd linhas 1-12): tabs, tipado, `@onready` com caminho de nó, conexão de `pressed` em `_ready`:
```gdscript
extends Control

var _contador: int = 0

@onready var _rotulo_mao: Label = $Centro/Caixa/RotuloMao
@onready var _botao: Button = $Centro/Caixa/BotaoTocar

func _ready() -> void:
	_botao.pressed.connect(_ao_tocar)
```
Funções privadas com prefixo `_`; handlers `_ao_*`. Valores de regra vêm de recurso, nunca de constante (inicial.gd 13-19):
```gdscript
var base: ConfigRegras = load("res://dados/regras_padrao.tres") as ConfigRegras
if base == null:
	push_error("regras_padrao.tres ausente ou invalido")
	return
var regras: ConfigRegras = base.duplicate() as ConfigRegras
regras.normalizar()
```
Na fase 2 usar `Sessao.partida.cfg` (já duplicado e normalizado pela `Partida`) em vez de reler o `.tres`.

**Estrutura da cena `.tscn`** (inicial.tscn 1-41): raiz `Control` FULL_RECT, `CenterContainer`, `VBoxContainer`, `Button` com `custom_minimum_size`:
```
[node name="Inicial" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_ini")

[node name="BotaoTocar" type="Button" parent="Centro/Caixa"]
custom_minimum_size = Vector2(320, 120)
layout_mode = 2
```
Divergência obrigatória: o análogo usa `theme_override_font_sizes/font_size` e `theme_override_constants/separation`. Na fase 2 usar `theme_type_variation` do `Theme` global (RESEARCH Padrão 6) para fontes/botões; `separation` de containers pode continuar como override (é espaçamento, não estilo). Adicionar `focus_mode = 0` em todos os botões (RESEARCH Padrão 7).

**Sem análogo no repositório** (usar RESEARCH): troca de cena via `Sessao.ir_para`, `ao_voltar()`, Tween, overlay `mouse_filter`, estados `_ocupado/_selecionada`.

### `cenas/mesa/mesa.gd` (ponto central: chamada ao núcleo)

**Análogo de uso da API:** `testes/unit/test_partida_turnos.gd` e `simulador/simulacao.gd`.

**Construção de `Partida`** (test_partida_turnos.gd 1-18), para `Sessao.nova_partida()`:
```gdscript
_bib = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
_dist = load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
_cfg = ConfigRegras.new()
...
var r := RandomNumberGenerator.new()
r.seed = semente
return Partida.new(_cfg, _bib, _dist, n_magos, r)
```
Na `Sessao`, `cfg` vem de `load("res://dados/regras_padrao.tres")`; `rng.seed` só se `cfg.semente > 0`, senão `rng.randomize()` (RESEARCH Padrão 1).

**API do núcleo a consumir** (`nucleo/partida.gd`):
- `jogar_silaba(indice_carta, palavra, espaco) -> ResultadoJogada.Tipo` (linhas 190-220). ACERTO já removeu a carta, repôs a mão, e pode já ter chamado `_passar_a_vez()` (213-214); ERRO passa a vez (218-219); no acerto final emite `cofre_aberto` e NÃO passa a vez.
- `trocar_mao()` (223-250) passa a vez ao final.
- `existe_jogada()` (161-169) para MESA-07; `concluida()` (145-149).
- `jogadores[jogador_atual].mao: Array[String]`, `.pontos: int` (jogador.gd 5-7).
- `palavras[i].dados.texto/.silabas/.imagem` (dados_palavra.gd), `palavras[i].preenchido_por[e]` = índice do núcleo (0..n-1) ou -1 (palavra_senha.gd 1-6, 20-21), `espaco_aberto(e)`, `total_espacos()`, `silaba(e)`.
- `Partida.cfg.mostrar_palavra_escrita` (config_regras.gd) para MESA-02.

**Armadilha a copiar do RESEARCH (Padrão 3):** fotografar `jogador_atual`, nó da carta e autor ANTES de `jogar_silaba`; não ligar a UI aos sinais do núcleo; não comparar sílaba na UI.
```gdscript
var autor_indice := _partida.jogador_atual          # ANTES da chamada
var carta_ctrl: Control = _cartas[_selecionada]      # ANTES
var res := _partida.jogar_silaba(_selecionada, p, e)
match res:
	ResultadoJogada.Tipo.ACERTO: ...
	ResultadoJogada.Tipo.ERRO: ...
```
O `match` sobre `ResultadoJogada.Tipo` também aparece no núcleo (enum em `nucleo/resultado_jogada.gd` linhas 1-5).

### `cenas/comum/magos.gd` (utilitário estático)

**Análogo:** `nucleo/resultado_jogada.gd` (class_name + RefCounted + enum) e `nucleo/jogador.gd`.
```gdscript
class_name ResultadoJogada
extends RefCounted
## Resultado de uma acao do mago sobre a Partida.

enum Tipo { ACERTO, ERRO, TROCOU, INVALIDO }
```
Copiar o cabeçalho (`class_name X` / `extends RefCounted` / comentário `##` sem acento) e usar `const` + `static func` conforme RESEARCH Padrão 2. Cor/símbolo/nome de mago vivem só aqui (não em `ConfigRegras`: não são regra). Comentários do núcleo estão sem acentos; manter esse estilo em `##`.

### Lógica de fluxo `RefCounted` (próxima etapa após jogada)

**Análogo:** `nucleo/palavra_senha.gd` (classe pequena, métodos curtos, sem Node).
```gdscript
class_name PalavraSenha
extends RefCounted
var dados: DadosPalavra
var preenchido_por: Array[int] = []
func _init(d: DadosPalavra) -> void:
	dados = d
	for k in range(d.silabas.size()):
		preenchido_por.append(-1)
```
Proibido: Node, `await`, Timer, `shuffle()` global. Se colocada em `cenas/comum/`, manter as mesmas regras para ser testável sem árvore.

### `sessao.gd` (autoload `Sessao`)

**Análogo parcial:** `simulador/simulacao.gd` (consumidor da API pública; duplicar cfg antes de usar):
```gdscript
cfg = cfg.duplicate() as ConfigRegras
cfg.normalizar()
```
Resto (autoload, `change_scene_to_file`, `_notification` do voltar, `_unhandled_input`) sem análogo: copiar RESEARCH Padrão 1. Sem `class_name Sessao` (conflito com autoload). Registrar em `project.godot` `[autoload] Sessao="*res://sessao.gd"`.

### `project.godot` (modificar)

Estado atual (linhas 9-13, 15-21, 26-29): `run/main_scene="res://cenas/inicial/inicial.tscn"`, `[display]` já com 1280x720/`canvas_items`/`expand`/`orientation=4`. Alterações:
```ini
[application]
run/main_scene="res://cenas/menu/menu.tscn"
config/quit_on_go_back=false

[autoload]
Sessao="*res://sessao.gd"

[gui]
theme/custom="res://tema/tema_cofre.tres"
```
Manter seções existentes e a ordem alfabética do arquivo (editor regrava). O arquivo já está modificado no working tree (`git status`): verificar `git diff project.godot` antes de editar.

### `testes/unit/test_magos.gd`, `test_sessao.gd` (lógica sem Node)

**Análogo:** `testes/unit/test_partida_turnos.gd` (linhas 1-18):
```gdscript
extends GutTest

var _bib: BibliotecaPalavras
var _dist: DistribuicaoBaralho
var _cfg: ConfigRegras

func before_each() -> void:
	_bib = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	...
func _nova(semente: int, n_magos: int = 2) -> Partida:
	var r := RandomNumberGenerator.new()
	r.seed = semente
	return Partida.new(_cfg, _bib, _dist, n_magos, r)
```
Helpers `_dar_carta` (linhas 40+) forçam uma sílaba na mão; reaproveitar a ideia para provocar ACERTO/ERRO determinísticos nos testes de fluxo. Nomes `test_*`, uma responsabilidade por teste, comentários `##` sem acento.

### `testes/unit/test_fluxo_cenas.gd` (fumaça de cena)

**Análogo exato:** `testes/unit/test_inicial.gd` (linhas 1-9):
```gdscript
extends GutTest

func test_botao_conta_toques() -> void:
	var cena: Control = load("res://cenas/inicial/inicial.tscn").instantiate()
	add_child_autofree(cena)
	var botao: Button = cena.get_node("Centro/Caixa/BotaoTocar")
	botao.pressed.emit()
	assert_eq(rotulo.text, "Toques: 2")
```
Padrão: `load(...).instantiate()` + `add_child_autofree` + `get_node` por caminho + `pressed.emit()` (simula toque sem input). Para a mesa: setar `Sessao.magos_ativos` e `Sessao.nova_partida()` antes de instanciar, `await wait_frames(2)`. O `Sessao` autoload está disponível em testes headless via `-s gut_cmdln.gd` (autoloads do `project.godot` são carregados); confirmar na execução. Teste não deve chamar `Sessao.ir_para` sem necessidade (troca a cena atual do runner).

### `CREDITOS.md` + `fontes/` (asset)

**Análogo:** linhas da tabela em `CREDITOS.md` (colunas `Caminho | Autor | URL | Licença | Data | Modificado`):
```
| arte/provisoria/placeholder_palavra.svg | Equipe Cofre Mágico | (autoria própria) | CC0 | 2026-11-17 | não |
```
Acrescentar linhas para `fontes/Andika-Regular.ttf`, `fontes/Andika-Bold.ttf` (SIL International / Andika Project, URL raw do google/fonts, SIL OFL 1.1, 2026-11-17, não) no mesmo commit do download. `fontes/OFL.txt` fica junto.

## Padrões compartilhados

### Convenções de estilo (todos os `.gd` novos)
**Fonte:** todo o repositório (`nucleo/*.gd`, `cenas/inicial/inicial.gd`)
- Indentação com tabs; GDScript tipado (`var x: int`, `-> void`); identificadores em português sem acento; arquivos minúsculas_com_underscore.
- Cada `.gd` novo gera `.gd.uid` (commitar, como os existentes).
- `class_name` só em classes reutilizáveis sem Node-singleton (`Magos`); nunca em autoload.

### Núcleo intocado
**Fonte:** `nucleo/partida.gd`. A UI só chama `jogar_silaba`, `trocar_mao`, `existe_jogada`, `concluida` e lê estado. Nenhum arquivo de `nucleo/` ou `dados/` é modificado nesta fase.

### Dados carregados de `.tres`
**Fonte:** `cenas/inicial/inicial.gd` 13-19 e `testes/unit/test_partida_turnos.gd` 10-13. `load(...) as Tipo`, checar `null`, `push_error`, duplicar/normalizar quando for mexer.

### Container/Layout (cenas)
**Fonte:** `cenas/inicial/inicial.tscn` (raiz FULL_RECT + `CenterContainer` + `VBoxContainer`); estender conforme RESEARCH Padrão 5 (`MarginContainer` 32, `ColorRect` de fundo, `TextureRect` com `EXPAND_IGNORE_SIZE`, `Label` com `clip_text`). Nunca posicionamento absoluto.

### Execução de testes
**Fonte:** `testes/rodar.ps1`. `$env:GODOT_BIN` aponta para `C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe`; roda `--import` e depois GUT com `-gdir=res://testes/unit -ginclude_subdirs`. Novos testes em `testes/unit/test_*.gd` são descobertos automaticamente. Novas fontes/cenas exigem o `--import` que o script já faz.

## Sem análogo encontrado

O planejador deve usar RESEARCH.md (seção indicada):

| Arquivo | Papel | Fluxo | Motivo / onde buscar |
|---------|-------|-------|----------------------|
| `sessao.gd` (parte de cena/voltar) | autoload | event-driven | Nenhum autoload existe; RESEARCH Padrão 1 |
| `cenas/comum/simbolo_mago.gd`, `icones_ponto.gd` | componente | `_draw()` | Sem desenho custom; RESEARCH Padrão 8 |
| Tween (voo/volta da carta, pulso do botão, cofre) em `mesa.gd`, `cofre.gd` | animação | event-driven | Sem Tween no repo; RESEARCH Padrões 3, 4, 9 e exemplos (fantasma em overlay, nunca Tween em filho de container) |
| `tema/tema_cofre.tres`, `ferramentas/gerar_tema.gd` | config/script `extends SceneTree` | transform | Sem Theme; RESEARCH Padrão 6. Único script headless análogo em estilo: `simulador/simular.gd` (ponto de entrada por linha de comando) |
| `cenas/mesa/faixa_vez.tscn`, `painel_pausa.tscn` | overlay | event-driven | Sem overlays; RESEARCH Padrão 7 (`mouse_filter=STOP`, `Button` flat de tela cheia) |
| `CPUParticles2D` do cofre | efeito | — | RESEARCH Padrão 9 |

## Pendências para o planejador

- Remover `cenas/inicial/` (inclui `.uid`) e `testes/unit/test_inicial.gd` no mesmo plano que troca `run/main_scene` (Armadilha 7); atualizar `README`/`CREDITOS.md` se citarem a cena.
- O texto "Heading 48px nos espaços" do RESEARCH contradiz o UI-SPEC e deve ser reconciliado antes da execução.
- `config_regras.gd` linha 14 diz que `mostrar_palavra_escrita` "ainda não é lido por nenhum código": atualizar o comentário (é uma modificação de comentário em `dados/tipos/`, única exceção possível ao "núcleo/dados intocados").
- `export_presets.cfg` já exclui `testes/*`, `simulador/*`, `addons/gut/*`; não excluir `fontes/`, `tema/`, `dados/`.

## Metadados

**Escopo da busca de análogos:** `nucleo/`, `dados/`, `simulador/`, `testes/`, `cenas/`, `project.godot`, `CREDITOS.md`
**Arquivos lidos:** 14
**Data da extração:** 2026-11-17
