extends SceneTree
## Gera res://tema/tema_cofre.tres. Uso: godot --headless --path . -s ferramentas/gerar_tema.gd

const FUNDO := Color("#22335C")
const ESCURO := Color("#14213D")
const ROXO := Color("#B388FF")
const CLARO := Color("#DCEBFA")
const CINZA := Color("#8FA0C4")


func _caixa(fundo: Color, borda: Color = Color(0, 0, 0, 0), largura: int = 0, raio: int = 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fundo
	s.set_corner_radius_all(raio)
	s.set_border_width_all(largura)
	s.border_color = borda
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


func _botao(t: Theme, nome: StringName, fundo: Color, borda: Color, largura: int, texto: Color, fonte: Font, tamanho: int) -> void:
	t.add_type(nome)
	t.set_type_variation(nome, &"Button")
	t.set_font(&"font", nome, fonte)
	t.set_font_size(&"font_size", nome, tamanho)
	for c in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_focus_color", &"font_hover_pressed_color"]:
		t.set_color(c, nome, texto)
	t.set_color(&"font_disabled_color", nome, CINZA)
	t.set_stylebox(&"normal", nome, _caixa(fundo, borda, largura))
	t.set_stylebox(&"hover", nome, _caixa(fundo, borda, largura))
	t.set_stylebox(&"pressed", nome, _caixa(fundo.darkened(0.1), borda, largura))
	t.set_stylebox(&"hover_pressed", nome, _caixa(fundo.darkened(0.1), borda, largura))
	t.set_stylebox(&"disabled", nome, _caixa(FUNDO, borda, largura))
	t.set_stylebox(&"focus", nome, StyleBoxEmpty.new())


func _rotulo(t: Theme, nome: StringName, fonte: Font, tamanho: int) -> void:
	t.add_type(nome)
	t.set_type_variation(nome, &"Label")
	t.set_font(&"font", nome, fonte)
	t.set_font_size(&"font_size", nome, tamanho)


func _init() -> void:
	var normal: Font = load("res://fontes/Andika-Regular.ttf") as Font
	var negrito: Font = load("res://fontes/Andika-Bold.ttf") as Font
	if normal == null or negrito == null:
		push_error("fontes Andika ausentes")
		quit(1)
		return
	var t := Theme.new()
	t.default_font = normal
	t.default_font_size = 24
	t.set_color(&"font_color", &"Label", Color.WHITE)
	_rotulo(t, &"Rotulo32", negrito, 32)
	_rotulo(t, &"Titulo48", negrito, 48)
	_rotulo(t, &"Display72", negrito, 72)
	_botao(t, &"BotaoPrimario", ROXO, Color(0, 0, 0, 0), 0, ESCURO, negrito, 32)
	_botao(t, &"BotaoSecundario", FUNDO, Color.WHITE, 2, Color.WHITE, negrito, 32)
	_botao(t, &"BotaoCarta", CLARO, ESCURO, 4, ESCURO, negrito, 72)
	_botao(t, &"BotaoEspaco", CLARO, Color("#5C6C91"), 2, ESCURO, negrito, 48)
	_botao(t, &"BotaoMago", FUNDO, Color(0, 0, 0, 0), 0, Color.WHITE, negrito, 32)
	t.add_type(&"PainelSuperficie")
	t.set_type_variation(&"PainelSuperficie", &"PanelContainer")
	var p := _caixa(FUNDO)
	p.set_content_margin_all(16)
	t.set_stylebox(&"panel", &"PainelSuperficie", p)
	var erro: int = ResourceSaver.save(t, "res://tema/tema_cofre.tres")
	if erro != OK:
		push_error("falha ao salvar tema: %d" % erro)
	quit(0 if erro == OK else 1)
