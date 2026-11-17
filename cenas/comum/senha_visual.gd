class_name SenhaVisual
extends VBoxContainer
## Cartao de uma palavra-senha: ilustracao placeholder, palavra opcional e um espaco por silaba.

signal espaco_tocado(espaco: int)

const VIOLETA := Color("#B388FF")
const FUNDO_ABERTO := Color("#DCEBFA")

var _palavra: PalavraSenha
var _botoes: Array[Button] = []
var _simbolos: Array[SimboloMago] = []
var _destaque: Array[bool] = []

@onready var _ilustracao: Control = $Ilustracao
@onready var _imagem: TextureRect = $Ilustracao/Imagem
@onready var _rotulo_placeholder: Label = $Ilustracao/RotuloPlaceholder
@onready var _rotulo_escrito: Label = $RotuloEscrito
@onready var _linha: HBoxContainer = $LinhaEspacos


func configurar(palavra: PalavraSenha, mostrar_escrita: bool, compacto: bool = false) -> void:
	_palavra = palavra
	_rotulo_placeholder.text = palavra.dados.texto.to_upper()
	_rotulo_escrito.text = palavra.dados.texto.to_upper()
	_rotulo_escrito.visible = mostrar_escrita and not compacto
	if compacto:
		_ilustracao.custom_minimum_size.y = 96
		_imagem.custom_minimum_size.y = 96
	for b in _botoes:
		b.queue_free()
	_botoes.clear()
	_simbolos.clear()
	_destaque.clear()
	for e in range(palavra.total_espacos()):
		var b := Button.new()
		b.custom_minimum_size = Vector2(92, 96)
		b.theme_type_variation = &"BotaoEspaco"
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(_ao_tocar.bind(e))
		_linha.add_child(b)
		_botoes.append(b)
		_simbolos.append(null)
		_destaque.append(false)
	atualizar([] as Array[int])


func _ao_tocar(e: int) -> void:
	espaco_tocado.emit(e)


func total_espacos() -> int:
	return _botoes.size()


func espaco_aberto(e: int) -> bool:
	return _palavra.espaco_aberto(e)


## Le preenchido_por e redesenha cada espaco. `ativos` mapeia indice do nucleo para id do mago.
func atualizar(ativos: Array[int]) -> void:
	for e in range(_botoes.size()):
		var quem: int = _palavra.preenchido_por[e]
		if quem == -1 or quem >= ativos.size():
			_desenhar_aberto(e)
		else:
			_desenhar_preenchido(e, ativos[quem])


func _desenhar_aberto(e: int) -> void:
	var b: Button = _botoes[e]
	b.text = ""
	if _simbolos[e] != null:
		_simbolos[e].queue_free()
		_simbolos[e] = null
	_aplicar_destaque(e)


func _desenhar_preenchido(e: int, id_mago: int) -> void:
	var b: Button = _botoes[e]
	b.text = _palavra.silaba(e).to_upper()
	var cor_texto: Color = Magos.COR_TEXTO[id_mago]
	for nome in ["font_color", "font_pressed_color", "font_hover_color", "font_disabled_color"]:
		b.add_theme_color_override(nome, cor_texto)
	for nome in ["normal", "hover", "pressed", "disabled"]:
		b.add_theme_stylebox_override(nome, _estilo(Magos.COR[id_mago], Color.TRANSPARENT, 0))
	if _simbolos[e] == null:
		var s := SimboloMago.new()
		s.custom_minimum_size = Vector2(24, 24)
		s.position = Vector2(4, 4)
		s.size = Vector2(24, 24)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(s)
		_simbolos[e] = s
	_simbolos[e].configurar(id_mago, cor_texto, false, false)


## Excecao documentada ao Theme: a cor do mago autor so e conhecida em tempo de execucao.
func _estilo(fundo: Color, borda: Color, largura: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fundo
	sb.border_color = borda
	sb.set_border_width_all(largura)
	sb.set_corner_radius_all(12)
	return sb


func destacar(e: int, ligado: bool) -> void:
	_destaque[e] = ligado and _palavra.espaco_aberto(e)
	_aplicar_destaque(e)


func _aplicar_destaque(e: int) -> void:
	var b: Button = _botoes[e]
	if not _palavra.espaco_aberto(e):
		return
	for nome in ["normal", "hover", "pressed", "disabled"]:
		if _destaque[e]:
			b.add_theme_stylebox_override(nome, _estilo(FUNDO_ABERTO, VIOLETA, 4))
		else:
			b.remove_theme_stylebox_override(nome)


func marcar_aceito(e: int, id_mago: int) -> void:
	_desenhar_preenchido(e, id_mago)
	var b: Button = _botoes[e]
	b.pivot_offset = b.size / 2.0
	var tw: Tween = b.create_tween()
	tw.tween_property(b, "scale", Vector2(1.1, 1.1), 0.1)
	tw.tween_property(b, "scale", Vector2.ONE, 0.1)


func marcar_completa() -> void:
	pivot_offset = size / 2.0
	var tw: Tween = create_tween()
	tw.tween_property(self, "scale", Vector2(1.04, 1.04), 0.15)
	tw.tween_property(self, "scale", Vector2.ONE, 0.15)
	var moldura := ReferenceRect.new()
	moldura.border_color = Color.WHITE
	moldura.border_width = 4.0
	moldura.editor_only = false
	moldura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	moldura.top_level = false
	add_child(moldura)
	moldura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func centro_espaco(e: int) -> Vector2:
	var b: Button = _botoes[e]
	return b.global_position + b.size / 2.0


func bloquear_toques(ligado: bool) -> void:
	for b in _botoes:
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE if ligado else Control.MOUSE_FILTER_STOP
