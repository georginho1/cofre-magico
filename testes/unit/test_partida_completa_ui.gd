extends GutTest
## Fluxo completo pela interface com 1 a 4 magos. Nao navega de cena: a ultima
## jogada e feita pelo nucleo, pois a mesa chamaria Sessao.ir_para ao concluir.

const CAM_LINHA := "Margem/Coluna/CentroSenhas/LinhaSenhas"
const CAM_MAO := "Margem/Coluna/FaixaMao/Mao"

var _escrita_original: bool


func before_each() -> void:
	Engine.time_scale = 4.0


func after_each() -> void:
	Engine.time_scale = 1.0
	var cfg: ConfigRegras = load("res://dados/regras_padrao.tres") as ConfigRegras
	cfg.mostrar_palavra_escrita = false


func _mesa(ids: Array[int]) -> Control:
	Sessao.ativar_magos(ids)
	Sessao.nova_partida()
	var mesa: Control = load("res://cenas/mesa/mesa.tscn").instantiate() as Control
	add_child_autofree(mesa)
	await wait_frames(2)
	return mesa


## Primeiro espaco aberto como [palavra, espaco], ou [] se nao houver.
func _primeiro_aberto(p: Partida) -> Array[int]:
	for pi in range(p.palavras.size()):
		for e in range(p.palavras[pi].total_espacos()):
			if p.palavras[pi].espaco_aberto(e):
				return [pi, e]
	return []


func _abertos(p: Partida) -> int:
	var n: int = 0
	for pal in p.palavras:
		for e in range(pal.total_espacos()):
			if pal.espaco_aberto(e):
				n += 1
	return n


func _jogar_ate_ultima(mesa: Control) -> void:
	var p: Partida = Sessao.partida
	var guarda: int = 0
	while _abertos(p) > 1 and guarda < 400:
		guarda += 1
		var faixa: Button = mesa.get_node("FaixaVez") as Button
		if faixa.visible:
			faixa.pressed.emit()
			await wait_frames(2)
		var alvo: Array[int] = _primeiro_aberto(p)
		p.jogadores[p.jogador_atual].mao[0] = p.palavras[alvo[0]].silaba(alvo[1])
		var carta: Button = mesa.get_node(CAM_MAO).get_child(0).get_child(0) as Button
		carta.pressed.emit()
		var senha: SenhaVisual = mesa.get_node(CAM_LINHA).get_child(alvo[0]) as SenhaVisual
		senha.espaco_tocado.emit(alvo[1])
		await wait_seconds(0.8)
	assert_lt(guarda, 400)


func _fluxo(n: int) -> void:
	var ids: Array[int] = []
	for i in range(n):
		ids.append(i)
	var mesa: Control = await _mesa(ids)
	await _jogar_ate_ultima(mesa)
	var p: Partida = Sessao.partida
	var alvo: Array[int] = _primeiro_aberto(p)
	p.jogadores[p.jogador_atual].mao[0] = p.palavras[alvo[0]].silaba(alvo[1])
	p.jogar_silaba(0, alvo[0], alvo[1])
	assert_true(p.concluida())
	var c: Control = load("res://cenas/cofre/cofre.tscn").instantiate() as Control
	add_child_autofree(c)
	var f: Control = load("res://cenas/final/final.tscn").instantiate() as Control
	add_child_autofree(f)
	await wait_frames(2)
	assert_eq(f.get_node("Margem/Coluna/Magos").get_child_count(), n)


func test_fluxo_1_mago() -> void:
	await _fluxo(1)


func test_fluxo_2_magos() -> void:
	await _fluxo(2)


func test_fluxo_3_magos() -> void:
	await _fluxo(3)


func test_fluxo_4_magos() -> void:
	await _fluxo(4)


func test_ordem_pula_inativos() -> void:
	var ids: Array[int] = [1, 3]
	var mesa: Control = await _mesa(ids)
	assert_eq(Sessao.id_do_indice(Sessao.partida.jogador_atual), 1)
	assert_eq(mesa.get_node("Margem/Coluna/Barra/Indicador/Caixa/RotuloVez").text, "Vez do Mago %s" % Magos.NOME[1])


func test_palavra_escrita_visivel_quando_ligada() -> void:
	var cfg: ConfigRegras = load("res://dados/regras_padrao.tres") as ConfigRegras
	cfg.mostrar_palavra_escrita = true
	var ids: Array[int] = [0]
	var mesa: Control = await _mesa(ids)
	var senha: Node = mesa.get_node(CAM_LINHA).get_child(0)
	assert_true((senha.get_node("RotuloEscrito") as Label).visible)


func test_palavra_escrita_oculta_quando_desligada() -> void:
	var cfg: ConfigRegras = load("res://dados/regras_padrao.tres") as ConfigRegras
	cfg.mostrar_palavra_escrita = false
	var ids: Array[int] = [0]
	var mesa: Control = await _mesa(ids)
	var senha: Node = mesa.get_node(CAM_LINHA).get_child(0)
	assert_false((senha.get_node("RotuloEscrito") as Label).visible)
