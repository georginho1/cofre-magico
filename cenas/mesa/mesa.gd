extends Control
## Mesa de jogo: faixa de vez, mao do mago da vez, dois toques (carta e espaco).
## Toda regra vive em Partida; a mesa so traduz toques em chamadas e anima o resultado.

const CENA_SENHA: PackedScene = preload("res://cenas/comum/senha_visual.tscn")
const VIOLETA := Color("#B388FF")
const LARGURA_CARTA: float = 144.0
const ALTURA_CARTA: float = 176.0
const ALTURA_CASA: float = 192.0
const Y_BAIXA: float = 16.0

var _partida: Partida
var _selecionada: int = -1
var _ocupado: bool = false
var _cartas: Array[Button] = []
var _senhas: Array[SenhaVisual] = []

@onready var _linha_senhas: HBoxContainer = $Margem/Coluna/CentroSenhas/LinhaSenhas
@onready var _mao: HBoxContainer = $Margem/Coluna/FaixaMao/Mao
@onready var _botao_trocar: Button = $Margem/Coluna/FaixaMao/BotaoTrocar
@onready var _circulo: SimboloMago = $Margem/Coluna/Barra/Indicador/Caixa/Circulo
@onready var _rotulo_vez: Label = $Margem/Coluna/Barra/Indicador/Caixa/RotuloVez
@onready var _fantasmas: Control = $CamadaFantasma
@onready var _bloqueio: Control = $Bloqueio
@onready var _faixa: FaixaVez = $FaixaVez
@onready var _mensagem_erro: Label = $MensagemErro


func _ready() -> void:
	_partida = Sessao.partida
	if _partida == null:
		push_error("mesa aberta sem partida na Sessao")
		_mensagem_erro.visible = true
		_bloqueio.visible = true
		_bloqueio.gui_input.connect(_ao_toque_erro)
		return
	for i in range(_partida.palavras.size()):
		var senha: SenhaVisual = CENA_SENHA.instantiate() as SenhaVisual
		_linha_senhas.add_child(senha)
		senha.configurar(_partida.palavras[i], _partida.cfg.mostrar_palavra_escrita)
		var indice: int = i
		senha.espaco_tocado.connect(func(e: int) -> void: _ao_tocar_espaco(indice, e))
		_senhas.append(senha)
	_botao_trocar.pressed.connect(_ao_tocar_trocar)
	_faixa.pressed.connect(_ao_faixa_tocada)
	_mostrar_faixa()


func _ao_toque_erro(ev: InputEvent) -> void:
	var toque: bool = ev is InputEventScreenTouch and (ev as InputEventScreenTouch).pressed
	var clique: bool = ev is InputEventMouseButton and (ev as InputEventMouseButton).pressed
	if toque or clique:
		Sessao.ir_para(Sessao.CENA_MENU)


func _definir_ocupado(valor: bool) -> void:
	_ocupado = valor
	_bloqueio.visible = valor


func _mostrar_faixa() -> void:
	_definir_ocupado(true)
	_mao.visible = false
	var id: int = Sessao.id_do_indice(_partida.jogador_atual)
	_faixa.configurar(id)
	_faixa.visible = true
	_circulo.configurar(id, Magos.COR_TEXTO[id], true, false)
	_rotulo_vez.text = "Vez do Mago %s" % Magos.NOME[id]


func _ao_faixa_tocada() -> void:
	_faixa.visible = false
	_reconstruir_mao()
	_mao.modulate.a = 0.0
	_mao.visible = true
	var tw: Tween = create_tween()
	tw.tween_property(_mao, "modulate:a", 1.0, 0.2)
	_selecionada = -1
	_definir_ocupado(false)


func _reconstruir_mao() -> void:
	for c in _mao.get_children():
		_mao.remove_child(c)
		c.queue_free()
	_cartas.clear()
	var mao: Array[String] = _partida.jogadores[_partida.jogador_atual].mao
	for i in range(mao.size()):
		var casa := Control.new()
		casa.custom_minimum_size = Vector2(LARGURA_CARTA, ALTURA_CASA)
		var carta := Button.new()
		carta.theme_type_variation = &"BotaoCarta"
		carta.focus_mode = Control.FOCUS_NONE
		carta.text = mao[i].to_upper()
		carta.size = Vector2(LARGURA_CARTA, ALTURA_CARTA)
		carta.position = Vector2(0, Y_BAIXA)
		carta.pressed.connect(_ao_tocar_carta.bind(i))
		casa.add_child(carta)
		_mao.add_child(casa)
		_cartas.append(carta)


## Selecao em dois toques (D-04): tocar a selecionada desmarca; tocar outra troca.
func _ao_tocar_carta(i: int) -> void:
	if _ocupado:
		return
	_selecionada = -1 if _selecionada == i else i
	for k in range(_cartas.size()):
		_elevar(_cartas[k], k == _selecionada)
	_atualizar_destaque()


func _elevar(carta: Button, alta: bool) -> void:
	var tw: Tween = carta.create_tween()
	tw.tween_property(carta, "position:y", 0.0 if alta else Y_BAIXA, 0.1)
	if alta:
		var base: StyleBox = carta.get_theme_stylebox("normal")
		if base is StyleBoxFlat:
			var sb: StyleBoxFlat = (base as StyleBoxFlat).duplicate() as StyleBoxFlat
			sb.border_color = VIOLETA
			sb.set_border_width_all(4)
			for nome in ["normal", "hover", "pressed"]:
				carta.add_theme_stylebox_override(nome, sb)
	else:
		for nome in ["normal", "hover", "pressed"]:
			carta.remove_theme_stylebox_override(nome)


## Com carta selecionada, todos os espacos abertos ficam destacados, sem pista do correto (D-02).
func _atualizar_destaque() -> void:
	for senha in _senhas:
		for e in range(senha.total_espacos()):
			senha.destacar(e, _selecionada >= 0 and senha.espaco_aberto(e))


func _limpar_destaques() -> void:
	for senha in _senhas:
		for e in range(senha.total_espacos()):
			senha.destacar(e, false)


func _ao_tocar_espaco(p: int, e: int) -> void:
	if _ocupado or _selecionada < 0 or not _senhas[p].espaco_aberto(e):
		return
	_definir_ocupado(true)
	var autor_indice: int = _partida.jogador_atual
	var carta_ctrl: Button = _cartas[_selecionada]
	var origem: Vector2 = carta_ctrl.global_position
	var res: ResultadoJogada.Tipo = _partida.jogar_silaba(_selecionada, p, e)
	_limpar_destaques()
	match res:
		ResultadoJogada.Tipo.ACERTO:
			await _animar_acerto(carta_ctrl, p, e, Sessao.id_do_indice(autor_indice))
		ResultadoJogada.Tipo.ERRO:
			await _animar_volta(carta_ctrl, origem)
		_:
			_definir_ocupado(false)
			return
	if not is_inside_tree():
		return
	_selecionada = -1
	match FluxoMesa.proxima_etapa(res, _partida.concluida()):
		FluxoMesa.Etapa.COFRE:
			Sessao.ir_para(Sessao.CENA_COFRE)
		FluxoMesa.Etapa.FAIXA_VEZ:
			_mostrar_faixa()
		_:
			_definir_ocupado(false)


func _criar_fantasma(carta: Button) -> Button:
	var f := Button.new()
	f.theme_type_variation = &"BotaoCarta"
	f.focus_mode = Control.FOCUS_NONE
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f.text = carta.text
	f.size = carta.size
	_fantasmas.add_child(f)
	f.global_position = carta.global_position
	return f


func _animar_acerto(carta: Button, p: int, e: int, id_mago: int) -> void:
	var f: Button = _criar_fantasma(carta)
	carta.modulate.a = 0.0
	var destino: Vector2 = _senhas[p].centro_espaco(e) - f.size / 2.0
	var tw: Tween = create_tween()
	tw.tween_property(f, "global_position", destino, 0.25).set_trans(Tween.TRANS_SINE)
	await tw.finished
	if not is_inside_tree():
		return
	f.queue_free()
	_senhas[p].marcar_aceito(e, id_mago)
	await get_tree().create_timer(0.2).timeout
	if not is_inside_tree():
		return
	if _partida.palavras[p].completa():
		_senhas[p].marcar_completa()


## Erro igual a qualquer outra passagem de vez: a carta volta e nada mais acontece (D-03).
func _animar_volta(carta: Button, origem: Vector2) -> void:
	var f: Button = _criar_fantasma(carta)
	carta.modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(f, "global_position", origem, 0.3).set_trans(Tween.TRANS_SINE)
	await tw.finished
	if not is_inside_tree():
		return
	f.queue_free()
	carta.modulate.a = 1.0


func _ao_tocar_trocar() -> void:
	if _ocupado:
		return
	_definir_ocupado(true)
	_limpar_destaques()
	var tw: Tween = create_tween().set_parallel(true)
	for c in _cartas:
		var f: Button = _criar_fantasma(c)
		c.modulate.a = 0.0
		tw.tween_property(f, "global_position:y", f.global_position.y + 260.0, 0.3)
		tw.tween_property(f, "modulate:a", 0.0, 0.3)
	await tw.finished
	if not is_inside_tree():
		return
	for f in _fantasmas.get_children():
		f.queue_free()
	_selecionada = -1
	_partida.trocar_mao()
	_mostrar_faixa()
