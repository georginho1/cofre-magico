extends Control
## Tela final: contribuicoes de cada mago, sem pontuacao numerica nem comparacao.

const CENA_SENHA: PackedScene = preload("res://cenas/comum/senha_visual.tscn")

@onready var _senhas: HBoxContainer = $Margem/Coluna/Senhas
@onready var _magos: HBoxContainer = $Margem/Coluna/Magos
@onready var _botao_novo: Button = $Margem/Coluna/Botoes/BotaoNovo
@onready var _botao_menu: Button = $Margem/Coluna/Botoes/BotaoMenu


func _ready() -> void:
	_botao_novo.pressed.connect(_jogar_de_novo)
	_botao_menu.pressed.connect(_ir_ao_menu)
	if Sessao.partida == null:
		$Margem.visible = false
		var aviso := Label.new()
		aviso.text = "Algo deu errado. Toque para voltar ao menu."
		aviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		add_child(aviso)
		var toque := Button.new()
		toque.flat = true
		toque.focus_mode = Control.FOCUS_NONE
		toque.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		toque.pressed.connect(_ir_ao_menu)
		add_child(toque)
		return
	var mostrar: bool = Sessao.partida.cfg.mostrar_palavra_escrita
	for palavra in Sessao.partida.palavras:
		var sv: SenhaVisual = CENA_SENHA.instantiate() as SenhaVisual
		_senhas.add_child(sv)
		sv.configurar(palavra, mostrar, true)
		sv.atualizar(Sessao.magos_ativos)
		sv.bloquear_toques(true)
	for i in range(Sessao.magos_ativos.size()):
		var id: int = Sessao.magos_ativos[i]
		var bloco := VBoxContainer.new()
		bloco.add_theme_constant_override("separation", 8)
		var simbolo := SimboloMago.new()
		simbolo.custom_minimum_size = Vector2(48, 48)
		simbolo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		bloco.add_child(simbolo)
		simbolo.configurar(id, Magos.COR_TEXTO[id], true, false)
		var pontos := IconesPonto.new()
		pontos.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		bloco.add_child(pontos)
		pontos.configurar(Sessao.partida.jogadores[i].pontos, Magos.COR[id], 24)
		_magos.add_child(bloco)


func _jogar_de_novo() -> void:
	if not Sessao.nova_partida():
		_ir_ao_menu()
		return
	Sessao.ir_para(Sessao.CENA_MESA)


func _ir_ao_menu() -> void:
	Sessao.limpar()
	Sessao.ir_para(Sessao.CENA_MENU)


func ao_voltar() -> void:
	_ir_ao_menu()
