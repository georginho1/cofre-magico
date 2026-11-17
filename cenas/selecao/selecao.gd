extends Control

const CINZA := Color("#5C6C91")
const FUNDO_APAGADO := Color("#22335C")

@onready var _linha: HBoxContainer = $Centro/Caixa/LinhaMagos
@onready var _dica: Label = $Centro/Caixa/Dica
@onready var _comecar: Button = $Centro/Caixa/BotaoComecar


func _ready() -> void:
	for id in range(4):
		var b: Button = _linha.get_child(id) as Button
		b.button_pressed = false
		b.toggled.connect(_ao_alternar.bind(id))
		_atualizar_mago(id)
	_atualizar_estado()
	_comecar.pressed.connect(_ao_comecar)


func _simbolo(id: int) -> SimboloMago:
	return _linha.get_child(id).get_node("Centro/Simbolo") as SimboloMago


func _atualizar_mago(id: int) -> void:
	var b: Button = _linha.get_child(id) as Button
	var s: SimboloMago = _simbolo(id)
	var cor_fundo: Color = Magos.COR[id] if b.button_pressed else FUNDO_APAGADO
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = cor_fundo
	estilo.set_corner_radius_all(16)
	for nome in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus"]:
		b.add_theme_stylebox_override(nome, estilo)
	if b.button_pressed:
		s.configurar(id, Magos.COR_TEXTO[id], false, false)
	else:
		s.configurar(id, CINZA, false, true)


func _ao_alternar(_ligado: bool, id: int) -> void:
	_atualizar_mago(id)
	_atualizar_estado()


func _acesos() -> Array[int]:
	var ids: Array[int] = []
	for id in range(4):
		if (_linha.get_child(id) as Button).button_pressed:
			ids.append(id)
	return ids


func _atualizar_estado() -> void:
	var n: int = _acesos().size()
	_comecar.disabled = n == 0
	_dica.visible = n == 0


func _ao_comecar() -> void:
	Sessao.ativar_magos(_acesos())
	if not Sessao.nova_partida():
		Sessao.ir_para(Sessao.CENA_MENU)
		return
	Sessao.ir_para(Sessao.CENA_MESA)


func ao_voltar() -> void:
	Sessao.ir_para(Sessao.CENA_MENU)
