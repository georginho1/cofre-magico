# Fase 2: Partida completa jogável - Pesquisa

**Pesquisado em:** 2026-11-17
**Domínio:** camada de apresentação Godot 4.7.2 (Control/containers, Theme, Tween, toque, fluxo de cenas) sobre o núcleo da Fase 1
**Confiança:** HIGH para API do núcleo e propriedades do motor (verificadas no binário 4.7.2 local); MEDIUM para o comportamento do botão voltar no aparelho (precisa de teste no Android real)

<user_constraints>
## User Constraints (de 02-CONTEXT.md)

### Decisões travadas
Regras herdadas da Fase 1 (não mudar): mão de 5, uma sílaba por turno, erro passa a vez (`erro_passa_a_vez=true`), troca da mão inteira encerra o turno e é permitida mesmo com jogada, sempre 4 senhas, valores em `dados/regras_padrao.tres`.

- **D-01:** Passagem de vez com faixa de tela "Vez do Mago X" (cor + símbolo do mago) e toque para começar; a mão do novo mago só aparece depois desse toque. As senhas continuam visíveis atrás/ao redor da faixa. Não é tela de privacidade.
- **D-02:** Ao selecionar uma carta, todos os espaços ainda abertos ficam destacados, sem indicar qual é o certo.
- **D-03:** Sílaba errada: a carta volta suavemente para a mão (Tween), sem X, vermelho, tremida, som ou texto de erro; em seguida vem a mesma passagem de vez de D-01, idêntica à de um acerto ou de uma troca.
- **D-04:** Seleção livre: tocar em outra carta troca a seleção; tocar na carta selecionada desmarca. Nada conta como jogada até tocar num espaço aberto. Tocar num espaço sem carta selecionada não faz nada.
- **D-05:** Identidade fixa dos magos (cor + símbolo): vermelho = sol, azul = lua, verde = folha, amarelo = estrela.
- **D-06:** Seleção com os 4 magos apagados; tocar acende/apaga. "Começar" só ativo com pelo menos 1 mago aceso. Sem digitar nomes.
- **D-07:** Ordem dos turnos fixa pela ordem das cores (vermelho → azul → verde → amarelo), pulando os inativos. O primeiro mago aceso nessa ordem começa.
- **D-08:** "Jogar de novo" inicia nova partida com os mesmos magos (novas senhas), sem passar pela seleção.
- **D-09:** 4 senhas em linha única em cima, mão do mago da vez embaixo, botão comprar/trocar sempre visível. Em 4:3 as senhas encolhem; nada pode ser cortado.
- **D-10:** Pontos simbólicos só para o mago da vez, no indicador de turno. Sem painel com todos lado a lado durante a partida.
- **D-11:** Ponto = ícones repetidos (um por sílaba, na cor do mago), sem número.
- **D-12:** Placeholder único (`arte/provisoria/placeholder_palavra.svg`) com o nome da palavra em texto dentro da área da ilustração. Separado da "palavra escrita" do MESA-02, que obedece a `mostrar_palavra_escrita`. O rótulo sai na Fase 3.
- **D-13:** Sílaba aceita fica no espaço com cor e símbolo do mago autor (MESA-05), até a tela final.
- **D-14:** Ao completar a última senha: tela do cofre (retângulo/porta) abre com Tween, brilho/confete nas cores dos magos ativos e "O cofre abriu!". Um toque leva à tela final.
- **D-15:** Tela final: 4 senhas completas com sílabas na cor/símbolo do autor; abaixo, magos ativos na ordem fixa das cores com ícones de ponto. Mago com 0 sílabas aparece igual. Mensagem coletiva, sem vencedor nem ordenação. Botões: "Jogar de novo" e voltar ao menu.
- **D-16:** Botão de pausa pequeno num canto da mesa abre painel "Continuar"/"Sair da partida" (sair pede confirmação, volta ao menu). Voltar do Android (e Esc no PC) abre o mesmo painel durante a partida. No menu, voltar fecha o jogo; na seleção, volta ao menu.
- **D-17:** Menu inicial com um botão grande "Jogar". Créditos e mudo ficam para a Fase 3.

### Discrição do Claude
- Forma do destaque do botão comprar/trocar quando `existe_jogada()` é falso (sem parecer erro).
- Feedback do acerto (encaixe com Tween, breve brilho) antes da faixa de vez.
- Estrutura de cenas, nomes de nós, autoload/gerente de cenas e mapeamento índice do núcleo → mago/cor.
- Detalhes visuais (paleta, fonte, tamanhos, espaçamentos), dentro de MESA-08/MESA-09 e alvos ≥ ~96 px.
- Desenho provisório dos símbolos (formas simples ou caracteres, legíveis).

### Ideias adiadas (FORA DO ESCOPO)
- Opção "Trocar magos" na tela final.
- Emojis OpenMoji como imagens provisórias (Fase 3).
- Também fora: ilustrações definitivas, créditos, áudio (Fase 3); arrastar e soltar, "como jogar", dica, painel do adulto (v2).
</user_constraints>

<phase_requirements>
## Requisitos da fase

| ID | Descrição | Suporte da pesquisa |
|----|-----------|---------------------|
| PART-01 | Escolher 1 a 4 magos tocando, sem nomes | Seção "Fluxo de cenas e estado" (Sessao.magos_ativos), botões-mago com `toggle_mode` |
| MESA-01 | 4 senhas com ilustração grande e um espaço por sílaba | Geometria resolvida; `TextureRect` com `EXPAND_IGNORE_SIZE`; 28 palavras de 2 sílabas e 2 de 3 |
| MESA-02 | Palavra escrita conforme config | Ler `Partida.cfg.mostrar_palavra_escrita` (cópia normalizada) |
| MESA-03 | Só a mão do mago da vez, indicador claro | `jogadores[jogador_atual].mao`; faixa de vez; Magos.gd mapeia índice → mago |
| MESA-04 | Dois toques | Máquina de estados da mesa; `Button` (`pressed` dispara no soltar) |
| MESA-05 | Sílaba marcada com cor/símbolo do autor | `PalavraSenha.preenchido_por[e]` dá o índice do autor |
| MESA-06 | Pontos simbólicos sem ranking | `Jogador.pontos` só do mago da vez, ícones repetidos |
| MESA-07 | Botão trocar sempre visível, destacado sem jogada | `Partida.existe_jogada()` no início de cada turno visível; Tween em loop |
| MESA-08 | Sem cortes em 16:9, 20:9, 4:3 | Orçamento de tamanho mínimo e containers (seção Layout) |
| MESA-09 | Maiúsculas grandes, sem serifa, alto contraste | Andika Bold; medição de largura; sílabas na mão a 72px |
| COFR-01 | Cofre abre com celebração coletiva | `cenas/cofre`, Tween + `CPUParticles2D` |
| COFR-02 | Tela final com contribuições | Dados de `Sessao.partida` preservados entre cenas |
| COFR-03 | Nova partida a partir dali | `Sessao.nova_partida()` + recarregar a mesa |
| COFR-04 | Menu inicial com "Jogar" | Cena `menu`; troca do `run/main_scene` |
| COFR-05 | Pausa/saída com confirmação; voltar do Android | `quit_on_go_back=false` + `NOTIFICATION_WM_GO_BACK_REQUEST` no autoload |
</phase_requirements>

## Resumo

A Fase 2 é só apresentação: nenhuma regra nova. O núcleo da Fase 1 já entrega tudo de que a mesa precisa (`Partida.jogar_silaba`, `trocar_mao`, `existe_jogada`, `concluida`, `preenchido_por`, `pontos`). A pilha é a do CLAUDE.md: `Control` + containers + `Theme` + `Tween`, sem addons. Os pontos de risco não são de motor, são de integração: (1) o núcleo já avança o turno e repõe a mão **dentro** de `jogar_silaba`, então a interface precisa fotografar o estado antes da chamada; (2) `Tween` sobre filhos de `Container` é sobrescrito pelo re-layout, o que exige animar uma cópia "fantasma" numa camada de sobreposição; (3) as medidas do UI-SPEC não fecham (sílaba de 72px não cabe nos espaços de 92px).

Medi a Andika Bold 4.x baixada do repositório google/fonts: a sílaba mais larga do vocabulário ("MO") tem **118 px de avanço a 72 px**. Logo nenhum espaço que caiba 3 por senha de 296px (máx. 93px) comporta 72px. Resolução recomendada: **72px só nas cartas da mão (144px de largura, folga ampla); nos espaços de sílaba (mesa e final) usar o tamanho Heading 48px Bold** (MO = 79px em 92px). Não cria um quinto tamanho de fonte.

**Recomendação principal:** um autoload `Sessao` (dados + troca de cenas + botão voltar), cenas `menu`, `selecao`, `mesa`, `cofre`, `final` com um `Theme` global configurado em `gui/theme/custom`, e uma classe estática `Magos` com cor/símbolo/ordem; a lógica de mapeamento e de fluxo em `RefCounted` testável com GUT, as cenas só com testes de fumaça.

## Mapa de responsabilidade arquitetural

| Capacidade | Tier primário | Tier secundário | Justificativa |
|------------|---------------|-----------------|---------------|
| Regras, turnos, mão, vitória | Núcleo (`nucleo/`, RefCounted) | — | Já pronto e testado; a UI só chama a API |
| Mapeamento índice → mago (cor/símbolo/nome) | Apresentação (`Magos`, estático) | `Sessao` (lista de ativos) | Não é regra; fica fora de `ConfigRegras` |
| Estado entre cenas (magos ativos, `Partida` atual) | Autoload `Sessao` | — | `change_scene_to_file` destrói a cena; o autoload sobrevive |
| Máquina de estados da mesa (selecionada/ocupada/faixa) | Cena `mesa` (script) | — | Só importa para a apresentação |
| Animações (voo da carta, volta, troca, cofre) | Cena (Tween) | — | Núcleo proibido de ter Tween/await |
| Botão voltar / Esc | Autoload `Sessao` | Método `ao_voltar()` de cada cena | Um único ponto recebe a notificação e delega |
| Persistência | Nenhuma | — | Sem dados de crianças; nada é gravado |

## Pilha padrão

### Principais
| Biblioteca | Versão | Propósito | Por que |
|------------|--------|-----------|---------|
| Godot (build padrão) | 4.7.2-stable (local em `C:\Tools\Godot\4.7.2\`) | Motor | Decisão da equipe [VERIFIED: `godot --version` local] |
| GDScript tipado | 4.7 | Lógica de cenas | Convenção do projeto |
| `Control`, containers, `Theme`, `Tween`, `CPUParticles2D` | 4.7 | Interface, animação, confete | `CPUParticles2D` existe e é compatível com Compatibility [VERIFIED: `ClassDB.class_exists` no binário] |
| Andika (Regular + Bold) | arquivos `ofl/andika` do repositório google/fonts, SIL OFL 1.1 | Fonte única | Escolha do UI-SPEC; cobre Á É Ã Ç Õ Ó etc. [VERIFIED: cmap da Andika-Bold conferido por fontTools] |

### De apoio
| Biblioteca | Versão | Propósito | Quando |
|------------|--------|-----------|--------|
| GUT | 9.7.1 (já no repositório) | Testes de lógica de fluxo e de fumaça | Mapeamento de magos, ordem de turno, instanciar cenas |

### Alternativas consideradas
| Em vez de | Poderia usar | Tradeoff |
|-----------|--------------|----------|
| `Theme` global em `gui/theme/custom` | Aplicar `theme` na raiz de cada cena | Mesmo efeito; o global evita esquecer uma cena e vale também para overlays instanciados. Desvio pequeno do texto do UI-SPEC ("aplicado na raiz"); tratar como equivalente |
| Símbolos por `_draw()` | Caracteres Unicode (☀ ☾ ✦) | A Andika provavelmente não tem esses glifos; fonte de reserva muda por aparelho. Desenhar polígonos é determinístico |

**Instalação (Andika, sem gerenciador de pacotes):**
```bash
mkdir -p fontes
curl -L -o fontes/Andika-Regular.ttf https://raw.githubusercontent.com/google/fonts/main/ofl/andika/Andika-Regular.ttf
curl -L -o fontes/Andika-Bold.ttf    https://raw.githubusercontent.com/google/fonts/main/ofl/andika/Andika-Bold.ttf
curl -L -o fontes/OFL.txt            https://raw.githubusercontent.com/google/fonts/main/ofl/andika/OFL.txt
```
Registrar em `CREDITOS.md` no mesmo commit (autor SIL International / Andika Project, URL acima, SIL OFL 1.1, data, não modificado). A existência dos arquivos foi verificada pela API do GitHub nesta sessão [VERIFIED: api.github.com/repos/google/fonts/contents/ofl/andika].

## Auditoria de legitimidade de pacotes

Nenhum pacote npm/pip/cargo é instalado nesta fase. O único recurso externo é a fonte Andika, baixada do repositório oficial google/fonts (arquivos `.ttf` + `OFL.txt`); o slopcheck não se aplica. GUT já está no repositório desde a Fase 1.

| Pacote | Registro | Idade | Downloads | Repositório | slopcheck | Disposição |
|--------|----------|-------|-----------|-------------|-----------|------------|
| (nenhum) | — | — | — | — | n/a | — |

**Removidos por [SLOP]:** nenhum. **Marcados [SUS]:** nenhum.

## Padrões de arquitetura

### Resolução das questões de geometria do UI-SPEC (números concretos)

Dados medidos (Andika Bold, avanço horizontal, sem kerning): sílabas do vocabulário vão de 80 px ("SI") a **118 px ("MO")** a 72 px; a 48 px o máximo é 79 px. 28 das 30 palavras têm 2 sílabas e 2 têm 3 [VERIFIED: leitura de `dados/biblioteca_palavras.tres` e fontTools].

| Questão do checker | Resolução recomendada | Conta |
|--------------------|-----------------------|-------|
| Espaço 92px vs. sílaba 72px (3×96+2×8 = 304 > 296) | **Manter cartão de 296 e espaço 92 x 96. Sílaba dentro do espaço (mesa e final) em Heading 48px Bold**; 72px fica só na carta da mão (144 x 176, útil 136px ≥ 118 ✓). | 3×92 + 2×8 = 292 ≤ 296 ✓. "MO" a 48px = 79px em 92 (folga 6px por lado) ✓. A 72px seria 118 > 92 ✗ (também não caberia em 96) |
| Botão de pausa 72px vs. barra de 64px | **Pausa 64 x 64** (= token 3xl = altura da barra). Continua menor que 96 de propósito (D-16) e com 16px de área morta; a barra fica em 64. | Orçamento vertical inalterado: 32+64+16+320+16+200+32 = **680 ≤ 720** ✓ |
| Margem lateral de 36px fora da escala | **Não existe margem de 36.** Margem externa = xl 32px (MarginContainer). Largura útil 1216; as 4 senhas (4×296 + 3×8 = 1208) ficam centralizadas por `CenterContainer`/`alignment=CENTER`, sobrando 4px de cada lado. | Largura mínima exigida 1208 ≤ 1216 ✓ |

Demais conferências de orçamento mínimo (todas ≤ base 1280x720, portanto 16:9, 20:9 e 4:3 só aumentam fundo): mão 5×144+4×16 = 784, +24 +360 do botão = 1168 ≤ 1216 ✓; altura da senha 160 (ilustração) + 8 + 32 (palavra escrita, opcional) + 8 + 96 (espaços) = 304 ≤ 320 ✓; seleção 4×200 + 3×24 = 872 ✓; final: título 64+16 + senhas 232 + 24 + magos 96 + 24 + botões 96 = 552 ✓.

Observação para o planejador: a alteração "espaço usa Heading 48" deve voltar ao UI-SPEC (regra de Tipografia e Espaçamento) antes da aprovação; ela contradiz a linha "manter 72px nos espaços". A alternativa seria reduzir a margem e apertar a separação das senhas para 292 (cartão 300), mas mesmo assim 118 > 96, então só reduzir o tamanho da fonte resolve.

### Diagrama de fluxo

```
[menu] --Jogar--> [selecao: toggles 4 magos] --Começar--> Sessao.magos_ativos = [ids em ordem fixa]
                                                               |
                                              Sessao.nova_partida(): Partida.new(cfg, bib, dist, n, rng)
                                                               v
 [mesa] <-----------------------------------------------------+
   | faixa_vez (toque) -> mão do mago aparece, existe_jogada() -> destaque do botão
   | toque carta -> seleciona; toque espaço aberto -> partida.jogar_silaba(i, p, e)
   |      ACERTO -> voo + pulso -> concluida()? --sim--> [cofre] --toque(>=1,5s)--> [final]
   |                                  \--não--> faixa_vez
   |      ERRO   -> volta suave à mão -> faixa_vez          (sem sinal visual)
   | toque "Trocar cartas" -> partida.trocar_mao() -> animação -> faixa_vez
   | pausa / Esc / voltar -> painel (Continuar | Sair? -> confirmar -> [menu])
   v
 [final] --Jogar de novo--> Sessao.nova_partida() -> [mesa]   |   --Voltar ao menu--> [menu]
```

### Estrutura de projeto recomendada
```
sessao.gd (ou autoload/sessao.gd)   # autoload "Sessao"
cenas/comum/magos.gd                # class_name Magos (const, static) cor/símbolo/nome/ordem
cenas/comum/simbolo_mago.gd         # Control com _draw() (sol, lua, folha, estrela)
cenas/comum/senha_visual.gd(+.tscn) # cartão de senha reutilizado pela mesa e pelo final
cenas/comum/icones_ponto.gd         # linha de N losangos/círculos na cor do mago
cenas/menu/ cenas/selecao/ cenas/mesa/ cenas/cofre/ cenas/final/
cenas/mesa/faixa_vez.tscn  cenas/mesa/painel_pausa.tscn
tema/tema_cofre.tres  fontes/  arte/provisoria/
testes/unit/test_magos.gd test_sessao.gd test_fluxo_cenas.gd
```
Autoload não pode ter o mesmo nome de um `class_name` (por isso `Sessao` sem `class_name Sessao`; use `extends Node` sem declarar classe global, ou outro nome).

### Padrão 1: autoload `Sessao` (estado entre cenas e botão voltar)
```gdscript
# sessao.gd — Project Settings > Globals > Autoload: Sessao
extends Node

const CENA_MENU := "res://cenas/menu/menu.tscn"
const CENA_SELECAO := "res://cenas/selecao/selecao.tscn"
const CENA_MESA := "res://cenas/mesa/mesa.tscn"
const CENA_COFRE := "res://cenas/cofre/cofre.tscn"
const CENA_FINAL := "res://cenas/final/final.tscn"

var magos_ativos: Array[int] = []   # ids 0..3 (0=vermelho,1=azul,2=verde,3=amarelo), ordenados
var partida: Partida = null

func nova_partida() -> void:
	var cfg := load("res://dados/regras_padrao.tres") as ConfigRegras
	var bib := load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	var dist := load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
	var rng := RandomNumberGenerator.new()
	if cfg.semente > 0:
		rng.seed = cfg.semente
	else:
		rng.randomize()
	partida = Partida.new(cfg, bib, dist, magos_ativos.size(), rng)

func ir_para(caminho: String) -> void:
	get_tree().change_scene_to_file(caminho)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:   # botão voltar do Android
		_voltar()

func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):         # Esc no PC
		_voltar()

func _voltar() -> void:
	var cena := get_tree().current_scene
	if cena != null and cena.has_method("ao_voltar"):
		cena.ao_voltar()
```
Regras: cada cena define `ao_voltar()` (menu: `get_tree().quit()`; seleção: `Sessao.ir_para(CENA_MENU)`; mesa: abrir/fechar painel de pausa; cofre: ignorar até terminar a animação; final: menu). Em `project.godot` seção `[application]` acrescentar `config/quit_on_go_back=false`; **a propriedade existe com esse nome e padrão `true` na 4.7.2** [VERIFIED: `ProjectSettings.has_setting("application/config/quit_on_go_back")` no binário]. A notificação existe na 4.7.2 (valor 1007) e a página oficial de quit requests afirma que o voltar a dispara [CITED: docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html]. Que ela chegue a nós do autoload (propagação para toda a árvore, como o close request) é o comportamento esperado mas **precisa ser confirmado no aparelho** [ASSUMED]; plano B: conectar `get_tree().root.go_back_requested` (o sinal existe em `Window`) [VERIFIED: ClassDB]. Para o Esc: `ui_cancel` já mapeia Esc por padrão [ASSUMED: padrão do InputMap].
Para o Esc/voltar com `Partida` ativa, nunca chamar `quit()` na mesa (só no menu).

### Padrão 2: dados dos magos
```gdscript
# cenas/comum/magos.gd
class_name Magos
extends RefCounted
enum Simbolo { SOL, LUA, FOLHA, ESTRELA }
const COR: Array[Color] = [Color("#E03C3C"), Color("#2F7BFF"), Color("#2EAD5E"), Color("#F2C200")]
const COR_TEXTO: Array[Color] = [Color.WHITE, Color.WHITE, Color.WHITE, Color("#14213D")]
const NOME: Array[String] = ["Vermelho", "Azul", "Verde", "Amarelo"]
# Simbolo do mago id == id (0 sol, 1 lua, 2 folha, 3 estrela)

# indice do nucleo (0..n-1) -> id do mago, pela ordem fixa dos ativos
static func id_do_indice(ativos: Array[int], indice: int) -> int:
	return ativos[indice]
```
`Sessao.magos_ativos` deve ser mantido **ordenado** (a seleção constrói varrendo 0..3). Com isso D-07 é automático: o núcleo roda os índices 0..n-1 em ordem e o primeiro (índice 0) é o primeiro aceso. Testável com GUT sem Node.

### Padrão 3: chamar o núcleo na mesa (armadilha do estado já avançado)
`jogar_silaba` em ACERTO já removeu a carta, repôs a mão e, se `silabas_por_turno` foi atingido, **já chamou `_passar_a_vez()`** (muda `jogador_atual`). Em ERRO também passa a vez (`erro_passa_a_vez`). `trocar_mao` também. Portanto:
```gdscript
func _ao_tocar_espaco(p: int, e: int) -> void:
	if _ocupado or _selecionada < 0 or not _partida.palavras[p].espaco_aberto(e):
		return
	_ocupado = true
	var autor_indice := _partida.jogador_atual          # ANTES da chamada
	var carta_ctrl: Control = _cartas[_selecionada]      # ANTES (a mão será reposta)
	var origem := carta_ctrl.global_position
	var res := _partida.jogar_silaba(_selecionada, p, e)
	match res:
		ResultadoJogada.Tipo.ACERTO:
			await _animar_acerto(carta_ctrl, p, e, autor_indice)   # autor = id via Magos
			if _partida.concluida():
				Sessao.ir_para(Sessao.CENA_COFRE)
			else:
				_mostrar_faixa()    # lê _partida.jogador_atual (já é o próximo)
		ResultadoJogada.Tipo.ERRO:
			await _animar_volta(carta_ctrl)
			_mostrar_faixa()
	_selecionada = -1
```
- No acerto que conclui a partida **não há** `turno_iniciado` (o núcleo emite `cofre_aberto`); testar `concluida()` depois da animação.
- Com 1 mago, "passar a vez" devolve o mesmo índice e `turno_iniciado` ainda é emitido; a faixa aparece igual (conforme UI-SPEC).
- A mão que a interface exibe depois do toque na faixa é `jogadores[jogador_atual].mao`; não reaproveitar nós da mão anterior.
- Não ligar a UI nos sinais do núcleo para encenar: eles disparam no meio da chamada, antes de a UI poder fotografar. Usar o valor de retorno + leitura do estado.
- MESA-07: após exibir a mão (depois do toque na faixa) e após cada troca, avaliar `not _partida.existe_jogada()` e ligar/desligar o Tween em loop do botão.
- Nunca decidir acerto/erro na UI: não comparar a sílaba da carta com a do espaço (isso vazaria a resposta ao destaque; D-02 pede destaque de todos os espaços abertos).

### Padrão 4: animar sem brigar com o container (pitfall central de Tween)
Filhos de `HBoxContainer`/`GridContainer` têm `position` reescrita a cada `queue_sort`. Um `Tween` em `position` "pisca" de volta. Soluções prescritas:
1. **Carta selecionada sobe 16px:** cada carta é um `Control` "casa" de 144 x (176+16) com a carta (`Button`) filha livre; a carta sobe animando `position.y` do filho (a casa mantém o layout). Ou usar `Tween` em `offset`/`pivot` do filho, nunca no filho direto do container.
2. **Voo ao espaço, volta ao erro, troca de mão:** criar uma cópia "fantasma" da carta num `Control` de sobreposição (último filho da mesa, `mouse_filter = IGNORE`, sem container), posicioná-la em `global_position` da carta, esconder o original, animar a fantasma com `create_tween().tween_property(fantasma, "global_position", destino, 0.25)` e liberar. No ERRO, animar de volta e só então mostrar o original.
3. Pulso de escala dos espaços: definir `pivot_offset = size / 2` antes de `scale`; escala também é válida em filhos de container (o container não mexe em `scale`).
4. Botão pulsante do MESA-07: `create_tween().set_loops()` com `tween_property(btn, "scale", Vector2(1.06,1.06), 0.4)` e volta; guardar a referência e dar `kill()` ao desligar; `pivot_offset` central (o container pode redefinir `size`, então setar o pivô em `resized`).
5. Todos os Tweens com `create_tween()` do próprio nó (morrem com ele). Após `await tween.finished` conferir `is_inside_tree()` caso o usuário tenha saído pela pausa.

### Padrão 5: layout responsivo (MESA-08)
Raiz `Control` FULL_RECT; `ColorRect` de fundo `#14213D` FULL_RECT; `MarginContainer` FULL_RECT com margens 32; dentro, `VBoxContainer` com: barra superior (`custom_minimum_size.y = 64`), `CenterContainer` com `size_flags_vertical = EXPAND_FILL` contendo o `HBoxContainer` das senhas (`separation = 8`), e a faixa da mão (`HBoxContainer` 5 casas + botão). Com `expand` a janela nunca é menor que 1280x720 em coordenadas lógicas, então a soma dos mínimos (616 + margens = 680) basta; 20:9 só alarga o `MarginContainer`, 4:3 só o alonga e o `CenterContainer` distribui a folga vertical [CITED: docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html]. Cuidados:
- `TextureRect` do placeholder: `expand_mode = EXPAND_IGNORE_SIZE`, `stretch_mode = KEEP_ASPECT_CENTERED`, `custom_minimum_size = (296,160)`; sem isso o SVG de 256 px infla o mínimo do cartão.
- `Label` do rótulo da palavra: sem `autowrap`, `clip_text = true`, para o mínimo não crescer.
- `Button` com ícone/texto: definir `custom_minimum_size` explícito; texto não deve inflar.
- Testar manualmente (ou via `--resolution`) 1280x720, 1600x720 (20:9), 1280x960 (4:3) e janela menor que a base (ex. 960x540).

### Padrão 6: Theme e fonte
- Importar os `.ttf` (o Godot importa como `FontFile`); em `Andika-*.ttf.import` manter `antialiasing=1`, `generate_mipmaps=false`; MSDF não é necessário com `canvas_items`.
- Um `Theme` `res://tema/tema_cofre.tres`: `default_font = Andika-Regular`, `default_font_size = 24`; tipos de variação (`Rotulo32`, `Titulo48`, `Display72` com Bold e tamanho; `BotaoPrimario` e `BotaoSecundario` com `StyleBoxFlat` de cantos 16px) via `set_type_variation`; usar `theme_type_variation = &"Display72"` nos nós. Isso respeita "nenhum `theme_override` solto".
- Aplicar com `gui/theme/custom="res://tema/tema_cofre.tres"` em `project.godot` (a propriedade existe, padrão vazio) [VERIFIED: ProjectSettings no binário].
- O `.tres` de Theme é verboso e frágil à mão. Prescrição: gerar com um script de editor/headless único (`ferramentas/gerar_tema.gd`, `extends SceneTree`, monta o `Theme` em código e chama `ResourceSaver.save`) e commitar o `.tres`; ou montar no editor. Ambos dão o mesmo arquivo.
- Maiúsculas: `text.to_upper()` ao preencher Label/Button; os dados não mudam. Para letras "como na cartilha" a Andika já traz formas de iniciante.

### Padrão 7: toque
- `input_devices/pointing/emulate_mouse_from_touch` já é `true` por padrão na 4.7.2 e `emulate_touch_from_mouse` é `false` [VERIFIED: ProjectSettings no binário]; logo `Button.pressed` funciona com dedo no Android e com mouse no PC sem configuração extra.
- `Button.pressed` dispara no **soltar** (action mode padrão): bom para crianças (se o dedo sair do botão, cancela). Usar `Button` plano com `StyleBoxFlat` para cartas, espaços, magos e faixa (faixa de vez = `Button` flat de tamanho total).
- `focus_mode = FOCUS_NONE` em todos os botões do jogo (evita anel de foco e ativação por Enter/Espaço do PC durante o jogo).
- Bloqueio durante animação: flag `_ocupado` + overlay de `mouse_filter = STOP` que cobre a mesa; a faixa de vez e o painel de pausa são `Control` cheios com `mouse_filter = STOP`, assim cliques não vazam para a mesa.
- Dois dedos: a emulação cobre só o primeiro toque; ignorar o resto (sem multitoque).
- Sem arrastar nesta fase.

### Padrão 8: símbolos desenhados
`SimboloMago` (`Control`, `custom_minimum_size` 24/48/96) com `var id`, `var cor`, e `_draw()`: sol = `draw_circle` + 8 `draw_line` de raios; lua = polígono crescente (pontos do arco externo e do arco interno deslocado, `draw_colored_polygon`); folha = polígono de losango alongado + nervura; estrela = `draw_colored_polygon` de 10 pontos (raios 1.0/0.4). Chamar `queue_redraw()` ao mudar `id`/`cor`. Mesmo componente usado na seleção (96), faixa (96), indicador (48), canto do espaço (24), final (48). Ícone de ponto = pequeno círculo/losango na cor do mago (`icones_ponto.gd`, N filhos ou `_draw`).

### Padrão 9: cofre
`Control` com `ColorRect` do cofre 320x320, "porta" `ColorRect` filha animada com `tween_property(porta, "scale:x", 0.0, 1.2)` (pivô na borda esquerda) ou `rotation`; interior violeta; `CPUParticles2D` (`emitting = true` após a abertura, `one_shot`, `amount` ~40, `color_ramp` com as cores dos magos ativos, `texture` nula = quadradinhos, `gravity`) — sem shader. O toque de avanço só é aceito após ≥ 1,5 s (flag em `Timer`/`tween.finished`). Em 4:3/20:9 ancorar o cofre ao centro com `CenterContainer`.

### Anti-padrões a evitar
- **Mexer em `position` de filho de container com Tween** — o layout desfaz; usar fantasma/casa.
- **Dar `Partida` à UI por sinais para encenar** — estado já avançado; usar retorno + fotografia.
- **Ler `ConfigRegras` com `load()` direto para `mostrar_palavra_escrita`** — usar `Partida.cfg` (cópia normalizada).
- **Cor de mago em código de regra / sem símbolo** — sempre via `Magos` e sempre com símbolo.
- **Vermelho, "X", tremida ou som no erro; destaque que revele a sílaba certa.**
- **Mostrar pontos de todos os magos durante a partida** — só o da vez.
- **`get_tree().paused` para a pausa** — desnecessário (overlay bloqueia entrada) e pausaria também o Tween que encerra animações; se quiser pausar, usar `process_mode`.

## Não reinventar

| Problema | Não construir | Usar | Por quê |
|----------|---------------|------|---------|
| Troca de cena | Gerenciador próprio de pilha | `get_tree().change_scene_to_file()` + autoload `Sessao` | Suficiente para 5 cenas; o autoload guarda o estado |
| Layout adaptável | Cálculo manual de posições | `MarginContainer`, `Center/H/VBoxContainer`, ancoras | Exigência do CLAUDE.md |
| Animação | Máquina de interpolação por `_process` | `Tween` | Nativo, encadeável, morre com o nó |
| Confete | Sistema de partículas manual | `CPUParticles2D` | Compatível com o renderizador Compatibility |
| Estilo visual | `theme_override` em cada nó | `Theme` + type variations | Consistência e uma só fonte da verdade |
| Sorteio/mistura | `shuffle()` global | RNG injetado do núcleo (`Partida` já faz) | Convenção do projeto |
| Decisão acerto/erro | Comparação na UI | `Partida.jogar_silaba` | Fonte única de regra |

**Insight central:** tudo que é regra já existe e é testado; a UI deve ser "burra" e só encenar o que o núcleo devolve.

## Armadilhas comuns

### Armadilha 1: UI desencontrada do estado do núcleo
**O que dá errado:** animação da carta aponta para a mão errada, ou a mão do próximo mago aparece cedo.
**Por quê:** `jogar_silaba` já repõe a mão e passa a vez antes de retornar.
**Como evitar:** fotografar `jogador_atual`, o nó da carta e o autor antes da chamada; só ler a nova mão depois do toque na faixa (D-01).
**Sinais:** carta "pisca" para outra posição; mão do mago anterior com o rótulo do próximo.

### Armadilha 2: Tween ignorado em filhos de container
Ver Padrão 4. Sintoma: a carta teleporta de volta, o botão pulsante não anima.

### Armadilha 3: mínimo de tamanho inflado
SVG de 256px, labels longos ou fonte grande inflam o mínimo dos containers e cortam a mesa em 4:3/janela pequena. Mitigar com `EXPAND_IGNORE_SIZE`, `clip_text` e conferir os orçamentos acima.

### Armadilha 4: sílaba não cabe no espaço
Ver geometria: 72px × "MO" = 118px. Usar Heading 48 nos espaços e conferir "MA/MO/PO" no aparelho.

### Armadilha 5: botão voltar fecha o app
Sem `quit_on_go_back=false` o Android sai direto. Depois de desligar, **o menu precisa chamar `quit()` explicitamente**, senão o jogador fica sem saída.

### Armadilha 6: cliques que vazam entre camadas
Faixa/pausa sem `mouse_filter = STOP` deixam o toque cair nas cartas atrás. Também: o toque que dispensa a faixa não deve selecionar uma carta (a mão só aparece **depois**; instanciar a mão após o `pressed`).

### Armadilha 7: `test_inicial.gd` quebra
Ao trocar a cena principal, remover `cenas/inicial/` e `testes/unit/test_inicial.gd` no mesmo plano (ou manter a cena fora do fluxo). Atualizar `run/main_scene` para o menu. `export_presets.cfg` já exclui `testes/*`, `simulador/*`, `addons/gut/*`; manter e não excluir `dados/`, `fontes/`, `tema/`.

### Armadilha 8: orientação e Android
`window/handheld/orientation=4` (sensor_landscape) já está no projeto [VERIFIED: project.godot]. O preset Android existente é só `arm64-v8a` e `permissions/internet=false` [VERIFIED: export_presets.cfg]; se o aparelho de teste for de 32 bits, ligar `armeabi-v7a` (nota do CLAUDE.md). A exportação com a fonte nova exige reimportar (`--import`).

### Armadilha 9: acertos sem "autor" no final
`PalavraSenha.preenchido_por[e]` guarda o **índice do núcleo**, não o id do mago; converter com `Sessao.magos_ativos[indice]` em todo lugar (mesa e final), e a `Partida` precisa sobreviver até a tela final (guardada em `Sessao.partida`; limpar ao voltar ao menu e ao "Jogar de novo").

## Exemplos de código

### Selecionar carta e destacar espaços abertos (D-02, D-04)
```gdscript
func _ao_tocar_carta(i: int) -> void:
	if _ocupado:
		return
	_selecionada = -1 if _selecionada == i else i
	_atualizar_elevacao_cartas()
	_atualizar_destaque_espacos()

func _atualizar_destaque_espacos() -> void:
	for s in _senhas:                                  # SenhaVisual
		for e in s.total_espacos():
			s.destacar(e, _selecionada >= 0 and s.espaco_aberto(e))   # contorno violeta 4px
```

### Faixa de vez (D-01) e botão pulsante (MESA-07)
```gdscript
func _mostrar_faixa() -> void:
	_ocupado = true
	_mao_box.visible = false
	var id := Sessao.magos_ativos[_partida.jogador_atual]
	_faixa.configurar(id)                 # cor, simbolo, "Vez do Mago %s" % Magos.NOME[id]
	_faixa.visible = true                 # Button flat de tela cheia

func _ao_faixa_tocada() -> void:
	_faixa.visible = false
	_reconstruir_mao()                    # lê _partida.jogadores[_partida.jogador_atual].mao
	_mao_box.modulate.a = 0.0
	create_tween().tween_property(_mao_box, "modulate:a", 1.0, 0.2)
	_pulsar_botao(not _partida.existe_jogada())
	_atualizar_indicador()                # só pontos do mago da vez
	_ocupado = false

func _pulsar_botao(ligar: bool) -> void:
	if _tween_botao: _tween_botao.kill()
	_botao_trocar.scale = Vector2.ONE
	if ligar:
		_tween_botao = create_tween().set_loops()
		_tween_botao.tween_property(_botao_trocar, "scale", Vector2(1.06, 1.06), 0.4)
		_tween_botao.tween_property(_botao_trocar, "scale", Vector2.ONE, 0.4)
```
(Estilo violeta do botão alterna por `theme_type_variation`.)

### Troca de mão
```gdscript
func _ao_tocar_trocar() -> void:
	if _ocupado: return
	_ocupado = true
	await _animar_saida_mao()
	_partida.trocar_mao()                 # já passa a vez
	_mostrar_faixa()
```
(Ordem: pode animar a saída antes de chamar, para o estado ainda ser o do mago que trocou.)

### Teste GUT de fluxo/mapeamento (sem Node)
```gdscript
extends GutTest
func test_ordem_fixa_pula_inativos() -> void:
	var ativos: Array[int] = [0, 2]       # vermelho, verde
	assert_eq(ativos[0], 0)               # indice 0 = primeiro aceso
	assert_eq(ativos[1], 2)
```

### Teste GUT de fumaça de cena (mesmo padrão de test_inicial.gd)
```gdscript
extends GutTest
func test_mesa_instancia_com_um_mago() -> void:
	Sessao.magos_ativos = [0]
	Sessao.nova_partida()
	var mesa: Control = load("res://cenas/mesa/mesa.tscn").instantiate()
	add_child_autofree(mesa)
	await wait_frames(2)
	assert_true(mesa.is_inside_tree())
```
Valor dos testes de cena: instanciar sem erro e conferir contagem de nós (5 cartas, 4 senhas) e um acerto "forçado" via API do núcleo. Não testar pixels nem Tween. A lógica relevante (regras) já está coberta pela Fase 1; para a Fase 2 vale mais um **mapa/ciclo de fluxo `RefCounted`** (ex. função que, dado `ResultadoJogada` e `concluida()`, devolve a próxima etapa `FAIXA|COFRE`) coberta por GUT, e o resto por checagem manual guiada.

## Estado da arte

| Antigo | Atual | Impacto |
|--------|-------|---------|
| Tweens via nó `Tween` | `create_tween()` do nó (4.x) | Sem nó extra; morre com o nó |
| `change_scene()` (3.x) | `change_scene_to_file()` | Nome atual da API |
| Theme só por override | Type variations + `gui/theme/custom` | Um único ponto de estilo |

**Obsoleto:** `TextureRect` sem `expand_mode` para ilustrações de tamanho variável; confete por shader (pesado/risco no Compatibility).

## Log de suposições

| # | Afirmação | Seção | Risco se errada |
|---|-----------|-------|-----------------|
| A1 | `NOTIFICATION_WM_GO_BACK_REQUEST` é entregue a um nó autoload (propagação a toda a árvore) | Padrão 1 | Voltar não abre a pausa; plano B: sinal `go_back_requested` da `Window` raiz; testar em APK |
| A2 | `ui_cancel` mapeia Esc por padrão | Padrão 1 | Esc não abre pausa; adicionar ação própria no InputMap |
| A3 | `CPUParticles2D` com `color_ramp` multicor roda bem no aparelho de teste | Padrão 9 | Trocar por retângulos animados por Tween |
| A4 | Largura 118px da sílaba "MO" medida sem kerning/arredondamentos do renderizador | Geometria | Margem de 6px a 48px; conferir no aparelho |
| A5 | Pausa de 64px ainda é tocável por crianças (propositalmente pequena) | Geometria | Validar nos testes de usabilidade; subir para 72 com barra de 72 se preciso |

## Questões em aberto

1. **Voltar durante o cofre**
   - O que sabemos: D-16 cobre mesa, seleção, menu; final → menu (UI-SPEC).
   - O que falta: comportamento no cofre.
   - Recomendação: ignorar até a animação terminar, depois equivale ao toque (vai ao final).
2. **UI-SPEC vs. resolução de geometria**
   - Sílaba nos espaços em Heading 48 contradiz a nota "manter 72px"; pedir ao planejador/usuário que atualize o contrato e reabra o checker (itens Tipografia e Espaçamento).
3. **Aparelho Android de teste** (FUND-02 ainda pendente): arquitetura (arm64 basta?), OpenGL ES 3.0. Define se liga `armeabi-v7a`.

## Disponibilidade do ambiente

| Dependência | Necessária para | Disponível | Versão | Alternativa |
|-------------|-----------------|------------|--------|-------------|
| Godot 4.7.2 (console) | Rodar testes e importar | Sim | 4.7.2.stable.official.ed1daf0bf em `C:\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe` (não está no PATH; `testes/rodar.ps1` usa `$env:GODOT_BIN`) | — |
| GUT | Testes | Sim | 9.7.1 (`addons/gut`) | — |
| Python + fontTools | Só medição da pesquisa | Sim | — | Não é dependência do projeto |
| Acesso ao GitHub | Baixar Andika | Sim | — | Google Fonts |
| JDK 17 / Android SDK / aparelho | APK e partida real (critério 5) | Não verificado nesta pesquisa | — | Depende do FUND-02 da Fase 1 |

**Bloqueio sem alternativa:** a validação em Android real depende do aparelho físico (pendência já registrada).

## Segurança

Aplicável de forma mínima (jogo offline, sem entrada de texto, sem rede, sem dados de crianças).

| Categoria ASVS | Aplica | Controle |
|----------------|--------|----------|
| V2/V3/V4 Autenticação, Sessão, Acesso | Não | — |
| V5 Validação de entrada | Sim (mínima) | Índices vindos de toque validados pelo núcleo (`INVALIDO`); sem texto livre |
| V6 Criptografia | Não | — |
| Privacidade/ética | Sim | `permissions/internet=false` já no preset; nenhuma gravação em disco; nenhum rótulo identifica quem errou |

| Padrão de ameaça | STRIDE | Mitigação |
|------------------|--------|-----------|
| Exposição pública de erro | Divulgação de informação | Erro/acerto/troca terminam na mesma faixa (D-03) |
| Arquivos de fonte de procedência duvidosa | Adulteração | Baixar do repositório oficial google/fonts e registrar em `CREDITOS.md` |

## Fontes

### Primárias (HIGH)
- Binário Godot 4.7.2 local (`ProjectSettings.has_setting`, `ClassDB`): `application/config/quit_on_go_back` (padrão true), `input_devices/pointing/emulate_mouse_from_touch` (true), `emulate_touch_from_mouse` (false), `gui/theme/custom`, `CPUParticles2D`, `NOTIFICATION_WM_GO_BACK_REQUEST = 1007`, sinal `Window.go_back_requested`.
- https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html — voltar do Android dispara `NOTIFICATION_WM_GO_BACK_REQUEST`; "Quit On Go Back" padrão ligado.
- https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html — `canvas_items` + `expand`, containers e âncoras.
- Código da Fase 1: `nucleo/partida.gd`, `nucleo/palavra_senha.gd`, `nucleo/jogador.gd`, `dados/tipos/*.gd`, `dados/biblioteca_palavras.tres` (28 palavras de 2 sílabas, 2 de 3), `project.godot`, `export_presets.cfg`, `testes/`.
- https://github.com/google/fonts/tree/main/ofl/andika — Andika Regular/Bold/OFL.txt (listagem via API do GitHub).

### Secundárias (MEDIUM)
- Medição da Andika Bold com fontTools nesta sessão (avanço sem kerning).

### Terciárias (LOW)
- Comportamento exato da propagação de `NOTIFICATION_WM_GO_BACK_REQUEST` no aparelho (A1).

## Metadados

**Confiança:**
- Pilha padrão: HIGH — tudo nativo, verificado no binário.
- Arquitetura: HIGH — baseada no código real da Fase 1; padrões de Tween em container são comportamento documentado do Godot.
- Armadilhas: MEDIUM — Android back e desempenho de partículas dependem de teste em aparelho.

**Data da pesquisa:** 2026-11-17
**Válido até:** 2026-12-17 (pilha estável; Godot 4.7.2 fixa)

## Restrições do projeto (do CLAUDE.md)

- Godot 4.7.2 padrão sem .NET, GDScript tipado; renderizador Compatibility; 1280x720 + `canvas_items` + `expand`; containers e âncoras, sem posicionamento absoluto de UI.
- Sem addons de cartas; sem arrastar como única forma; sem SDK de rede/anúncios; APK sem permissão de internet.
- Identificadores em português sem acento; arquivos em minúsculas com underscore; pastas `nucleo/`, `dados/`, `cenas/`, `arte/provisoria/`, `testes/unit/` (`test_*.gd`).
- Núcleo sem Node/await/Timer/`shuffle()` global (RNG injetado); valores de regra só em `ConfigRegras`.
- Alvos de toque ≥ ~96px na base 1280x720 (exceção documentada: pausa 64px).
- Recursos de licença livre registrados em `CREDITOS.md` no momento em que entram (Andika + `OFL.txt` em `fontes/`).
- Sem exposição pública de erros; sem coleta de dados de crianças.
- Testes por `testes/rodar.ps1`.
